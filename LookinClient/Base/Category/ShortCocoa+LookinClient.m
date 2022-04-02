//
//  ShortCocoa+LookinClient.m
//  Lookin
//
//  Created by Li Kai on 2018/12/8.
//  https://lookin.work
//

#import "ShortCocoa+LookinClient.h"
#import <objc/runtime.h>
#import "ShortCocoa+Private.h"
#import "LKBaseView.h"

@implementation ShortCocoa (Lookin)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method oriMethod = class_getInstanceMethod([self class], @selector(sizeToFit));
        Method newMethod = class_getInstanceMethod([self class], @selector(lookin_sizeToFit));
        method_exchangeImplementations(oriMethod, newMethod);
        
        Method oriMethod1 = class_getInstanceMethod([self class], @selector(heightToFit));
        Method newMethod1 = class_getInstanceMethod([self class], @selector(lookin_heightToFit));
        method_exchangeImplementations(oriMethod1, newMethod1);
    });
}

- (ShortCocoa *)lookin_sizeToFit {
    [self unpackClassA:[LKBaseView class] doA:^(LKBaseView * _Nonnull view, BOOL * _Nonnull stop) {
        NSSize size = [view sizeThatFits:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
        NSRect rect = view.frame;
        rect.size = size;
        view.frame = rect;
    } classB:[NSControl class] doB:^(NSControl * _Nonnull control, BOOL * _Nonnull stop) {
        NSSize size = [control sizeThatFits:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
        if (isnan(size.width)) {
            size.width = 0;
        }
        if (isnan(size.height)) {
            size.height = 0;
        }
        NSRect rect = control.frame;
        rect.size = size;
        control.frame = rect;
    }];
    return self;
}

- (ShortCocoa *)lookin_heightToFit {
    [self unpackClassA:[LKBaseView class] doA:^(LKBaseView * _Nonnull view, BOOL * _Nonnull stop) {
        CGFloat limitedWidth = CGRectGetWidth(view.bounds);
        CGFloat height = [view sizeThatFits:NSMakeSize(limitedWidth, CGFLOAT_MAX)].height;
        
        CGRect rect = view.frame;
        rect.size.height = height;
        view.frame = rect;
    } classB:[NSControl class] doB:^(NSControl * _Nonnull control, BOOL * _Nonnull stop) {
        CGFloat limitedWidth = CGRectGetWidth(control.bounds);
        CGFloat height = [control sizeThatFits:NSMakeSize(limitedWidth, CGFLOAT_MAX)].height;
        
        CGRect rect = control.frame;
        rect.size.height = height;
        control.frame = rect;
    }];
    return self;
}

- (ShortCocoa * (^)(CGFloat))lk_maxWidth {
    return ^(CGFloat maxWidth) {
        if (isnan(maxWidth)) {
            NSAssert(NO, @"传入了 NaN");
            return self;
        }
        
        [self unpackClassA:[NSView class] doA:^(NSView *view, BOOL *stop) {
            CGRect rect = view.frame;
            if (rect.size.width > maxWidth) {
                rect.size.width = maxWidth;
                view.frame = rect;
            }
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            CGRect rect = layer.frame;
            if (rect.size.width > maxWidth) {
                rect.size.width = maxWidth;
                layer.frame = rect;
            }
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))lk_minWidth {
    return ^(CGFloat minWidth) {
        if (isnan(minWidth)) {
            NSAssert(NO, @"传入了 NaN");
            return self;
        }
        
        [self unpackClassA:[NSView class] doA:^(NSView *view, BOOL *stop) {
            CGRect rect = view.frame;
            if (rect.size.width < minWidth) {
                rect.size.width = minWidth;
                view.frame = rect;
            }
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            CGRect rect = layer.frame;
            if (rect.size.width < minWidth) {
                rect.size.width = minWidth;
                layer.frame = rect;
            }
        }];
        return self;
    };
}

@end
