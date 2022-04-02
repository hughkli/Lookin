//
//  LKDeviceManager.h
//  Lookin
//
//  Created by Li Kai on 2018/11/3.
//  https://lookin.work
//

#import <Foundation/Foundation.h>
#import "LKInspectableApp.h"

extern NSString *const LKInspectingAppDidEndNotificationName;

@interface LKAppsManager : NSObject

+ (instancetype)sharedInstance;

/// 获取当前所有可查看的 iOS app
/// needImages 是否需要返回截图和图标，不需要则可加快速度
/// localInfos 本地已经存在的 appInfos，传入该参数从而可增量更新
/// data 为 NSArray<LKInspectableApp *>，该方法不会 sendError
- (RACSignal *)fetchAppInfosWithImage:(BOOL)needImages localInfos:(NSArray<LookinAppInfo *> *)localInfos;

@property(nonatomic, strong) LKInspectableApp *inspectingApp;

/// 断开后自动重连成功
@property(nonatomic, strong, readonly) RACSubject *didAutoReconnectSucc;

@end
