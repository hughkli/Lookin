//
//  LKReloadItemAndChildrenUpdateTaskMaker.m
//  LookinClient
//
//  Created by likai.123 on 2024/3/3.
//  Copyright © 2024 hughkli. All rights reserved.
//

#import "LKReloadItemAndChildrenUpdateTaskMaker.h"
#import "LKStaticAsyncUpdateManager.h"
#import "LKAppsManager.h"
#import "LKVersionComparer.h"

@implementation LKReloadItemAndChildrenUpdateTaskMaker

+ (NSArray<LookinStaticAsyncUpdateTask *> *)makeWithItem:(LookinDisplayItem *)item {
    if (!item || [LKStaticAsyncUpdateManager sharedInstance].isUpdating) {
        NSAssert(NO, @"");
        return nil;
    }
    NSString *serverVersion = [[LKAppsManager sharedInstance] inspectingApp].appInfo.serverReadableVersion;
    BOOL supported = [LKVersionComparer compareWithExpectedVersion:@"1.2.7" realVersion:serverVersion];
    if (!supported) {
        AlertErrorText(NSLocalizedString(@"Operation failed.", nil), NSLocalizedString(@"Please upgrade the LookinServer SDK version in your iOS project to 1.2.7 or higher.", nil), CurrentKeyWindow);
        return nil;
    }
    LookinStaticAsyncUpdateTask *task = [LookinStaticAsyncUpdateTask new];
    task.oid = item.layerObject.oid;
    task.taskType = LookinStaticAsyncUpdateTaskTypeNoScreenshot;
    task.attrRequest = LookinDetailUpdateTaskAttrRequest_NotNeed;
    task.needBasisVisualInfo = YES;
    task.needSubitems = YES;
    task.frameSize = item.frame.size;
    task.clientReadableVersion = [LKHelper lookinReadableVersion];
    return @[task];
}

@end
