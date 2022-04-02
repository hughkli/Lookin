//
//  LKHierarchyController.h
//  Lookin
//
//  Created by Li Kai on 2019/5/12.
//  https://lookin.work
//

#import "LKBaseViewController.h"
#import "LKHierarchyView.h"

@class LKHierarchyDataSource;

@interface LKHierarchyController : LKBaseViewController <LKHierarchyViewDelegate>

- (instancetype)initWithDataSource:(LKHierarchyDataSource *)dataSource;

@property(nonatomic, strong, readonly) LKHierarchyDataSource *dataSource;

@property(nonatomic, strong, readonly) LKHierarchyView *hierarchyView;

- (NSView *)currentSelectedRowView;

@end
