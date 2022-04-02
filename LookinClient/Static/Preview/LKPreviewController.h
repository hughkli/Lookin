//
//  LKPreviewViewController.h
//  Lookin
//
//  Created by Li Kai on 2018/8/6.
//  https://lookin.work
//

#import "LKBaseViewController.h"

@class LKHierarchyDataSource, LKStaticViewController;

@interface LKPreviewController : LKBaseViewController

- (instancetype)initWithDataSource:(LKHierarchyDataSource *)dataSource;

@property(nonatomic, weak) LKStaticViewController *staticViewController;

@end
