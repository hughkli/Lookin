//
//  LKDashboardTextControlEditingFlag.m
//  LookinClient
//
//  Created by likaimacbookhome on 2024/3/3.
//  Copyright © 2024 hughkli. All rights reserved.
//

#import "LKDashboardTextControlEditingFlag.h"

@implementation LKDashboardTextControlEditingFlag

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LKDashboardTextControlEditingFlag *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

@end
