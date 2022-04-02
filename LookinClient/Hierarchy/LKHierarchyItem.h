//
//  LKHierarchyObject.h
//  Lookin
//
//  Created by Li Kai on 2019/4/29.
//  https://lookin.work
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LKHierarchyItemStatus) {
    LKHierarchyItemStatusNotExpandable,
    LKHierarchyItemStatusExpanded,
    LKHierarchyItemStatusCollapsed
};

@interface LKHierarchyItem : NSObject

@property(nonatomic, copy) NSArray<LKHierarchyItem *> *subItems;

@property(nonatomic, weak, readonly) LKHierarchyItem *superItem;

@property(nonatomic, assign) LKHierarchyItemStatus status;

@property(nonatomic, assign, readonly) NSUInteger indentation;

- (NSArray<LKHierarchyItem *> *)flatItems;

+ (NSArray<LKHierarchyItem *> *)flatItemsFromRootItems:(NSArray<LKHierarchyItem *> *)items;

@end
