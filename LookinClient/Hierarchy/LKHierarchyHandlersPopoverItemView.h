//
//  LKHierarchyHandlersPopoverItemView.h
//  Lookin
//
//  Created by Li Kai on 2019/8/11.
//  https://lookin.work
//

#import "LKBaseView.h"

@class LookinEventHandler;

@interface LKHierarchyHandlersPopoverItemView : LKBaseView

/// read 模式下的 editable 需要传入 NO
- (instancetype)initWithEventHandler:(LookinEventHandler *)handler editable:(BOOL)editable;

@property(nonatomic, assign) BOOL needTopBorder;

@end
