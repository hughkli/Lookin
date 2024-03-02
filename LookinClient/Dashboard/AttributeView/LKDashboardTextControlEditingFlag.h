//
//  LKDashboardTextControlEditingFlag.h
//  LookinClient
//
//  Created by likaimacbookhome on 2024/3/3.
//  Copyright © 2024 hughkli. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LKDashboardTextControlEditingFlag : NSObject

+ (instancetype)sharedInstance;

@property(nonatomic, assign) BOOL shouldIgnoreTextEditingChangeEvent;

@end

NS_ASSUME_NONNULL_END
