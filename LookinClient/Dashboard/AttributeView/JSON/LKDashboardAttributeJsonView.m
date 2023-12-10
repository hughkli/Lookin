//
//  LKDashboardAttributeJsonView.m
//  LookinClient
//
//  Created by likai.123 on 2023/11/30.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "LKDashboardAttributeJsonView.h"
#import "LKNavigationManager.h"
#import "LKJSONAttributeContentView.h"
#import "LKDashboardViewController.h"

@interface LKDashboardAttributeJsonView ()

@property(nonatomic, strong) LKJSONAttributeContentView *contentView;

@end

@implementation LKDashboardAttributeJsonView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        //        self.layer.borderWidth = 1;
        //        self.layer.borderColor = [NSColor redColor].CGColor;
        self.layer.cornerRadius = DashboardCardControlCornerRadius;
        
        self.contentView = [[LKJSONAttributeContentView alloc] initWithBigFont:NO];
        @weakify(self);
        self.contentView.didReloadData = ^{
            @strongify(self);
            [self.dashboardViewController.view setNeedsLayout:YES];
        };
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.contentView).fullFrame;
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat height = [self.contentView queryContentHeight];
    limitedSize.height = height;
    return limitedSize;
}

- (void)renderWithAttribute {
    [super renderWithAttribute];
    NSString *json = self.attribute.value;
    if (![json isKindOfClass:[NSString class]]) {
        [self.contentView renderWithJSON:nil];
        NSAssert(NO, @"");
        return;
    }
    [self.contentView renderWithJSON:json];
}

- (void)showInNewWindow {
    NSString *json = self.attribute.value;
    if (![json isKindOfClass:[NSString class]]) {
        NSAssert(NO, @"");
        return;
    }

    [[LKNavigationManager sharedInstance] showJsonWindow:json];
}

@end
