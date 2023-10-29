//
//  LKReadViewController.m
//  Lookin
//
//  Created by Li Kai on 2019/5/12.
//  https://lookin.work
//

#import "LKReadViewController.h"
#import "LKSplitView.h"
#import "LKDashboardViewController.h"
#import "LKReadHierarchyController.h"
#import "LKReadHierarchyDataSource.h"
#import "LookinHierarchyFile.h"
#import "LKPreviewController.h"
#import "LKTipsView.h"
#import "LKReadWindowController.h"
#import "LookinHierarchyFile.h"
#import "LookinHierarchyInfo.h"
#import "LKPreferenceManager.h"
#import "LKNavigationManager.h"
#import "LKMeasureController.h"

@interface LKReadViewController () <NSSplitViewDelegate>

@property(nonatomic, strong) LKSplitView *splitView;
@property(nonatomic, strong) NSView *splitLeftView;
@property(nonatomic, strong) NSView *splitRightView;

@property(nonatomic, strong) LKDashboardViewController *dashboardController;
@property(nonatomic, strong) LKReadHierarchyController *hierarchyController;
@property(nonatomic, strong) LKPreviewController *previewController;
@property(nonatomic, strong) LKMeasureController *measureController;
@property(nonatomic, strong) LKYellowTipsView *focusTipView;

@end

@implementation LKReadViewController

- (instancetype)initWithFile:(LookinHierarchyFile *)file preferenceManager:(LKPreferenceManager *)manager {
    if (self = [self initWithContainerView:nil]) {
        self.hierarchyDataSource = [[LKReadHierarchyDataSource alloc] initWithFile:file preferenceManager:manager];
     
        self.hierarchyController = [[LKReadHierarchyController alloc] initWithDataSource:self.hierarchyDataSource];
        [self addChildViewController:self.hierarchyController];
        self.splitLeftView = self.hierarchyController.view;
        [self.splitView addArrangedSubview:self.splitLeftView];
        
        self.splitRightView = [LKBaseView new];
        [self.splitView addArrangedSubview:self.splitRightView];
        
        self.previewController = [[LKPreviewController alloc] initWithDataSource:self.hierarchyDataSource];
        [self.splitRightView addSubview:self.previewController.view];
        [self addChildViewController:self.previewController];
        
        self.dashboardController = [[LKDashboardViewController alloc] initWithReadDataSource:self.hierarchyDataSource];
        [self.splitRightView addSubview:self.dashboardController.view];
        [self addChildViewController:self.dashboardController];
        
        self.measureController = [[LKMeasureController alloc] initWithDataSource:self.hierarchyDataSource];
        self.measureController.view.hidden = YES;
        [self.splitRightView addSubview:self.measureController.view];
        [self addChildViewController:self.measureController];
        
        self.focusTipView = [LKYellowTipsView new];
        self.focusTipView.image = NSImageMake(@"icon_info");
        self.focusTipView.title = NSLocalizedString(@"Currently in Focus mode", nil);
        self.focusTipView.hidden = YES;
        self.focusTipView.buttonText = NSLocalizedString(@"Exit", nil);
        self.focusTipView.target = self;
        self.focusTipView.clickAction = @selector(_handleExitFocusTipView);
        [self.view addSubview:self.focusTipView];
        
        [manager.isMeasuring subscribe:self action:@selector(_handleToggleMeasure:) relatedObject:nil];
        
        @weakify(self);
        [RACObserve(self.hierarchyDataSource, state) subscribeNext:^(NSNumber * _Nullable x) {
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
    }
    return self;
}

- (NSView *)makeContainerView {
    self.splitView = [LKSplitView new];
    self.splitView.didFinishFirstLayout = ^(LKSplitView *view) {
        [view setPosition:350 ofDividerAtIndex:0];
    };
    self.splitView.arrangesAllSubviews = NO;
    self.splitView.vertical = YES;
    self.splitView.dividerStyle = NSSplitViewDividerStyleThin;
    self.splitView.delegate = self;
    return self.splitView;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    $(self.previewController.view).fullFrame;
    $(self.dashboardController.view).width(DashboardViewWidth).right(0).fullHeight;
    $(self.measureController.view).width(MeasureViewWidth).right(DashboardHorInset).fullHeight;
    
    CGFloat windowTitleHeight = [LKNavigationManager sharedInstance].windowTitleBarHeight;
    __block CGFloat tipsY = windowTitleHeight + 10;
    [$(self.focusTipView).visibles.array enumerateObjectsUsingBlock:^(LKTipsView *tipsView, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat midX = self.hierarchyController.view.$width + (self.previewController.view.$width - DashboardViewWidth) / 2.0;
        $(tipsView).sizeToFit.y(tipsY).midX(midX);
        tipsY = tipsView.$maxY + 5;
    }];
}

- (LKHierarchyView *)currentHierarchyView {
    return self.hierarchyController.hierarchyView;
}

- (void)_handleToggleMeasure:(LookinMsgActionParams *)param {
    BOOL isMeasuring = param.boolValue;
    self.dashboardController.view.hidden = isMeasuring;
    self.measureController.view.hidden = !isMeasuring;
}

- (void)_handleExitFocusTipView {
    [[self hierarchyDataSource] endFocus];
}

#pragma mark - <NSSplitViewDelegate>

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return NO;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return 200;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return 700;
}

@end
