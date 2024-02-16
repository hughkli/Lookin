//
//  LKStaticAsyncUpdateManager.m
//  Lookin
//
//  Created by Li Kai on 2019/2/19.
//  https://lookin.work
//

#import "LKStaticAsyncUpdateManager.h"
#import "LookinDisplayItem.h"
#import "LKAppsManager.h"
#import "LKStaticHierarchyDataSource.h"
#import "LookinDisplayItemDetail.h"
#import "LKPreferenceManager.h"
#import "LKProgressIndicatorView.h"
#import "LookinHierarchyInfo.h"
#import "LookinStaticAsyncUpdateTask.h"
#import "LKNavigationManager.h"
#import "LKPerformanceReporter.h"
#import "LookinDisplayItem+LookinClient.h"
#import "LKPreferenceManager.h"

@interface LKStaticAsyncUpdateManager ()

@property(nonatomic, assign) BOOL isSyncing;

@end

@implementation LKStaticAsyncUpdateManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LKStaticAsyncUpdateManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        _updateAll_ProgressSignal = [RACSubject subject];
        _updateAll_CompletionSignal = [RACSubject subject];
        _updateAll_ErrorSignal = [RACSubject subject];
        _modifyingUpdateProgressSignal = [RACSubject subject];
        _modifyingUpdateErrorSignal = [RACSubject subject];
        
        @weakify(self);
        [RACObserve([LKStaticHierarchyDataSource sharedInstance], displayingFlatItems) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self _handleDisplayingFlatItemsChange:x];
        }];
    }
    return self;
}

- (void)updateAll {
    LKInspectableApp *app = [LKAppsManager sharedInstance].inspectingApp;
    if (!app || !self.dataSource.flatItems.count) {
        return;
    }
    
    self.isSyncing = YES;
    
    [self.updateAll_ProgressSignal sendNext:[RACTuple tupleWithObjects:@0, @0, nil]];
    
    NSArray<LookinStaticAsyncUpdateTask *> *tasks = [self _makeScreenshotsAndAttrGroupsTasks];
    NSArray<LookinStaticAsyncUpdateTasksPackage *> *packages = [self _makePackagesFromTasks:tasks];
    
    NSUInteger totalTasksCount = tasks.count;
    __block NSUInteger receivedTasksCount = 0;
    @weakify(self);
    [[app fetchHierarchyDetailWithTaskPackages:packages] subscribeNext:^(NSArray<LookinDisplayItemDetail *> *details) {
        @strongify(self);
        [details enumerateObjectsUsingBlock:^(LookinDisplayItemDetail * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            [[LKStaticHierarchyDataSource sharedInstance] modifyWithDisplayItemDetail:detail];
        }];
        receivedTasksCount += details.count;
        [self.updateAll_ProgressSignal sendNext:[RACTuple tupleWithObjects:@(receivedTasksCount), @(totalTasksCount), nil]];
        
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        if (error.code == LookinErrCode_PingFailForTimeout) {
            error = LookinErrorMake(NSLocalizedString(@"Failed to sync screenshots due to the request timeout.", nil), LookinErrorText_Timeout);
        } else if (error.code == LookinErrCode_Timeout) {
            NSString *msgTitle = [NSString stringWithFormat:NSLocalizedString(@"Failed to sync remaining %@ screenshots due to the request timeout.", nil), @(totalTasksCount - receivedTasksCount)];
            NSString *msgDetail = NSLocalizedString(@"Perhaps your iOS app is paused with breakpoint in Xcode, blocked by other tasks in main thread, or moved to background state.\nToo large screenshots may also lead to this error.", nil);
            error = LookinErrorMake(msgTitle, msgDetail);
        }
        [self.updateAll_CompletionSignal sendNext:nil];
        [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
            // 此时可能 StaticViewController 还没来得及被初始化导致错误 tips 显示不出来，所以稍等一下
            [self.updateAll_ErrorSignal sendNext:error];
        }];
        self.isSyncing = NO;
    } completed:^{
        // 注意，用户手动取消请求后，也会走到这里
        @strongify(self);
        [self.updateAll_CompletionSignal sendNext:nil];
        self.isSyncing = NO;
        
        [LKPerformanceReporter.sharedInstance didComplete];
    }];
}

- (BOOL)updateForItemsIfNeed:(NSArray<LookinDisplayItem *> *)items forced:(BOOL)forced {
    LKInspectableApp *app = [LKAppsManager sharedInstance].inspectingApp;
    if (!app || !self.dataSource.flatItems.count || self.isSyncing) {
        return NO;
    }
    
    NSArray<LookinStaticAsyncUpdateTask *> *tasks = [self _makeScreenshotsAndAttrGroupsTasksByItems:items forced:forced];
    if (tasks.count == 0) {
        return NO;
    }
    self.isSyncing = YES;
    
    [self.updateAll_ProgressSignal sendNext:[RACTuple tupleWithObjects:@0, @0, nil]];
    
    NSArray<LookinStaticAsyncUpdateTasksPackage *> *packages = [self _makePackagesFromTasks:tasks];
    
    NSUInteger totalTasksCount = tasks.count;
    __block NSUInteger receivedTasksCount = 0;
    @weakify(self);
    [[app fetchHierarchyDetailWithTaskPackages:packages] subscribeNext:^(NSArray<LookinDisplayItemDetail *> *details) {
        @strongify(self);
        [details enumerateObjectsUsingBlock:^(LookinDisplayItemDetail * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            [[LKStaticHierarchyDataSource sharedInstance] modifyWithDisplayItemDetail:detail];
        }];
        receivedTasksCount += details.count;
        [self.updateAll_ProgressSignal sendNext:[RACTuple tupleWithObjects:@(receivedTasksCount), @(totalTasksCount), nil]];
        
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        if (error.code == LookinErrCode_PingFailForTimeout) {
            error = LookinErrorMake(NSLocalizedString(@"Failed to sync screenshots due to the request timeout.", nil), LookinErrorText_Timeout);
        } else if (error.code == LookinErrCode_Timeout) {
            NSString *msgTitle = [NSString stringWithFormat:NSLocalizedString(@"Failed to sync remaining %@ screenshots due to the request timeout.", nil), @(totalTasksCount - receivedTasksCount)];
            NSString *msgDetail = NSLocalizedString(@"Perhaps your iOS app is paused with breakpoint in Xcode, blocked by other tasks in main thread, or moved to background state.\nToo large screenshots may also lead to this error.", nil);
            error = LookinErrorMake(msgTitle, msgDetail);
        }
        [self.updateAll_CompletionSignal sendNext:nil];
        [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
            // 此时可能 StaticViewController 还没来得及被初始化导致错误 tips 显示不出来，所以稍等一下
            [self.updateAll_ErrorSignal sendNext:error];
        }];
        self.isSyncing = NO;
    } completed:^{
        // 注意，用户手动取消请求后，也会走到这里
        @strongify(self);
        [self.updateAll_CompletionSignal sendNext:nil];
        self.isSyncing = NO;
        
        [LKPerformanceReporter.sharedInstance didComplete];
    }];
    return YES;
}

- (void)endUpdatingAll {
    [InspectingApp cancelHierarchyDetailFetching];
}

- (NSArray<LookinStaticAsyncUpdateTask *> *)_makeScreenshotsAndAttrGroupsTasks {
    NSMutableArray<LookinStaticAsyncUpdateTask *> *tasks = [(NSArray<LookinDisplayItem *> *)self.dataSource.displayingFlatItems lookin_map:^id(NSUInteger idx, LookinDisplayItem *item) {
        if (item.isUserCustom) {
            return nil;
        }
        if (item.doNotFetchScreenshotReason == LookinFetchScreenshotPermitted) {
            if (item.isExpandable && item.isExpanded) {
                return [self _taskFromDisplayItem:item type:LookinStaticAsyncUpdateTaskTypeSoloScreenshot];
            } else {
                return [self _taskFromDisplayItem:item type:LookinStaticAsyncUpdateTaskTypeGroupScreenshot];
            }
            
        } else {
            return [self _taskFromDisplayItem:item type:LookinStaticAsyncUpdateTaskTypeNoScreenshot];
        }
    }].mutableCopy;
    
    if ([LKPreferenceManager mainManager].refreshMode == LookinRefreshModeAllItems) {
        [self.dataSource.flatItems enumerateObjectsUsingBlock:^(LookinDisplayItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            if (item.isUserCustom) {
                return;
            }
            if (item.doNotFetchScreenshotReason != LookinFetchScreenshotPermitted) {
                LookinStaticAsyncUpdateTask *task = [self _taskFromDisplayItem:item type:LookinStaticAsyncUpdateTaskTypeNoScreenshot];
                if (![tasks containsObject:task]) {
                    [tasks addObject:task];
                }
                
            } else {
                LookinStaticAsyncUpdateTask *task = [self _taskFromDisplayItem:item type:LookinStaticAsyncUpdateTaskTypeGroupScreenshot];
                if (![tasks containsObject:task]) {
                    [tasks addObject:task];
                }
                
                if (item.isExpandable) {
                    LookinStaticAsyncUpdateTask *task2 = [self _taskFromDisplayItem:item type:LookinStaticAsyncUpdateTaskTypeSoloScreenshot];
                    if (![tasks containsObject:task2]) {
                        [tasks addObject:task2];
                    }
                }
            }
        }];
    }
    
    return tasks.copy;
}

- (NSArray<LookinStaticAsyncUpdateTask *> *)_makeScreenshotsAndAttrGroupsTasksByItems:(NSArray<LookinDisplayItem *> *)items forced:(BOOL)forced {
    NSArray<LookinStaticAsyncUpdateTask *> *tasks = [items lookin_map:^id(NSUInteger idx, LookinDisplayItem *item) {
        if (item.isUserCustom) {
            return nil;
        }
        if (!forced) {
            if ((item.soloScreenshot != nil && item.isExpanded)
                || (item.groupScreenshot != nil && !item.isExpanded)
                || !item.shouldCaptureImage
                || (item.frame.size.width == 0 || item.frame.size.height == 0)) {
                return nil;
            }
        }
        if (item.doNotFetchScreenshotReason == LookinFetchScreenshotPermitted) {
            if (item.isExpandable && item.isExpanded) {
                return [self _taskFromDisplayItem:item type:LookinStaticAsyncUpdateTaskTypeSoloScreenshot];
            } else {
                return [self _taskFromDisplayItem:item type:LookinStaticAsyncUpdateTaskTypeGroupScreenshot];
            }
            
        } else {
            return [self _taskFromDisplayItem:item type:LookinStaticAsyncUpdateTaskTypeNoScreenshot];
        }
    }];
    return tasks;
}

- (NSArray<LookinStaticAsyncUpdateTasksPackage *> *)_makePackagesFromTasks:(NSArray<LookinStaticAsyncUpdateTask *> *)tasks {
    NSMutableArray<LookinStaticAsyncUpdateTasksPackage *> *packages = [NSMutableArray array];
    NSMutableArray<LookinStaticAsyncUpdateTask *> *bufferTasks = [NSMutableArray array];
    
    __block NSUInteger packageTotalArea = 0;
    NSUInteger packageMaxArea = 2000000;
    NSUInteger packageMaxTasksCount = 100;
    [tasks enumerateObjectsUsingBlock:^(LookinStaticAsyncUpdateTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat currentArea = task.frameSize.width * task.frameSize.height;
        if ((packageTotalArea + currentArea > packageMaxArea) || bufferTasks.count >= packageMaxTasksCount) {
            if (bufferTasks.count > 0) {
                packageTotalArea = 0;
                LookinStaticAsyncUpdateTasksPackage *package = [LookinStaticAsyncUpdateTasksPackage new];
                package.tasks = bufferTasks;
                [packages addObject:package];
                [bufferTasks removeAllObjects];
            }
        }
        
        packageTotalArea += currentArea;
        [bufferTasks addObject:task];
    }];
    
    if (bufferTasks.count) {
        LookinStaticAsyncUpdateTasksPackage *package = [LookinStaticAsyncUpdateTasksPackage new];
        package.tasks = bufferTasks;
        [packages addObject:package];
    }
    return packages.copy;
}

- (LookinStaticAsyncUpdateTask *)_taskFromDisplayItem:(LookinDisplayItem *)item type:(LookinStaticAsyncUpdateTaskType)type {
    LookinStaticAsyncUpdateTask *task = [LookinStaticAsyncUpdateTask new];
    task.oid = item.layerObject.oid;
    task.frameSize = item.frame.size;
    task.taskType = type;
    task.clientReadableVersion = [LKHelper lookinReadableVersion];
    return task;
}

- (void)_handleDisplayingFlatItemsChange:(NSArray<LookinDisplayItem *> *)items {
    if (!self.isSyncing) {
        return;
    }
    LKInspectableApp *app = [LKAppsManager sharedInstance].inspectingApp;
    if (!app || !items.count) {
        return;
    }
    NSArray<LookinStaticAsyncUpdateTask *> *tasks = [(NSArray<LookinDisplayItem *> *)self.dataSource.displayingFlatItems lookin_map:^id(NSUInteger idx, LookinDisplayItem *item) {
        if (item.doNotFetchScreenshotReason != LookinFetchScreenshotPermitted) {
            return [self _taskFromDisplayItem:item type:LookinStaticAsyncUpdateTaskTypeNoScreenshot];
        } else if (item.isExpandable && item.isExpanded) {
            return [self _taskFromDisplayItem:item type:LookinStaticAsyncUpdateTaskTypeSoloScreenshot];
        } else {
            return [self _taskFromDisplayItem:item type:LookinStaticAsyncUpdateTaskTypeGroupScreenshot];
        }
    }];
    NSArray<LookinStaticAsyncUpdateTasksPackage *> *packages = [self _makePackagesFromTasks:tasks];
    [app pushHierarchyDetailBringForwardTaskPackages:packages];
}

- (void)updateAfterModifyingDisplayItem:(LookinDisplayItem *)displayItem {
    LKInspectableApp *app = [LKAppsManager sharedInstance].inspectingApp;
    if (!app) {
        return;
    }
    if (!displayItem) {
        NSAssert(NO, @"");
        return;
    }
    
    NSMutableArray<LookinStaticAsyncUpdateTask *> *tasks = [NSMutableArray array];
    [displayItem enumerateSelfAndAncestors:^(LookinDisplayItem *item, BOOL *stop) {
        if (item.doNotFetchScreenshotReason != LookinFetchScreenshotPermitted) {
            return;
        }
        if (item == displayItem && item.subitems.count) {
            LookinStaticAsyncUpdateTask *task = [self _taskFromDisplayItem:item type:LookinStaticAsyncUpdateTaskTypeSoloScreenshot];
            [tasks addObject:task];
        }
        LookinStaticAsyncUpdateTask *task2 = [self _taskFromDisplayItem:item type:LookinStaticAsyncUpdateTaskTypeGroupScreenshot];
        [tasks addObject:task2];
    }];
    
    [self.modifyingUpdateProgressSignal sendNext:[RACTwoTuple tupleWithObjectsFromArray:@[@0, @0]]];
    
    @weakify(self);
    NSUInteger screenshotsTotalCount = tasks.count;
    __block NSUInteger receivedScreenshotsCount = 0;
    [[app fetchModificationPatchWithTasks:tasks] subscribeNext:^(LookinDisplayItemDetail *detail) {
        @strongify(self);
        [[LKStaticHierarchyDataSource sharedInstance] modifyWithDisplayItemDetail:detail];
        
        if (detail.groupScreenshot) {
            receivedScreenshotsCount++;
        }
        if (detail.soloScreenshot) {
            receivedScreenshotsCount++;
        }
        [self.modifyingUpdateProgressSignal sendNext:[RACTwoTuple tupleWithObjectsFromArray:@[@(receivedScreenshotsCount), @(screenshotsTotalCount)]]];
        
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        NSAssert(NO, @"");
        [self.modifyingUpdateProgressSignal sendError:error];
        
    } completed:^{
        @strongify(self);
        NSAssert(screenshotsTotalCount == screenshotsTotalCount, @"");
        [self.modifyingUpdateProgressSignal sendNext:[RACTwoTuple tupleWithObjectsFromArray:@[@(screenshotsTotalCount), @(screenshotsTotalCount)]]];
    }];
}

- (LKStaticHierarchyDataSource *)dataSource {
    return [LKStaticHierarchyDataSource sharedInstance];
}

@end
