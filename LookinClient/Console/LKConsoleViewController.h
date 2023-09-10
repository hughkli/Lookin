//
//  LKConsoleViewController.h
//  Lookin
//
//  Created by Li Kai on 2019/4/19.
//  https://lookin.work
//

#import "LKBaseViewController.h"

@class LookinObject, LKHierarchyDataSource;

@interface LKConsoleViewController : LKBaseViewController

- (instancetype)initWithHierarchyDataSource:(LKHierarchyDataSource *)dataSource;

@property(nonatomic, assign) BOOL isControllerShowing;

- (void)submitWithObj:(LookinObject *)obj text:(NSString *)text;

@end
