//
//  LKReadViewController.h
//  Lookin
//
//  Created by Li Kai on 2019/5/12.
//  https://lookin.work
//

#import "LKBaseViewController.h"

@class LookinHierarchyFile, LKPreferenceManager, LKReadHierarchyDataSource, LKHierarchyView;

@interface LKReadViewController : LKBaseViewController

- (instancetype)initWithFile:(LookinHierarchyFile *)file preferenceManager:(LKPreferenceManager *)manager;

@property(nonatomic, strong) LKReadHierarchyDataSource *hierarchyDataSource;

/// 获取当前的 hierarchyView
- (LKHierarchyView *)currentHierarchyView;

@end
