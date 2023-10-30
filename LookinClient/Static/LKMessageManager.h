//
//  LKMessageManager.h
//  LookinClient
//
//  Created by likai.123 on 2023/10/30.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const LKMessage_Jobs;
extern NSString *const LKMessage_NewServerVersion;
extern NSString *const LKMessage_SwiftSubspec;

@interface LKMessageManager : NSObject

+ (instancetype)sharedInstance;

- (void)addMessage:(NSString *)message;

- (void)removeMessage:(NSString *)message;

- (NSArray<NSString *> *)queryMessages;

#if DEBUG
- (void)reset;
#endif

@end

NS_ASSUME_NONNULL_END
