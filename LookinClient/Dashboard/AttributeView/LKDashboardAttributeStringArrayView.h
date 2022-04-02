//
//  LKDashboardAttributeStringArrayView.h
//  Lookin
//
//  Created by Li Kai on 2019/6/15.
//  https://lookin.work
//

#import "LKDashboardAttributeView.h"

@interface LKDashboardAttributeStringArrayView : LKDashboardAttributeView

/// 子类必须实现该方法
- (NSArray<NSString *> *)stringListWithAttribute:(LookinAttribute *)attribute;

@end
