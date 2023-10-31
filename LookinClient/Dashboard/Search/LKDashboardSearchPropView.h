//
//  LKDashboardSearchPropView.h
//  Lookin
//
//  Created by Li Kai on 2019/9/5.
//  https://lookin.work
//

#import "LKDashboardSearchCardView.h"
#import "LookinAttrIdentifiers.h"

@class LookinAttribute, LKDashboardSearchPropView;

@protocol LKDashboardSearchPropViewDelegate <NSObject>

- (void)dashboardSearchPropView:(LKDashboardSearchPropView *)view didClickRevealAttribute:(LookinAttribute *)attr;

@end

@interface LKDashboardSearchPropView : LKDashboardSearchCardView

@property(nonatomic, weak) id<LKDashboardSearchPropViewDelegate> delegate;

- (void)renderWithAttribute:(LookinAttribute *)attribute;

@end
