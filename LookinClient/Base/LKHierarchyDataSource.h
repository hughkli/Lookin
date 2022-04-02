//
//  LKHierarchyDataSource.h
//  Lookin_macOS
//
//  Created by 李凯 on 2019/5/6.
//  Copyright © 2019 hughkli. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LookinHierarchyInfo, LookinDisplayItem, LookinStaticDisplayItem, LKPreferenceManager;

@interface LKHierarchyDataSource : NSObject

/**
 如果 keepState 为 YES，则会尽量维持刷新之前的折叠状态、选中态等
 */
- (void)reloadWithHierarchyInfo:(LookinHierarchyInfo *)info keepState:(BOOL)keepState;

/// 一维数组，包含所有 hierarchy 树中可见和不可见的 displayItems
@property(nonatomic, copy, readonly) NSArray<LookinDisplayItem *> *flatItems;

/// 一维数组，只包括在 hierarchy 树中可见的 displayItems
@property(nonatomic, copy, readonly) NSArray<LookinDisplayItem *> *displayingFlatItems;

/**
 index 范围：0 ~ 4
 referenceDict 的 key 为 layerOid，value 为 @(YES)/@(NO) 即是否展开，它记录了一组 displayItem 的展开状态
 在调整一个 item 的 expansion 时，如果 referenceDict 中存在这个 item 的记录则会采用 referenceDict 里的数据，否则会重新根据 index 来调整
 */
- (void)adjustExpansionByIndex:(NSInteger)index referenceDict:(NSDictionary<NSNumber *, NSNumber *> *)referenceDict;

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

/// 将 item 折叠起来，如果该 item 没有 subitems 或已经被折叠，则该方法不起任何作用
- (void)collapseItem:(LookinDisplayItem *)item;

/// 将 item 展开，如果该 item 没有 subitems 或已经被展开，则该方法不起任何作用
- (void)expandItem:(LookinDisplayItem *)item;

/// 如果 item 在 hierarchy 中可见则该方法不执行任何操作，否则会将 item 的所有上级元素展开以显示 item
- (void)expandToShowItem:(LookinDisplayItem *)item;

/// 把 item 及所有后代元素全部折叠
- (void)collapseItemsRootedByItem:(LookinDisplayItem *)item;
/// 把 item 及所有后代元素全部展开
- (void)expandItemsRootedByItem:(LookinDisplayItem *)item;

/// 通过 oid 找到对应的 displayItem
- (LookinDisplayItem *)displayItemWithOid:(unsigned long)oid;

@property(nonatomic, strong, readonly) LookinHierarchyInfo *rawHierarchyInfo;

/// 某个 item 的 isHidden 或 alpha 发生改变
@property(nonatomic, strong, readonly) RACSubject *itemDidChangeHiddenAlphaValue;
/// 某个 item 的 attrGroup 改变
@property(nonatomic, strong, readonly) RACSubject *itemDidChangeAttrGroup;

/// 子类实现该方法
- (LKPreferenceManager *)preferenceManager;

@end

@interface LKHierarchyWithPreviewDataSource : LKHierarchyDataSource

- (NSArray<LookinStaticDisplayItem *> *)staticFlatItems;

@property(nonatomic, strong, readonly) RACSubject *itemDidChangeNoPreview;

@end
