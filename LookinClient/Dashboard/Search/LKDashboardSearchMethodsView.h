//
//  LKDashboardSearchMethodsView.h
//  Lookin
//
//  Created by Li Kai on 2019/9/6.
//  https://lookin.work
//

#import "LKDashboardSearchCardView.h"

@class LKDashboardSearchMethodsView;

@protocol LKDashboardSearchMethodsViewDelegate <NSObject>

- (void)dashboardSearchMethodsView:(LKDashboardSearchMethodsView *)view requestToInvokeMethod:(NSString *)method oid:(unsigned long)oid;

@end

@interface LKDashboardSearchMethodsView : LKDashboardSearchCardView

@property(nonatomic, weak) id<LKDashboardSearchMethodsViewDelegate> delegate;

- (void)renderWithMethods:(NSArray<NSString *> *)methods oid:(unsigned long)oid;

- (void)renderWithError:(NSError *)error;

@end
