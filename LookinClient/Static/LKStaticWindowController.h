//
//  LKStaticWindowController.h
//  Lookin
//
//  Created by Li Kai on 2018/11/4.
//  https://lookin.work
//

#import "LKWindowController.h"
#import "LKMenuPopoverAppsListController.h"

@class LKStaticViewController;

@interface LKStaticWindowController : LKWindowController

@property(nonatomic, strong, readonly) LKStaticViewController *viewController;

- (void)popupAllInspectableAppsWithSource:(MenuPopoverAppsListControllerEventSource)source;

@end
