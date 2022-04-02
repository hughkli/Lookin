//
//  LKDashboardSectionView.h
//  Lookin
//
//  Created by Li Kai on 2019/6/7.
//  https://lookin.work
//

#import "LKBaseView.h"

@class LookinAttributesSection, LKDashboardViewController;

typedef NS_ENUM(NSInteger, LKDashboardSectionManageState) {
    LKDashboardSectionManageState_None,
    LKDashboardSectionManageState_CanAdd,
    LKDashboardSectionManageState_CanRemove
};

@interface LKDashboardSectionView : LKBaseView

@property(nonatomic, strong) LookinAttributesSection *attrSection;

@property(nonatomic, assign) BOOL showTopSeparator;

@property(nonatomic, weak) LKDashboardViewController *dashboardViewController;

@property(nonatomic, assign) LKDashboardSectionManageState manageState;

@end
