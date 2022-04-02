//
//  LKMethodTraceViewController.m
//  Lookin
//
//  Created by Li Kai on 2019/5/23.
//  https://lookin.work
//

#import "LKMethodTraceViewController.h"
#import "LKSplitView.h"
#import "LKMethodTraceMenuView.h"
#import "LKMethodTraceDetailView.h"
#import "LKMethodTraceDataSource.h"
#import "LKNavigationManager.h"
#import "LKMethodTraceSelectMethodContentView.h"
#import "LKWindow.h"
#import "LKAppsManager.h"
#import "LKMethodTraceLaunchView.h"
#import "LKTutorialManager.h"

@interface LKMethodTraceViewController () <NSSplitViewDelegate>

@property(nonatomic, strong) LKSplitView *splitView;

@property(nonatomic, strong) LKMethodTraceMenuView *menuView;
@property(nonatomic, strong) LKMethodTraceDetailView *detailView;

@property(nonatomic, strong) LKMethodTraceLaunchView *launchView;

@property(nonatomic, strong) LKMethodTraceDataSource *dataSource;

@end

@implementation LKMethodTraceViewController

- (NSView *)makeContainerView {
    self.dataSource = [LKMethodTraceDataSource new];
    [LKNavigationManager sharedInstance].activeMethodTraceDataSource = self.dataSource;
    
    self.splitView = [[LKSplitView alloc] init];
    self.splitView.didFinishFirstLayout = ^(LKSplitView *view) {
        CGFloat totalWidth = view.bounds.size.width;
        [view setPosition:totalWidth * .3 ofDividerAtIndex:0];
    };
    self.splitView.arrangesAllSubviews = NO;
    self.splitView.vertical = YES;
    self.splitView.dividerStyle = NSSplitViewDividerStyleThin;
    self.splitView.delegate = self;
    
    self.menuView = [[LKMethodTraceMenuView alloc] initWithDataSource:self.dataSource];
    self.detailView = [[LKMethodTraceDetailView alloc] initWithDataSource:self.dataSource];

    [self.splitView addArrangedSubview:self.menuView];
    [self.splitView addArrangedSubview:self.detailView];
    
    self.launchView = [LKMethodTraceLaunchView new];
    self.launchView.showTutorial = !TutorialMng.methodTrace;
    @weakify(self);
    self.launchView.didClickContinue = ^{
        @strongify(self);
        [self handleToolBarAddButton];
    };
    [self.splitView addSubview:self.launchView];
    
    RAC(self.launchView, hidden) = [RACObserve(self.dataSource, menuData) map:^id _Nullable(NSArray *value) {
        return @(value.count > 0);
    }];
    
    return self.splitView;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    if (self.launchView) {
        // 每个 window 的 windowTitleBarHeight 居然不一样，这里临时减去 3
        $(self.launchView).fullFrame.toY([LKNavigationManager sharedInstance].windowTitleBarHeight - 5);
    }
}

- (void)handleToolBarAddButton {
    TutorialMng.methodTrace = YES;

    @weakify(self);
    [[self.dataSource syncData] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        LKMethodTraceSelectMethodContentView *view = [[LKMethodTraceSelectMethodContentView alloc] initWithDataSource:self.dataSource];
        LKWindow *window = [LKWindow panelWindowWithWidth:400 height:140 contentView:view];
        view.needExit = ^{
            [self.view.window endSheet:window];
        };
        [self.view.window beginSheet:window completionHandler:nil];
        
    } error:^(NSError * _Nullable error) {
        AlertError(error, self.view.window);
    }];
}

- (void)handleToolBarRemoveButton {
    [self.dataSource clearAllRecords];
}

- (BOOL)shouldShowConnectionTips {
    return YES;
}

#pragma mark - <NSSplitViewDelegate>

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return NO;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex {
    return proposedPosition;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return dividerIndex == 0 ? 100 : 500;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (dividerIndex == 0) {
        return 400;
    }
    if (dividerIndex == 1) {
        CGFloat totalWidth = splitView.bounds.size.width;
        return MAX(totalWidth - 200, 500);
    }
    NSAssert(NO, @"");
    return proposedMaximumPosition;
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view {
    return NO;
}

@end
