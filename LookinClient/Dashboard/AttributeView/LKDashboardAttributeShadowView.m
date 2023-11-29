//
//  LKDashboardAttributeShadowView.m
//  LookinClient
//
//  Created by likai.123 on 2023/11/29.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "LKDashboardAttributeShadowView.h"
#import "LKColorIndicatorLayer.h"
#import "LKPreferenceManager.h"

@interface LKDashboardAttributeShadowView ()

@property(nonatomic, strong) LKBaseView *colorContainerView;
@property(nonatomic, strong) LKColorIndicatorLayer *colorIndicatorLayer;
@property(nonatomic, strong) LKLabel *colorDescLabel;

@end

@implementation LKDashboardAttributeShadowView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
//        self.layer.borderWidth = 1;
//        self.layer.borderColor = [NSColor redColor].CGColor;
        
        self.colorContainerView = [LKBaseView new];
        self.colorContainerView.layer.cornerRadius = DashboardCardControlCornerRadius;
        self.colorContainerView.backgroundColorName = @"DashboardCardValueBGColor";
        [self addSubview:self.colorContainerView];
        
        self.colorIndicatorLayer = [LKColorIndicatorLayer new];
        [self.colorContainerView.layer addSublayer:self.colorIndicatorLayer];
        
        self.colorDescLabel = [LKLabel new];
        self.colorDescLabel.textColor = [NSColor colorNamed:@"DashboardCardValueColor"];
        self.colorDescLabel.font = NSFontMake(13);
        [self.colorContainerView addSubview:self.colorDescLabel];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.colorContainerView).fullWidth.height(30).y(0);
    $(self.colorIndicatorLayer).width(16).height(16).x(8).verAlign;
    $(self.colorDescLabel).x(28).toRight(20).heightToFit.verAlign.offsetY(-1);
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat height = 30;
    limitedSize.height = height;
    return limitedSize;
}

- (void)renderWithAttribute {
    if (!self.attribute) {
        NSAssert(NO, @"");
        return;
    }
    NSDictionary *info = self.attribute.value;
    if (![info isKindOfClass:[NSDictionary class]]) {
        NSAssert(NO, @"");
        return;
    }
    // 可能为 nil
    NSColor *color = [NSColor lk_colorFromRGBAComponents:info[@"color"]];
    
    NSValue *offsetValue = info[@"offset"];
    if (![offsetValue isKindOfClass:[NSValue class]]) {
        NSAssert(NO, @"");
        return;
    }
    CGSize offset = [offsetValue sizeValue];
    
    NSNumber *opacityNumber = info[@"opacity"];
    if (![opacityNumber isKindOfClass:[NSNumber class]]) {
        NSAssert(NO, @"");
        return;
    }
    CGFloat opacity = [opacityNumber doubleValue];
    
    self.colorIndicatorLayer.color = color;
    if (color) {
        self.colorDescLabel.stringValue = [LKPreferenceManager mainManager].rgbaFormat ? color.rgbaString : color.hexString;
    } else {
        self.colorDescLabel.stringValue = @"nil";
    }
}

@end
