//
//  LKDashboardAttributeJsonView.m
//  LookinClient
//
//  Created by likai.123 on 2023/11/30.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "LKDashboardAttributeJsonView.h"
#import "LKNavigationManager.h"

@interface LKDashboardAttributeJsonView ()

@property(nonatomic, strong) LKLabel *textLabel;

@end

@implementation LKDashboardAttributeJsonView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        //        self.layer.borderWidth = 1;
        //        self.layer.borderColor = [NSColor redColor].CGColor;
        self.layer.cornerRadius = DashboardCardControlCornerRadius;
        
        self.textLabel = [LKLabel new];
        self.textLabel.stringValue = @"点击以展示…";
        self.textLabel.textColor = [NSColor colorNamed:@"DashboardCardValueColor"];
        self.textLabel.maximumNumberOfLines = 0;
        self.textLabel.font = NSFontMake(12);
        [self addSubview:self.textLabel];
        
        self.backgroundColorName = @"DashboardCardValueBGColor";
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.textLabel).x(5).toRight(20).heightToFit.verAlign;
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat height = 27;
    limitedSize.height = height;
    return limitedSize;
}

- (void)renderWithAttribute {
    [super renderWithAttribute];
}

- (void)mouseDown:(NSEvent *)event {
    NSString *json = self.attribute.value;
    if (![json isKindOfClass:[NSString class]]) {
        NSAssert(NO, @"");
        return;
    }
    
    [[LKNavigationManager sharedInstance] showJsonWindow:json];
}

@end
