//
//  LKHierarchyHandlersPopoverController.h
//  Lookin
//
//  Created by Li Kai on 2019/8/11.
//  https://lookin.work
//

#import "LKBaseViewController.h"

@class LookinDisplayItem;

@interface LKHierarchyHandlersPopoverController : LKBaseViewController

- (instancetype)initWithDisplayItem:(LookinDisplayItem *)item editable:(BOOL)editable;

- (NSSize)neededSize;

@end
