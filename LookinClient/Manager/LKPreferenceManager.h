//
//  LKPreferenceManager.h
//  Lookin
//
//  Created by Li Kai on 2019/1/8.
//  https://lookin.work
//

#import <Foundation/Foundation.h>
#import "LookinAttributesGroup.h"
#import "LKExportManager.h"
#import "LookinMsgAttribute.h"

extern NSString *const LKWindowSizeName_Dynamic;
extern NSString *const LKWindowSizeName_Static;

/// 初始的 preview scale
extern const CGFloat LKInitialPreviewScale;

typedef NS_ENUM(NSInteger, LookinPreferredAppeanranceType) {
    LookinPreferredAppeanranceTypeDark,
    LookinPreferredAppeanranceTypeLight,
    LookinPreferredAppeanranceTypeSystem
};


typedef NS_ENUM(NSInteger, LookinDoubleClickBehavior) {
    LookinDoubleClickBehaviorCollapse,
    LookinDoubleClickBehaviorFocus
};

typedef NS_ENUM(NSInteger, LookinPreferredCallStackType) {
    LookinPreferredCallStackTypeDefault,    // 格式化 + 简略
    LookinPreferredCallStackTypeFormattedCompletely, // 格式化 + 完整
    LookinPreferredCallStackTypeRaw    // 原始堆栈
};

@interface LKPreferenceManager : NSObject

+ (instancetype)mainManager;

/// 默认为 NO
@property(nonatomic, assign) BOOL shouldStoreToLocal;

/// 仅在 macOS 10.14 及以后上生效
@property(nonatomic, assign) LookinPreferredAppeanranceType appearanceType;

@property(nonatomic, assign) LookinDoubleClickBehavior doubleClickBehavior;

/// 有效值为 0 ～ 4
@property(nonatomic, assign) NSInteger expansionIndex;

@property(nonatomic, strong, readonly) LookinBOOLMsgAttribute *showOutline;

@property(nonatomic, strong, readonly) LookinBOOLMsgAttribute *showHiddenItems;

// 范围是 0 ～ 1
@property(nonatomic, strong, readonly) LookinDoubleMsgAttribute *zInterspace;

@property(nonatomic, assign) BOOL enableReport;

@property(nonatomic, assign) BOOL rgbaFormat;

/// 0 ~ 2
@property(nonatomic, assign) NSInteger imageContrastLevel;

/// 是否自动将选中的 UIView/CALayer 作为控制台的目标对象
@property(nonatomic, assign) BOOL syncConsoleTarget;

// 被折叠的 AttrGroup
@property(nonatomic, copy) NSArray<LookinAttrGroupIdentifier> *collapsedAttrGroups;

@property(nonatomic, assign) CGFloat preferredExportCompression;

@property(nonatomic, strong, readonly) LookinBOOLMsgAttribute *freeRotation;

/// 上次接收到 iOS app 里传过来的 color config 和 collapsedClasses 信息的时间，用来统计
@property(nonatomic, assign) NSTimeInterval receivingConfigTime_Color;
@property(nonatomic, assign) NSTimeInterval receivingConfigTime_Class;

/// 返回某个 section 是否应该被显示在主界面上
- (BOOL)isSectionShowing:(LookinAttrSectionIdentifier)secID;
/// 把某个 section 显示在主界面上
- (void)showSection:(LookinAttrSectionIdentifier)secID;
/// 把某个 section 从主界面上移除
- (void)hideSection:(LookinAttrSectionIdentifier)secID;
/// 当某个 section 被添加或移除时，会发出该通知
extern NSString *const NotificationName_DidChangeSectionShowing;

#pragma mark - 以下属性不会持久化

@property(nonatomic, assign) LookinPreferredCallStackType callStackType;

@property(nonatomic, strong, readonly) LookinIntegerMsgAttribute *previewDimension;

@property(nonatomic, strong, readonly) LookinDoubleMsgAttribute *previewScale;

/// param 里的 userInfo 为 NSNumber(BOOL)，如果为 YES 则表示本次 measure 是由快捷键触发的
@property(nonatomic, strong, readonly) LookinBOOLMsgAttribute *isMeasuring;

/// 是否用户正在按住 cmd 键而处于快速选择模式
@property(nonatomic, strong, readonly) LookinBOOLMsgAttribute *isQuickSelecting;

/// 如果之前没弹过“双击图层时你希望发生什么？”这个框，则这个方法会弹框且返回 YES。否则该方法什么都不会做且返回 NO
+ (BOOL)popupToAskDoubleClickBehaviorIfNeededWithWindow:(NSWindow *)window;

- (void)reset;

- (void)reportStatistics;

@end
