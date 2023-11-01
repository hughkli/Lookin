//
//  LKPreviewView.h
//  Lookin
//
//  Created by Li Kai on 2019/8/17.
//  https://lookin.work
//

#import <SceneKit/SceneKit.h>

extern const CGFloat LookinPreviewMinScale;
extern const CGFloat LookinPreviewMaxScale;

extern const CGFloat LookinPreviewMaxZInterspace;
extern const CGFloat LookinPreviewMinZInterspace;

typedef NS_ENUM (NSUInteger, LookinPreviewDimension) {
    LookinPreviewDimension2D,
    LookinPreviewDimension3D
};

@class LookinDisplayItem, LKPreferenceManager, LKHierarchyDataSource;

@interface LKPreviewView : SCNView

- (instancetype)initWithDataSource:(LKHierarchyDataSource *)dataSource;

/// rotation.x 是左右旋转的角度，rotation.y 是上下旋转的角度
@property(nonatomic, assign, readonly) CGPoint rotation;
- (void)setRotation:(CGPoint)rotation animated:(BOOL)animated;
/// duration 为 0 时表示使用系统默认时长（即 0.25s）
- (void)setRotation:(CGPoint)rotation animated:(BOOL)animated timingFunction:(CAMediaTimingFunction *)function duration:(CGFloat)duration;

/// 上下移动的距离
@property(nonatomic, assign) CGPoint translation;

/// 图像大小，最小值是 LookinPreviewMinScale，最大值是 LookinPreviewMaxScale
@property(nonatomic, assign) CGFloat scale;

/// 图层之间的纵向间距，最小值是 LookinPreviewMinZInterspace，最大值是 LookinPreviewMaxZInterspace
@property(nonatomic, assign) CGFloat zInterspace;

/**
 设置 2D 和 3D 模式
 置为 2D 会使得 rotation 变成 0，置为 3D 不会改变 rotation
 */
@property(nonatomic, assign, readonly) LookinPreviewDimension dimension;
- (void)setDimension:(LookinPreviewDimension)dimension animated:(BOOL)animated;

/// iOS App 的屏幕大小
@property(nonatomic, assign) CGSize appScreenSize;

@property(nonatomic, strong) LKPreferenceManager *preferenceManager;

/// 通过 items 来构建对应的 node，items 里不应该包含 noPreview 为 YES 的 item
/// 如果 discardCache 为 YES，则会丢弃本次渲染未用到的 node 对象。如果 discardCache 为 NO，则本次渲染未用到的 node 对象会被隐藏起来但不会被丢弃，从而供以后使用
- (void)renderWithDisplayItems:(NSArray<LookinDisplayItem *> *)items discardCache:(BOOL)discardCache;

- (void)updateZPosition;

- (LookinDisplayItem *)displayItemAtPoint:(CGPoint)point;

- (void)didSelectItem:(LookinDisplayItem *)item;

@property(nonatomic, assign) BOOL isDarkMode;

@property(nonatomic, assign) BOOL showHiddenItems;

@end
