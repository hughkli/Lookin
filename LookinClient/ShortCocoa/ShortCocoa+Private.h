//
//  ShortCocoa+Private.h
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

#define ShortCocoaEqualClass(object, CLASS) [object isKindOfClass:[CLASS class]]

NS_ASSUME_NONNULL_BEGIN

@interface ShortCocoa (Private)

/**
 遍历 self.get，并将其中类型为 classA 的对象传入 handlerA 中
 */
- (void)unpack:(Class)classA do:(void (^)(id obj, BOOL *stop))handlerA;

/**
 遍历 self.get，并将其中类型为 classA 的对象传入 handlerA 中，将类型为 classB 的对象传入 handlerB 中
 */
- (void)unpackClassA:(Class)classA doA:(void (^)(id obj, BOOL *stop))handlerA classB:(nullable Class)classB doB:(nullable void (^)(id obj, BOOL *stop))handlerB;

/// 辅助进行字符串相关的处理
@property(nonatomic, strong) NSMutableAttributedString *cachedAttrString;

@end

@interface ShortCocoaHelper : NSObject

// 获取 string 的 NSParagraphStyle，如果不存在则创建一个新的
+ (NSMutableParagraphStyle *)paragraphStyleForAttributedString:(NSAttributedString *)string;

/// 将 ShortCocoaQuad 转换为 @[@10, @20, @30, @40] 这样的数组
+ (nullable NSArray<NSNumber *> *)fourNumbersFromShortCocoaQuad:(nullable ShortCocoaQuad)obj;

/**
 将 ShortCocoaString 转换为 NSMutableAttributedString
 @note 如果传入参数不合法则返回 nil
 */
+ (nullable NSMutableAttributedString *)attrStringFromShortCocoaString:(nullable ShortCocoaString)obj;

#if TARGET_OS_IPHONE

/// 将 ShortCocoaColor 转换为 UIColor
+ (nullable UIColor *)colorFromShortCocoaColor:(nullable ShortCocoaColor)obj;
/// 将 ShortCocoaImage 转换为 UIImage
+ (nullable UIImage *)imageFromShortCocoaImage:(nullable ShortCocoaImage)obj;
/// 将 ShortCocoaFont 转换为 UIFont
+ (nullable UIFont *)fontFromShortCocoaFont:(nullable ShortCocoaFont)obj;

#elif TARGET_OS_MAC

/// 将 ShortCocoaColor 转换为 NSColor
+ (nullable NSColor *)colorFromShortCocoaColor:(nullable ShortCocoaColor)obj;
/// 将 ShortCocoaImage 转换为 NSImage
+ (nullable NSImage *)imageFromShortCocoaImage:(nullable ShortCocoaImage)obj;
/// 将 ShortCocoaFont 转换为 NSFont
+ (nullable NSFont *)fontFromShortCocoaFont:(nullable ShortCocoaFont)obj;

#endif

@end

NS_ASSUME_NONNULL_END
