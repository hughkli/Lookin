//
//  LKHierarchyView.h
//  Lookin
//
//  Created by Li Kai on 2018/8/4.
//  https://lookin.work
//

#import "LKBaseView.h"
#import "LKHierarchyRowView.h"

@class LKHierarchyView, LKTableView;

@protocol LKHierarchyViewDelegate <NSObject>

- (void)hierarchyView:(LKHierarchyView *)view didSelectItem:(LookinDisplayItem *)item;

- (void)hierarchyView:(LKHierarchyView *)view didDoubleClickItem:(LookinDisplayItem *)item;

- (void)hierarchyView:(LKHierarchyView *)view shouldFocusItem:(LookinDisplayItem *)item;

- (void)cancelFocusedOnHierarchyView:(LKHierarchyView *)view;

- (void)hierarchyView:(LKHierarchyView *)view didHoverAtItem:(LookinDisplayItem *)item;

- (void)hierarchyView:(LKHierarchyView *)view needToExpandItem:(LookinDisplayItem *)item recursively:(BOOL)recursively;

- (void)hierarchyView:(LKHierarchyView *)view needToCollapseItem:(LookinDisplayItem *)item;

- (void)hierarchyView:(LKHierarchyView *)view needToCollapseChildrenOfItem:(LookinDisplayItem *)item;

/// 在底部的搜索框里输入了文字，string 可能为空字符串或 nil
/// 当用户通过搜索框的关闭按钮、ESC 等方式手动结束搜索时，该方法同样会被调用，参数是 nil
- (void)hierarchyView:(LKHierarchyView *)view didInputSearchString:(NSString *)string;

@optional

- (void)hierarchyView:(LKHierarchyView *)view needToCancelPreviewOfItem:(LookinDisplayItem *)item;

- (void)hierarchyView:(LKHierarchyView *)view needToShowPreviewOfItem:(LookinDisplayItem *)item;

@end

@interface LKHierarchyView : LKBaseView

@property(nonatomic, strong, readonly) LKTableView *tableView;

@property(nonatomic, copy) NSArray<LookinDisplayItem *> *displayItems;

@property(nonatomic, weak) id<LKHierarchyViewDelegate> delegate;

- (void)scrollToMakeItemVisible:(LookinDisplayItem *)item;

- (void)updateGuidesWithHoveredItem:(LookinDisplayItem *)item;

/// 激活搜索框
- (void)activateSearchBar;

- (void)activateFocused;
- (void)deactivateFocused;

@end
