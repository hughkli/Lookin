//
//  LKBaseViewController.m
//  Lookin
//
//  Created by Li Kai on 2018/8/28.
//  https://lookin.work
//

#import "LKBaseViewController.h"
#import "LKWindowController.h"
#import "LKTipsView.h"
#import "LKAppsManager.h"
#import "LKNavigationManager.h"
#import "LKStaticWindowController.h"

@interface LKBaseViewController ()

@end

@implementation LKBaseViewController

- (instancetype)initWithContainerView:(NSView *)view {
    if (self = [super initWithNibName:nil bundle:nil]) {
        if (!view) {
            view = [self makeContainerView];
        }
        self.view = view;
    }
    return self;
}

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithContainerView:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    return [self initWithContainerView:nil];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    _isViewAppeared = YES;
}

- (void)setView:(NSView *)view {
    [super setView:view];
    if (self.shouldShowConnectionTips) {
        _connectionTipsView = [LKRedTipsView new];
        self.connectionTipsView.hidden = YES;
        self.connectionTipsView.title = NSLocalizedString(@"Reconnecting…", nil);
        self.connectionTipsView.buttonText = NSLocalizedString(@"Change App", nil);
        self.connectionTipsView.target = self;
        self.connectionTipsView.clickAction = @selector(_handleClickReconnectTips);
        
        @weakify(self);
        [RACObserve([LKAppsManager sharedInstance], inspectingApp) subscribeNext:^(LKInspectableApp *app) {
            @strongify(self);
            if (app) {
                [self.connectionTipsView endAnimation];
                self.connectionTipsView.hidden = YES;
                [self.connectionTipsView setImageByDeviceType:app.appInfo.deviceType];
                
            } else {
                if (!self.connectionTipsView.superview) {
                    [view addSubview:self.connectionTipsView];
                }
                self.connectionTipsView.hidden = NO;
                [self.connectionTipsView startAnimation];
                
                [self.view setNeedsLayout:YES];
            }
        }];
    }
}

- (void)viewDidLayout {
    [super viewDidLayout];
    if (self.connectionTipsView.isVisible) {
        CGFloat windowTitleHeight = [LKNavigationManager sharedInstance].windowTitleBarHeight;
        $(self.connectionTipsView).sizeToFit.horAlign.y(windowTitleHeight + 10);
    }
}

- (void)_handleClickReconnectTips {
    NSWindowController *wc = self.view.window.windowController;
    LKStaticWindowController *staticWc = [LKNavigationManager sharedInstance].staticWindowController;
    
    if (wc == staticWc) {
        [staticWc popupAllInspectableAppsWithSource:MenuPopoverAppsListControllerEventSourceNoConnectionTips];

    } else if (staticWc) {
        [staticWc showWindow:self];
        [staticWc popupAllInspectableAppsWithSource:MenuPopoverAppsListControllerEventSourceNoConnectionTips];
        
    } else {
        NSAssert(NO, @"");
    }
}

- (void)dealloc {
    NSLog(@"%@ dealloc", self.class);
}

@end

@implementation LKBaseViewController (NSSubclassingHooks)

- (NSView *)makeContainerView {
    return [[LKBaseView alloc] init];
}

- (BOOL)shouldShowConnectionTips {
    return NO;
}

@end
