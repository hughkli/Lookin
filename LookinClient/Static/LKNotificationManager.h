//
//  LKNotificationManager.h
//  LookinClient
//
//  Created by likai.123 on 2023/10/30.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LKNotificationManager : NSObject

+ (instancetype)sharedInstance;

- (void)markHasShowedJobs;

- (BOOL)queryIfShouldShowJobs;

#if DEBUG
- (void)reset;
#endif

@end

NS_ASSUME_NONNULL_END
