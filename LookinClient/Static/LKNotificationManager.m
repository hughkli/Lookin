//
//  LKNotificationManager.m
//  LookinClient
//
//  Created by likai.123 on 2023/10/30.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "LKNotificationManager.h"

@implementation LKNotificationManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LKNotificationManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (void)markHasShowedJobs {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LKNotificationManager_HasReadJobs"];
}

- (BOOL)queryIfShouldShowJobs {
    bool hasRead = [[NSUserDefaults standardUserDefaults] boolForKey:@"LKNotificationManager_HasReadJobs"];
    return !hasRead;
}

#if DEBUG
- (void)reset {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LKNotificationManager_HasReadJobs"];
}
#endif

@end
