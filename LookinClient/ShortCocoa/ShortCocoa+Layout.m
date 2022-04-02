//
//  ShortCocoa+Layout.m
//  ShortCocoa
//
//  Copyright © 2018年 hughkli. All rights reserved.
//

#import "ShortCocoa+Layout.h"
#import "ShortCocoa+Private.h"

#if TARGET_OS_IPHONE
    #define NS_UI_View UIView
#elif TARGET_OS_MAC
    #define NS_UI_View NSView
#endif

@implementation ShortCocoa (Layout)

#pragma mark - 基础方法

- (ShortCocoa *)sizeToFit {
#if TARGET_OS_IPHONE
    [self unpack:[UIView class] do:^(UIView *view, BOOL *stop) {
        [view sizeToFit];
    }];
#elif TARGET_OS_MAC
    [self unpack:[NSControl class] do:^(NSControl *control, BOOL *stop) {
        [control sizeToFit];
    }];
#endif
    return self;
}

- (ShortCocoa * (^)(CGFloat))width {
    return ^(CGFloat value) {
        if (isnan(value)) {
            NSAssert(NO, @"传入了 NaN");
            value = 0;
        }
        
        [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
            CGRect rect = view.frame;
            rect.size.width = CGFloatSnapToPixel(value);
            view.frame = rect;
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            CGRect rect = layer.frame;
            rect.size.width = CGFloatSnapToPixel(value);
            layer.frame = rect;
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))height {
    return ^(CGFloat value) {
        if (isnan(value)) {
            NSAssert(NO, @"传入了 NaN");
            value = 0;
        }
        
        [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
            CGRect rect = view.frame;
            rect.size.height = CGFloatSnapToPixel(value);
            view.frame = rect;
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            CGRect rect = layer.frame;
            rect.size.height = CGFloatSnapToPixel(value);
            layer.frame = rect;
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGSize))size {
    return ^(CGSize value) {
        return self.width(value.width).height(value.height);
    };
}

- (ShortCocoa * (^)(CGRect))frame {
    return ^(CGRect value) {
        return self.origin(value.origin).size(value.size);
    };
}

- (ShortCocoa * (^)(CGFloat))x {
    return ^(CGFloat value) {
        if (isnan(value)) {
            NSAssert(NO, @"传入了 NaN");
            value = 0;
        }
        [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
            CGRect rect = view.frame;
            rect.origin.x = CGFloatSnapToPixel(value);
            view.frame = rect;
            
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            CGRect rect = layer.frame;
            rect.origin.x = CGFloatSnapToPixel(value);
            layer.frame = rect;
        }];
        
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))y {
    return ^(CGFloat value) {
        if (isnan(value)) {
            NSAssert(NO, @"传入了 NaN");
            value = 0;
        }
        [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
            CGRect rect = view.frame;
            rect.origin.y = CGFloatSnapToPixel(value);
            view.frame = rect;
            
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            CGRect rect = layer.frame;
            rect.origin.y = CGFloatSnapToPixel(value);
            layer.frame = rect;
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGPoint))origin {
    return ^(CGPoint value) {
        return self.x(value.x).y(value.y);
    };
}

- (ShortCocoa * (^)(CGFloat, CGFloat))offset {
    return ^(CGFloat x, CGFloat y) {
        if (isnan(x)) {
            NSAssert(NO, @"传入了 NaN");
            x = 0;
        }
        if (isnan(y)) {
            NSAssert(NO, @"传入了 NaN");
            y = 0;
        }
        [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
            CGRect rect = view.frame;
            rect.origin.x = CGFloatSnapToPixel(CGRectGetMinX(view.frame) + x);
            rect.origin.y = CGFloatSnapToPixel(CGRectGetMinY(view.frame) + y);
            view.frame = rect;
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            CGRect rect = layer.frame;
            rect.origin.x = CGFloatSnapToPixel(CGRectGetMinX(layer.frame) + x);
            rect.origin.y = CGFloatSnapToPixel(CGRectGetMinY(layer.frame) + y);
            layer.frame = rect;
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))midX {
    return ^(CGFloat value) {
        if (isnan(value)) {
            NSAssert(NO, @"传入了 NaN");
            value = 0;
        }
        [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
            CGFloat width = CGRectGetWidth(view.bounds);
            ShortCocoaMake(view).x(value - width / 2);
            
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            CGFloat width = CGRectGetWidth(layer.bounds);
            ShortCocoaMake(layer).x(value - width / 2);
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))maxX {
    return ^(CGFloat value) {
        if (isnan(value)) {
            NSAssert(NO, @"传入了 NaN");
            value = 0;
        }
        [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
            CGFloat width = CGRectGetWidth(view.bounds);
            ShortCocoaMake(view).x(value - width);
            
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            CGFloat width = CGRectGetWidth(layer.bounds);
            ShortCocoaMake(layer).x(value - width);
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))midY {
    return ^(CGFloat value) {
        if (isnan(value)) {
            NSAssert(NO, @"传入了 NaN");
            value = 0;
        }
        [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
            CGFloat height = CGRectGetHeight(view.bounds);
            ShortCocoaMake(view).y(value - height / 2);
            
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            CGFloat height = CGRectGetHeight(layer.bounds);
            ShortCocoaMake(layer).y(value - height / 2);
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))maxY {
    return ^(CGFloat value) {
        if (isnan(value)) {
            NSAssert(NO, @"传入了 NaN");
            value = 0;
        }
        [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
            CGFloat height = CGRectGetHeight(view.bounds);
            ShortCocoaMake(view).y(value - height);
            
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            CGFloat height = CGRectGetHeight(layer.bounds);
            ShortCocoaMake(layer).y(value - height);
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))right {
    return ^(CGFloat value) {
        if (isnan(value)) {
            NSAssert(NO, @"传入了 NaN");
            value = 0;
        }
        [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
            if (view.superview) {
                CGFloat superWidth = CGRectGetWidth(view.superview.bounds);
                ShortCocoaMake(view).maxX(superWidth - value);
            } else {
                NSAssert(NO, @"必须存在 superview 才可使用该方法");
            }
            
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            if (layer.superlayer) {
                CGFloat superWidth = CGRectGetWidth(layer.superlayer.bounds);
                ShortCocoaMake(layer).maxX(superWidth - value);
            } else {
                NSAssert(NO, @"必须存在 superlayer 才可使用该方法");
            }
        }];
        
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))bottom {
    return ^(CGFloat value) {
        if (isnan(value)) {
            NSAssert(NO, @"传入了 NaN");
            value = 0;
        }
#if TARGET_OS_IPHONE
        [self unpackClassA:[UIView class] doA:^(UIView *view, BOOL *stop) {
            if (view.superview) {
                CGFloat superHeight = CGRectGetHeight(view.superview.bounds);
                ShortCocoaMake(view).maxY(superHeight - value);
            } else {
                NSAssert(NO, @"必须存在 superview 才可使用该方法");
            }
#elif TARGET_OS_MAC
        [self unpackClassA:[NSView class] doA:^(NSView *view, BOOL *stop) {
            if (view.superview) {
                CGFloat superHeight = view.superview.bounds.size.height;
                if (view.superview.isFlipped) {
                    ShortCocoaMake(view).maxY(superHeight - value);
                } else {
                    ShortCocoaMake(view).y(value);
                }
            } else {
                NSAssert(NO, @"必须存在 superview 才可使用该方法");
            }
#endif
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            if (layer.superlayer) {
                if (layer.superlayer.contentsAreFlipped) {
                    CGFloat superHeight = CGRectGetHeight(layer.superlayer.bounds);
                    ShortCocoaMake(layer).maxY(superHeight - value);
                } else {
                    ShortCocoaMake(layer).y(value);
                }
            } else {
                NSAssert(NO, @"必须存在 superlayer 才可使用该方法");
            }
        }];
        return self;
    };
}

- (ShortCocoa *)horAlign {
    [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
        if (view.superview) {
            CGFloat superWidth = CGRectGetWidth(view.superview.bounds);
            ShortCocoaMake(view).midX(superWidth / 2);
        } else {
            NSAssert(NO, @"必须存在 superview 才可使用该方法");
        }
    } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
        if (layer.superlayer) {
            CGFloat superWidth = CGRectGetWidth(layer.superlayer.bounds);
            ShortCocoaMake(layer).midX(superWidth / 2);
        } else {
            NSAssert(NO, @"必须存在 superlayer 才可使用该方法");
        }
    }];
    return self;
}

- (ShortCocoa *)verAlign {
    [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
        if (view.superview) {
            CGFloat superHeight = CGRectGetHeight(view.superview.bounds);
            ShortCocoaMake(view).midY(superHeight / 2);
        } else {
            NSAssert(NO, @"必须存在 superview 才可使用该方法");
        }
        
    } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
        if (layer.superlayer) {
            CGFloat superHeight = CGRectGetHeight(layer.superlayer.bounds);
            ShortCocoaMake(layer).midY(superHeight / 2);
        } else {
            NSAssert(NO, @"必须存在 superlayer 才可使用该方法");
        }
    }];
    return self;
}

- (ShortCocoa *)centerAlign {
    return self.verAlign.horAlign;
}

- (ShortCocoa *)fullWidth {
    self.x(0).toRight(0);
    return self;
}

- (ShortCocoa *)fullHeight {
    [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
        if (view.superview) {
            CGFloat superHeight = CGRectGetHeight(view.superview.bounds);
            ShortCocoaMake(view).height(superHeight).y(0);
        } else {
            NSAssert(NO, @"必须存在 superview 才可使用该方法");
        }
    } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
        if (layer.superlayer) {
            CGFloat superHeight = CGRectGetHeight(layer.superlayer.bounds);
            ShortCocoaMake(layer).height(superHeight).y(0);
        } else {
            NSAssert(NO, @"必须存在 superlayer 才可使用该方法");
        }
    }];
    return self;
}

- (ShortCocoa *)fullFrame {
    return self.fullWidth.fullHeight;
}

- (ShortCocoa * (^)(CGFloat))offsetX {
    return ^(CGFloat x) {
        self.offset(x, 0);
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))offsetY {
    return ^(CGFloat y) {
        self.offset(0, y);
        return self;
    };
}

#pragma mark - Group Set 系列

- (ShortCocoa * (^)(CGFloat))groupX {
    return ^(CGFloat value) {
        self.offsetX(value - self.$groupX);
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))groupMidX {
    return ^(CGFloat value) {
        self.offsetX(value - self.$groupMidX);
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))groupMaxX {
    return ^(CGFloat value) {
        self.offsetX(value - self.$groupMaxX);
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))groupY {
    return ^(CGFloat value) {
        self.offsetY(value - self.$groupY);
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))groupMidY {
    return ^(CGFloat value) {
        self.offsetY(value - self.$groupMidY);
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))groupMaxY {
    return ^(CGFloat value) {
        self.offsetY(value - self.$groupMaxY);
        return self;
    };
}

- (ShortCocoa * (^)(CGPoint))groupOrigin {
    return ^(CGPoint value) {
        self.offset(value.x - self.$groupX, value.y - self.$groupY);
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))groupRight {
    return ^(CGFloat value) {
        if (![self allPackedViewsAndLayersAreInTheSameCoordinate]) {
            return self;
        }
        
        __block CGFloat superWidth = 0;
        [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
            superWidth = CGRectGetWidth(view.superview.bounds);
            *stop = YES;
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            superWidth = CGRectGetWidth(layer.superlayer.bounds);
            *stop = YES;
        }];
        self.groupMaxX(superWidth - value);
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))groupBottom {
    return ^(CGFloat value) {
#if TARGET_OS_IPHONE
        CALayer *superlayer;
        if (![self allPackedViewsAndLayersAreInTheSameCoordinateWithSuperlayer:&superlayer superview:nil]) {
            return self;
        }
        if (superlayer.contentsAreFlipped) {
            self.groupMaxY(CGRectGetHeight(superlayer.bounds) - value);
        } else {
            self.groupY(value);
        }
        return self;
#elif TARGET_OS_MAC
        CALayer *superlayer;
        NSView *superview;
        if (![self allPackedViewsAndLayersAreInTheSameCoordinateWithSuperlayer:&superlayer superview:&superview]) {
            return self;
        }
        if (superlayer) {
            if (superlayer.contentsAreFlipped) {
                self.groupMaxY(CGRectGetHeight(superlayer.bounds) - value);
            } else {
                self.groupY(value);
            }
        } else if (superview) {
            if (superview.isFlipped) {
                self.groupMaxY(CGRectGetHeight(superlayer.bounds) - value);
            } else {
                self.groupY(value);
            }
        }
        return self;
#endif
    };
}

- (ShortCocoa *)groupHorAlign {
    if (![self allPackedViewsAndLayersAreInTheSameCoordinate]) {
        return self;
    }
    
    __block CGFloat superWidth = 0;
    [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
        superWidth = CGRectGetWidth(view.superview.bounds);
        *stop = YES;
    } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
        superWidth = CGRectGetWidth(layer.superlayer.bounds);
        *stop = YES;
    }];
    self.groupMidX(superWidth / 2);
    return self;
}

- (ShortCocoa *)groupVerAlign {
    if (![self allPackedViewsAndLayersAreInTheSameCoordinate]) {
        return self;
    }
    
    __block CGFloat superHeight = 0;
    [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
        superHeight = CGRectGetHeight(view.superview.bounds);
        *stop = YES;
    } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
        superHeight = CGRectGetHeight(layer.superlayer.bounds);
        *stop = YES;
    }];
    self.groupMidY(superHeight / 2);
    return self;
}

- (ShortCocoa *)groupCenterAlign {
    return self.groupVerAlign.groupHorAlign;
}

#pragma mark - Group Get 系列

- (CGFloat)$groupX {
    if ([self filteredGet:[NS_UI_View class], [CALayer class], nil].count > 1) {
        if (![self allPackedViewsAndLayersAreInTheSameCoordinate]) {
            return 0;
        }
    }
    __block CGFloat minX = 0;
    __block BOOL hasDeterminedMinX = NO;
    [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
        minX = hasDeterminedMinX ? MIN(minX, CGRectGetMinX(view.frame)) : CGRectGetMinX(view.frame);
        hasDeterminedMinX = YES;
    } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
        minX = hasDeterminedMinX ? MIN(minX, CGRectGetMinX(layer.frame)) : CGRectGetMinX(layer.frame);
        hasDeterminedMinX = YES;
    }];
    return minX;
}

- (CGFloat)$groupMidX {
    if ([self filteredGet:[NS_UI_View class], [CALayer class], nil].count > 1) {
        if (![self allPackedViewsAndLayersAreInTheSameCoordinate]) {
            return 0;
        }
    }
    CGFloat minX = self.$groupX;
    CGFloat maxX = self.$groupMaxX;
    CGFloat midX = minX + (maxX - minX) / 2;
    return midX;
}

- (CGFloat)$groupMaxX {
    if ([self filteredGet:[NS_UI_View class], [CALayer class], nil].count > 1) {
        if (![self allPackedViewsAndLayersAreInTheSameCoordinate]) {
            return 0;
        }
    }
    __block CGFloat maxX = 0;
    __block BOOL hasDeterminedMaxX = NO;
    [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
        maxX = hasDeterminedMaxX ? MAX(maxX, CGRectGetMaxX(view.frame)) : CGRectGetMaxX(view.frame);
        hasDeterminedMaxX = YES;
    } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
        maxX = hasDeterminedMaxX ? MAX(maxX, CGRectGetMaxX(layer.frame)) : CGRectGetMaxX(layer.frame);
        hasDeterminedMaxX = YES;
    }];
    return maxX;
}

- (CGFloat)$groupY {
    if ([self filteredGet:[NS_UI_View class], [CALayer class], nil].count > 1) {
        if (![self allPackedViewsAndLayersAreInTheSameCoordinate]) {
            return 0;
        }
    }
    __block CGFloat minY = 0;
    __block BOOL hasDeterminedMinY = NO;
    [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
        minY = hasDeterminedMinY ? MIN(minY, CGRectGetMinY(view.frame)) : CGRectGetMinY(view.frame);
        hasDeterminedMinY = YES;
    } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
        minY = hasDeterminedMinY ? MIN(minY, CGRectGetMinY(layer.frame)) : CGRectGetMinY(layer.frame);
        hasDeterminedMinY = YES;
    }];
    return minY;
}

- (CGFloat)$groupMidY {
    if ([self filteredGet:[NS_UI_View class], [CALayer class], nil].count > 1) {
        if (![self allPackedViewsAndLayersAreInTheSameCoordinate]) {
            return 0;
        }
    }
    CGFloat minY = self.$groupY;
    CGFloat maxY = self.$groupMaxY;
    CGFloat midY = minY + (maxY - minY) / 2;
    return midY;
}

- (CGFloat)$groupMaxY {
    if ([self filteredGet:[NS_UI_View class], [CALayer class], nil].count > 1) {
        if (![self allPackedViewsAndLayersAreInTheSameCoordinate]) {
            return 0;
        }
    }
    __block CGFloat maxY = 0;
    __block BOOL hasDeterminedMaxY = NO;
    [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
        maxY = hasDeterminedMaxY ? MAX(maxY, CGRectGetMaxY(view.frame)) : CGRectGetMaxY(view.frame);
        hasDeterminedMaxY = YES;
    } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
        maxY = hasDeterminedMaxY ? MAX(maxY, CGRectGetMaxY(layer.frame)) : CGRectGetMaxY(layer.frame);
        hasDeterminedMaxY = YES;
    }];
    return maxY;
}

- (CGPoint)$groupOrigin {
    CGPoint origin = CGPointMake(self.$groupX, self.$groupY);
    return origin;
}

- (CGFloat)$groupWidth {
    if ([self filteredGet:[NS_UI_View class], [CALayer class], nil].count > 1) {
        if (![self allPackedViewsAndLayersAreInTheSameCoordinate]) {
            return 0;
        }
    }
    CGFloat maxX = self.$groupMaxX;
    CGFloat minX = self.$groupX;
    CGFloat width = maxX - minX;
    return width;
}

- (CGFloat)$groupHeight {
    if ([self filteredGet:[NS_UI_View class], [CALayer class], nil].count > 1) {
        if (![self allPackedViewsAndLayersAreInTheSameCoordinate]) {
            return 0;
        }
    }
    CGFloat maxY = self.$groupMaxY;
    CGFloat minY = self.$groupY;
    CGFloat height = maxY - minY;
    return height;
}

- (CGSize)$groupSize {
    if ([self filteredGet:[NS_UI_View class], [CALayer class], nil].count > 1) {
        if (![self allPackedViewsAndLayersAreInTheSameCoordinate]) {
            return CGSizeZero;
        }
    }
    CGFloat width = self.$groupWidth;
    CGFloat height = self.$groupHeight;
    CGSize size = CGSizeMake(width, height);
    return size;
}

#pragma mark - to 系列

- (ShortCocoa * (^)(CGFloat))toX {
    return ^(CGFloat value) {
        if (isnan(value)) {
            NSAssert(NO, @"传入了 NaN");
            value = 0;
        }
        
        [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
            CGFloat safeValue = value;
            if (safeValue > CGRectGetMaxX(view.frame)) {
                safeValue = CGRectGetMaxX(view.frame);
            }
            
            CGRect rect = view.frame;
            CGFloat width = CGRectGetMaxX(rect) - safeValue;
            rect.size.width = CGFloatSnapToPixel(width);
            rect.origin.x = CGFloatSnapToPixel(safeValue);
            view.frame = rect;
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            CGFloat safeValue = value;
            if (safeValue > CGRectGetMaxX(layer.frame)) {
                safeValue = CGRectGetMaxX(layer.frame);
            }
            
            CGRect rect = layer.frame;
            CGFloat width = CGFloatSnapToPixel(CGRectGetMaxX(rect) - safeValue);
            rect.size.width = width;
            rect.origin.x = CGFloatSnapToPixel(safeValue);
            layer.frame = rect;
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))toMaxX {
    return ^(CGFloat value) {
        if (isnan(value)) {
            NSAssert(NO, @"传入了 NaN");
            value = 0;
        }
        
        [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
            CGFloat safeValue = value;
            if (safeValue < CGRectGetMinX(view.frame)) {
                safeValue = CGRectGetMinX(view.frame);
            }
            
            CGRect rect = view.frame;
            CGFloat width = CGFloatSnapToPixel(safeValue - CGRectGetMinX(rect));
            rect.size.width = width;
            view.frame = rect;
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            CGFloat safeValue = value;
            if (safeValue < CGRectGetMinX(layer.frame)) {
                safeValue = CGRectGetMinX(layer.frame);
            }
            
            CGRect rect = layer.frame;
            CGFloat width = CGFloatSnapToPixel(safeValue - CGRectGetMinX(rect));
            rect.size.width = width;
            layer.frame = rect;
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))toY {
    return ^(CGFloat value) {
        if (isnan(value)) {
            NSAssert(NO, @"传入了 NaN");
            value = 0;
        }
        
        [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
            CGFloat safeValue = value;
            if (safeValue > CGRectGetMaxY(view.frame)) {
                safeValue = CGRectGetMaxY(view.frame);
            }
            
            CGRect rect = view.frame;
            CGFloat height = CGRectGetMaxY(rect) - safeValue;
            rect.size.height = CGFloatSnapToPixel(height);
            rect.origin.y = CGFloatSnapToPixel(safeValue);
            view.frame = rect;
            
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            CGFloat safeValue = value;
            if (safeValue > CGRectGetMaxY(layer.frame)) {
                safeValue = CGRectGetMaxY(layer.frame);
            }
            
            CGRect rect = layer.frame;
            CGFloat height = CGRectGetMaxY(rect) - safeValue;
            rect.size.height = CGFloatSnapToPixel(height);
            rect.origin.y = CGFloatSnapToPixel(safeValue);
            layer.frame = rect;
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))toMaxY {
    return ^(CGFloat value) {
        if (isnan(value)) {
            NSAssert(NO, @"传入了 NaN");
            value = 0;
        }
        
        [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
            CGFloat safeValue = value;
            if (safeValue < CGRectGetMinY(view.frame)) {
                safeValue = CGRectGetMinY(view.frame);
            }
            
            CGRect rect = view.frame;
            CGFloat height = safeValue - CGRectGetMinY(rect);
            rect.size.height = CGFloatSnapToPixel(height);
            view.frame = rect;
            
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            CGFloat safeValue = value;
            if (safeValue < CGRectGetMinY(layer.frame)) {
                safeValue = CGRectGetMinY(layer.frame);
            }
            
            CGRect rect = layer.frame;
            CGFloat height = safeValue - CGRectGetMinY(rect);
            rect.size.height = CGFloatSnapToPixel(height);
            layer.frame = rect;
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))toRight {
    return ^(CGFloat value) {
        if (isnan(value)) {
            NSAssert(NO, @"传入了 NaN");
            value = 0;
        }
        
        [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
            CGRect rect = view.frame;
            CGFloat width = CGFloatSnapToPixel(CGRectGetWidth(view.superview.bounds) - CGRectGetMinX(rect) - value);
            if (width < 0) {
                width = 0;
            }
            rect.size.width = width;
            view.frame = rect;
            
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            CGRect rect = layer.frame;
            CGFloat width = CGFloatSnapToPixel(CGRectGetWidth(layer.superlayer.bounds) - CGRectGetMinX(rect) - value);
            if (width < 0) {
                width = 0;
            }
            rect.size.width = width;
            layer.frame = rect;
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))toBottom {
    return ^(CGFloat value) {
        if (isnan(value)) {
            NSAssert(NO, @"传入了 NaN");
            value = 0;
        }
#if TARGET_OS_IPHONE
        [self unpackClassA:[UIView class] doA:^(UIView *view, BOOL *stop) {
            if (view.superview) {
                CGFloat maxY = CGRectGetHeight(view.superview.bounds) - value;
                ShortCocoaMake(view).toMaxY(maxY);
            } else {
                NSAssert(NO, @"必须存在 superview 才可使用该方法");
            }
#elif TARGET_OS_MAC
        [self unpackClassA:[NSView class] doA:^(NSView *view, BOOL *stop) {
            if (view.superview) {
                if (view.superview.isFlipped) {
                    CGFloat maxY = CGRectGetHeight(view.superview.bounds) - value;
                    ShortCocoaMake(view).toMaxY(maxY);
                } else {
                    ShortCocoaMake(view).toY(value);
                }
            } else {
                NSAssert(NO, @"必须存在 superview 才可使用该方法");
            }
#endif
        } classB:[CALayer class] doB:^(CALayer *layer, BOOL *stop) {
            if (layer.superlayer) {
                if (layer.superlayer.contentsAreFlipped) {
                    CGFloat maxY = CGRectGetHeight(layer.superlayer.bounds) - value;
                    ShortCocoaMake(layer).toMaxY(maxY);
                } else {
                    ShortCocoaMake(layer).toY(value);
                }
            } else {
                NSAssert(NO, @"必须存在 superlayer 才可使用该方法");
            }
        }];
        return self;
    };
}

#pragma mark - sizeThatFits 系列

- (ShortCocoa *)heightToFit {
#if TARGET_OS_IPHONE
    [self unpack:[UIView class] do:^(UIView *view, BOOL *stop) {
#elif TARGET_OS_MAC
    [self unpack:[NSControl class] do:^(NSControl *view, BOOL *stop) {
#endif
        CGFloat width = CGRectGetWidth(view.bounds);
        CGFloat height = [view sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height;
        ShortCocoaMake(view).height(height);
    }];
    return self;
}

- (ShortCocoa *)widthToFit {
#if TARGET_OS_IPHONE
    [self unpack:[UIView class] do:^(UIView *view, BOOL *stop) {
#elif TARGET_OS_MAC
    [self unpack:[NSControl class] do:^(NSControl *view, BOOL *stop) {
#endif
        CGFloat height = CGRectGetHeight(view.bounds);
        CGFloat width = [view sizeThatFits:CGSizeMake(CGFLOAT_MAX, height)].width;
        ShortCocoaMake(view).width(width);
    }];
    return self;
}

#pragma mark - Private

- (CGSize)getBestSize {
    // 此方法不考虑 self.get 是数组的情况，下面其余 5 个方法也是一样
    __block CGSize size = CGSizeZero;
#if TARGET_OS_IPHONE
    [self unpack:[UIView class] do:^(UIView *view, BOOL *stop) {
#elif TARGET_OS_MAC
    [self unpack:[NSControl class] do:^(NSControl *view, BOOL *stop) {
#endif
        size = [view sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    }];
    return size;
}

- (CGFloat)getBestWidth {
    return self.getBestSize.width;
}

- (CGFloat)getBestHeight {
    return self.getBestSize.height;
}

/**
 检查是否所有 view 和 layer 都处于相同的坐标系里（有共同的 superview/superlayer）
 */
- (BOOL)allPackedViewsAndLayersAreInTheSameCoordinateWithSuperlayer:(inout CALayer **)superlayerPointer superview:(inout NS_UI_View **)superviewPointer {
    if (!self.get) {
        return NO;
    }
    __block BOOL validated = YES;

    __block NS_UI_View *superview = nil;
    __block CALayer *superlayer = nil;

    [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View * _Nonnull view, BOOL *stop) {
        if (!view.superview) {
            validated = NO;
            NSAssert(NO, @"superview 不存在");
            *stop = YES;
        }
        if (superview) {
            if (view.superview != superview) {
                validated = NO;
                NSAssert(NO, @"包装了多个 View 对象，但它们没有相同的 superview");
                *stop = YES;
            }
        } else {
            superview = view.superview;
        }
    } classB:[CALayer class] doB:^(CALayer * _Nonnull layer, BOOL *stop) {
        if (!layer.superlayer) {
            validated = NO;
            NSAssert(NO, @"superlayer 不存在");
            *stop = YES;
        }
        if (superlayer) {
            if (layer.superlayer != superlayer) {
                validated = NO;
                NSAssert(NO, @"包装了多个 CALayer 对象，但它们没有相同的 superlayer");
                *stop = YES;
            }
        } else {
            superlayer = layer.superlayer;
        }
    }];

    if (validated) {
        if (superview && superlayer && superview.layer != superlayer) {
            if (!superview.layer) {
                validated = NO;
#if TARGET_OS_IPHONE
                NSAssert(NO, @"同时包装了 View 和 Layer 对象，但其中某些 View 的 layer 属性为 nil");
#elif TARGET_OS_MAC
                NSAssert(NO, @"同时包装了 View 和 Layer 对象，但其中某些 View 的 layer 属性为 nil，是否忘记设置 wantsLayer 为 YES？");
#endif
            } else if (superview.layer != superlayer) {
                validated = NO;
                NSAssert(NO, @"同时包装了 View 和 Layer 对象，但这些 View 和 Layer 没有相同的 superlayer");
            }
        }
    }
    
    if (validated) {
        if (superlayer) {
            if (superlayerPointer) {
                *superlayerPointer = superlayer;
            }
        }
        if (superview) {
            if (superviewPointer) {
                *superviewPointer = superview;
            }
            if (!superlayer) {
                if (superlayerPointer) {
                    *superlayerPointer = superview.layer;                    
                }
            }
        }
    }
    
    return validated;
}
     
- (BOOL)allPackedViewsAndLayersAreInTheSameCoordinate {
    return [self allPackedViewsAndLayersAreInTheSameCoordinateWithSuperlayer:nil superview:nil];
}

- (NSArray *)filteredGet:(Class)aClass, ... {
    if (!aClass) {
        return nil;
    }
    NSMutableArray<Class> *classes = [NSMutableArray array];;
    [classes addObject:aClass];
    
    va_list args;
    va_start(args, aClass);
    id arg;
    while ((1)) {
        arg = va_arg(args, id);
        if (arg) {
            [classes addObject:arg];
        } else {
            // 传入了 nil
            break;
        }
    }
    va_end(args);
    
    NSMutableArray *filtered = [NSMutableArray array];
    id initialGet = self.get;
    if (ShortCocoaEqualClass(initialGet, NSArray)) {
        [initialGet enumerateObjectsUsingBlock:^(id  _Nonnull get, NSUInteger idx, BOOL * _Nonnull stop) {
            [classes enumerateObjectsUsingBlock:^(Class  _Nonnull className, NSUInteger idx, BOOL * _Nonnull innerStop) {
                if (ShortCocoaEqualClass(get, className)) {
                    [filtered addObject:get];
                    *innerStop = YES;
                }
            }];
        }];
    } else {
        [classes enumerateObjectsUsingBlock:^(Class  _Nonnull className, NSUInteger idx, BOOL * _Nonnull stop) {
            if (ShortCocoaEqualClass(initialGet, className)) {
                [filtered addObject:initialGet];
                *stop = YES;
            }
        }];
    }
    return filtered.count ? filtered : nil;
}

/**
 调整传入值的大小以使其在当前设备上可以像素对齐
 
 @note 假如是一个屏幕 scale 为 2 的设备，当你设置一个 view 的 origin 为 0.7pt 时，则它实际会被渲染为 1.4px，而 1.4px 不是整数，这将导致这个 view 看起来有些模糊，这个现象对于 UILabel 等文字控件的显示尤其明显。而该方法可以把 0.7 修正为 1.0，从而解决这个问题。
 @note 数值将被 ceil() 向上取整，比如 scale 为 2 时：0.1=>0.5，1.3=>1.5
 
 @note 这个像素对齐的优化策略来自于 QMUI iOS：
 https://github.com/QMUI/QMUI_iOS/
 https://github.com/QMUI/QMUI_iOS/blob/master/QMUIKit/QMUICore/QMUICommonDefines.h
 */
CG_INLINE CGFloat CGFloatSnapToPixel(CGFloat rawValue) {
    if (rawValue == CGFLOAT_MIN || rawValue == CGFLOAT_MAX) {
        // CGFLOAT_MIN, CGFLOAT_MAX 一般被当做一个标志位来用，所以不对它们进行处理
        return rawValue;
    }
#if TARGET_OS_IPHONE
    CGFloat screenScale = [[UIScreen mainScreen] scale];
#elif TARGET_OS_MAC
    CGFloat screenScale = [[NSScreen mainScreen] backingScaleFactor];
#endif
    CGFloat parsedValue = ceil(rawValue * screenScale) / screenScale;
    return parsedValue;
}

@end

#if TARGET_OS_IPHONE
@implementation UIView (ShortCocoaLayout)
#elif TARGET_OS_MAC
@implementation NSView (ShortCocoaLayout)
#endif

- (CGFloat)$x {
    return ShortCocoaMake(self).$groupX;
}
- (CGFloat)$midX {
    return ShortCocoaMake(self).$groupMidX;
}
- (CGFloat)$maxX {
    return ShortCocoaMake(self).$groupMaxX;
}
- (CGFloat)$y {
    return ShortCocoaMake(self).$groupY;
}
- (CGFloat)$midY {
    return ShortCocoaMake(self).$groupMidY;
}
- (CGFloat)$maxY {
    return ShortCocoaMake(self).$groupMaxY;
}
- (CGFloat)$width {
    return ShortCocoaMake(self).$groupWidth;
}
- (CGFloat)$height {
    return ShortCocoaMake(self).$groupHeight;
}
- (CGSize)$size {
    return ShortCocoaMake(self).$groupSize;
}
#if TARGET_OS_IPHONE
- (CGSize)$bestSize {
    return ShortCocoaMake(self).getBestSize;
}
- (CGFloat)$bestWidth {
    return ShortCocoaMake(self).getBestWidth;
}
- (CGFloat)$bestHeight {
    return ShortCocoaMake(self).getBestHeight;
}
#endif

@end

@implementation CALayer (ShortCocoaLayout)

- (CGFloat)$x {
    return ShortCocoaMake(self).$groupX;
}
- (CGFloat)$midX {
    return ShortCocoaMake(self).$groupMidX;
}
- (CGFloat)$maxX {
    return ShortCocoaMake(self).$groupMaxX;
}
- (CGFloat)$y {
    return ShortCocoaMake(self).$groupY;
}
- (CGFloat)$midY {
    return ShortCocoaMake(self).$groupMidY;
}
- (CGFloat)$maxY {
    return ShortCocoaMake(self).$groupMaxY;
}
- (CGFloat)$width {
    return ShortCocoaMake(self).$groupWidth;
}
- (CGFloat)$height {
    return ShortCocoaMake(self).$groupHeight;
}
- (CGSize)$size {
    return ShortCocoaMake(self).$groupSize;
}

@end
