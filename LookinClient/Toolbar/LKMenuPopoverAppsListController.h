//
//  LKMenuPopoverAppsListController.h
//  Lookin
//
//  Created by Li Kai on 2018/11/5.
//  https://lookin.work
//

#import "LKBaseViewController.h"

@class LKInspectableApp;

typedef NS_ENUM(NSInteger, MenuPopoverAppsListControllerEventSource) {
    MenuPopoverAppsListControllerEventSourceReloadButton,
    MenuPopoverAppsListControllerEventSourceNoConnectionTips,
    MenuPopoverAppsListControllerEventSourceAppButton
};

@interface LKMenuPopoverAppsListController : LKBaseViewController

- (instancetype)initWithApps:(NSArray<LKInspectableApp *> *)apps source:(MenuPopoverAppsListControllerEventSource)source;

@property(nonatomic, copy) void (^didSelectApp)(LKInspectableApp *app);

- (NSSize)bestSize;

@end
