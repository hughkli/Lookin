//
//  LKConstraintPopoverController.h
//  Lookin
//
//  Created by Li Kai on 2019/9/28.
//  https://lookin.work
//

#import "LKBaseViewController.h"

@class LookinAutoLayoutConstraint, LKHierarchyDataSource, LookinObject;

@interface LKConstraintPopoverController : LKBaseViewController

- (instancetype)initWithConstraint:(LookinAutoLayoutConstraint *)constraint;

- (NSSize)contentSize;

@property(nonatomic, copy) void (^requestJumpingToObject)(LookinObject *lookinObj);

@end
