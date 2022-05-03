//
//  LKPerformanceReporter.m
//  LookinClient
//
//  Created by 李凯 on 2022/5/3.
//  Copyright © 2022 hughkli. All rights reserved.
//

#import "LKPerformanceReporter.h"
@import AppCenter;
@import AppCenterAnalytics;


@interface LKPerformanceReporter ()

@property(nonatomic, assign) CFTimeInterval reloadStartTime;
@property(nonatomic, assign) CFTimeInterval hierarchyFetchedTime;

@end

@implementation LKPerformanceReporter

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LKPerformanceReporter *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (void)willStartReload {
    self.reloadStartTime = CACurrentMediaTime();
}

- (void)didFetchHierarchy {
    self.hierarchyFetchedTime = CACurrentMediaTime();
    
    NSString *desc = [self resolveDurationDescription:(CACurrentMediaTime() - self.reloadStartTime)];
    [MSACAnalytics trackEvent:@"Perf(FetchHierarchy)" withProperties:@{@"time":desc}];
}

- (void)didComplete {
    NSString *desc = [self resolveDurationDescription:(CACurrentMediaTime() - self.hierarchyFetchedTime)];
    [MSACAnalytics trackEvent:@"Perf(UpdateDetails)" withProperties:@{@"time":desc}];
    
    NSString *desc2 = [self resolveDurationDescription:(CACurrentMediaTime() - self.reloadStartTime)];
    [MSACAnalytics trackEvent:@"Perf(Reload)" withProperties:@{@"time":desc2}];
}

- (NSString *)resolveDurationDescription:(CFTimeInterval)duration {
    if (duration < 0.1) {
        return @"< 0.1s";
    }
    if (duration < 0.5) {
        return @"0.1s ~ 0.5s";
    }
    if (duration < 1.0) {
        return @"0.5s ~ 1.0s";
    }
    if (duration < 3.0) {
        return @"1s ~ 3s";
    }
    if (duration < 6.0) {
        return @"3s ~ 6s";
    }
    if (duration < 10.0) {
        return @"6s ~ 10s";
    }
    if (duration < 20.0) {
        return @"10s ~ 20s";
    }
    if (duration < 30.0) {
        return @"20s ~ 30s";
    }
    return @"> 30s";
}

@end
