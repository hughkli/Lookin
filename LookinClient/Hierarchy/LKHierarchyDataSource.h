//
//  LKHierarchyDataSource.h
//  Lookin
//
//  Created by Li Kai on 2019/5/6.
//  https://lookin.work
//

#import <Foundation/Foundation.h>

@class LookinHierarchyInfo, LookinDisplayItem, LKPreferenceManager;

typedef NS_ENUM(NSUInteger, LKHierarchyDataSourceState) {
    LKHierarchyDataSourceStateNormal,
    LKHierarchyDataSourceStateSearch,
    LKHierarchyDataSourceStateFocus,
};

@interface LKHierarchyDataSource : NSObject
@property(nonatomic, strong, readonly) RACSignal<NSNumber *> *stateSignal;
@property(nonatomic, assign, readonly) LKHierarchyDataSourceState state;

/**
 如果 keepState 为 YES，则会尽量维持刷新之前的折叠状态和选中态
 */
- (void)reloadWithHierarchyInfo:(LookinHierarchyInfo *)info keepState:(BOOL)keepState;
@property(nonatomic, strong, readonly) RACSubject *didReloadHierarchyInfo;

/// 一维数组，包含所有 hierarchy 树中可见和不可见的 displayItems
@property(nonatomic, copy, readonly) NSArray<LookinDisplayItem *> *flatItems;

/// 一维数组，只包括在 hierarchy 树中因为未被折叠而可见的 displayItems
@property(nonatomic, copy, readonly) NSArray<LookinDisplayItem *> *displayingFlatItems;

/**
 index 范围：0 ~ 4
 referenceDict 的 key 为 layerOid，value 为 @(YES)/@(NO) 即是否展开，它记录了一组 displayItem 的展开状态
 在调整一个 item 的 expansion 时，如果 referenceDict 中存在这个 item 的记录则会采用 referenceDict 里的数据，否则会重新根据 index 来调整
 */
- (void)adjustExpansionByIndex:(NSInteger)index referenceDict:(NSDictionary<NSNumber *, NSNumber *> *)referenceDict selectedItem:(LookinDisplayItem **)selectedItem;

/// 当前应该被显示的 rows 行数
- (NSInteger)numberOfRows;

/// 获取指定行的 item
- (LookinDisplayItem *)itemAtRow:(NSInteger)index;

/// 获取指定 item 的 row，可能为 NSNotFound
- (NSInteger)rowForItem:(LookinDisplayItem *)item;

/// 当前选中的 item
@property(nonatomic, weak) LookinDisplayItem *selectedItem;

/// 当前被鼠标 hover 的 item
@property(nonatomic, weak) LookinDisplayItem *hoveredItem;

/// 某个颜色的业务别名，如果不存在则返回 nil
- (NSArray<NSString *> *)aliasForColor:(NSColor *)color;
/// 在 dashboard 里选择颜色时弹出的 menu
@property(nonatomic, strong, readonly) NSMenu *selectColorMenu;
/// 该 tag 标示这个 menuItem 是“自定义……”那个选项
@property(nonatomic, assign, readonly) NSInteger customColorMenuItemTag;
/// The menu tag of "switch color format"
@property(nonatomic, assign, readonly) NSInteger toggleColorFormatMenuItemTag;

/// 将 item 折叠起来，如果该 item 没有 subitems 或已经被折叠，则该方法不起任何作用
- (void)collapseItem:(LookinDisplayItem *)item;

/// 将 item 展开，如果该 item 没有 subitems 或已经被展开，则该方法不起任何作用
- (void)expandItem:(LookinDisplayItem *)item;

/// 如果 item 在 hierarchy 中可见则该方法不执行任何操作，否则会将 item 的所有上级元素展开以显示 item
- (void)expandToShowItem:(LookinDisplayItem *)item;
/// 把 item 及所有后代元素全部展开
- (void)expandItemsRootedByItem:(LookinDisplayItem *)item;
/// 把 item 所有后代元素全部折叠（但是不折叠 item 自身）
- (void)collapseAllChildrenOfItem:(LookinDisplayItem *)item;

/// 通过 oid 找到对应的 displayItem
- (LookinDisplayItem *)displayItemWithOid:(unsigned long)oid;

@property(nonatomic, strong, readonly) LookinHierarchyInfo *rawHierarchyInfo;

/// 某个 item 的 isHidden 或 alpha 发生改变
@property(nonatomic, strong, readonly) RACSubject *itemDidChangeHiddenAlphaValue;
/// 某个 item 的 attrGroup 改变
@property(nonatomic, strong, readonly) RACSubject *itemDidChangeAttrGroup;

@property(nonatomic, strong, readonly) RACSubject *itemDidChangeNoPreview;

/// 子类实现该方法
- (LKPreferenceManager *)preferenceManager;

/// 当该属性为 YES 时，表示正处于 dashboard 搜索状态中，此时 preview 界面不应该响应图层点击
@property(nonatomic, assign) BOOL shouldAvoidChangingPreviewSelectionDueToDashboardSearch;

#pragma mark - Search

/// 应该在用户输入搜索词时调用该方法，内部会直接更改 flatItems 和 displayingFlatItems 对象
/// string 不能为 nil 或空字符串
- (void)searchWithString:(NSString *)string;

- (void)focusThisItem:(LookinDisplayItem *)item;

/// 应该在点击搜索框的关闭按钮时调用该方法，用来恢复搜索前的状态等一系列工作
- (void)endSearch;

/// 由于搜索而修改了 flatItems
@property(nonatomic, strong, readonly) RACSubject *didReloadFlatItemsWithSearch;

@end
