//
//  LKDashboardAccessoryWindowController.h
//  Lookin
//
//  Created by Li Kai on 2019/8/30.
//  https://lookin.work
//

#import "LKWindowController.h"
#import "LookinAttrIdentifiers.h"

@class LookinAttributesSection, LKDashboardViewController, LKDashboardAccessoryWindowController;

@protocol LKDashboardAccessoryWindowControllerDelegate <NSObject>

- (void)dashboardAccessoryWindowControllerWillClose:(LKDashboardAccessoryWindowController *)controller;

@end

@interface LKDashboardAccessoryWindowController : LKWindowController

@property(nonatomic, weak) id<LKDashboardAccessoryWindowControllerDelegate> delegate;

/// contentSize 是内容所需的窗口大小，由该方法返回
- (instancetype)initWithDashboardController:(LKDashboardViewController *)dashboardController attrGroupID:(LookinAttrGroupIdentifier)groupID;

- (NSSize)renderWithAttrSections:(NSArray<LookinAttributesSection *> *)sections;

@end
