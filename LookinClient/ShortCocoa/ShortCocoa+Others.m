//
//  ShortCocoa+Others.m
//  ShortCocoa
//
//  Copyright © 2018年 hughkli. All rights reserved.
//

#import "ShortCocoa+Others.h"
#import "ShortCocoa+Private.h"

@implementation ShortCocoa (Others)

- (ShortCocoa * (^)(ShortCocoaColor))textColor {
    return ^(ShortCocoaColor color) {
        id UI_or_NS_Color = [ShortCocoaHelper colorFromShortCocoaColor:color];
        if (self.cachedAttrString.length) {
            [self.cachedAttrString addAttribute:NSForegroundColorAttributeName value:UI_or_NS_Color range:NSMakeRange(0, self.cachedAttrString.length)];
            
        } else {
#if TARGET_OS_IPHONE
            UIColor *textColor = [ShortCocoaHelper colorFromShortCocoaColor:color];
            [self unpackClassA:[UIButton class] doA:^(UIButton * _Nonnull obj, BOOL *stop) {
                [obj setTitleColor:textColor forState:UIControlStateNormal];
            } classB:[UILabel class] doB:^(UILabel * _Nonnull obj, BOOL *stop) {
                [obj setTextColor:textColor];
            }];
#endif
        }
        return self;
    };
}

- (ShortCocoa * (^)(ShortCocoaFont))font {
    return ^(ShortCocoaFont value) {
        id UI_or_NS_Font = [ShortCocoaHelper fontFromShortCocoaFont:value];
        if (self.cachedAttrString.length) {
            [self.cachedAttrString addAttribute:NSFontAttributeName value:UI_or_NS_Font range:NSMakeRange(0, self.cachedAttrString.length)];
            
        } else {
#if TARGET_OS_IPHONE
            if (UI_or_NS_Font) {
                [self unpackClassA:[UIButton class] doA:^(UIButton * _Nonnull obj, BOOL *stop) {
                    obj.titleLabel.font = UI_or_NS_Font;
                } classB:[UILabel class] doB:^(UILabel * _Nonnull obj, BOOL *stop) {
                    obj.font = UI_or_NS_Font;
                }];
            }
#elif TARGET_OS_MAC
            
#endif
        }
        return self;
    };
}

- (NSArray *)array {
    id selfGet = self.get;
    if (!selfGet) {
        return nil;
    }
    if ([selfGet isKindOfClass:[NSArray class]]) {
        return selfGet;
    }
    return @[selfGet];
}

- (ShortCocoa *)textAlignLeft {
    self.textAlign(NSTextAlignmentLeft);
    return self;
}

- (ShortCocoa *)textAlignCenter {
    self.textAlign(NSTextAlignmentCenter);
    return self;
}

- (ShortCocoa *)textAlignRight {
    self.textAlign(NSTextAlignmentRight);
    return self;
}

- (ShortCocoa * (^)(NSTextAlignment alignment))textAlign {
    return ^(NSTextAlignment alignment) {
        if (self.cachedAttrString.length) {
            NSMutableParagraphStyle *paraStyle = [ShortCocoaHelper paragraphStyleForAttributedString:self.cachedAttrString];
            paraStyle.alignment = alignment;
            [self.cachedAttrString addAttribute:NSParagraphStyleAttributeName value:paraStyle.copy range:NSMakeRange(0, self.cachedAttrString.length)];
        } else {
#if TARGET_OS_IPHONE
            [self unpackClassA:[UIButton class] doA:^(UIButton * _Nonnull obj, BOOL *stop) {
                obj.titleLabel.textAlignment = alignment;
            } classB:[UILabel class] doB:^(UILabel * _Nonnull obj, BOOL *stop) {
                obj.textAlignment = alignment;
            }];
#endif
        }
        return self;
    };
}

- (ShortCocoa * (^)(NSLineBreakMode))lineBreakMode {
    return ^(NSLineBreakMode mode) {
        if (self.cachedAttrString.length) {
            NSMutableParagraphStyle *paraStyle = [ShortCocoaHelper paragraphStyleForAttributedString:self.cachedAttrString];
            paraStyle.lineBreakMode = mode;
            [self.cachedAttrString addAttribute:NSParagraphStyleAttributeName value:paraStyle.copy range:NSMakeRange(0, self.cachedAttrString.length)];
        } else {
#if TARGET_OS_IPHONE
            [self unpackClassA:[UIButton class] doA:^(UIButton * _Nonnull obj, BOOL *stop) {
                obj.titleLabel.lineBreakMode = mode;
            } classB:[UILabel class] doB:^(UILabel * _Nonnull obj, BOOL *stop) {
                obj.lineBreakMode = mode;
            }];
#endif
        }
        return self;
    };
}

@end
