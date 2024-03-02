//
//  LKMainViewController.m
//  Lookin
//
//  Created by Li Kai on 2018/8/4.
//  https://lookin.work
//

#import "LKStaticViewController.h"
#import "LKSplitView.h"
#import "LKStaticHierarchyDataSource.h"
#import "LKStaticHierarchyController.h"
#import "LKPreviewController.h"
#import "LKDashboardViewController.h"
#import "LKLaunchViewController.h"
#import "LKProgressIndicatorView.h"
#import "LKWindowController.h"
#import "LKStaticWindowController.h"
#import "LKTipsView.h"
#import "LKAppsManager.h"
#import "LKStaticAsyncUpdateManager.h"
#import "LKNavigationManager.h"
#import "LKConsoleViewController.h"
#import "LookinDisplayItem.h"
#import "LKTutorialManager.h"
#import "LKPreferenceManager.h"
#import "LKMeasureController.h"
@import AppCenter;
@import AppCenterAnalytics;

NSString *const LKAppShowConsoleNotificationName = @"LKAppShowConsoleNotificationName";

@interface LKStaticViewController () <NSSplitViewDelegate>

@property(nonatomic, strong) LKSplitView *mainSplitView;
@property(nonatomic, strong) LKSplitView *rightSplitView;
@property(nonatomic, strong) LKBaseView *splitTopView;

@property(nonatomic, strong) LKTipsView *imageSyncTipsView;
@property(nonatomic, strong) LKRedTipsView *tooLargeToSyncScreenshotTipsView;
@property(nonatomic, strong) LKTipsView *userConfigNoPreviewTipsView;
@property(nonatomic, strong) LKTipsView *noPreviewTipView;
@property(nonatomic, strong) LKTipsView *tutorialTipView;
@property(nonatomic, strong) LKTipsView *customViewTipView;
@property(nonatomic, strong) LKYellowTipsView *focusTipView;
@property(nonatomic, strong) LKTipsView *fastModeTipView;

@property(nonatomic, strong) LKDashboardViewController *dashboardController;
@property(nonatomic, strong) LKStaticHierarchyController *hierarchyController;
@property(nonatomic, strong) LKConsoleViewController *consoleController;
@property(nonatomic, strong) LKMeasureController *measureController;

@end

@implementation LKStaticViewController

- (NSView *)makeContainerView {
    self.mainSplitView = [LKSplitView new];
    self.mainSplitView.didFinishFirstLayout = ^(LKSplitView *view) {
        CGFloat x = MIN(MAX(350, view.bounds.size.width * .3), 700);
        [view setPosition:x ofDividerAtIndex:0];
    };
    self.mainSplitView.arrangesAllSubviews = NO;
    self.mainSplitView.vertical = YES;
    self.mainSplitView.dividerStyle = NSSplitViewDividerStyleThin;
    self.mainSplitView.delegate = self;
    return self.mainSplitView;
}

- (void)setView:(NSView *)view {
    [super setView:view];
    
    LKPreferenceManager *preferenceManager = [LKPreferenceManager mainManager];
    [preferenceManager.measureState subscribe:self action:@selector(_handleMeasureStateChange:) relatedObject:nil];
    
    LKStaticHierarchyDataSource *dataSource = [LKStaticHierarchyDataSource sharedInstance];
    
    self.hierarchyController = [[LKStaticHierarchyController alloc] initWithDataSource:dataSource];
    [self addChildViewController:self.hierarchyController];
    [self.mainSplitView addArrangedSubview:self.hierarchyController.view];
    
    self.rightSplitView = [LKSplitView new];
    self.rightSplitView.arrangesAllSubviews = YES;
    self.rightSplitView.vertical = NO;
    self.rightSplitView.dividerStyle = NSSplitViewDividerStyleThin;
    self.rightSplitView.delegate = self;
    [self.mainSplitView addArrangedSubview:self.rightSplitView];
    
    self.splitTopView = [LKBaseView new];
    [self.rightSplitView addArrangedSubview:self.splitTopView];
    
    _viewsPreviewController = [[LKPreviewController alloc] initWithDataSource:dataSource];
    self.viewsPreviewController.staticViewController = self;
    [self.splitTopView addSubview:self.viewsPreviewController.view];
    [self addChildViewController:self.viewsPreviewController];
    
    self.dashboardController = [[LKDashboardViewController alloc] initWithStaticDataSource:dataSource];
    [self.splitTopView addSubview:self.dashboardController.view];
    [self addChildViewController:self.dashboardController];
    
    self.measureController = [[LKMeasureController alloc] initWithDataSource:dataSource];
    self.measureController.view.hidden = YES;
    [self.splitTopView addSubview:self.measureController.view];
    [self addChildViewController:self.measureController];
    
    self.imageSyncTipsView = [LKTipsView new];
    self.imageSyncTipsView.hidden = YES;
    [self.view addSubview:self.imageSyncTipsView];
    
    self.tooLargeToSyncScreenshotTipsView = [LKRedTipsView new];
    self.tooLargeToSyncScreenshotTipsView.image = NSImageMake(@"icon_info");
    self.tooLargeToSyncScreenshotTipsView.title = NSLocalizedString(@"Image is too large to be displayed.", nil);
    self.tooLargeToSyncScreenshotTipsView.hidden = YES;
    [self.view addSubview:self.tooLargeToSyncScreenshotTipsView];
    
    self.focusTipView = [LKYellowTipsView new];
    self.focusTipView.image = NSImageMake(@"icon_info");
    self.focusTipView.title = NSLocalizedString(@"Currently in focus mode", nil);
    self.focusTipView.hidden = YES;
    self.focusTipView.buttonText = NSLocalizedString(@"Exit", nil);
    self.focusTipView.target = self;
    self.focusTipView.clickAction = @selector(_handleExitFocusTipView);
    [self.view addSubview:self.focusTipView];
    
    self.fastModeTipView = [LKTipsView new];
    self.fastModeTipView.image = NSImageMake(@"Icon_Inspiration_small");
    self.fastModeTipView.title = NSLocalizedString(@"Fast refresh mode is enabled, which may result in layer consistency issues.", nil);
    self.fastModeTipView.hidden = YES;
    self.fastModeTipView.buttonText = NSLocalizedString(@"Details", nil);
    self.fastModeTipView.target = self;
    self.fastModeTipView.clickAction = @selector(_handleFastModeTipViewClick);
    [self.view addSubview:self.fastModeTipView];
    
    self.noPreviewTipView = [LKTipsView new];
    self.noPreviewTipView.image = NSImageMake(@"icon_hide");
    self.noPreviewTipView.title = NSLocalizedString(@"The screenshot of selected item is not displayed.", nil);
    self.noPreviewTipView.buttonText = NSLocalizedString(@"Display", nil);
    self.noPreviewTipView.target = self;
    self.noPreviewTipView.clickAction = @selector(_handleNoPreviewTipView);
    self.noPreviewTipView.hidden = YES;
    [self.view addSubview:self.noPreviewTipView];
    
    self.customViewTipView = [LKTipsView new];
    self.customViewTipView.image = NSImageMake(@"Icon_Inspiration_small");
    self.customViewTipView.title = NSLocalizedString(@"This object may not be a UIView or CALayer.", nil);
    self.customViewTipView.buttonText = NSLocalizedString(@"Details", nil);
    self.customViewTipView.target = self;
    self.customViewTipView.clickAction = @selector(handleCustomViewTipsView);
    self.customViewTipView.hidden = YES;
    [self.view addSubview:self.customViewTipView];
    
    self.userConfigNoPreviewTipsView = [LKTipsView new];
    self.userConfigNoPreviewTipsView.image = NSImageMake(@"icon_hide");
    self.userConfigNoPreviewTipsView.title = NSLocalizedString(@"The screenshot is not displayed due to the config in iOS App.", nil);
    self.userConfigNoPreviewTipsView.buttonText = NSLocalizedString(@"Details", nil);
    self.userConfigNoPreviewTipsView.target = self;
    self.userConfigNoPreviewTipsView.clickAction = @selector(_handleUserConfigNoPreviewTipView);
    self.userConfigNoPreviewTipsView.hidden = YES;
    [self.view addSubview:self.userConfigNoPreviewTipsView];
    
    self.progressView = [LKProgressIndicatorView new];
    [self.view addSubview:self.progressView];
    
    @weakify(self);
    [RACObserve(dataSource, selectedItem) subscribeNext:^(LookinDisplayItem *item) {
        @strongify(self);
        [self handleSelectItemDidChange];
    }];
    
    [[[RACSignal merge:@[RACObserve(dataSource, selectedItem), dataSource.itemDidChangeNoPreview]] skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        LookinDisplayItem *item = dataSource.selectedItem;
        BOOL shouldShowNoPreviewTip = item.inNoPreviewHierarchy && item.doNotFetchScreenshotReason != LookinDoNotFetchScreenshotForUserConfig;
        if (shouldShowNoPreviewTip || !self.noPreviewTipView.hidden) {
            self.noPreviewTipView.title = [NSString stringWithFormat:NSLocalizedString(@"The screenshot of selected %@ is not displayed.", nil), item.title];
            self.noPreviewTipView.bindingObject = item;
            self.noPreviewTipView.hidden = !shouldShowNoPreviewTip;
            [self.view setNeedsLayout:YES];
        }
    }];
    
    [RACObserve(dataSource, state) subscribeNext:^(NSNumber * _Nullable x) {
        @strongify(self);
        LKHierarchyDataSourceState state = x.unsignedIntegerValue;
        BOOL isFocus = (state == LKHierarchyDataSourceStateFocus);
        self.focusTipView.hidden = !isFocus;
        if (isFocus) {
            [self.focusTipView startAnimation];
        } else {
            [self.focusTipView endAnimation];
        }
        [self.view setNeedsLayout:YES];
    }];
    
    [RACObserve([LKAppsManager sharedInstance], inspectingApp) subscribeNext:^(LKInspectableApp *app) {
        @strongify(self);
        if (app) {
            [self.imageSyncTipsView setImageByDeviceType:app.appInfo.deviceType];
        }
    }];
    
    LKStaticAsyncUpdateManager *updateMng = [LKStaticAsyncUpdateManager sharedInstance];
    [updateMng.modifyingUpdateProgressSignal subscribeNext:^(RACTwoTuple *x) {
        @strongify(self);
        NSUInteger received = ((NSNumber *)x.first).integerValue;
        NSUInteger total = MAX(1, ((NSNumber *)x.second).integerValue);
        CGFloat progress = (CGFloat)received / total;
        if (progress >= 1) {
            [self.progressView finishWithCompletion:nil];
            self.imageSyncTipsView.hidden = YES;
        } else {
            [self.progressView animateToProgress:MAX(progress, .2) duration:.1];
            self.imageSyncTipsView.hidden = NO;
            self.imageSyncTipsView.title = [NSString stringWithFormat:NSLocalizedString(@"Updating screenshots… %@ / %@", nil), @(received), @(total)];
            [self.view setNeedsLayout:YES];
        }
    }];
    [updateMng.modifyingUpdateErrorSignal subscribeNext:^(NSError *error) {
        @strongify(self);
        self.imageSyncTipsView.hidden = YES;
        [self.progressView resetToZero];
        AlertError(error, self.view.window);
    }];
    [preferenceManager.fastMode subscribe:self action:@selector(_handleFastModeChange:) relatedObject:nil sendAtOnce:YES];
    
    [[LKPreferenceManager mainManager] reportStatistics];
}

- (void)viewDidLayout {
    [super viewDidLayout];
    $(self.dashboardController.view).width(DashboardViewWidth).right(0).fullHeight;
    $(self.measureController.view).width(MeasureViewWidth).right(DashboardHorInset).fullHeight;
    $(self.viewsPreviewController.view).fullFrame;
    
    CGFloat windowTitleHeight = [LKNavigationManager sharedInstance].windowTitleBarHeight;
    
    $(self.progressView).fullWidth.height(3).y(windowTitleHeight);

    __block CGFloat tipsY = windowTitleHeight + 10;
    [$(self.connectionTipsView, self.imageSyncTipsView, self.tooLargeToSyncScreenshotTipsView, self.noPreviewTipView, self.focusTipView, self.userConfigNoPreviewTipsView, self.tutorialTipView, self.customViewTipView, self.fastModeTipView).visibles.array enumerateObjectsUsingBlock:^(LKTipsView *tipsView, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat midX = self.hierarchyController.view.$width + (self.viewsPreviewController.view.$width - DashboardViewWidth) / 2.0;
        $(tipsView).sizeToFit.y(tipsY).midX(midX);
        tipsY = tipsView.$maxY + 5;
    }];

    @weakify(self);
    [[NSNotificationCenter.defaultCenter rac_addObserverForName:LKAppShowConsoleNotificationName object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        [MSACAnalytics trackEvent:@"PrintItem"];
        
        BOOL isFirstTimeToShowConsole = (self.consoleController == nil);
        self.showConsole = true;
        LookinDisplayItem *item = x.object;
        if (isFirstTimeToShowConsole) {
            // give a little time to initialize console
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.consoleController submitWithObj:item.viewObject text:@"self"];
            });
        } else {
            [self.consoleController submitWithObj:item.viewObject text:@"self"];
        }
    }];
}

- (void)setShowConsole:(BOOL)showConsole {
    _showConsole = showConsole;
    if (showConsole) {
        [MSACAnalytics trackEvent:@"Launch Console"];
        
        if (!self.consoleController) {
            self.consoleController = [[LKConsoleViewController alloc] initWithHierarchyDataSource:[LKStaticHierarchyDataSource sharedInstance]];
            [self addChildViewController:self.consoleController];
        }
        [self.rightSplitView addArrangedSubview:self.consoleController.view];
        
        if (self.consoleController.view.bounds.size.height < 20) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.rightSplitView setPosition:(self.rightSplitView.bounds.size.height - 150) ofDividerAtIndex:0];
            });
        }
    } else {
        if (self.consoleController.view.superview) {
            [self.rightSplitView removeArrangedSubview:self.consoleController.view];
        } else {
            NSAssert(NO, @"");
        }
    }
    
    self.consoleController.isControllerShowing = showConsole;
}

- (LKHierarchyView *)currentHierarchyView {
    return self.hierarchyController.hierarchyView;
}

- (LKHierarchyDataSource *)dataSource {
    return self.hierarchyController.dataSource;
}

#pragma mark - Tutorial

- (void)viewDidAppear {
    [super viewDidAppear];
    if (TutorialMng.hasAlreadyShowedTipsThisLaunch) {
        return;
    }
}

- (void)showQuickSelectionTutorialTips {
    TutorialMng.quickSelection = YES;
    TutorialMng.hasAlreadyShowedTipsThisLaunch = YES;
    self.isShowingQuickSelectTutorialTips = YES;
    [self _initTutorialTipsIfNeeded];
    self.tutorialTipView.title = NSLocalizedString(@"While holding \"Command\" key, you can directly select a screenshot without expanding its superview first", nil);
    [self.view setNeedsLayout:YES];
}

- (void)showMoveWithSpaceTutorialTips {
    TutorialMng.moveWithSpace = YES;
    TutorialMng.hasAlreadyShowedTipsThisLaunch = YES;
    self.isShowingMoveWithSpaceTutorialTips = YES;
    [self _initTutorialTipsIfNeeded];
    self.tutorialTipView.title = NSLocalizedString(@"You can move screenshots by holding \"Space\" key and left mouse button", nil);
    [self.view setNeedsLayout:YES];
}

- (void)showNoPreviewTutorialTips {
    TutorialMng.hasAlreadyShowedTipsThisLaunch = YES;
    TutorialMng.togglePreview = YES;
    [self _initTutorialTipsIfNeeded];
    self.tutorialTipView.title = NSLocalizedString(@"You can hide a screenshot in its right-click menu", nil);
    [self.view setNeedsLayout:YES];
}

- (void)removeTutorialTips {
    if (self.tutorialTipView) {
        [self.tutorialTipView removeFromSuperview];
        self.tutorialTipView = nil;
        [self.view setNeedsLayout:YES];
    }
    self.isShowingQuickSelectTutorialTips = NO;
    self.isShowingMoveWithSpaceTutorialTips = NO;
}

- (void)_initTutorialTipsIfNeeded {
    if (!self.tutorialTipView) {
        self.tutorialTipView = [LKTipsView new];
        self.tutorialTipView.image = NSImageMake(@"Icon_Inspiration_small");
        self.tutorialTipView.buttonText = NSLocalizedString(@"Do not show again", nil);
        @weakify(self);
        self.tutorialTipView.didClick = ^(LKTipsView *tipsView) {
            @strongify(self);
            [tipsView removeFromSuperview];
            [self.view setNeedsLayout:YES];
        };
        [self.view addSubview:self.tutorialTipView];
    }
    self.tutorialTipView.hidden = NO;
}

#pragma mark - <NSSplitViewDelegate>

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return NO;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (splitView == self.mainSplitView) {
        return HierarchyMinWidth;
    } else {
        return splitView.bounds.size.height * .3;
    }
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (splitView == self.mainSplitView) {
        return MAX(splitView.bounds.size.width - DashboardViewWidth - 100, HierarchyMinWidth);
    } else {
        return splitView.bounds.size.height - 50;
    }
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification {
    [self.view setNeedsLayout:YES];
}

#pragma mark - Event Handler

- (void)_handleNoPreviewTipView {
    [self.hierarchyController hierarchyView:nil needToShowPreviewOfItem:self.noPreviewTipView.bindingObject];
    
    if (!TutorialMng.togglePreview) {
        NSView *selectedRowView = [self.hierarchyController currentSelectedRowView];
        if (!selectedRowView) {
            return;
        }
        [TutorialMng showPopoverOfView:selectedRowView text:@"你可在右键菜单里再次隐藏它的图像" learned:^{
            TutorialMng.togglePreview = YES;
            TutorialMng.hasAlreadyShowedTipsThisLaunch = YES;
        }];
    }
}

- (void)handleCustomViewTipsView {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://bytedance.feishu.cn/docx/TRridRXeUoErMTxs94bcnGchnlb"]];
}

- (void)_handleExitFocusTipView {
    [[self dataSource] endFocus];
}

- (void)_handleFastModeTipViewClick {
    NSMenu *menu = [NSMenu new];
    
    
    NSMenuItem *menuItem = [NSMenuItem new];
    menuItem.title = NSLocalizedString(@"View feature description", nil);
    menuItem.target = self;
    menuItem.action = @selector(handleFastModeDocumentation);
    [menu addItem:menuItem];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *menuItem2 = [NSMenuItem new];
    menuItem2.title = NSLocalizedString(@"Don't remind me again", nil);
    menuItem2.target = self;
    menuItem2.action = @selector(handleIgnoreFastModeTip);
    [menu addItem:menuItem2];
    
    [NSMenu popUpContextMenu:menu withEvent:NSApplication.sharedApplication.currentEvent forView:self.fastModeTipView.button];
}

- (void)handleFastModeDocumentation {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://qxh1ndiez2w.feishu.cn/wiki/BPihwfigUigWLQk1Epmc5SFenEe"]];
}

- (void)handleIgnoreFastModeTip {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IgnoreFastModeTips"];
    self.fastModeTipView.hidden = YES;
}

- (void)_handleUserConfigNoPreviewTipView {
    [LKHelper openCustomConfigWebsite];
}

- (void)_handleMeasureStateChange:(LookinMsgActionParams *)param {
    LookinMeasureState state = param.integerValue;
    BOOL isMeasure = (state != LookinMeasureState_no);
    self.dashboardController.view.hidden = isMeasure;
    self.measureController.view.hidden = !isMeasure;
}

- (void)_handleFastModeChange:(LookinMsgActionParams *)param {
    if (!param.boolValue) {
        self.fastModeTipView.hidden = YES;
        return;
    }
    BOOL shouldIgnoreTips = [[NSUserDefaults standardUserDefaults] boolForKey:@"IgnoreFastModeTips"];
    self.fastModeTipView.hidden = shouldIgnoreTips;
    [self.view setNeedsLayout:YES];
}

- (void)handleSelectItemDidChange {
    LookinDisplayItem *item = [[self dataSource] selectedItem];
    
    {
        BOOL showTips = (item && ![item appropriateScreenshot] && item.doNotFetchScreenshotReason == LookinDoNotFetchScreenshotForTooLarge);
        BOOL shouldHide = !showTips;
        if (self.tooLargeToSyncScreenshotTipsView.hidden != shouldHide) {
            self.tooLargeToSyncScreenshotTipsView.hidden = shouldHide;
            if (shouldHide) {
                [self.tooLargeToSyncScreenshotTipsView endAnimation];
            } else {
                [self.tooLargeToSyncScreenshotTipsView startAnimation];
            }
            [self.view setNeedsLayout:YES];
        }
    }
    {
        BOOL showTips = (item && item.isUserCustom);
        BOOL shouldHide = !showTips;
        if (self.customViewTipView.hidden != shouldHide) {
            self.customViewTipView.hidden = shouldHide;
            [self.view setNeedsLayout:YES];
        }
    }
}

- (LKStaticWindowController *)_staticWindowController {
    NSWindowController *windowController = self.view.window.windowController;
    if ([windowController isKindOfClass:[LKStaticWindowController class]]) {
        return (LKStaticWindowController *)windowController;
    } else {
        NSAssert(NO, @"");
        return nil;
    }
}

- (BOOL)shouldShowConnectionTips {
    return YES;
}

@end
