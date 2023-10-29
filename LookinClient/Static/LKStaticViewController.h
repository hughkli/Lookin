//
//  LKMainViewController.h
//  Lookin
//
//  Created by Li Kai on 2018/8/4.
//  https://lookin.work
//

#import <Cocoa/Cocoa.h>

@class LKPreviewController, LKProgressIndicatorView, LKHierarchyView;

@interface LKStaticViewController : LKBaseViewController

@property(nonatomic, strong, readonly) LKPreviewController *viewsPreviewController;

@property(nonatomic, strong) LKProgressIndicatorView *progressView;

@property(nonatomic, assign) BOOL showConsole;

/// 获取当前的 hierarchyView
- (LKHierarchyView *)currentHierarchyView;

#pragma mark - Tutorials

- (void)showQuickSelectionTutorialTips;
@property(nonatomic, assign) BOOL isShowingQuickSelectTutorialTips;

- (void)showMoveWithSpaceTutorialTips;
@property(nonatomic, assign) BOOL isShowingMoveWithSpaceTutorialTips;

@property(nonatomic, assign) BOOL isShowingDoubleClickTutorialTips;

- (void)showNoPreviewTutorialTips;

- (void)removeTutorialTips;


@end
