//
//  LKDashboardSearchInputView.h
//  Lookin
//
//  Created by Li Kai on 2019/9/5.
//  https://lookin.work
//

#import "LKBaseView.h"

@class LKDashboardSearchInputView;

@protocol LKDashboardSearchInputViewDelegate <NSObject>

- (void)dashboardSearchInputView:(LKDashboardSearchInputView *)view didToggleActive:(BOOL)isActive;

- (void)dashboardSearchInputView:(LKDashboardSearchInputView *)view didInputString:(NSString *)string;

@end

@interface LKDashboardSearchInputView : LKBaseView

@property(nonatomic, assign) BOOL isActive;

- (NSString *)currentInputString;

@property(nonatomic, weak) id<LKDashboardSearchInputViewDelegate> delegate;

@end
