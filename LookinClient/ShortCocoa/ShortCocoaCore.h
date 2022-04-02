//
//  ShortCocoaCore.h
//  ShortCocoa
//
//  Copyright © 2018年 hughkli. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 通过 $(...) 将任何对象包装为 ShortCocoa 对象，进而使用链式语法
 */
@interface ShortCocoa : NSObject {
    @protected
    id _get;
}

/**
 将一个或多个对象包装为一个 ShortCocoa 对象
 
 @warning 传入的 count 值必须和传入的 object 的参数数量保持一致，否则会导致 Crash
 @note 不推荐使用这个繁琐的语法，请使用 $(...) 这个宏
 
 @param count 在 object 里传入的参数数量
 @param object 被包装的对象
 */
- (instancetype)initWithObjectsCount:(uint)count objects:(nullable id)object,...;

/**
 获取被 ShortCocoa 包装的原始对象
 
 一种常见的使用场景：
 @code
 self.label = $(UILabel).text(@"Hello").addTo(self.view).get;
 @endcode
 
 各种情况的返回值：
 @code
 
 $(self.label).get; // => self.label
 
 $(label1, nil, label2).get; // => @[label1, label2]
 
 $(UIView).get;     // => [UIView new]，即返回一个 UIView 的实例
 
 @endcode
 
 */
@property(nonatomic, strong, readonly, nullable) id get;

@end

NS_ASSUME_NONNULL_END

/**
 便利的 ShortCocoa 初始化方法，该参数的第一个传入值 something 可以为对象也可以为 Class，从而实现了 $(UIView) 这种写法
 @note 该方法因为有 ShortCocoa 的前缀命名空间因此更加安全，主要在 ShortCocoa 内部使用。外部请使用更便利的 $(...) 方法
 */
#define ShortCocoaMake(something, ...) [[ShortCocoa alloc] initWithObjectsCount:(ShortCocoaCountArgs(ShortCocoaMakeInstance([something self]), ##__VA_ARGS__)) objects:ShortCocoaMakeInstance([something self]), ##__VA_ARGS__]

/**
 在编译时计算传入的参数数量，从而实现 $(label1, label2) 这种写法，即参数数量不确定而又无需在末尾标注 nil 等符号
 @note 如果没有传入任何参数则返回 1
 @warning 最多支持传入 63 个参数，并非无限
 */
#define ShortCocoaCountArgs(...) ShortCocoaCountArgs1(__VA_ARGS__,ShortCocoaCountArgs2())
#define ShortCocoaCountArgs1(...) ShortCocoaCountArgs3(__VA_ARGS__)
#define ShortCocoaCountArgs3( \
_1, _2, _3, _4, _5, _6, _7, _8, _9,_10, \
_11,_12,_13,_14,_15,_16,_17,_18,_19,_20, \
_21,_22,_23,_24,_25,_26,_27,_28,_29,_30, \
_31,_32,_33,_34,_35,_36,_37,_38,_39,_40, \
_41,_42,_43,_44,_45,_46,_47,_48,_49,_50, \
_51,_52,_53,_54,_55,_56,_57,_58,_59,_60, \
_61,_62,_63,N,...) N
#define ShortCocoaCountArgs2() \
63,62,61,60,                   \
59,58,57,56,55,54,53,52,51,50, \
49,48,47,46,45,44,43,42,41,40, \
39,38,37,36,35,34,33,32,31,30, \
29,28,27,26,25,24,23,22,21,20, \
19,18,17,16,15,14,13,12,11,10, \
9,8,7,6,5,4,3,2,1,0

/**
 如果传入 Class 则返回该 Class 的一个实例，否则直接将传入的参数返回
 */
id ShortCocoaMakeInstance(id object);
