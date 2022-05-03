//
//  LKWindowToolbarAppView.h
//  LookinClient
//
//  Created by 李凯 on 2020/6/14.
//  Copyright © 2020 hughkli. All rights reserved.
//

#import <AppKit/AppKit.h>

@class LookinAppInfo;

@interface LKWindowToolbarAppButton : NSButton

@property(nonatomic, strong) LookinAppInfo *appInfo;

@end
