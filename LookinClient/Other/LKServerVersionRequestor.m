//
// LKServerVersionRequestor.m
// LookinClient
//
// Created by likai.123 on 2023/10/30.
// Copyright © 2023 hughkli. All rights reserved.
//

#import "LKServerVersionRequestor.h"

@implementation LKServerVersionRequestor

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static LKServerVersionRequestor *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self shared];
}

- (void)preload {
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyyMMdd";
    // avoid network cache
    NSString *dateString = [dateFormatter stringFromDate:now];
    
    NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://lookin.work/queryversion.json?time=%@", dateString]];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:jsonURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            return;
        }
        
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            NSLog(@"JSON Error: %@", jsonError);
            return;
        }
        NSString *version = json[@"currentVersion"];
        if (!version) {
            NSLog(@"No currentVersion");
            return;
        }
        dispatch_async(dispatch_get_main_queue(),  ^{
            [self handleReceiveVersion:version];
        });
    }];
    [dataTask resume];
}

- (void)handleReceiveVersion:(NSString *)version {
    NSLog(@"Receive version: %@", version);
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"LKServerVersionRequestor_version"];
    [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:@"LKServerVersionRequestor_time"];
}

- (NSString *)query {
    NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:@"LKServerVersionRequestor_version"];
    double time = [[NSUserDefaults standardUserDefaults] doubleForKey:@"LKServerVersionRequestor_time"];
    if (time <= 0 || version.length == 0) {
        return nil;
    }
    double timeDiff = [[NSDate date] timeIntervalSince1970] - time;
    if (timeDiff >= 3600 * 24 * 3) {
        // 3 day
        return nil;
    }
    return version;
}

@end
