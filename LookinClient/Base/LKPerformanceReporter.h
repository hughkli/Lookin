//
//  LKPerformanceReporter.h
//  LookinClient
//
//  Created by 李凯 on 2022/5/3.
//  Copyright © 2022 hughkli. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LKPerformanceReporter : NSObject

+ (instancetype)sharedInstance;

- (void)willStartReload;

- (void)didFetchHierarchy;

- (void)didComplete;

@end

NS_ASSUME_NONNULL_END
