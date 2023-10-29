//
//  LKPreviewViewController.m
//  Lookin
//
//  Created by Li Kai on 2018/8/6.
//  https://lookin.work
//

#import "LKPreviewController.h"
#import "LKStaticHierarchyDataSource.h"
#import "LKReadHierarchyDataSource.h"
#import "LKPreviewStageView.h"
#import "LKPreviewPanGestureRecognizer.h"
#import "LookinDisplayItem.h"
#import "LKHierarchyView.h"
#import "LKPreferenceManager.h"
#import "LookinAppInfo.h"
#import "LookinHierarchyInfo.h"
#import "LKNavigationManager.h"
#import "LKTutorialManager.h"
#import "LKStaticViewController.h"
#import "LookinPreviewView.h"
#import "LKUserActionManager.h"
#import "LKHierarchyDataSource+KeyDown.h"

extern NSString *const LKAppShowConsoleNotificationName;

@interface LKPreviewController () <NSGestureRecognizerDelegate, LKPreviewStageViewDelegate, NSMenuDelegate>

@property(nonatomic, strong) NSClickGestureRecognizer *clickRecognizer;

@property(nonatomic, strong) LKPreviewPanGestureRecognizer *panRecognizer;

@property(nonatomic, strong) LKHierarchyDataSource *dataSource;

@property(nonatomic, strong) LKPreviewStageView *stageView;
@property(nonatomic, strong) LookinPreviewView *previewView;

/// 按住 space 时可以通过 pan 来移动图像
@property(nonatomic, assign) BOOL isKeyingDownSpace;
/// 按住 command 时可以穿透选择，以及通过 scroll 鼠标来放大缩小图像
@property(nonatomic, assign) BOOL isKeyingDownCommand;
/// 按住 option 时可以测距
@property(nonatomic, assign) BOOL isKeyingDownOption;

@property(nonatomic, strong) id keyUpEventMonitor;
@property(nonatomic, strong) id keyMaskFlagsChangedEventMonitor;

@property(nonatomic, strong) NSMenu *rightClickMenu;
@property(nonatomic, strong) LookinDisplayItem *rightClickingDisplayItem;

@property(nonatomic, strong) NSClickGestureRecognizer *doubleClickRecognizer;
@property(nonatomic, strong) NSClickGestureRecognizer *rightClickRecognizer;

@end

@implementation LKPreviewController

- (instancetype)initWithDataSource:(LKHierarchyDataSource *)dataSource {
    if (self = [self initWithContainerView:nil]) {
        self.dataSource = dataSource;
        
        LookinAppInfo *appInfo = dataSource.rawHierarchyInfo.appInfo;
        
        self.previewView = [[LookinPreviewView alloc] initWithDataSource:dataSource];
        self.previewView.preferenceManager = self.dataSource.preferenceManager;
        self.previewView.alphaValue = 0;
        self.previewView.appScreenSize = CGSizeMake(appInfo.screenWidth, appInfo.screenHeight);
        self.previewView.showHiddenItems = dataSource.preferenceManager.showHiddenItems.currentBOOLValue;
        [dataSource.preferenceManager.showHiddenItems subscribe:self action:@selector(_handleShowHiddenItemsChange:) relatedObject:nil];
        @weakify(self);
        self.stageView.didChangeAppearanceBlock = ^(LKBaseView *view, BOOL isDarkMode) {
            @strongify(self);
            self.previewView.isDarkMode = isDarkMode;
        };
        [self.view addSubview:self.previewView];
        

        // 这里通过 [RACSignal return:nil] 来立即执行一次渲染
        [[RACSignal merge:@[[RACSignal return:nil],
                            self.dataSource.didReloadHierarchyInfo,
                            self.dataSource.itemDidChangeNoPreview]] subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            NSArray<LookinDisplayItem *> *validItems = [dataSource.flatItems lookin_filter:^BOOL(LookinDisplayItem *obj) {
                return !obj.inNoPreviewHierarchy;
            }];
            [self.previewView renderWithDisplayItems:validItems discardCache:YES];
        }];
        
        [self.dataSource.didReloadFlatItemsWithSearchOrFocus subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            NSArray<LookinDisplayItem *> *validItems = [dataSource.flatItems lookin_filter:^BOOL(LookinDisplayItem *obj) {
                return !obj.inNoPreviewHierarchy;
            }];
            [self.previewView renderWithDisplayItems:validItems discardCache:NO];
        }];
        
        NSMutableArray<RACSignal *> *signalsToUpdateZIndex = @[RACObserve(dataSource, displayingFlatItems)].mutableCopy;
        if ([dataSource isKindOfClass:[LKStaticHierarchyDataSource class]]) {
            [signalsToUpdateZIndex addObject:((LKStaticHierarchyDataSource *)dataSource).itemDidChangeHiddenAlphaValue];
            [signalsToUpdateZIndex addObject:((LKStaticHierarchyDataSource *)dataSource).itemsDidChangeFrame];
        }
        [[[RACSignal merge:signalsToUpdateZIndex] skip:1]
         subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self.previewView updateZPosition];
        }];
        
        self.panRecognizer = [[LKPreviewPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanGesture:)];
        self.panRecognizer.delegate = self;
        [self.previewView addGestureRecognizer:self.panRecognizer];

        self.clickRecognizer = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(_handleClickGesture:)];
        self.clickRecognizer.numberOfClicksRequired = 1;
        self.clickRecognizer.delegate = self;
        [self.previewView addGestureRecognizer:self.clickRecognizer];

        self.doubleClickRecognizer = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(_handleDoubleClick:)];
        self.doubleClickRecognizer.numberOfClicksRequired = 2;
        [self.previewView addGestureRecognizer:self.doubleClickRecognizer];

        self.rightClickRecognizer = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(_handleRightClick:)];
        self.rightClickRecognizer.buttonMask = 0x2;
        self.rightClickRecognizer.numberOfClicksRequired = 1;
        [self.previewView addGestureRecognizer:self.rightClickRecognizer];
        
        self.rightClickMenu = [self _makeRightClickMenu];
        
        self.keyUpEventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyUp handler:^NSEvent * _Nullable(NSEvent * _Nonnull event) {
            @strongify(self);
            // 在 macbook 上，按下 space 然后通过触摸板拖拽然后松开 space，此时 keyUp: 方法不会被调到，不知道为啥，这里做个兜底
            if (event.type == NSEventTypeKeyUp && [event.charactersIgnoringModifiers isEqualToString:@" "]) {
                self.isKeyingDownSpace = NO;
                [self.view.window invalidateCursorRectsForView:self.view];
            }
            return event;
        }];
        self.keyMaskFlagsChangedEventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskFlagsChanged handler:^NSEvent * _Nullable(NSEvent * _Nonnull event) {
            @strongify(self);
            if ([event modifierFlags] & NSEventModifierFlagCommand) {
                self.isKeyingDownCommand = YES;
            } else {
                self.isKeyingDownCommand = NO;
            }
            
            if ([event modifierFlags] & NSEventModifierFlagOption) {
                self.isKeyingDownOption = YES;
            } else {
                self.isKeyingDownOption = NO;
            }
            
            return event;
        }];
        
        [self.dataSource.preferenceManager.previewScale subscribe:self action:@selector(_handleManagerPreviewScaleDidChange:) relatedObject:nil sendAtOnce:YES];
        [self.dataSource.preferenceManager.previewDimension subscribe:self action:@selector(_handleManagerPreviewDimensionDidChange:) relatedObject:nil sendAtOnce:YES];
        [self.dataSource.preferenceManager.freeRotation subscribe:self action:@selector(_handleManagerFreeRotationDidChange:) relatedObject:nil sendAtOnce:YES];
        [self.dataSource.preferenceManager.zInterspace subscribe:self action:@selector(_handleManagerZInterspaceDidChange:) relatedObject:nil sendAtOnce:YES];
        
        // 用于在 reload app 时重置 translation 和 scale
        [[RACObserve(dataSource, rawHierarchyInfo) skip:1] subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self _hierarchyInfoDidChange];
        }];
        
        [RACObserve(dataSource, selectedItem) subscribeNext:^(LookinDisplayItem *item) {
            @strongify(self);
            [self.previewView didSelectItem:item];
        }];
    
        [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidResignKeyNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            @strongify(self);
            if (note.object == self.view.window) {
                self.isKeyingDownSpace = NO;
                self.isKeyingDownOption = NO;
                self.isKeyingDownCommand = NO;
            }
        }];
    }
    return self;
}

- (NSView *)makeContainerView {
    self.stageView = [[LKPreviewStageView alloc] init];
    self.stageView.didChangeAppearanceBlock = ^(LKBaseView *view, BOOL isDarkMode) {
        view.backgroundColor = isDarkMode ? LookinColorMake(0, 0, 0) : LookinColorMake(255, 255, 255);
    };
    self.stageView.delegate = self;
    return self.stageView;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    
    /// 向左多延伸一个 dashboard 的视觉宽度（由于一般向右旋转，所以少延伸个 20 似乎更好看一点），向下多延伸一个 titleBar 高度，从而让 preview 在视觉上居中
    CGFloat titleBarHeight = [LKNavigationManager sharedInstance].windowTitleBarHeight;
    $(self.previewView).width(self.view.$width + DashboardViewWidth - DashboardHorInset - 20).right(0).height(self.view.$height + titleBarHeight).y(0);
//    $(self.previewView).fullFrame;
    
    BOOL hasLayouted = [self lookin_getBindBOOLForKey:@"hasLayouted"];
    if (!hasLayouted) {
        [self lookin_bindBOOL:YES forKey:@"hasLayouted"];
        
        // 做一个开场动画
        [self.previewView setRotation:CGPointMake(.8, 0) animated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
                context.duration = 1;
                self.previewView.animator.alphaValue = 1;
            } completionHandler:nil];
            
            [self.previewView setRotation:CGPointMake(.6, 0) animated:YES timingFunction:[CAMediaTimingFunction functionWithControlPoints:.3 :.93 :.26 :.88] duration:1.5];
        });
    }
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self.view.window makeFirstResponder:self];
}

- (void)dealloc {
    [NSEvent removeMonitor:self.keyUpEventMonitor];
    [NSEvent removeMonitor:self.keyMaskFlagsChangedEventMonitor];
}

#pragma mark - <NSGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(NSGestureRecognizer *)gestureRecognizer shouldAttemptToRecognizeWithEvent:(NSEvent *)event {
#ifdef DEBUG
    if (gestureRecognizer == self.clickRecognizer) {
        if (event.locationInWindow.y <= 25) {
            // 点击底部的 debug 按钮
            return NO;
        }
    }
#endif
    if (gestureRecognizer == self.panRecognizer) {
        if (self.previewView.dimension != LookinPreviewDimension3D && !self.isKeyingDownSpace) {
            // 没有 isKeyingDownSpace 说明此时手势目的是旋转，而此时视图又不是 3D，因此直接拒绝该手势
            return NO;
        }
    }
    return YES;
}

#pragma mark - <LKPreviewStageViewDelegate>

- (void)previewStageView:(LKPreviewStageView *)view mouseMoved:(NSEvent *)event {
    if (self.isKeyingDownSpace) {
        if (self.dataSource.hoveredItem) {
            self.dataSource.hoveredItem = nil;
        }
        return;
    }
    NSPoint rawPoint = [event locationInWindow];
    rawPoint.y = self.view.window.frame.size.height - rawPoint.y;
    NSView *targetView = [self.view.window.contentView hitTest:rawPoint];
    if (targetView != self.previewView) {
        return;
    }
    
    NSPoint point = [self.previewView convertPoint:rawPoint fromView:self.view.window.contentView];
    LookinDisplayItem *item = [self.previewView displayItemAtPoint:point];
    if (self.dataSource.hoveredItem != item) {
        self.dataSource.hoveredItem = item;
    }
}

#pragma mark - Event

- (void)_handleShowHiddenItemsChange:(LookinMsgActionParams *)param {
    self.previewView.showHiddenItems = param.boolValue;
    [self.previewView updateZPosition];
}

- (void)_handleManagerFreeRotationDidChange:(LookinMsgActionParams *)params {
    BOOL canFreeRotate = params.boolValue;
    if (canFreeRotate) {
        if (self.previewView.dimension == LookinPreviewDimension3D) {
            CGPoint rotation = self.previewView.rotation;
            rotation.y = -0.05;
            [self.previewView setRotation:rotation animated:YES];
        }
        
    } else {
        CGPoint rotation = self.previewView.rotation;
        if (rotation.y == 0) {
            return;
        }
        rotation.y = 0;
        [self.previewView setRotation:rotation animated:YES];
    }
    
}

- (void)_handleManagerPreviewScaleDidChange:(LookinMsgActionParams *)params {
    double scale = params.doubleValue;
    self.previewView.scale = scale;
}

- (void)_handleManagerPreviewDimensionDidChange:(LookinMsgActionParams *)params {
    LookinPreviewDimension newDimension = params.integerValue;
    
    if (self.previewView.dimension == newDimension) {
        return;
    }
    
    if (newDimension == LookinPreviewDimension2D) {
        [self lookin_bindPoint:self.previewView.rotation forKey:@"prevRotation"];
        [self.previewView setDimension:newDimension animated:YES];
    } else {
        CGPoint rotation = [self lookin_getBindPointForKey:@"prevRotation"];
        [self.previewView setDimension:newDimension animated:YES];
        
        // 避免之前的 rotation 太小而感知不到 2D / 3D 的切换
        if (rotation.x >= 0) {
            rotation.x = MAX(0.18, rotation.x);
        } else if (rotation.x < 0) {
            rotation.x = MIN(-0.18, rotation.x);
        }
        
        if (!self.dataSource.preferenceManager.freeRotation.currentBOOLValue) {
            rotation.y = 0;
        }
        
        [self.previewView setRotation:rotation animated:YES];
    }
}

- (void)_handleManagerZInterspaceDidChange:(LookinMsgActionParams *)params {
    double doubleValue = params.doubleValue;
    self.previewView.zInterspace = doubleValue;
}

- (void)_handlePanGesture:(LKPreviewPanGestureRecognizer *)recognizer {
    if (recognizer.state == NSGestureRecognizerStateBegan) {
        [[LKUserActionManager sharedInstance] sendAction:LKUserActionType_PreviewOperation];
        
        // 停止可能正在编辑的 card 输入框
        [self.view.window makeFirstResponder:self];
        
        if (self.isKeyingDownSpace) {
            recognizer.purpose = PreviewPanGesturePurposeTranslate;
            
            if (self.staticViewController) {
                if (self.staticViewController.isShowingMoveWithSpaceTutorialTips) {
                    [self.staticViewController removeTutorialTips];
                }
            }
        } else {
            recognizer.purpose = PreviewPanGesturePurposeRotate;
        }
        recognizer.initialRotation = self.previewView.rotation;
        recognizer.initialTranslation = self.previewView.translation;
        
    } else if (recognizer.state == NSGestureRecognizerStateChanged) {
        NSPoint translation = [recognizer translationInView:self.view];
        if (recognizer.purpose == PreviewPanGesturePurposeRotate) {
            if (self.previewView.dimension != LookinPreviewDimension3D) {
                return;
            }
            CGFloat newRotationX = recognizer.initialRotation.x + translation.x * 0.01;
            CGFloat newRotationY;
            if (self.dataSource.preferenceManager.freeRotation.currentBOOLValue) {
                newRotationY = recognizer.initialRotation.y + translation.y * 0.004;
            } else {
                newRotationY = 0;
            }
            [self.previewView setRotation:CGPointMake(newRotationX, newRotationY) animated:NO];
            
        } else if (recognizer.purpose == PreviewPanGesturePurposeTranslate) {
            TutorialMng.moveWithSpace = YES;
            if (self.staticViewController.isShowingMoveWithSpaceTutorialTips) {
                [self.staticViewController removeTutorialTips];
            }
            
            NSPoint initialTranslation = recognizer.initialTranslation;
            // 我们希望随着 scale 的变大，translation 的比率逐渐变小，避免图像被放大到很大的时候轻轻一滑就滑走了
            // currentScale 范围是 0 ~ 1，factor 被相应映射为 1 ~ 0.1
            CGFloat currentScale = self.previewView.scale;
            CGFloat factor = (1 - currentScale) * 0.92 + 0.08;
            NSPoint newTranslation = NSMakePoint(initialTranslation.x + translation.x * 0.01 * factor, initialTranslation.y - translation.y * 0.01 * factor);
            self.previewView.translation = newTranslation;
        }
    }
}

- (void)_handleClickGesture:(NSClickGestureRecognizer *)recognizer {    
    if (self.dataSource.shouldAvoidChangingPreviewSelectionDueToDashboardSearch) {
        return;
    }
    
    [[LKUserActionManager sharedInstance] sendAction:LKUserActionType_PreviewOperation];
    
    // 停止可能正在编辑的 card 输入框
    [self.view.window makeFirstResponder:self];
    
    NSPoint point = [recognizer locationInView:self.previewView];
    LookinDisplayItem *item = [self.previewView displayItemAtPoint:point];

    if (self.dataSource.selectedItem == item) {
        return;
    }
    // 注意这里要先 expand 然后再 select 以使得可以滚动到目标位置
    if (!item.displayingInHierarchy) {
        TutorialMng.quickSelection = YES;
        if (self.staticViewController && self.staticViewController.isShowingQuickSelectTutorialTips) {
            [self.staticViewController removeTutorialTips];
        }
        
        [self.dataSource expandToShowItem:item];
    }
    
    self.dataSource.selectedItem = item;
    
    if (!TutorialMng.hasAlreadyShowedTipsThisLaunch && !TutorialMng.togglePreview) {
        CGFloat parsedRotation = ((self.previewView.rotation.x * 180.0) / M_PI);
        if ((parsedRotation > 75 && parsedRotation < 100) || (parsedRotation < -75 && parsedRotation > -100)) {
            TutorialMng.togglePreview = YES;
            TutorialMng.hasAlreadyShowedTipsThisLaunch = YES;
            [self.staticViewController showNoPreviewTutorialTips];
        }
    }
}

- (void)_handleRightClick:(NSClickGestureRecognizer *)recognizer {
    [[LKUserActionManager sharedInstance] sendAction:LKUserActionType_PreviewOperation];
    // 停止可能正在编辑的 card 输入框
    [self.view.window makeFirstResponder:self];
    
    NSPoint point = [recognizer locationInView:self.previewView];
    LookinDisplayItem *item = [self.previewView displayItemAtPoint:point];

    if (!item.displayingInHierarchy) {
        return;
    }
    
    if (self.dataSource.selectedItem != item) {
        self.dataSource.selectedItem = item;
    }
    
    self.rightClickingDisplayItem = item;
    [self.rightClickMenu popUpMenuPositioningItem:nil atLocation:[NSEvent mouseLocation] inView:nil];
}

- (void)_handleDoubleClick:(NSClickGestureRecognizer *)recognizer {
    [[LKUserActionManager sharedInstance] sendAction:LKUserActionType_PreviewOperation];
    // 停止可能正在编辑的 card 输入框
    [self.view.window makeFirstResponder:self];
    
    NSPoint point = [recognizer locationInView:self.previewView];
    LookinDisplayItem *item = [self.previewView displayItemAtPoint:point];
    
    TutorialMng.doubleClick = YES;
    if (self.staticViewController.isShowingDoubleClickTutorialTips) {
        [self.staticViewController removeTutorialTips];
    }
    
    if (!item.displayingInHierarchy) {
        return;
    }
    if (item.isExpandable) {
        if (item.isExpanded) {
            [self.dataSource collapseItem:item];
        } else {
            [self.dataSource expandItem:item];
        }
    }
}

- (void)magnifyWithEvent:(NSEvent *)event {
    [super magnifyWithEvent:event];
    if (event.phase == NSEventPhaseChanged) {
        LKPreferenceManager *manager = self.dataSource.preferenceManager;
        double targetScale = manager.previewScale.currentDoubleValue + event.magnification * 0.3;
        targetScale = MAX(MIN(targetScale, 1), 0);
        [manager.previewScale setDoubleValue:targetScale ignoreSubscriber:nil];
    }
}

- (void)scrollWheel:(NSEvent *)event {
    [super scrollWheel:event];
    if (self.isKeyingDownCommand) {
        LKPreferenceManager *manager = self.dataSource.preferenceManager;
        CGFloat currentScale = manager.previewScale.currentDoubleValue;
        CGFloat targetScale = currentScale - event.deltaY * .005;
        targetScale = MAX(MIN(targetScale, LookinPreviewMaxScale), LookinPreviewMinScale);
        [manager.previewScale setDoubleValue:targetScale ignoreSubscriber:nil];
        
    } else {
        // 我们希望随着 scale 的变大，translation 的比率逐渐变小，避免图像被放大到很大的时候轻轻一滑就滑走了
        // currentScale 范围是 0 ~ 1，factor 被相应映射为 1 ~ 0.3
        CGFloat currentScale = self.previewView.scale;
        CGFloat factor = (1 - currentScale) * 0.7 + 0.3;
        
        CGPoint translation = self.previewView.translation;
        translation.x += event.deltaX * 0.04 * factor;
        translation.y -= event.deltaY * 0.04 * factor;
        self.previewView.translation = translation;
        
        if (self.staticViewController && !TutorialMng.hasAlreadyShowedTipsThisLaunch && !TutorialMng.moveWithSpace) {
            TutorialMng.moveWithSpace = YES;
            [self.staticViewController showMoveWithSpaceTutorialTips];
        }
    }
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)keyDown:(NSEvent *)event {
    if ([event.charactersIgnoringModifiers isEqualToString:@" "]) {
        self.isKeyingDownSpace = YES;
        return;
    }

    if ([self.dataSource keyDown:event]) {
        return;
    }

    [super keyDown:event];
}

- (void)keyUp:(NSEvent *)event {
    if ([event.charactersIgnoringModifiers isEqualToString:@" "]) {
        self.isKeyingDownSpace = NO;
        return;
    }
    [super keyUp:event];
}

- (void)setIsKeyingDownCommand:(BOOL)isKeyingDownCommand {
    _isKeyingDownCommand = isKeyingDownCommand;
    
    if (isKeyingDownCommand && self.view.window.isKeyWindow) {
        [self.dataSource.preferenceManager.isQuickSelecting setBOOLValue:YES ignoreSubscriber:nil];
    } else {
        [self.dataSource.preferenceManager.isQuickSelecting setBOOLValue:NO ignoreSubscriber:nil];
    }
}

- (void)setIsKeyingDownSpace:(BOOL)isKeyingDownSpace {
    _isKeyingDownSpace = isKeyingDownSpace;
    
    [self.view.window invalidateCursorRectsForView:self.view];
    if (self.isKeyingDownSpace) {
        self.doubleClickRecognizer.enabled = NO;
        self.rightClickRecognizer.enabled = NO;
    } else {
        self.doubleClickRecognizer.enabled = YES;
        self.rightClickRecognizer.enabled = YES;
    }
}

- (void)setIsKeyingDownOption:(BOOL)isKeyingDownOption {
    _isKeyingDownOption = isKeyingDownOption;
    
    BOOL shouldStartMeasure;
    if (isKeyingDownOption && self.dataSource.selectedItem && [self.view.window isKeyWindow]) {
        shouldStartMeasure = YES;
    } else {
        shouldStartMeasure = NO;
    }
    [self.dataSource.preferenceManager.isMeasuring setValue:@(shouldStartMeasure) ignoreSubscriber:nil userInfo:@(YES)];
}

- (void)didResetCursorRectsInPreviewStageView:(LKPreviewStageView *)view {
    if (self.isKeyingDownSpace) {
        [view addCursorRect:self.view.bounds cursor:[NSCursor openHandCursor]];
    }
}

- (void)_hierarchyInfoDidChange {
    LookinHierarchyInfo *currentInfo = self.dataSource.rawHierarchyInfo;
    if (!currentInfo) {
        NSAssert(NO, @"");
        return;
    }
    
    self.previewView.appScreenSize = CGSizeMake(currentInfo.appInfo.screenWidth, currentInfo.appInfo.screenHeight);
    
    LookinHierarchyInfo *prevInfo = [self lookin_getBindObjectForKey:@"prevRawHierarchyInfo"];
    [self lookin_bindObject:currentInfo forKey:@"prevRawHierarchyInfo"];
    if (!prevInfo) {
        return;
    }
    CGFloat prevWidth = prevInfo.appInfo.screenWidth;
    CGFloat prevHeight = prevInfo.appInfo.screenHeight;
    CGFloat currentWidth = currentInfo.appInfo.screenWidth;
    CGFloat currentHeight = currentInfo.appInfo.screenHeight;
    
    if (prevWidth == currentWidth && prevHeight == currentHeight) {
        // 内容尺寸没有变化
        return;
    }
    /// iOS App 尺寸变化，重置 Scale
    [self.dataSource.preferenceManager.previewScale setDoubleValue:LKInitialPreviewScale ignoreSubscriber:nil];
}

#pragma mark - <NSMenuDelegate>

- (NSMenu *)_makeRightClickMenu {
    NSMenu *menu = [NSMenu new];
    menu.autoenablesItems = NO;
    menu.delegate = self;

    [menu addItem:({
        NSMenuItem *item = [NSMenuItem new];
        item.target = self;
        item.action = @selector(_handleFocusCurrentItem:);
        item.title = NSLocalizedString(@"Focus", nil);
        item;
    })];
    [menu addItem:({
        NSMenuItem *item = [NSMenuItem new];
        item.target = self;
        item.action = @selector(_handlePrintItem:);
        item.title = NSLocalizedString(@"Print", nil);
        item;
    })];
    [menu addItem:[NSMenuItem separatorItem]];

    [menu addItem:({
        NSMenuItem *item = [NSMenuItem new];
        item.target = self;
        item.action = @selector(_handleExpandRecursively:);
        item.title = NSLocalizedString(@"Expand recursively", nil);
        item;
    })];
    [menu addItem:({
        NSMenuItem *item = [NSMenuItem new];
        item.target = self;
        item.action = @selector(_handleCollapseChildren:);
        item.title = NSLocalizedString(@"Collapse children", nil);
        item;
    })];
    
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:({
        NSMenuItem *item = [NSMenuItem new];
        item.enabled = YES;
        item.target = self;
        item.action = @selector(_handleCancelPreview:);
        item.title = NSLocalizedString(@"Hide screenshot this time", nil);
        item;
    })];
    [menu addItem:({
        NSMenuItem *item = [NSMenuItem new];
        item.enabled = YES;
        item.target = self;
        item.action = @selector(_handleExportScreenshot:);
        item.title = NSLocalizedString(@"Export screenshot…", nil);
        item;
    })];
    
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:({
        NSMenuItem *item = [NSMenuItem new];
        item.target = self;
        item.action = @selector(_handleHideScreenshotForever);
        item.title = NSLocalizedString(@"Hide screenshot forever…", nil);
        item;
    })];
    return menu;
}

- (void)menuNeedsUpdate:(NSMenu *)menu {
    LookinDisplayItem *displayItem = self.rightClickingDisplayItem;
    if (!displayItem) {
        return;
    }
    NSMenuItem *item_expand = [menu itemAtIndex:0];
    NSMenuItem *item_collapse = [menu itemAtIndex:1];
//    NSMenuItem *item_cancelPreview = [menu itemAtIndex:3];
    NSMenuItem *item_export = [menu itemAtIndex:4];
    
    // 设置“全部展开”和“全部收起”的 enabled
    if (displayItem.isExpandable) {
        item_expand.enabled = YES;
        item_collapse.enabled = YES;
    } else {
        item_expand.enabled = NO;
        item_collapse.enabled = NO;
    }
    
    item_export.enabled = !!displayItem.groupScreenshot;
}

- (void)menuDidClose:(NSMenu *)menu {
    // 按住 cmd 键激活右键菜单，然后松开 cmd，然后关闭菜单，这时 eventMonitor 不会捕捉到 cmd 被松开，所以要在这里弥补一下
    if ([NSEvent modifierFlags] & NSEventModifierFlagCommand) {
        self.isKeyingDownCommand = YES;
    } else {
        self.isKeyingDownCommand = NO;
    }
}

- (void)_handlePrintItem:(NSMenuItem *)menuItem {
    LookinDisplayItem *item = self.rightClickingDisplayItem;
    [[NSNotificationCenter defaultCenter] postNotificationName:LKAppShowConsoleNotificationName object:item];
}

- (void)_handleFocusCurrentItem:(NSMenuItem *)menuItem {
    LookinDisplayItem *item = self.rightClickingDisplayItem;
    [self.dataSource focusDisplayItem:item];
}

- (void)_handleExpandRecursively:(NSMenuItem *)menuItem {
    LookinDisplayItem *item = self.rightClickingDisplayItem;
    NSAssert(item, @"");
    [self.dataSource expandItemsRootedByItem:item];
}

- (void)_handleCollapseChildren:(NSMenuItem *)menuItem {
    LookinDisplayItem *item = self.rightClickingDisplayItem;
    NSAssert(item, @"");
    [self.dataSource collapseAllChildrenOfItem:item];
}

- (void)_handleCancelPreview:(NSMenuItem *)menuItem {
    [LKTutorialManager sharedInstance].togglePreview = YES;
    
    LookinDisplayItem *item = self.rightClickingDisplayItem;
    item.noPreview = YES;
    [self.dataSource.itemDidChangeNoPreview sendNext:nil];
}

- (void)_handleExportScreenshot:(NSMenuItem *)menuItem {
    LookinDisplayItem *item = self.rightClickingDisplayItem;
    [LKExportManager exportScreenshotWithDisplayItem:item];
}

- (void)_handleHideScreenshotForever {
    [LKHelper openCustomConfigWebsite];
}

@end
