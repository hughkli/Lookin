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
#import "LKVersionComparer.h"

@interface LKDetailUpdateRequest : NSObject

@property(nonatomic, copy) NSArray<LookinStaticAsyncUpdateTasksPackage *> *packages;
/// 已经收到回复的 task 的数量（但受限于目前的设计，无法知道具体是哪些 task 收到了回复）
@property(nonatomic, assign) NSInteger finishedTasksCount;
@property(nonatomic, assign) NSInteger tasksTotalCount;

@end

@implementation LKDetailUpdateRequest

- (BOOL)queryIfContainsTask:(LookinStaticAsyncUpdateTask *)task {
    for (LookinStaticAsyncUpdateTasksPackage *pack in self.packages) {
        if ([pack.tasks containsObject:task]) {
            return YES;
        }
    }
    return NO;
}

- (NSInteger)tasksTotalCount {
    NSInteger count = 0;
    for (LookinStaticAsyncUpdateTasksPackage *pack in self.packages) {
        count += pack.tasks.count;
    }
    return count;
}

@end

@interface LKStaticAsyncUpdateManager ()

/// 已经成功收到了所有回复的 request
@property(nonatomic, strong) NSMutableArray<LKDetailUpdateRequest *> *succeededRequests;
/// 已经发送出去、尚未结束的 request
@property(nonatomic, strong) LKDetailUpdateRequest *ongoingRequest;

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
        self.succeededRequests = [NSMutableArray array];
        _modifyingUpdateProgressSignal = [RACSubject subject];
        _modifyingUpdateErrorSignal = [RACSubject subject];
        
        @weakify(self);
        [[self dataSource].willReloadHierarchyInfo subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self.succeededRequests removeAllObjects];
        }];
    }
    return self;
}

- (void)updateAll {
    NSAssert(!LKPreferenceManager.mainManager.turboMode.currentBOOLValue, @"");
    
    LKInspectableApp *app = [LKAppsManager sharedInstance].inspectingApp;
    if (!app || !self.dataSource.flatItems.count) {
        return;
    }
    [self endUpdating];
    
    NSArray<LookinStaticAsyncUpdateTask *> *newTasks = [self makeMaximumTasks];
    if (newTasks.count == 0) {
        return;
    }
    [self sendTasks:newTasks];
}

- (void)endUpdating {
    if (!self.ongoingRequest) {
        return;
    }
    NSLog(@"AsyncUpdate - endUpdating");
    // 这句会触发 sendTasks 方法里的 completed 事件，进而导致 delegate 被通知
    [InspectingApp cancelHierarchyDetailFetching];
}

- (NSArray<LookinStaticAsyncUpdateTask *> *)makeMaximumTasks {
    // tasks 里的元素顺序很重要：index 更小的 task 会优先被拉取回来展示。所以我们优先把用户可见的图层加进来，这样用户体验更好
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
    
    [self.dataSource.flatItems enumerateObjectsUsingBlock:^(LookinDisplayItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (item.isUserCustom) {
            return;
        }
        if (item.doNotFetchScreenshotReason == LookinFetchScreenshotPermitted) {
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
        } else {
            LookinStaticAsyncUpdateTask *task = [self _taskFromDisplayItem:item type:LookinStaticAsyncUpdateTaskTypeNoScreenshot];
            if (![tasks containsObject:task]) {
                [tasks addObject:task];
            }
        }
    }];    
    return tasks.copy;
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

- (NSArray<LookinStaticAsyncUpdateTask *> *)makeMinimumTasksForItems:(NSArray<LookinDisplayItem *> *)items {
    NSArray<LookinStaticAsyncUpdateTask *> *tasks = [items lookin_map:^id(NSUInteger idx, LookinDisplayItem *item) {
        if (item.isUserCustom) {
            return nil;
        }
        if (item.appropriateScreenshot != nil) {
            // 已经有图像了，无需再拉取（而且既然有图像了，那么 attrs 必然也有了）
            return nil;
        }
        
        LookinStaticAsyncUpdateTask *newTask = nil;
        if (item.doNotFetchScreenshotReason == LookinFetchScreenshotPermitted) {
            // 该图层应该有图像（但是现在没有），所以应该拉取图像
            if (item.isExpandable && item.isExpanded) {
                newTask = [self _taskFromDisplayItem:item type:LookinStaticAsyncUpdateTaskTypeSoloScreenshot];
            } else {
                newTask = [self _taskFromDisplayItem:item type:LookinStaticAsyncUpdateTaskTypeGroupScreenshot];
            }
        } else {
            // 该图层确实不应该有图像
            if (item.attributesGroupList.count > 0) {
                // 有 attr 了，说明已经拉取过了，无需再次拉取
                return nil;
            } else {
                // 拉取 attr
                newTask = [self _taskFromDisplayItem:item type:LookinStaticAsyncUpdateTaskTypeNoScreenshot];
            }
        }
        if (!newTask) {
            return nil;
        }
        
        /// Client 1.0.7 & Server 1.2.7 开始支持 attrRequest 这个参数
        if (item.attributesGroupList.count == 0) {
            newTask.attrRequest = LookinDetailUpdateTaskAttrRequest_Need;
        } else {
            newTask.attrRequest = LookinDetailUpdateTaskAttrRequest_NotNeed;
        }
        
        for (LKDetailUpdateRequest *req in self.succeededRequests) {
            if ([req queryIfContainsTask:newTask]) {
                // 该 task 已经请求成功过，不再重复请求
                return nil;
            }
        }
        return newTask;
    }];
    return tasks;
}

- (void)updateForDisplayingItems {
    NSAssert(LKPreferenceManager.mainManager.turboMode.currentValue, @"");

    LKInspectableApp *app = [LKAppsManager sharedInstance].inspectingApp;
    if (!app) {
        return;
    }
    NSArray *items = [LKStaticHierarchyDataSource sharedInstance].displayingFlatItems;
    if (items.count == 0) {
        return;
    }
    NSArray<LookinStaticAsyncUpdateTask *> *newTasks = [self makeMinimumTasksForItems:items];
    if (newTasks.count == 0) {
        return;
    }
    // 相同请求不能并发，因此必须先把之前的请求先取消掉
    [self endUpdating];
    [self sendTasks:newTasks];
}

- (void)sendTasks:(NSArray<LookinStaticAsyncUpdateTask *> *)newTasks {
    LKInspectableApp *app = [LKAppsManager sharedInstance].inspectingApp;
    if (!app || newTasks.count == 0) {
        return;
    }
    NSArray<LookinStaticAsyncUpdateTasksPackage *> *packages = [self _makePackagesFromTasks:newTasks];
    self.ongoingRequest = [LKDetailUpdateRequest new];
    self.ongoingRequest.packages = packages;
    
    [self notifyTasksCountToDelegate];
    
    NSLog(@"AsyncUpdate - Will send %@ tasks.", @(newTasks.count));
    
    @weakify(self);
    [[app fetchHierarchyDetailWithTaskPackages:packages] subscribeNext:^(NSArray<LookinDisplayItemDetail *> *details) {
        @strongify(self);
        [details enumerateObjectsUsingBlock:^(LookinDisplayItemDetail * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            [[LKStaticHierarchyDataSource sharedInstance] modifyWithDisplayItemDetail:detail];
        }];
        self.ongoingRequest.finishedTasksCount += details.count;
        [self notifyTasksCountToDelegate];
        
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        self.ongoingRequest = nil;
        [self notifyTasksCountToDelegate];
        
        NSString *msgTitle = [NSString stringWithFormat:NSLocalizedString(@"Request timeout, layer data transmission failed.", nil)];
        NSString *msgDetail = NSLocalizedString(@"Perhaps your iOS app is paused with breakpoint in Xcode, blocked by other tasks in main thread, or moved to background state.\nToo large screenshots may also lead to this error.", nil);
        error = LookinErrorMake(msgTitle, msgDetail);
        [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
            // 此时可能 StaticViewController 还没来得及被初始化导致错误 tips 显示不出来，所以稍等一下
            [self.delegate detailUpdateReceivedError:error];
        }];
    } completed:^{
        // 注意，用户手动取消请求后，也会走到这里
        @strongify(self);
        if (self.ongoingRequest) {
            BOOL userCancel = (self.ongoingRequest.tasksTotalCount > self.ongoingRequest.finishedTasksCount);
            if (!userCancel) {
                [self.succeededRequests addObject:self.ongoingRequest];
            }
            self.ongoingRequest = nil;
        } else {
            NSAssert(NO, @"");
        }
        [self notifyTasksCountToDelegate];
        [LKPerformanceReporter.sharedInstance didComplete];
    }];
}

- (void)notifyTasksCountToDelegate {
    NSUInteger totalCount = 0;

    for (LookinStaticAsyncUpdateTasksPackage *pack in self.ongoingRequest.packages) {
        totalCount += pack.tasks.count;
    }
    NSUInteger finishedCount = self.ongoingRequest.finishedTasksCount;

    NSLog(@"AsyncUpdate - notify delagate: %@/%@", @(finishedCount), @(totalCount));
    [self.delegate detailUpdateTasksTotalCount:totalCount finishedCount:finishedCount];
}

@end
