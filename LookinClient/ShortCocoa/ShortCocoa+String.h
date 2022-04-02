//
//  ShortCocoa+String.h
//  ShortCocoa
//
//  Copyright © 2018年 hughkli. All rights reserved.
//

#import "ShortCocoaCore.h"
#import "ShortCocoaDefines.h"
#import <CoreGraphics/CoreGraphics.h>

@interface ShortCocoa (String)

/**
 将被包装对象转换为 NSString 并返回
 
 @code
 $(@"abc").string;  // => @"abc"
 @endcode
 */
- (nullable NSString *)string;

/**
 将被包装对象转换为 NSAttributedString 并返回
 
 @code
 // => [[NSAttributedString alloc] initWithString:@"abc"]
 $(@"abc").attrString;
 @endcode
 */
- (nullable NSAttributedString *)attrString;

/**
 将被包装对象转换为 NSMutableAttributedString 并返回
 
 @code
 // => [[NSMutableAttributedString alloc] initWithString:@"abc"]
 $(@"abc").mAttrString;
 @endcode
 */
- (nullable NSMutableAttributedString *)mAttrString;

/**
 在开头添加字符串
 
 @note 传入参数支持 ShortCocoa, NSString, NSAttributedString, NSNumber，详见 ShortCocoaString
 @code
 $(@"bc").prepend(@"a").string; // => @"abc"
 @endcode
 */
- (ShortCocoa * (^)(_Nullable ShortCocoaString))prepend;

/**
 在指定位置添加字符串
 
 @note 传入参数支持 ShortCocoa, NSString, NSAttributedString, NSNumber，详见 ShortCocoaString
 @code
 $(@"ac").insert(@"b", 1).string; // => @"abc"
 @endcode
 */
- (ShortCocoa * (^)(_Nullable ShortCocoaString, NSUInteger location))insert;

/**
 在末尾添加字符串
 
 @note 传入参数支持 ShortCocoa, NSString, NSAttributedString, NSNumber，详见 ShortCocoaString
 @code
 $(@"ab").add(@"c").string; // => @"abc"
 @endcode
 */
- (ShortCocoa * (^)(_Nullable ShortCocoaString))add;

/**
 在末尾添加一张图片
 
 @note 图片传入值支持 UIImage 或 NSString(图片名字)，详见 ShortCocoaImage
 @note 通过 baselineOffset 调整图片的上下偏移（值越大则图片越靠上），通过 marginLeft 和 marginRight 调整图片左右的间距
 @attention 内部实现是通过 NSTextAttachment 的原理添加图片
 
 @code
 // 末尾添加 image 图片，图片的 baselineOffset 为 2，距离左侧文字距离为 3，距离右侧文字距离为 4
 $(@"abc").addImage(image, 2, 3, 4);
 @endcode
 */
- (ShortCocoa * (^)(_Nullable ShortCocoaImage image, CGFloat baselineOffset, CGFloat marginLeft, CGFloat marginRight))addImage;

/**
 在末尾增加一段长度为 width 的空白图片，一般用来精确调整字符之间的间距
 */
- (ShortCocoa * (^)(CGFloat width))addSpace;

/**
 设置行高
 
 @note 具体实现是添加一个 NSParagraphStyle 并设置它的 minimumLineHeight/maximumLineHeight
 
 @code
 $(@"abc").lineHeight(30).attrString;
 @endcode
 */
- (ShortCocoa * (^)(CGFloat))lineHeight;

/**
 添加 NSBaselineOffsetAttributeName
 
 @code
 // => 等价于 [addAttributes:@{NSBaselineOffsetAttributeName: @2} range:NSMakeRange(0, @"abc".length)]
 $(@"abc").baselineOffset(2).attrString;
 @endcode
 */
- (ShortCocoa * (^)(CGFloat))baselineOffset;

/**
 添加 NSBaselineOffsetAttributeName (NSUnderlineStyleSingle)
 
 @code
 // => 等价于 [addAttributes:@{NSBaselineOffsetAttributeName: @(NSUnderlineStyleSingle)} range:NSMakeRange(0, @"abc".length)]
 $(@"abc").strikethrough.attrString;
 @endcode
 */
- (ShortCocoa *)strikethrough;

/**
 添加 NSKernAttributeName
 
 @code
 // => 等价于 [addAttributes:@{NSKernAttributeName: @2} range:NSMakeRange(0, @"abc".length)]
 $(@"abc").kern(2).attrString;
 @endcode
 */
- (ShortCocoa * (^)(CGFloat))kern;

/**
 添加 NSKernAttributeName
 
 @code
 // => 等价于 [addAttributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)} range:NSMakeRange(0, @"abc".length)]
 $(@"abc").underline.attrString;
 @endcode
 */
- (ShortCocoa *)underline;

@end
