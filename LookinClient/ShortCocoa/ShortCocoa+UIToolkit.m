//
//  ShortCocoa+UIToolkit.m
//  ShortCocoa
//
//  Copyright © 2018年 hughkli. All rights reserved.
//

#import "ShortCocoa+UIToolkit.h"
#import "ShortCocoa+Private.h"

#if TARGET_OS_IPHONE
    #define NS_UI_View UIView
#elif TARGET_OS_MAC
    #define NS_UI_View NSView
#endif

@implementation ShortCocoa (UIToolkit)

- (ShortCocoa *)visibles {
    if (ShortCocoaEqualClass(_get, NS_UI_View)) {
        if (![self isVisibleView:_get]) {
            _get = nil;
        }
    } else if (ShortCocoaEqualClass(_get, CALayer)) {
        if (![self isVisibleLayer:_get]) {
            _get = nil;
        }
    } else if (ShortCocoaEqualClass(_get, NSArray)) {
        NSMutableArray *visibleOnes = [NSMutableArray arrayWithCapacity:((NSArray *)_get).count];
        [(NSArray *)_get enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self isVisibleViewOrLayer:obj]) {
                [visibleOnes addObject:obj];
            }
        }];
        _get = visibleOnes.count > 1 ? visibleOnes.copy : [visibleOnes firstObject];
    }
    return self;
}

- (ShortCocoa * (^)(CGFloat))opacity {
    return ^(CGFloat value) {
#if TARGET_OS_IPHONE
        [self unpackClassA:[UIView class] doA:^(UIView *view, BOOL *stop) {
            view.alpha = value;
#elif TARGET_OS_MAC
            [self unpackClassA:[NSView class] doA:^(NSView *view, BOOL *stop) {
                view.alphaValue = value;
#endif
            } classB:[CALayer class] doB:^(CALayer * _Nonnull layer, BOOL *stop) {
                layer.opacity = value;
            }];
            return self;
        };
}
 
- (ShortCocoa * (^)(CGFloat))alpha {
    return ^(CGFloat value) {
         return self.opacity(value);
    };
}
         
- (ShortCocoa *)hide {
    [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
        view.hidden = YES;
    } classB:[CALayer class] doB:^(CALayer * _Nonnull layer, BOOL *stop) {
        layer.hidden = YES;
    }];
    return self;
}
 
- (ShortCocoa *)show {
    [self unpackClassA:[NS_UI_View class] doA:^(NS_UI_View *view, BOOL *stop) {
        view.hidden = NO;
    } classB:[CALayer class] doB:^(CALayer * _Nonnull layer, BOOL *stop) {
        layer.hidden = NO;
    }];
    return self;
}
         
#if TARGET_OS_IPHONE

- (ShortCocoa * (^)(id container))addTo {
    return ^(id container) {
        if (!container) {
            return self;
        }
        [self unpackClassA:[UIView class] doA:^(UIView *  _Nonnull view, BOOL *stop) {
            if (ShortCocoaEqualClass(container, UIView)) {
                [container addSubview:view];
            } else if (ShortCocoaEqualClass(container, CALayer)) {
                [container addSublayer:view.layer];
            }
             
        } classB:[CALayer class] doB:^(CALayer * _Nonnull layer, BOOL *stop) {
            if (ShortCocoaEqualClass(container, UIView)) {
                [((UIView *)container).layer addSublayer:layer];
            } else if (ShortCocoaEqualClass(container, CALayer)) {
                [container addSublayer:layer];
            }
        }];
        return self;
    };
}
         
- (ShortCocoa * (^)(id target, SEL action))onTap {
    return ^(id target, SEL action) {
        [self unpack:[UIControl class] do:^(UIControl * _Nonnull control, BOOL *stop) {
        [control addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }];
    return self;
    };
}
         
- (ShortCocoa * (^)(BOOL))userInteractionEnabled {
    return ^(BOOL enabled) {
        [self unpack:[UIView class] do:^(UIView * _Nonnull obj, BOOL *stop) {
            obj.userInteractionEnabled = enabled;
        }];
        return self;
    };
}

- (ShortCocoa * (^)(BOOL))clipsToBounds {
    return ^(BOOL boolValue) {
        [self unpackClassA:[UIView class] doA:^(UIView *view, BOOL *stop) {
            view.clipsToBounds = boolValue;
        } classB:[CALayer class] doB:^(CALayer * _Nonnull layer, BOOL *stop) {
            layer.masksToBounds = boolValue;
        }];
        return self;
    };
}

- (ShortCocoa * (^)(BOOL))masksToBounds {
    return ^(BOOL boolValue) {
        self.clipsToBounds(boolValue);
        return self;
    };
}

- (ShortCocoa * (^)(id))bgColor {
    return ^(id value) {
        id UI_or_NS_Color = [ShortCocoaHelper colorFromShortCocoaColor:value];
        [self unpackClassA:[UIView class] doA:^(UIView *view, BOOL *stop) {
            view.backgroundColor = UI_or_NS_Color;
        } classB:[CALayer class] doB:^(CALayer * _Nonnull layer, BOOL *stop) {
            layer.backgroundColor = [UI_or_NS_Color CGColor];
        }];
        return self;
    };
}

- (ShortCocoa * (^)(id))borderColor {
    return ^(id value) {
        id UI_or_NS_Color = [ShortCocoaHelper colorFromShortCocoaColor:value];
        [self unpackClassA:[UIView class] doA:^(UIView *view, BOOL *stop) {
            view.layer.borderColor = [UI_or_NS_Color CGColor];
        } classB:[CALayer class] doB:^(CALayer * _Nonnull layer, BOOL *stop) {
            layer.borderColor = [UI_or_NS_Color CGColor];
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))borderWidth {
    return ^(CGFloat value) {
        [self unpackClassA:[UIView class] doA:^(UIView *view, BOOL *stop) {
            view.layer.borderWidth = value;
        } classB:[CALayer class] doB:^(CALayer * _Nonnull layer, BOOL *stop) {
            layer.borderWidth = value;
        }];
        return self;
    };
}
         

                      
- (ShortCocoa * (^)(CGFloat))corners {
    return ^(CGFloat value) {
        [self unpackClassA:[UIView class] doA:^(UIView *view, BOOL *stop) {
            view.layer.cornerRadius = value;
        } classB:[CALayer class] doB:^(CALayer * _Nonnull layer, BOOL *stop) {
            layer.cornerRadius = value;
        }];
        return self;
    };
}

- (ShortCocoa * (^)(ShortCocoaImage _Nullable))image {
    return ^(ShortCocoaImage _Nullable image) {
        id UI_or_NS_Image = [ShortCocoaHelper imageFromShortCocoaImage:image];
        [self unpackClassA:[UIButton class] doA:^(UIButton *  _Nonnull button, BOOL *stop) {
            [button setImage:UI_or_NS_Image forState:UIControlStateNormal];
        } classB:[UIImageView class] doB:^(UIImageView * _Nonnull imageView, BOOL *stop) {
            [imageView setImage:UI_or_NS_Image];
        }];
        return self;
    };
}
     
- (ShortCocoa * (^)(CGFloat))indicatorInsetTop {
    return ^(CGFloat insetTop) {
        [self unpack:[UIScrollView class] do:^(UIScrollView * _Nonnull obj, BOOL *stop) {
            UIEdgeInsets indicatorInsets = obj.scrollIndicatorInsets;
            indicatorInsets.top = insetTop;
            obj.scrollIndicatorInsets = indicatorInsets;
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))indicatorInsetLeft {
    return ^(CGFloat insetLeft) {
        [self unpack:[UIScrollView class] do:^(UIScrollView * _Nonnull obj, BOOL *stop) {
            UIEdgeInsets indicatorInsets = obj.scrollIndicatorInsets;
            indicatorInsets.left = insetLeft;
            obj.scrollIndicatorInsets = indicatorInsets;
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))indicatorInsetBottom {
    return ^(CGFloat insetBottom) {
        [self unpack:[UIScrollView class] do:^(UIScrollView * _Nonnull obj, BOOL *stop) {
            UIEdgeInsets indicatorInsets = obj.scrollIndicatorInsets;
            indicatorInsets.bottom = insetBottom;
            obj.scrollIndicatorInsets = indicatorInsets;
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))indicatorInsetRight {
    return ^(CGFloat insetRight) {
        [self unpack:[UIScrollView class] do:^(UIScrollView * _Nonnull obj, BOOL *stop) {
            UIEdgeInsets indicatorInsets = obj.scrollIndicatorInsets;
            indicatorInsets.right = insetRight;
            obj.scrollIndicatorInsets = indicatorInsets;
        }];
        return self;
    };
}

- (ShortCocoa * (^)(ShortCocoaQuad))insets {
    return ^(ShortCocoaQuad insets) {
        NSArray<NSNumber *> *insetsNumbers = [ShortCocoaHelper fourNumbersFromShortCocoaQuad:insets];
        if (insetsNumbers.count == 4) {
            UIEdgeInsets uiEdgeInsets = UIEdgeInsetsMake([insetsNumbers[0] doubleValue], [insetsNumbers[1] doubleValue], [insetsNumbers[2] doubleValue], [insetsNumbers[3] doubleValue]);
            
            [self unpackClassA:[UIScrollView class] doA:^(UIScrollView * _Nonnull obj, BOOL *stop) {
                obj.contentInset = uiEdgeInsets;
            } classB:[UIButton class] doB:^(UIButton *  _Nonnull obj, BOOL *stop) {
                obj.contentEdgeInsets = uiEdgeInsets;
            }];
        }
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))insetTop {
    return ^(CGFloat insetTop) {
        [self unpackClassA:[UIScrollView class] doA:^(UIScrollView * _Nonnull obj, BOOL *stop) {
            UIEdgeInsets insets = obj.contentInset;
            insets.top = insetTop;
            obj.contentInset = insets;
            
        } classB:[UIButton class] doB:^(UIButton * _Nonnull obj, BOOL *stop) {
            UIEdgeInsets insets = obj.contentEdgeInsets;
            insets.top = insetTop;
            obj.contentEdgeInsets = insets;
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))insetLeft {
    return ^(CGFloat insetLeft) {
        [self unpackClassA:[UIScrollView class] doA:^(UIScrollView * _Nonnull obj, BOOL *stop) {
            UIEdgeInsets insets = obj.contentInset;
            insets.left = insetLeft;
            obj.contentInset = insets;
            
        } classB:[UIButton class] doB:^(UIButton * _Nonnull obj, BOOL *stop) {
            UIEdgeInsets insets = obj.contentEdgeInsets;
            insets.left = insetLeft;
            obj.contentEdgeInsets = insets;
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))insetBottom {
    return ^(CGFloat insetBottom) {
        [self unpackClassA:[UIScrollView class] doA:^(UIScrollView * _Nonnull obj, BOOL *stop) {
            UIEdgeInsets insets = obj.contentInset;
            insets.bottom = insetBottom;
            obj.contentInset = insets;
            
        } classB:[UIButton class] doB:^(UIButton * _Nonnull obj, BOOL *stop) {
            UIEdgeInsets insets = obj.contentEdgeInsets;
            insets.bottom = insetBottom;
            obj.contentEdgeInsets = insets;
        }];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))insetRight {
    return ^(CGFloat insetRight) {
        [self unpackClassA:[UIScrollView class] doA:^(UIScrollView * _Nonnull obj, BOOL *stop) {
            UIEdgeInsets insets = obj.contentInset;
            insets.right = insetRight;
            obj.contentInset = insets;
            
        } classB:[UIButton class] doB:^(UIButton * _Nonnull obj, BOOL *stop) {
            UIEdgeInsets insets = obj.contentEdgeInsets;
            insets.right = insetRight;
            obj.contentEdgeInsets = insets;
        }];
        return self;
    };
}
     
- (ShortCocoa * (^)(NSInteger))lines {
    return ^(NSInteger maxValue) {
        [self unpack:[UILabel class] do:^(UILabel * _Nonnull label, BOOL *stop) {
            label.numberOfLines = maxValue;
        }];
        return self;
    };
}
     
- (ShortCocoa * (^)(id))text {
    return ^(id string) {
        [self unpackClassA:[UILabel class] doA:^(UILabel * _Nonnull obj, BOOL *stop) {
            if (!string) {
                obj.text = nil;
                obj.attributedText = nil;
            } else if (ShortCocoaEqualClass(string, NSString)) {
                obj.text = string;
            } else if (ShortCocoaEqualClass(string, NSAttributedString)) {
                obj.attributedText = string;
            } else if (ShortCocoaEqualClass(string, NSNumber)) {
                obj.text = [NSString stringWithFormat:@"%@", string];
            } else {
                NSAssert(NO, @"传入的 string 不是 NSString、NSAttributedString 或 NSNumber");
            }
            
        } classB:[UIButton class] doB:^(UIButton * _Nonnull obj, BOOL *stop) {
            if (!string) {
                [obj setTitle:nil forState:UIControlStateNormal];
                [obj setAttributedTitle:nil forState:UIControlStateNormal];
            } else if (ShortCocoaEqualClass(string, NSString)) {
                [obj setAttributedTitle:nil forState:UIControlStateNormal];
                [obj setTitle:string forState:UIControlStateNormal];
            } else if (ShortCocoaEqualClass(string, NSAttributedString)) {
                [obj setTitle:nil forState:UIControlStateNormal];
                [obj setAttributedTitle:string forState:UIControlStateNormal];
            } else if (ShortCocoaEqualClass(string, NSNumber)) {
                [obj setAttributedTitle:nil forState:UIControlStateNormal];
                [obj setTitle:[NSString stringWithFormat:@"%@", string] forState:UIControlStateNormal];
            } else {
                NSAssert(NO, @"传入的 string 不是 NSString、NSAttributedString 或 NSNumber");
            }
        }];
        return self;
    };
}

#endif
     
#pragma mark - Private

- (BOOL)isVisibleView:(NS_UI_View *)view {
#if TARGET_OS_IPHONE
    return view && !view.hidden && view.superview && view.alpha >= 0.01;
#elif TARGET_OS_MAC
    return view && !view.hidden && view.superview && view.alphaValue >= 0.01;
#endif
}         

- (BOOL)isVisibleLayer:(CALayer *)layer {
    return layer && !layer.hidden && layer.superlayer && layer.opacity >= 0.01;
}

- (BOOL)isVisibleViewOrLayer:(id)object {
    if (ShortCocoaEqualClass(object, NS_UI_View)) {
        return [self isVisibleView:object];
    } else if (ShortCocoaEqualClass(object, CALayer)) {
        return [self isVisibleLayer:object];
    } else {
        return NO;
    }
}

@end
