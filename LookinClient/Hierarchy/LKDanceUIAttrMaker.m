//
//  LKDanceUIAttrMaker.m
//  LookinClient
//
//  Created by likai.123 on 2023/12/21.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "LKDanceUIAttrMaker.h"
#import "LookinAttributesGroup.h"
#import "LookinAttributesSection.h"
#import "LookinAttribute.h"

@implementation LKDanceUIAttrMaker

+ (void)makeDanceUIJumpAttribute:(LookinDisplayItem *)item danceSource:(NSString *)source {
    NSString *className = [self getClassFromSource:source];
    if (!className) {
        return;
    }
    
    __block BOOL alreadyHas = NO;
    [item.attributesGroupList enumerateObjectsUsingBlock:^(LookinAttributesGroup * _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([group.identifier isEqualToString:LookinAttrGroup_Class]) {
            alreadyHas = YES;
            *stop = YES;
        }
    }];
    if (alreadyHas) {
//        NSAssert(NO, @"");
        return;
    }
    LookinAttribute *attr = [LookinAttribute new];
    attr.identifier = LookinAttr_Class_Class_Class;
    attr.attrType = LookinAttrTypeCustomObj;
    attr.value = @[@[className]];
    
    LookinAttributesSection *sec = [LookinAttributesSection new];
    sec.identifier = LookinAttrSec_Class_Class;
    sec.attributes = @[attr];
    
    LookinAttributesGroup *group = [LookinAttributesGroup new];
    group.identifier = LookinAttrGroup_Class;
    group.attrSections = @[sec];
    
    if (item.attributesGroupList) {
        item.attributesGroupList = [item.attributesGroupList arrayByAddingObject:group];
    } else {
        item.attributesGroupList = @[group];
    }
}

+ (NSString *)getClassFromSource:(NSString *)json {
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (error) {
        NSAssert(NO, @"");
        return nil;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        NSAssert(NO, @"");
        return nil;
    }
    NSString *type = dict[@"type"];
    if (!type) {
        NSAssert(NO, @"");
        return nil;
    }
    return type;
}

@end
