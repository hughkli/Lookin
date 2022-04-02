//
//  LKHierarchyDataSource.m
//  Lookin_macOS
//
//  Created by 李凯 on 2019/5/6.
//  Copyright © 2019 hughkli. All rights reserved.
//

#import "LKHierarchyDataSource.h"
#import "LookinHierarchyInfo.h"
#import "LookinStaticDisplayItem.h"
#import "LKPreferenceManager.h"
#import "LKColorIndicatorLayer.h"

@interface LKSelectColorItem : NSObject

+ (instancetype)itemWithTitle:(NSString *)title color:(LookinColor *)color;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) NSColor *color;

@end

@implementation LKSelectColorItem

+ (instancetype)itemWithTitle:(NSString *)title color:(LookinColor *)color {
    LKSelectColorItem *item = [LKSelectColorItem new];
    item.title = title;
    item.color = color;
    return item;
}

@end

@interface LKSelectColorItemsSection : NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSArray<LKSelectColorItem *> *items;

@end

@implementation LKSelectColorItemsSection

- (void)setItems:(NSArray<LKSelectColorItem *> *)items {
    _items = [items sortedArrayUsingComparator:^NSComparisonResult(LKSelectColorItem * _Nonnull obj1, LKSelectColorItem * _Nonnull obj2) {
        return [obj1.title caseInsensitiveCompare:obj2.title];
    }].copy;
}

@end

@interface LKHierarchyDataSource ()

@property(nonatomic, strong, readwrite) LookinHierarchyInfo *rawHierarchyInfo;

@property(nonatomic, copy, readwrite) NSArray<LookinDisplayItem *> *flatItems;
@property(nonatomic, copy, readwrite) NSArray<LookinDisplayItem *> *displayingFlatItems;

@property(nonatomic, strong, readwrite) NSMenu *selectColorMenu;
@property(nonatomic, copy) NSDictionary<NSNumber *, LookinDisplayItem *> *oidToDisplayItemMap;

/**
 key 是 rgba 字符串，value 是 alias 字符串数组，比如：
 
 @{
 @"(255, 255, 255, 1)": @[@"MyWhite", @"MainThemeWhite"],
 @"(255, 0, 0, 0.5)": @[@"BestRed", @"TransparentRed"]
 };
 
 */
@property(nonatomic, strong) NSDictionary<NSString *, NSArray<NSString *> *> *colorToAliasMap;

@end

@implementation LKHierarchyDataSource

- (instancetype)init {
    if (self = [super init]) {
        _itemDidChangeHiddenAlphaValue = [RACSubject subject];
        _itemDidChangeAttrGroup = [RACSubject subject];
        
        @weakify(self);
        [[[RACObserve([LKPreferenceManager mainManager], rgbaFormat) skip:1] distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self _setUpColors];
        }];
    }
    return self;
}

- (void)reloadWithHierarchyInfo:(LookinHierarchyInfo *)info keepState:(BOOL)keepState {
    self.rawHierarchyInfo = info;
    
    unsigned long prevSelectedOid = 0;
    NSMutableDictionary *prevExpansionMap = nil;
    if (keepState) {
        prevSelectedOid = self.selectedItem.layerObject.oid;
        
        prevExpansionMap = [NSMutableDictionary dictionary];
        [self.flatItems enumerateObjectsUsingBlock:^(LookinDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            prevExpansionMap[@(obj.layerObject.oid)] = @(obj.isExpanded);
        }];
    }
    
    // 设置 color alias 和 select color menu
    [self _setUpColors];
    
    // 打平为二维数组
    self.flatItems = [LookinDisplayItem flatItemsFromHierarchicalItems:info.displayItems];
    [LookinDisplayItem setUpIndentLevelForFlatItems:self.flatItems];
    
    // 设置 preferToBeCollapsed 属性
    NSSet<NSString *> *classesPreferredToCollapse = [NSSet setWithObjects:@"UILabel", @"UIPickerView", @"UIProgressView", @"UIActivityIndicatorView", @"UIAlertView", @"UIActionSheet", @"UISearchBar", @"UIButton", @"UITextView", @"UIDatePicker", @"UIPageControl", @"UISegmentedControl", @"UITextField", @"UISlider", @"UISwitch", @"UIVisualEffectView", @"UIImageView", @"WKCommonWebView", @"UITextEffectsWindow", @"LKI_LocalInspectContainerWindow", nil];
    if (info.collapsedClassList.count) {
        classesPreferredToCollapse = [classesPreferredToCollapse setByAddingObjectsFromArray:info.collapsedClassList];
    }
    [self.flatItems enumerateObjectsUsingBlock:^(LookinDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj itemIsKindOfClassesWithNames:classesPreferredToCollapse]) {
            [obj enumerateSelfAndChildren:^(LookinDisplayItem *item) {
                item.preferToBeCollapsed = YES;
            }];
        }
    }];
    
    // 设置展开和折叠
    NSInteger expansionIndex = self.preferenceManager.expansionIndex;
    if (self.flatItems.count > 300) {
        if (expansionIndex > 2) {
            expansionIndex = 2;
        }
    }
    [self adjustExpansionByIndex:expansionIndex referenceDict:(keepState ? prevExpansionMap : nil)];
    
    // 设置选中
    LookinDisplayItem *shouldSelectedItem = nil;
    if (keepState) {
        LookinDisplayItem *prevSelectedItem = [self displayItemWithOid:prevSelectedOid];
        if (prevSelectedItem) {
            shouldSelectedItem = prevSelectedItem;
        }
    }
    if (!shouldSelectedItem) {
        LookinDisplayItem *mainContentViewItem = [self _findMainContentViewItemInFlatItems:self.flatItems];
        if (mainContentViewItem && mainContentViewItem.displayingInHierarchy) {
            shouldSelectedItem = mainContentViewItem;
        }
    }
    if (!shouldSelectedItem) {
        shouldSelectedItem = self.flatItems.firstObject;
    }
    self.selectedItem = shouldSelectedItem;
}

- (NSInteger)numberOfRows {
    return self.displayingFlatItems.count;
}

- (LookinDisplayItem *)itemAtRow:(NSInteger)index {
    if (index < 0) {
        return nil;
    }
    if ([self.displayingFlatItems hasIndex:index]) {
        return self.displayingFlatItems[index];
    }
    return nil;
}

- (NSInteger)rowForItem:(LookinDisplayItem *)item {
    NSInteger row = [self.displayingFlatItems indexOfObject:item];
    return row;
}

- (void)setSelectedItem:(LookinDisplayItem *)selectedItem {
    if (_selectedItem == selectedItem) {
        return;
    }
    _selectedItem.isSelected = NO;
    _selectedItem = selectedItem;
    _selectedItem.isSelected = YES;
}

- (void)setHoveredItem:(LookinDisplayItem *)hoveredItem {
    if (_hoveredItem == hoveredItem) {
        return;
    }
    _hoveredItem.isHovered = NO;
    _hoveredItem = hoveredItem;
    _hoveredItem.isHovered = YES;
}

- (void)adjustExpansionByIndex:(NSInteger)index referenceDict:(NSDictionary<NSNumber *, NSNumber *> *)referenceDict {
    if (index < 0 || index > 4) {
        NSAssert(NO, @"");
    }
    index = MAX(MIN(index, 4), 0);
    
    self.preferenceManager.expansionIndex = index;
    
    if (index == 0) {
        // 全部折叠，只剩下 UIWindow
        [self.flatItems enumerateObjectsUsingBlock:^(LookinDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!obj.isExpandable) {
                return;
            }
            
            NSNumber *prevState = referenceDict[@(obj.layerObject.oid)];
            if (prevState) {
                // 旧的对象，直接维持之前的状态
                obj.isExpanded = [prevState boolValue];
                return;
            }
            
            obj.isExpanded = NO;
        }];
        
    } else if (index == 1) {
        // 业务 vc 刚好露出来，也就是现在“全部收起”时的层级状态
        static NSSet<NSString *> *list_selfExpanded;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            list_selfExpanded = [NSSet setWithObjects:@"UIWindow", @"UILayoutContainerView", @"UITransitionView", @"UIViewControllerWrapperView", @"UILayoutContainerView", @"UINavigationTransitionView", @"UIViewControllerWrapperView", nil];
        });
        
        LookinDisplayItem *mainContentViewItem = [self _findMainContentViewItemInFlatItems:self.flatItems];
        
        [self.flatItems enumerateObjectsUsingBlock:^(LookinDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!obj.isExpandable) {
                return;
            }
            
            NSNumber *prevState = referenceDict[@(obj.layerObject.oid)];
            if (prevState) {
                // 旧的对象，直接维持之前的状态
                obj.isExpanded = [prevState boolValue];
                return;
            }
            
            if ([obj itemIsKindOfClassesWithNames:list_selfExpanded] && !obj.inHiddenHierarchy) {
                if ([obj isKindOfClass:[LookinStaticDisplayItem class]]) {
                    if (!((LookinStaticDisplayItem *)obj).inNoPreviewHierarchy) {
                        obj.isExpanded = YES;
                        return;
                    }
                } else {
                    obj.isExpanded = YES;
                    return;
                }
            }
            if (obj == mainContentViewItem) {
                obj.isExpanded = YES;
                return;
            }
            obj.isExpanded = NO;
        }];
        
    } else if (index == 2) {
        // 注意这里可能获取不到
        LookinDisplayItem *mainContentViewItem = [self _findMainContentViewItemInFlatItems:self.flatItems];
        
        // 如果 mainContentViewItem 存在，则以它为基准向下多展开三层，但如果提前遇到了 UITableViewCell，则停在刚刚好看到 cell 这一层
        NSString *Key_ExpansionDetermined = @"Key_ExpansionDetermined";
        
        static NSSet<NSString *> *list_subitemsCollapsed;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            list_subitemsCollapsed = [NSSet setWithObjects:@"UITableView", @"UICollectionView", nil];
        });
        
        [self.flatItems enumerateObjectsUsingBlock:^(LookinDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!obj.isExpandable) {
                return;
            }
            if ([obj lookin_getBindBOOLForKey:Key_ExpansionDetermined]) {
                return;
            }
            
            NSNumber *prevState = referenceDict[@(obj.layerObject.oid)];
            if (prevState) {
                // 旧的对象，直接维持之前的状态
                obj.isExpanded = [prevState boolValue];
                return;
            }
            
            BOOL shouldCollapseSelfAndChildren = NO;
            if (obj.isHidden || obj.alpha <= 0) {
                shouldCollapseSelfAndChildren = YES;
               
            } else if ([obj isKindOfClass:[LookinStaticDisplayItem class]] && ((LookinStaticDisplayItem *)obj).noPreview) {
                shouldCollapseSelfAndChildren = YES;
                
            } else if (mainContentViewItem && obj.indentLevel > mainContentViewItem.indentLevel + 3) {
                shouldCollapseSelfAndChildren = YES;
                
            } else if (obj.preferToBeCollapsed) {
                shouldCollapseSelfAndChildren = YES;
                
            } else if ([obj.title isEqualToString:@"UINavigationBar"] || [obj.title isEqualToString:@"UITabBar"]) {
                shouldCollapseSelfAndChildren = YES;
                
            } else if ([obj.superItem itemIsKindOfClassesWithNames:list_subitemsCollapsed]) {
                shouldCollapseSelfAndChildren = YES;
            }
            
            if (shouldCollapseSelfAndChildren) {
                [obj enumerateSelfAndChildren:^(LookinDisplayItem *item) {
                    item.isExpanded = NO;
                    [item lookin_bindBOOL:YES forKey:Key_ExpansionDetermined];
                }];
                return;
            }
            obj.isExpanded = YES;
        }];
        
        [self.flatItems enumerateObjectsUsingBlock:^(LookinDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj lookin_clearBindForKey:Key_ExpansionDetermined];
        }];
        
    } else if (index == 3) {
        // 展开几乎全部，把 UITabBar、UINavigationBar 收起，把那些 UIButton, UILabel 等常用系统控件收起
        NSString *Key_ExpansionDetermined = @"Key_ExpansionDetermined";
        
        [self.flatItems enumerateObjectsUsingBlock:^(LookinDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!obj.isExpandable) {
                return;
            }
            if ([obj lookin_getBindBOOLForKey:Key_ExpansionDetermined]) {
                return;
            }
            
            NSNumber *prevState = referenceDict[@(obj.layerObject.oid)];
            if (prevState) {
                // 旧的对象，直接维持之前的状态
                obj.isExpanded = [prevState boolValue];
                return;
            }
            
            BOOL shouldCollapseSelfAndChildren = NO;
            if (obj.isHidden || obj.alpha <= 0) {
                // 把 hidden, noPreview 都折叠起来
                shouldCollapseSelfAndChildren = YES;
                
            } else if ([obj isKindOfClass:[LookinStaticDisplayItem class]] && ((LookinStaticDisplayItem *)obj).noPreview) {
                shouldCollapseSelfAndChildren = YES;
                
            } else if (obj.preferToBeCollapsed) {
                shouldCollapseSelfAndChildren = YES;
                
            } else if ([obj.title isEqualToString:@"UINavigationBar"] || [obj.title isEqualToString:@"UITabBar"]) {
                shouldCollapseSelfAndChildren = YES;
                
            }
            if (shouldCollapseSelfAndChildren) {
                [obj enumerateSelfAndChildren:^(LookinDisplayItem *item) {
                    item.isExpanded = NO;
                    [item lookin_bindBOOL:YES forKey:Key_ExpansionDetermined];
                }];
                return;
            }
            obj.isExpanded = YES;
        }];
        
        [self.flatItems enumerateObjectsUsingBlock:^(LookinDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj lookin_clearBindForKey:Key_ExpansionDetermined];
        }];
        
    } else if (index == 4) {
        // 全部展开，包括 UIButton、UITabBar、UINavigationBar 等等，全部展开
        [self.flatItems enumerateObjectsUsingBlock:^(LookinDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!obj.isExpandable) {
                return;
            }
            
            NSNumber *prevState = referenceDict[@(obj.layerObject.oid)];
            if (prevState) {
                // 旧的对象，直接维持之前的状态
                obj.isExpanded = [prevState boolValue];
                return;
            }
            
            if ([obj isKindOfClass:[LookinStaticDisplayItem class]] && ((LookinStaticDisplayItem *)obj).inNoPreviewHierarchy) {
                obj.isExpanded = NO;
                return;
            }
            obj.isExpanded = YES;
        }];
    }
    
    [self updateDisplayingFlatItems];
}

- (LookinDisplayItem *)displayItemWithOid:(unsigned long)oid {
    LookinDisplayItem *item = self.oidToDisplayItemMap[@(oid)];
    return item;
}

- (void)setFlatItems:(NSArray<LookinDisplayItem *> *)flatItems {
    _flatItems = flatItems.copy;
    
    NSMutableDictionary<NSNumber *, LookinDisplayItem *> *map = [NSMutableDictionary dictionaryWithCapacity:flatItems.count * 2];
    [flatItems enumerateObjectsUsingBlock:^(LookinDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.viewObject.oid) {
            map[@(obj.viewObject.oid)] = obj;
        }
        if (obj.layerObject.oid) {
            map[@(obj.layerObject.oid)] = obj;
        }
    }];
    self.oidToDisplayItemMap = map;
}

- (void)updateDisplayingFlatItems {
    NSMutableArray<LookinDisplayItem *> *displayingItems = [NSMutableArray array];
    [self.flatItems enumerateObjectsUsingBlock:^(LookinDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.displayingInHierarchy) {
            [displayingItems addObject:obj];
        }
    }];
    self.displayingFlatItems = displayingItems;
}

- (void)collapseItem:(LookinDisplayItem *)item {
    if (!item.isExpandable) {
        return;
    }
    if (!item.isExpanded) {
        return;
    }
    item.isExpanded = NO;
    [self updateDisplayingFlatItems];
}

- (void)expandItem:(LookinDisplayItem *)item {
    if (!item.isExpandable) {
        return;
    }
    if (item.isExpanded) {
        return;
    }
    item.isExpanded = YES;
    [self updateDisplayingFlatItems];
}

- (void)expandToShowItem:(LookinDisplayItem *)item {
    [item enumerateAncestors:^(LookinDisplayItem *targetItem, BOOL *stop) {
        if (!targetItem.isExpanded) {
            targetItem.isExpanded = YES;
        }
    }];
    
    [self updateDisplayingFlatItems];
}

- (void)collapseItemsRootedByItem:(LookinDisplayItem *)item {
    [item enumerateSelfAndChildren:^(LookinDisplayItem *targetItem) {
        if (targetItem.isExpanded) {
            targetItem.isExpanded = NO;
        }
    }];
    
    [self updateDisplayingFlatItems];
}

- (void)expandItemsRootedByItem:(LookinDisplayItem *)item {
    if (item.preferToBeCollapsed) {
        [item enumerateSelfAndChildren:^(LookinDisplayItem *targetItem) {
            if (targetItem.isExpandable && !targetItem.isExpanded) {
                targetItem.isExpanded = YES;
            }
        }];
    } else {
        [item enumerateSelfAndChildren:^(LookinDisplayItem *targetItem) {
            if (targetItem.isExpandable && !targetItem.isExpanded && ![targetItem preferToBeCollapsed]) {
                targetItem.isExpanded = YES;
            }
        }];
    }
    
    [self updateDisplayingFlatItems];
}

- (LookinDisplayItem *)_findMainContentViewItemInFlatItems:(NSArray<LookinDisplayItem *> *)items {
    LookinDisplayItem *mainContentView = [items firstFiltered:^BOOL(LookinDisplayItem *obj) {
        if (obj.hostViewControllerObject) {
            if ([obj.title isEqualToString:@"UIView"] || ![obj.title hasPrefix:@"UI"]) {
                return YES;
            }
        }
        return NO;
    }];
    return mainContentView;
}

#pragma mark - Colors

- (NSArray<NSString *> *)aliasForColor:(NSColor *)color {
    if (!color) {
        return nil;
    }
    NSString *rgbaString = color.rgbaString;
    NSArray<NSString *> *names = self.colorToAliasMap[rgbaString];
    return names;
}

- (void)_setUpColors {
    NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *colorToAliasMap = [NSMutableDictionary dictionary];
    /// 成员可能是 LKSelectColorItem 和 LKSelectColorItemsSection 混杂在一起
    NSMutableArray *aliasColorItemsOrSections = [NSMutableArray array];
    
    /**
     hierarchyInfo.colorAlias 可以有三种结构：
     1）key 是颜色别名，value 是 UIColor/NSColor。即 <NSString *, Color *>
     2）key 是一组颜色的标题，value 是 NSDictionary，而这个 NSDictionary 的 key 是颜色别名，value 是 UIColor / NSColor。即 <NSString *, NSDictionary<NSString *, Color *> *>
     3）以上两者混在一起
     */
    [self.rawHierarchyInfo.colorAlias enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id _Nonnull colorOrDict, BOOL * _Nonnull stop) {
        if ([colorOrDict isKindOfClass:[NSColor class]]) {
            NSString *colorDesc = [((NSColor *)colorOrDict) rgbaString];
            if (colorDesc) {
                if (!colorToAliasMap[colorDesc]) {
                    colorToAliasMap[colorDesc] = [NSMutableArray array];
                }
                [colorToAliasMap[colorDesc] addObject:key];
            }
            
            [aliasColorItemsOrSections addObject:[LKSelectColorItem itemWithTitle:key color:(NSColor *)colorOrDict]];
            
        } else if ([colorOrDict isKindOfClass:[NSDictionary class]]) {
            LKSelectColorItemsSection *section = [LKSelectColorItemsSection new];
            section.title = key;
            NSMutableArray<LKSelectColorItem *> *aliasItems = [NSMutableArray array];
            
            [((NSDictionary *)colorOrDict) enumerateKeysAndObjectsUsingBlock:^(NSString *colorAliaName, NSColor *colorObj, BOOL * _Nonnull stop) {
                NSString *colorDesc = colorObj.rgbaString;
                if (colorDesc) {
                    if (!colorToAliasMap[colorDesc]) {
                        colorToAliasMap[colorDesc] = [NSMutableArray array];
                    }
                    [colorToAliasMap[colorDesc] addObject:colorAliaName];
                }
                
                [aliasItems addObject:[LKSelectColorItem itemWithTitle:colorAliaName color:colorObj]];
            }];
            
            if (aliasItems.count) {
                section.items = aliasItems;
                [aliasColorItemsOrSections addObject:section];
            }
            
        } else {
            NSAssert(NO, @"");
        }
    }];
    
    [aliasColorItemsOrSections sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 isKindOfClass:[LKSelectColorItem class]]) {
            if ([obj2 isKindOfClass:[LKSelectColorItem class]]) {
                return [((LKSelectColorItem *)obj1).title caseInsensitiveCompare:((LKSelectColorItem *)obj2).title];
            }
            if ([obj2 isKindOfClass:[LKSelectColorItemsSection class]]) {
                return NSOrderedAscending;
            }
        }
        if ([obj1 isKindOfClass:[LKSelectColorItemsSection class]]) {
            if ([obj2 isKindOfClass:[LKSelectColorItem class]]) {
                return NSOrderedDescending;
            }
            if ([obj2 isKindOfClass:[LKSelectColorItemsSection class]]) {
                return [((LKSelectColorItemsSection *)obj1).title caseInsensitiveCompare:((LKSelectColorItemsSection *)obj2).title];
            }
        }
        NSAssert(NO, @"");
        return NSOrderedAscending;
    }];
    
    self.colorToAliasMap = colorToAliasMap;
    self.selectColorMenu = [self _makeMenuWithAliasColorItemsOrSections:aliasColorItemsOrSections usingRGBAFormat:[LKPreferenceManager mainManager].rgbaFormat];
}

- (NSMenu *)_makeMenuWithAliasColorItemsOrSections:(NSArray *)AliasColorItemsOrSections usingRGBAFormat:(BOOL)rgbaFormat {
    NSMutableArray *menuModel = [NSMutableArray array];
    
    [menuModel addObject:[LKSelectColorItem itemWithTitle:@"nil" color:nil]];
    [menuModel addObject:[LKSelectColorItem itemWithTitle:@"clear color" color:LookinColorRGBAMake(0, 0, 0, 0)]];
    
    NSArray<NSColor *> *defaultColors = @[LookinColorMake(0, 0, 0),
                                          LookinColorMake(126, 126, 126),
                                          LookinColorMake(255, 255, 255),
                                          LookinColorRGBAMake(0, 166, 248, .5),
                                          LookinColorMake(253, 62, 0),
                                          LookinColorMake(105, 190, 0),
                                          LookinColorMake(254, 182, 2)];
    NSArray<LKSelectColorItem *> *defaultColorItems = [defaultColors lookin_map:^id(NSUInteger idx, NSColor *value) {
        LKSelectColorItem *item = [LKSelectColorItem new];
        item.color = value;
        if (value) {
            item.title = rgbaFormat ? [value rgbaString]: [value hexString];
        } else {
            item.title = @"nil";
        }
        return item;
    }];
    [menuModel addObjectsFromArray:defaultColorItems];
    
    NSUInteger defaultItemsCount = menuModel.count;
    
    if (AliasColorItemsOrSections) {
        [menuModel addObjectsFromArray:AliasColorItemsOrSections];
    }
    
    NSMenu *menu = [NSMenu new];
    [menuModel enumerateObjectsUsingBlock:^(id itemOrSection, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == defaultItemsCount) {
            [menu addItem:[NSMenuItem separatorItem]];
        }
        
        if ([itemOrSection isKindOfClass:[LKSelectColorItemsSection class]]) {
            LKSelectColorItemsSection *itemsSection = itemOrSection;
            
            NSMenuItem *menuItem = [NSMenuItem new];
            menuItem.image = [[NSImage alloc] initWithSize:NSMakeSize(1, 22)];
            [menu addItem:menuItem];
            menuItem.title = itemsSection.title;
            
            NSMenu *submenu = [NSMenu new];
            [itemsSection.items enumerateObjectsUsingBlock:^(LKSelectColorItem * _Nonnull subAliasItem, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMenuItem *subMenuItem = [self _menuItemFromColorItem:subAliasItem];
                [submenu addItem:subMenuItem];
            }];
            menuItem.submenu = submenu;
            
        } else if ([itemOrSection isKindOfClass:[LKSelectColorItem class]]) {
            NSMenuItem *menuItem = [self _menuItemFromColorItem:itemOrSection];
            [menu addItem:menuItem];
            
        } else {
            NSAssert(NO, @"");
        }
    }];
    
    return menu;
}

- (NSMenuItem *)_menuItemFromColorItem:(LKSelectColorItem *)item {
    NSImage *image = [LKColorIndicatorLayer imageWithColor:item.color shapeSize:NSMakeSize(20, 20) insets:NSEdgeInsetsMake(4, 5, 4, 6)];
    NSMenuItem *menuItem = [NSMenuItem new];
    menuItem.image = image;
    menuItem.title = item.title;
    menuItem.representedObject = item.color;
    return menuItem;
}

#pragma mark - Others

/// 子类实现该方法
- (LKPreferenceManager *)preferenceManager {
    NSAssert(NO, @"should implement by subclass");
    return nil;
}

- (void)dealloc {
    NSLog(@"%@ dealloc", self.class);
}

@end

@implementation LKHierarchyWithPreviewDataSource

- (instancetype)init {
    if (self = [super init]) {
        _itemDidChangeNoPreview = [RACSubject subject];
    }
    return self;
}

- (NSArray<LookinStaticDisplayItem *> *)staticFlatItems {
    NSAssert(NO, @"should implement by subclass");
    return nil;
}

@end
