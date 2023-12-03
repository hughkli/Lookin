//
//  LKJSONAttributeItem.m
//  LookinClient
//
//  Created by likai.123 on 2023/12/4.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "LKJSONAttributeItem.h"

@implementation LKJSONAttributeItem

- (instancetype)init {
    self = [super init];
    if (self) {
        self.expanded = YES;
        self.subItems = [NSMutableArray array];
    }
    return self;
}

- (NSArray<LKJSONAttributeItem *> *)flatItems {
    NSMutableArray<LKJSONAttributeItem *> *array = [NSMutableArray array];
    
    [array addObject:self];
    
    if (self.expanded) {
        [self.subItems enumerateObjectsUsingBlock:^(LKJSONAttributeItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.indentation = self.indentation + 1;
            [array addObjectsFromArray:[obj flatItems]];
        }];
    }
    
    return array;
}

@end
