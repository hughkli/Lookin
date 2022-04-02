//
//  LKOutlineItem.h
//  Lookin
//
//  Created by Li Kai on 2019/5/28.
//  https://lookin.work
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LKOutlineItemStatus) {
    LKOutlineItemStatusNotExpandable,
    LKOutlineItemStatusExpanded,
    LKOutlineItemStatusCollapsed
};

@interface LKOutlineItem : NSObject

@property(nonatomic, strong) NSArray<LKOutlineItem *> *subItems;

@property(nonatomic, assign) LKOutlineItemStatus status;

@property(nonatomic, copy) NSString *titleText;

@property(nonatomic, strong) NSImage *image;

@property(nonatomic, assign, readonly) NSUInteger indentation;

+ (NSArray<LKOutlineItem *> *)flatItemsFromRootItems:(NSArray<LKOutlineItem *> *)items;

@end
