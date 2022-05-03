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

@interface LKStaticViewController () <NSSplitViewDelegate>

@property(nonatomic, strong) LKSplitView *mainSplitView;
@property(nonatomic, strong) LKSplitView *rightSplitView;
@property(nonatomic, strong) LKBaseView *splitTopView;

@property(nonatomic, strong) LKTipsView *imageSyncTipsView;
@property(nonatomic, strong) LKRedTipsView *avoidSyncScreenshotTipsView;
@property(nonatomic, strong) LKTipsView *noPreviewTipView;
@property(nonatomic, strong) LKTipsView *tutorialTipView;
@property(nonatomic, strong) LKTipsView *delayReloadTipView;

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
    [preferenceManager.isMeasuring subscribe:self action:@selector(_handleToggleMeasure:) relatedObject:nil];
    
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
    
    self.delayReloadTipView = [LKTipsView new];
    self.delayReloadTipView.hidden = YES;
    [self.view addSubview:self.delayReloadTipView];
    
    self.avoidSyncScreenshotTipsView = [LKRedTipsView new];
    self.avoidSyncScreenshotTipsView.image = NSImageMake(@"icon_info");
    self.avoidSyncScreenshotTipsView.title = NSLocalizedString(@"Image is too large to be displayed.", nil);
    self.avoidSyncScreenshotTipsView.hidden = YES;
    [self.view addSubview:self.avoidSyncScreenshotTipsView];
    
    self.noPreviewTipView = [LKTipsView new];
    self.noPreviewTipView.image = NSImageMake(@"icon_hide");
    self.noPreviewTipView.title = NSLocalizedString(@"The screenshot of selected item is not displayed.", nil);
    self.noPreviewTipView.buttonText = NSLocalizedString(@"Display", nil);
    self.noPreviewTipView.target = self;
    self.noPreviewTipView.clickAction = @selector(_handleNoPreviewTipView);
    self.noPreviewTipView.hidden = YES;
    [self.view addSubview:self.noPreviewTipView];
    
    self.progressView = [LKProgressIndicatorView new];
    [self.view addSubview:self.progressView];
    
    @weakify(self);
    [RACObserve(dataSource, selectedItem) subscribeNext:^(LookinDisplayItem *item) {
        @strongify(self);
        BOOL shouldHide = ([item appropriateScreenshot] || !item.avoidSyncScreenshot);
        if (self.avoidSyncScreenshotTipsView.hidden == !shouldHide) {
            self.avoidSyncScreenshotTipsView.hidden = shouldHide;
            if (shouldHide) {
                [self.avoidSyncScreenshotTipsView endAnimation];
            } else {
                [self.avoidSyncScreenshotTipsView startAnimation];
            }
            [self.view setNeedsLayout:YES];
        }
    }];
    
    [[[RACSignal merge:@[RACObserve(dataSource, selectedItem), dataSource.itemDidChangeNoPreview]] skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        LookinDisplayItem *item = dataSource.selectedItem;
        BOOL shouldShowNoPreviewTip = item.inNoPreviewHierarchy;
        if (shouldShowNoPreviewTip || !self.noPreviewTipView.hidden) {
            self.noPreviewTipView.title = [NSString stringWithFormat:NSLocalizedString(@"The screenshot of selected %@ is not displayed.", nil), item.title];
            self.noPreviewTipView.bindingObject = item;
            self.noPreviewTipView.hidden = !shouldShowNoPreviewTip;
            [self.view setNeedsLayout:YES];
        }
    }];
    
    [RACObserve([LKAppsManager sharedInstance], inspectingApp) subscribeNext:^(LKInspectableApp *app) {
        @strongify(self);
        if (app) {
            [self.imageSyncTipsView setImageByDeviceType:app.appInfo.deviceType];
            [self.delayReloadTipView setImageByDeviceType:app.appInfo.deviceType];
        }
    }];
    
    LKStaticAsyncUpdateManager *updateMng = [LKStaticAsyncUpdateManager sharedInstance];
    [updateMng.updateAll_ErrorSignal subscribeNext:^(NSError *error) {
        @strongify(self);
        AlertError(error, self.view.window);
    }];
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
}

- (void)viewDidLayout {
    [super viewDidLayout];
    $(self.dashboardController.view).width(DashboardViewWidth).right(0).fullHeight;
    $(self.measureController.view).width(MeasureViewWidth).right(DashboardHorInset).fullHeight;
    $(self.viewsPreviewController.view).fullFrame;
    
    CGFloat windowTitleHeight = [LKNavigationManager sharedInstance].windowTitleBarHeight;
    
    $(self.progressView).fullWidth.height(3).y(windowTitleHeight);

    __block CGFloat tipsY = windowTitleHeight + 10;
    [$(self.connectionTipsView, self.imageSyncTipsView, self.avoidSyncScreenshotTipsView, self.noPreviewTipView, self.tutorialTipView, self.delayReloadTipView).visibles.array enumerateObjectsUsingBlock:^(LKTipsView *tipsView, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat midX = self.hierarchyController.view.$width + (self.viewsPreviewController.view.$width - DashboardViewWidth) / 2.0;
        $(tipsView).sizeToFit.y(tipsY).midX(midX);
        tipsY = tipsView.$maxY + 5;
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

- (void)showDelayReloadTipWithSeconds:(NSInteger)seconds {
    self.delayReloadTipView.title = [NSString stringWithFormat:NSLocalizedString(@"Will reload in %@ seconds…", nil), @(seconds)];
    self.delayReloadTipView.hidden = NO;
    [self.view setNeedsLayout:YES];
}

- (void)removeDelayReloadTip {
    self.delayReloadTipView.hidden = YES;
    [self.view setNeedsLayout:YES];
}

#pragma mark - Tutorial

- (void)viewDidAppear {
    [super viewDidAppear];
    if (TutorialMng.hasAlreadyShowedTipsThisLaunch) {
        return;
    }
    if (!TutorialMng.doubleClick) {
        [self _showDoubleClickTutorialTips];
        return;
    }
}

- (void)_showDoubleClickTutorialTips {
    TutorialMng.doubleClick = YES;
    TutorialMng.hasAlreadyShowedTipsThisLaunch = YES;
    self.isShowingDoubleClickTutorialTips = YES;
    [self _initTutorialTipsIfNeeded];
    self.tutorialTipView.title = NSLocalizedString(@"You can double-click screenshot to expand or collapse it", nil);
    [self.view setNeedsLayout:YES];
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
    self.isShowingDoubleClickTutorialTips = NO;
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

- (void)_handleTutorialTipView {
    
}

- (void)_handleToggleMeasure:(LookinMsgActionParams *)param {
    BOOL isMeasuring = param.boolValue;
    self.dashboardController.view.hidden = isMeasuring;
    self.measureController.view.hidden = !isMeasuring;
}

#pragma mark - Others

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
