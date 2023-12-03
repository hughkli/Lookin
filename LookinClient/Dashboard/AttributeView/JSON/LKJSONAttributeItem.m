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
        self.subItems = [NSMutableArray array];
    }
    return self;
}

@end
