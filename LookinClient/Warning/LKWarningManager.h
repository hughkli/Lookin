//
//  LKWarningManager.h
//  LookinClient
//
//  Created by LikaiMacStudioWork on 2024/3/28.
//  Copyright © 2024 hughkli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKWarningManager : NSObject

+ (instancetype)sharedInstance;

- (void)handleReceiveServerInfo:(NSDictionary *)info;

- (void)notifyMainWorkspaceDidAppear;

- (void)showWarningIfNeeded;


@end
