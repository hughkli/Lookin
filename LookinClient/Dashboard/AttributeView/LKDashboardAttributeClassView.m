//
//  LKDashboardAttributeClassView.m
//  Lookin
//
//  Created by Li Kai on 2019/6/14.
//  https://lookin.work
//

#import "LKDashboardAttributeClassView.h"
#import "Lookin-Swift.h"

@implementation LKDashboardAttributeClassView

- (NSArray<NSString *> *)stringListWithAttribute:(LookinAttribute *)attribute {
    NSArray<NSArray<NSString *> *> *lists = attribute.value;
    NSArray<NSString *> *result = [lists lookin_map:^id(NSUInteger idx, NSArray<NSString *> *rawClassList) {
        NSArray<NSString *> *demangled = [rawClassList lookin_map:^id(NSUInteger idx, NSString *rawClass) {
            return [LKSwiftDemangler completedParseWithInput:rawClass];
        }];
        return [demangled componentsJoinedByString:@"\n"];
    }];
    return result;
}

@end
