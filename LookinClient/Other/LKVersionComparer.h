//
//  LKVersionComparer.h
//  LookinClient
//
//  Created by likai.123 on 2023/10/30.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LKVersionComparer : NSObject

/// latest 指网上最高的 LookinServer 版本号，user 指用户真实的版本号。如果用户版本号低于最高版本号，则该方法返回 NO，此时应该提示用户升级。
+ (BOOL)compareWithNewest:(NSString *)latest user:(NSString *)user;

@end

NS_ASSUME_NONNULL_END
