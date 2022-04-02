//
//  ShortCocoa+Layout.h
//  ShortCocoa
//
//  Copyright © 2018年 hughkli. All rights reserved.
//

#import "ShortCocoaCore.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Appkit/Appkit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 如果注释中不做特殊说明，则此文件里这些方法均同时支持 UIView/NSView 和 CALayer
 
 @warning 使用这一系列布局方法时会自动像素对齐来获得更好的渲染效果，比如在一个屏幕 scale 为 2 的设备上，你写下 $(view).x(0.3)，则实际上 view.frame.origin 会被设置为 0.5，详情参看 ShortCocoa+Layout.m 里的 CGFloatSnapToPixel 的注释
 */
@interface ShortCocoa (Layout)

#pragma mark - 基础方法

/// 等价于调用系统控件的 sizeToFit 方法，支持的被包装对象：UIView(iOS)、NSControl(macOS)，
- (ShortCocoa *)sizeToFit;

/// 修改 frame.size.width
- (ShortCocoa * (^)(CGFloat))width;
/// 修改 frame.size.height
- (ShortCocoa * (^)(CGFloat))height;
/// 修改 frame.size
- (ShortCocoa * (^)(CGSize))size;
/// 修改 frame
- (ShortCocoa * (^)(CGRect))frame;
/// 修改 frame.origin.x，size 不会被改变
- (ShortCocoa * (^)(CGFloat))x;
/// 修改 frame 的 midX 位置，size 不会被改变
- (ShortCocoa * (^)(CGFloat))midX;
/// 修改 frame 的 maxX 位置，size 不会被改变
- (ShortCocoa * (^)(CGFloat))maxX;
/// 修改 frame.origin.y，size 不会被改变
- (ShortCocoa * (^)(CGFloat))y;
/// 修改 frame 的 midY 位置，size 不会被改变
- (ShortCocoa * (^)(CGFloat))midY;
/// 修改 frame 的 maxY 位置，size 不会被改变
- (ShortCocoa * (^)(CGFloat))maxY;
/// 修改 frame.origin，size 不会被改变
- (ShortCocoa * (^)(CGPoint))origin;
/// 修改 frame 的 origin，使得右侧和 superview 的右侧的距离为传入值，size 不会被改变
- (ShortCocoa * (^)(CGFloat))right;
///修改 frame 的 origin，使得底部和 superview 的底部的距离为传入值，size 不会被改变
- (ShortCocoa * (^)(CGFloat))bottom;
/// 修改 frame 的 origin，使得在 superview 里水平居中，size 不会被改变
- (ShortCocoa *)horAlign;
/// 修改 frame 的 origin，使得在 superview 里垂直居中，size 不会被改变
- (ShortCocoa *)verAlign;
/// 修改 frame 的 origin，使得在 superview 里同时保持垂直、水平居中，size 不会被改变
- (ShortCocoa *)centerAlign;
/// 修改 frame 使得在水平方向上撑满父元素，即把 x 设置为 0，把 width 设置为 superview/superlayer 的 width
- (ShortCocoa *)fullWidth;
/// 修改 frame 使得在竖直方向上撑满父元素，即把 y 设置为 0，把 height 设置为 superview/superlayer 的 height
- (ShortCocoa *)fullHeight;
/// 修改 frame 为 superview.bounds 或 superlayer.bounds
- (ShortCocoa *)fullFrame;

/// 偏移 frame 的 origin，size 不会被改变
- (ShortCocoa * (^)(CGFloat x, CGFloat y))offset;
/// 偏移 frame 的 origin.x，size 不会被改变
- (ShortCocoa * (^)(CGFloat))offsetX;
/// 偏移 frame 的 origin.y，size 不会被改变
- (ShortCocoa * (^)(CGFloat))offsetY;

#pragma mark - to 系列

/// 调整左侧边的位置，其它三条边位置不动
- (ShortCocoa * (^)(CGFloat))toX;
/// 调整右侧边的位置，其它三条边位置不动，origin 不会被改变
- (ShortCocoa * (^)(CGFloat))toMaxX;
/// 调整顶部边的位置，其它三条边位置不动
- (ShortCocoa * (^)(CGFloat))toY;
/// 调整底部边的位置，其它三条边位置不动，origin 不会被改变
- (ShortCocoa * (^)(CGFloat))toMaxY;
/// 保持其它三条边位置不动的情况下，仅调整右侧边的位置，使得右侧距离 superview 右侧的距离为传入值，origin 不会被改变
- (ShortCocoa * (^)(CGFloat))toRight;
/// 保持其它三条边位置不动的情况下，仅调整底部边的位置，使得底部距离 superview 底部的距离为传入值，origin 不会被改变
- (ShortCocoa * (^)(CGFloat))toBottom;


#pragma mark - Group Set 系列

/**
 包装了多个对象时，被包装的 view/layer 会被看作一个整体来调整 frame.origin.x
 @code
 // 1）布局靠左的 label 会被平移至 x 为 50 的位置
 // 2）另一个 label 会被平移相同的距离
 // 3）两个 label 之间的距离不会被改变，它们的 size 也不会被改变
 $(label1, label2).groupX(50);
 @endcode
 */
- (ShortCocoa * (^)(CGFloat))groupX;
/**
 包装了多个对象时，被包装的 view/layer 会被看作一个整体来调整 frame 的 midX
 @code
 // 1）两个 label 会被平移至它们整体的 midX 为 50 的位置
 // 2）两个 label 之间的距离不会改变，它们的 size 也不会被改变
 $(label1, label2).groupMidX(50);
 @endcode
 */
- (ShortCocoa * (^)(CGFloat))groupMidX;
/**
 包装了多个对象时，被包装的 view/layer 会被看作一个整体来调整 frame 的 maxX
 @code
 // 1）布局靠右的 label 会被平移至 maxX 为 50 的位置
 // 2）另一个 label 会被平移相同的距离
 // 3）两个 label 之间的距离不会被改变，它们的 size 也不会被改变
 $(label1, label2).groupMaxX(50);
 @endcode
 */
- (ShortCocoa * (^)(CGFloat))groupMaxX;
/**
 包装了多个对象时，被包装的 view/layer 会被看作一个整体来调整 frame.origin.y
 @code
 // 1）布局靠上的 label 会被平移至 y 为 50 的位置
 // 2）另一个 label 会被平移相同的距离
 // 3）两个 label 之间的距离不会被改变，它们的 size 也不会被改变
 $(label1, label2).groupY(50);
 @endcode
 */
- (ShortCocoa * (^)(CGFloat))groupY;
/**
 包装了多个对象时，被包装的 view/layer 会被看作一个整体来调整 frame 的 midY
 @code
 // 1）两个 label 会被平移至它们整体的 midY 为 50 的位置
 // 2）两个 label 之间的距离不会改变，它们的 size 也不会被改变
 $(label1, label2).groupMidY(50);
 @endcode
 */
- (ShortCocoa * (^)(CGFloat))groupMidY;
/**
 包装了多个对象时，被包装的 view/layer 会被看作一个整体来调整 frame 的 maxX
 @code
 // 1）布局靠下的 label 会被平移至 maxY 为 50 的位置
 // 2）另一个 label 会被平移相同的距离
 // 3）两个 label 之间的距离不会被改变，它们的 size 也不会被改变
 $(label1, label2).groupMaxY(50);
 @endcode
 */
- (ShortCocoa * (^)(CGFloat))groupMaxY;
/**
 包装了多个对象时，被包装的 view/layer 会被看作一个整体来调整 frame.origin
 @code
 // 1）两个 label 会被平移至它们整体的左上角 origin 为传入值的位置
 // 2）两个 label 之间的距离不会被改变，它们的 size 也不会被改变
 $(label1, label2).groupOrigin(point);
 @endcode
 */
- (ShortCocoa * (^)(CGPoint))groupOrigin;
/**
 包装了多个对象时，被包装的 view/layer 会被看作一个整体来调整它们右侧距离 superview 右侧的值
 @code
 // 1）布局靠右的 label 会被平移至它的右侧和 superview 右侧之间距离为 50 的位置
 // 2）另一个 label 会被平移相同的距离
 // 3）两个 label 之间的距离不会被改变，它们的 size 也不会被改变
 $(label1, label2).groupRight(50);
 @endcode
 */
- (ShortCocoa * (^)(CGFloat))groupRight;
/**
 包装了多个对象时，被包装的 view/layer 会被看作一个整体来调整它们底部距离 superview 底部的值
 @code
 // 1）布局靠下的 label 会被平移至它的底部和 superview 底部之间距离为 50 的位置
 // 2）另一个 label 会被平移相同的距离
 // 3）两个 label 之间的距离不会被改变，它们的 size 也不会被改变
 $(label1, label2).groupBottom(50);
 @endcode
 */
- (ShortCocoa * (^)(CGFloat))groupBottom;
/**
 包装了多个对象时，被包装的 view/layer 会整体水平居中
 @code
 // 1）两个 label 会被平移至它们整体的 midX 为 superview 的水平中点位置
 // 2）两个 label 之间的距离不会改变，它们的 size 也不会被改变
 $(label1, label2).groupHorAlign;
 @endcode
 */
- (ShortCocoa *)groupHorAlign;
/**
 包装了多个对象时，被包装的 view/layer 会整体垂直居中
 @code
 // 1）两个 label 会被平移至它们整体的 midY 为 superview 的垂直中点位置
 // 2）两个 label 之间的距离不会改变，它们的 size 也不会被改变
 $(label1, label2).groupVerAlign;
 @endcode
 */
- (ShortCocoa *)groupVerAlign;
/**
 包装了多个对象时，被包装的 view/layer 会整体垂直、水平居中
 @code
 // 1）两个 label 会被平移至它们整体的 midX、midY 为 superview 的中点位置
 // 2）两个 label 之间的距离不会改变，它们的 size 也不会被改变
 $(label1, label2).groupCenterAlign();
 @endcode
 */
- (ShortCocoa *)groupCenterAlign;

#pragma mark - Group Get 系列

/// 被包装的所有 view/layer 会被看作一个整体，该方法返回这个整体的 frame 的 minX 值（即被包装的所有对象的 frame 的 x 的最小值）
- (CGFloat)$groupX;
/// 被包装的所有 view/layer 会被看作一个整体，该方法返回这个整体的 midX 值
- (CGFloat)$groupMidX;
/// 被包装的所有 view/layer 会被看作一个整体，该方法返回这个整体的 frame 的 maxX 值（即被包装的所有对象的 frame 的 maxX 的最大值）
- (CGFloat)$groupMaxX;
/// 被包装的所有 view/layer 会被看作一个整体，该方法返回这个整体的 frame 的 minY 值（即被包装的所有对象的 frame 的 y 的最小值）
- (CGFloat)$groupY;
/// 被包装的所有 view/layer 会被看作一个整体，该方法返回这个整体的 midY 值
- (CGFloat)$groupMidY;
/// 被包装的所有 view/layer 会被看作一个整体，该方法返回这个整体的 frame 的 maxY 值（即被包装的所有对象的 frame 的 maxY 的最大值）
- (CGFloat)$groupMaxY;
/// 返回一个 CGPoint，值为 {$groupX, $groupY}
- (CGPoint)$groupOrigin;
/// 被包装的所有 view/layer 会被看作一个整体，该方法返回这个整体的 size 值
- (CGSize)$groupSize;
/// 被包装的所有 view/layer 会被看作一个整体，该方法返回这个整体的 width 值
- (CGFloat)$groupWidth;
/// 被包装的所有 view/layer 会被看作一个整体，该方法返回这个整体的 height 值
- (CGFloat)$groupHeight;

#pragma mark - sizeThatFits 系列

/**
 将高度设置为当前自身宽度下 sizeThatFits: 返回的高度值，即 [view sizeThatFits:CGSizeMake(CGRectGetWidth(view.bounds), CGFLOAT_MAX)].height
 @note 支持的被包装对象：UIView(iOS)、NSControl(macOS)
 */
- (ShortCocoa *)heightToFit;
/**
 将高度设置为当前自身宽度下 sizeThatFits: 返回的高度值，即 [view sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(view.bounds))].width
 @note 支持的被包装对象：UIView(iOS)、NSControl(macOS)
 */
- (ShortCocoa *)widthToFit;

@end

#if TARGET_OS_IPHONE
@interface UIView (ShortCocoaLayout)
#elif TARGET_OS_MAC
@interface NSView (ShortCocoaLayout)
#endif

/// 等价于 view.frame.origin.x
- (CGFloat)$x;
/// 等价于 CGRectGetMidX(view.frame)
- (CGFloat)$midX;
/// 等价于 CGRectGetMaxX(view.frame)
- (CGFloat)$maxX;
/// 等价于 view.origin.y
- (CGFloat)$y;
/// 等价于 CGRectGetMidY(view.frame)
- (CGFloat)$midY;
/// 等价于 CGRectGetMaxY(view.frame)
- (CGFloat)$maxY;
/// 等价于 view.frame.size.width
- (CGFloat)$width;
/// 等价于 view.frame.size.height
- (CGFloat)$height;
/// 等价于 view.frame.size
- (CGSize)$size;

#if TARGET_OS_IPHONE
/// 等价于 [view sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)]
- (CGSize)$bestSize;
/// 等价于 [view sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width
- (CGFloat)$bestWidth;
/// 等价于 [view sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].height
- (CGFloat)$bestHeight;
#endif

@end

@interface CALayer (ShortCocoaLayout)

/// 等价于 layer.frame.origin.x
- (CGFloat)$x;
/// 等价于 CGRectGetMidX(layer.frame)
- (CGFloat)$midX;
/// 等价于 CGRectGetMaxX(view.frame)
- (CGFloat)$maxX;
/// 等价于 view.origin.y
- (CGFloat)$y;
/// 等价于 CGRectGetMidY(view.frame)
- (CGFloat)$midY;
/// 等价于 CGRectGetMaxY(view.frame)
- (CGFloat)$maxY;
/// 等价于 view.frame.size.width
- (CGFloat)$width;
/// 等价于 view.frame.size.height
- (CGFloat)$height;
/// 等价于 view.frame.size
- (CGSize)$size;

@end

NS_ASSUME_NONNULL_END
