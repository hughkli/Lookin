//
//  LKConsoleSelectPopoverController.h
//  Lookin
//
//  Created by Li Kai on 2019/6/19.
//  https://lookin.work
//

#import "LKBaseViewController.h"

@class LKConsoleDataSource;

@interface LKConsoleSelectPopoverController : LKBaseViewController

- (instancetype)initWithDataSource:(LKConsoleDataSource *)dataSource;

- (CGFloat)bestHeight;

- (void)reRender;

@property(nonatomic, copy) void (^needShowError)(NSError *error);
@property(nonatomic, copy) void (^needClose)(void);

@end
