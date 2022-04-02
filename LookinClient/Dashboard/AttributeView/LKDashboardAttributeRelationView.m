//
//  LKDashboardAttributeRelationView.m
//  Lookin
//
//  Created by Li Kai on 2019/6/14.
//  https://lookin.work
//

#import "LKDashboardAttributeRelationView.h"

@implementation LKDashboardAttributeRelationView

- (NSArray<NSString *> *)stringListWithAttribute:(LookinAttribute *)attribute {
    return attribute.value;
}

@end
