//
//  ShortCocoa+UIToolkit.h
//  ShortCocoa
//
//  Copyright © 2018年 hughkli. All rights reserved.
//

#import "ShortCocoaCore.h"
#import "ShortCocoaDefines.h"
#import "TargetConditionals.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Appkit/Appkit.h>
#endif

@interface ShortCocoa (UIToolkit)


/**
 使得当前方法调用链上的后续方法仅对可见的 view/layer 生效

 @note "view 可见"的定义是：view && !view.hidden && view.superview && view.alpha >= 0.01，layer 类似
 
 @code
 
 // horAlign 方法仅对 visibleLabel 生效，hiddenLabel 不会受到任何影响
 $(visibleLabel, hiddenLabel).visibles.horAlign;
 
 // => @[visibleView]
 $(visibleView, hiddenView).visibles.array;
 
 @endcode
 */
- (ShortCocoa *)visibles;

/**
 设置 view 的 alpha，或 CALayer 的 opacity
 
 @note 支持的被包装对象：UIView/NSView, CALayer
 @note 范围是 0 ~ 1
 @note 该方法和 alpha 方法完全等价
 */
- (ShortCocoa * (^)(CGFloat))opacity;

/**
 设置 view 的 alpha，或 CALayer 的 opacity
 
 @note 支持的被包装对象：UIView/NSView, CALayer
 @note 范围是 0 ~ 1
 @note 该方法和 opacity 方法完全等价
 */
- (ShortCocoa * (^)(CGFloat))alpha;

/**
 等价于设置 hidden 属性为 YES
 @note 支持的被包装对象：UIView/NSView, CALayer
 */
- (ShortCocoa *)hide;

/**
 等价于设置 hidden 属性为 NO
 @note 支持的被包装对象：UIView/NSView, CALayer
 */
- (ShortCocoa *)show;

#if TARGET_OS_IPHONE

/**
 将 UIView / CALayer 添加到另一个 UIView / CALayer 上，即代替 addSubview: 和 addSublayer: 方法
 
 @note 支持的被包装对象：UIView, CALayer
 
 @code
 $(view).addTo(view2);  // 等价于 [view2 addSubview:view]
 $(layer).addTo(layer2);// 等价于 [layer2 addSublayer:layer]
 $(view).addTo(layer);  // 等价于 [layer addSublayer:view.layer]
 $(layer).addTo(view);  // 等价于 [view.layer addSublayer:layer]
 @endcode
 */
- (ShortCocoa * (^)(_Nullable id))addTo;

/**
 设置 UIControl 的点击（UIControlEventTouchUpInside）响应事件，等价于 addTarget:action:forControlEvents:
 @note 支持的被包装对象：UIControl
 */
- (ShortCocoa * (^)(id target, SEL action))onTap;

/**
 等价于 UILabel 的 numberOfLines
 @note 支持的被包装对象：UILabel
 */
- (ShortCocoa * (^)(NSInteger))lines;

/**
 等价于 UIView 的 clipsToBounds 或 CALayer 的 masksToBounds;
 @note 支持的被包装对象：UIView, CALayer
 */
- (ShortCocoa * (^)(BOOL))clipsToBounds;

/**
 等价于 UIView 的 clipsToBounds 或 CALayer 的 masksToBounds;
 @note 支持的被包装对象：UIView, CALayer
 */
- (ShortCocoa * (^)(BOOL))masksToBounds;

/**
 设置 UIView / CALayer 的 backgroundColor
 
 @note 支持的被包装对象：UIView, CALayer
 @note 传入值支持 UIColor 或 RGB, RGBA, HEX 或 @"red" 等字符串，详见 ShortCocoaColor 定义
 
 */
- (ShortCocoa * (^)(_Nullable ShortCocoaColor))bgColor;

/**
 设置 UIView / CALayer 的 borderColor
 
 @note 支持的被包装对象：UIView, CALayer
 @note 传入值支持 UIColor 或 RGB, RGBA, HEX 或 @"red" 等字符串，详见 ShortCocoaColor 定义
 @note $(view).borderColor() 等价于 $(view.layer).borderColor()
 */
- (ShortCocoa * (^)(_Nullable ShortCocoaColor))borderColor;

/**
 设置 UIView / CALayer 的 borderWidth
 
 @note 支持的被包装对象：UIView, CALayer
 @note $(view).borderWidth(1) 等价于 $(view.layer).borderWidth(1)
 */
- (ShortCocoa * (^)(CGFloat))borderWidth;

/**
 设置 UIView / CALayer 的 cornerRadius
 
 @note 支持的被包装对象：UIView, CALayer
 @note $(view).corners() 等价于 $(view.layer).corners()
 */
- (ShortCocoa * (^)(CGFloat))corners;

/**
 设置 UILabel / UIButton 的文字
 
 @note 支持的被包装对象：UILabel, UIButton
 @note 传入值支持 NSString, NSAttributedString 或 NSNumber，详见 ShortCocoaString
 
 @code
 
 // 等价于 [[UILabel new] setText:@"abc"]
 $(UILabel).text(@"abc");
 
 // 等价于 [[UILabel new] setAttributedText:attrString]
 $(UILabel).text(attrString);
 
 // 等价于 [[UIButton new] setTitle:@"abc" forState:UIControlStateNormal]
 $(UIButton).text(@"abc");
 
 // 等价于 [[UIButton new] setAttributedTitle:attrString forState:UIControlStateNormal]
 $(UIButton).text(attrString);
 
 @endcode
 */
- (ShortCocoa * (^)(_Nullable ShortCocoaString))text;

/**
 设置 UIImageView / UIButton 的图片
 
 @note 支持的被包装对象：UIImageView, UIButton
 @note 传入值支持 UIImage 或 NSString(图片名字)，详见 ShortCocoaImage
 
 @code
 
 // 等价于 [[UIButton new] setImage:image forState:UIControlStateNormal]
 $(UIButton).image(image);
 
 // 等价于 [[UIImageView new] setImage:image]
 $(UIImageView).image(image);
 
 @endcode
 */
- (ShortCocoa * (^)(ShortCocoaImage _Nullable))image;


/**
 等价于 view.userInteractionEnabled
 
 @note 支持的被包装对象：UIView
 */
- (ShortCocoa * (^)(BOOL))userInteractionEnabled;

/**
 设置 UIScrollView.scrollIndicatorInsets.top
 @note 支持的被包装对象：UIScrollView
 */
- (ShortCocoa * (^)(CGFloat))indicatorInsetTop;
/**
 设置 UIScrollView.scrollIndicatorInsets.left
 @note 支持的被包装对象：UIScrollView
 */
- (ShortCocoa * (^)(CGFloat))indicatorInsetLeft;
/**
 设置 UIScrollView.scrollIndicatorInsets.bottom
 @note 支持的被包装对象：UIScrollView
 */
- (ShortCocoa * (^)(CGFloat))indicatorInsetBottom;
/**
 设置 UIScrollView.scrollIndicatorInsets.right
 @note 支持的被包装对象：UIScrollView
 */
- (ShortCocoa * (^)(CGFloat))indicatorInsetRight;

/**
 设置 UIScrollView.contentInset 或 UIButton.contentEdgeInsets
 @note 支持的被包装对象：UIScrollView, UIButton
 */
- (ShortCocoa * (^)(ShortCocoaQuad))insets;
/**
 设置 UIScrollView.contentInset 或 UIButton.contentEdgeInsets 的 top 值
 @note 支持的被包装对象：UIScrollView, UIButton
 */
- (ShortCocoa * (^)(CGFloat))insetTop;
/**
 设置 UIScrollView.contentInset 或 UIButton.contentEdgeInsets 的 left 值
 @note 支持的被包装对象：UIScrollView, UIButton
 */
- (ShortCocoa * (^)(CGFloat))insetLeft;
/**
 设置 UIScrollView.contentInset 或 UIButton.contentEdgeInsets 的 bottom 值
 @note 支持的被包装对象：UIScrollView, UIButton
 */
- (ShortCocoa * (^)(CGFloat))insetBottom;
/**
 设置 UIScrollView.contentInset 或 UIButton.contentEdgeInsets 的 right 值
 @note 支持的被包装对象：UIScrollView, UIButton
 */
- (ShortCocoa * (^)(CGFloat))insetRight;

#endif

@end
