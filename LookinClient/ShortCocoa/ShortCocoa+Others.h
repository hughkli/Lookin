//
//  ShortCocoa+Others.h
//  ShortCocoa
//
//  Copyright © 2018年 hughkli. All rights reserved.
//

#import "ShortCocoaCore.h"
#import "ShortCocoaDefines.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Appkit/Appkit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface ShortCocoa (Others)

/**
 设置 UILabel / UIButton 的文字颜色，或者给 NSAttributedString 添加 NSForegroundColorAttributeName
 
 @note 支持的被包装对象：UILabel, UIButton, 以及 ShortCocoaString
 @note 传入值支持 UIColor 或 RGB, RGBA, HEX 或 @"red" 等字符串，详见 ShortCocoaColor 定义
 
 @code
 
 // 等价于 [[UILabel new] setTextColor:redColor]
 $(UILabel).textColor(redColor);
 
 // 等价于 [[UIButton new] setTitleColor:redColor forState:UIControlStateNormal]
 $(UIButton).textColor(redColor);
 
 // 等价于 [NSAttributedString alloc] initWithString:@"abc" attributes:@{NSForegroundColorAttributeName:color}
 $(@"abc").textColor(color).attrString;
 
 @endcode
 */
- (ShortCocoa * (^)(_Nullable ShortCocoaColor))textColor;

/**
 设置 UILabel / UIButton 的文字字体，或者给 NSAttributedString 添加 NSFontAttributeName
 
 @note 支持的被包装对象：UILabel, UIButton, 以及 ShortCocoaString
 @note 传入值支持 UIFont、@"15" 这种字符串、或 @15 这种 NSNumber，详见 ShortCocoaFont 定义
 
 @code
 
 // 等价于 [[UILabel new] setFont:fontObject]
 $(UILabel).font(fontObject);
 
 // 等价于 [UIButton new].titleLabel.font = [UIFont systemFontOfSize:15];
 $(UIButton).font(@15);
 
 // 等价于 [NSAttributedString alloc] initWithString:@"abc" attributes:@{NSFontAttributeName:font}
 $(@"abc").font(font).attrString;
 
 @endcode
 */
- (ShortCocoa * (^)(_Nullable ShortCocoaFont))font;

/**
 设置 UILabel / UIButton 的文字为 NSTextAlignmentLeft，或者给 NSAttributedString 的 NSParagraphStyle 设置文字对齐方式为 NSTextAlignmentLeft
 */
- (ShortCocoa *)textAlignLeft;
/**
 设置 UILabel / UIButton 的文字为 NSTextAlignmentCenter，或者给 NSAttributedString 的 NSParagraphStyle 设置文字对齐方式为 NSTextAlignmentCenter
 */
- (ShortCocoa *)textAlignCenter;
/**
 设置 UILabel / UIButton 的文字为 NSTextAlignmentRight，或者给 NSAttributedString 的 NSParagraphStyle 设置文字对齐方式为 NSTextAlignmentRight
 */
- (ShortCocoa *)textAlignRight;

/**
 设置 UILabel / UIButton 的 lineBreakMode，或者给 NSAttributedString 的 NSParagraphStyle 设置 lineBreakMode
 */
- (ShortCocoa * (^)(NSLineBreakMode))lineBreakMode;

/**
 将被包装对象中非 nil 的对象放到一个数组中并返回，如果被包装对象全部为 nil 则返回 nil
 
 @code
 // => @[@"a", @"b"]
 $(@"a", nil, @"b").array;
 
 //=> @[visibleView]，visibles 方法 剔除被隐藏的 view
 $(visibleView, nil, hiddenView).visibles.array;
 @endcode
 */
- (NSArray *)array;

@end

NS_ASSUME_NONNULL_END
