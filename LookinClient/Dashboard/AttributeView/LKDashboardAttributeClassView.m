//
//  LKDashboardAttributeClassView.m
//  Lookin
//
//  Created by Li Kai on 2019/6/14.
//  https://lookin.work
//

#import "LKDashboardAttributeClassView.h"

@implementation LKDashboardAttributeClassView

- (NSArray<NSString *> *)stringListWithAttribute:(LookinAttribute *)attribute {
    NSArray<NSArray<NSString *> *> *lists = attribute.value;
    return [lists lookin_map:^id(NSUInteger idx, NSArray<NSString *> *value) {
        return [value componentsJoinedByString:@"\n"];
    }];
}

@end
