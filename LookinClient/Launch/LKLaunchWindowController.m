//
//  LKLaunchWindowController.m
//  Lookin
//
//  Created by Li Kai on 2018/11/3.
//  https://lookin.work
//

#import "LKLaunchWindowController.h"
#import "LKLaunchViewController.h"
#import "LKWindow.h"

@interface LKLaunchWindowController ()

@end

@implementation LKLaunchWindowController

- (instancetype)init {
    LKWindow *window = [[LKWindow alloc] initWithContentRect:NSMakeRect(0, 0, 252, 400) styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskFullSizeContentView backing:NSBackingStoreBuffered defer:YES];
    window.backgroundColor = [NSColor clearColor];
    window.titlebarAppearsTransparent = YES;
    window.movableByWindowBackground = YES;
    [window center];

    if (self = [self initWithWindow:window]) {
        _launchViewController = [[LKLaunchViewController alloc] initWithWindow:window];
        window.contentView = self.launchViewController.view;
        self.contentViewController = self.launchViewController;
    }
    return self;
}

@end
