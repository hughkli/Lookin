//
//  LKDashboardViewController.h
//  Lookin
//
//  Created by Li Kai on 2018/8/6.
//  https://lookin.work
//

#import <Cocoa/Cocoa.h>

@class LKHierarchyDataSource, LKStaticHierarchyDataSource, LookinAttribute, LKReadHierarchyDataSource;

@interface LKDashboardViewController : LKBaseViewController

- (instancetype)initWithStaticDataSource:(LKStaticHierarchyDataSource *)dataSource;

- (instancetype)initWithReadDataSource:(LKReadHierarchyDataSource *)dataSource;

- (LKHierarchyDataSource *)currentDataSource;

- (RACSignal *)modifyAttribute:(LookinAttribute *)attribute newValue:(id)newValue;

/// 如果为 YES 则表示当前使用的是 StaticDataSource 而非 ReadDataSource
@property(nonatomic, assign, readonly) BOOL isStaticMode;

@end
