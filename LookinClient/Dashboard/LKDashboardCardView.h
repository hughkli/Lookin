//
//  LKDashboardCardView.h
//  Lookin
//
//  Created by Li Kai on 2018/11/18.
//  https://lookin.work
//

#import "LKBaseView.h"
#import "LookinDisplayItem.h"
#import "LKDashboardAttributeView.h"

@class LKDashboardViewController, LKDashboardCardView, LKDashboardSectionView;

@protocol LKDashboardCardViewDelegate <NSObject>

- (void)dashboardCardViewNeedToggleCollapse:(LKDashboardCardView *)view;

@end

@interface LKDashboardCardView : LKBaseView

@property(nonatomic, weak) LKDashboardViewController *dashboardViewController;

@property(nonatomic, weak) id<LKDashboardCardViewDelegate> delegate;

/// 用来渲染的数据，设置该属性并不会触发任何渲染之类的行为
@property(nonatomic, strong) LookinAttributesGroup *attrGroup;
/// 使用 attrGroup 属性来渲染
- (void)render;

@property(nonatomic, assign) BOOL isCollapsed;

- (LKDashboardSectionView *)querySectionViewWithSection:(LookinAttributesSection *)sec;

/// 如果 rect 为 CGRectZero，则会全部变暗
- (void)playFadeAnimationWithHighlightRect:(CGRect)rect;

@end
