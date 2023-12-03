//
//  LKJSONAttributeWindowController.m
//  LookinClient
//
//  Created by likai.123 on 2023/12/4.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "LKJSONAttributeWindowController.h"
#import "LKJSONAttributeViewController.h"
#import "LKWindow.h"

@interface LKJSONAttributeWindowController ()

@end

@implementation LKJSONAttributeWindowController

- (instancetype)init {
    LKWindow *window = [[LKWindow alloc] initWithContentRect:NSMakeRect(0, 0, 600, 320) styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskResizable|NSWindowStyleMaskFullSizeContentView backing:NSBackingStoreBuffered defer:YES];
    window.movableByWindowBackground = YES;
    window.titleVisibility = NSWindowTitleHidden;
    window.minSize = CGSizeMake(200, 200);
    [window center];
    
    if (self = [self initWithWindow:window]) {
        LKJSONAttributeViewController *vc = [LKJSONAttributeViewController new];
        window.contentView = vc.view;
        self.contentViewController = vc;
    }
    return self;
}

@end
