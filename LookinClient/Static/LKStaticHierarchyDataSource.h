//
//  LKStaticHierarchyDataSource.h
//  Lookin
//
//  Created by Li Kai on 2018/12/21.
//  https://lookin.work
//

#import "LookinDefines.h"
#import "LKHierarchyDataSource.h"

@class LookinDisplayItemDetail, LookinStaticDisplayItem, LookinAppInfo;

@interface LKStaticHierarchyDataSource : LKHierarchyDataSource

+ (instancetype)sharedInstance;

@property(nonatomic, strong, readonly) LookinAppInfo *appInfo;

#pragma mark - Signal

/// 某些 item 的 frame 发生改变
@property(nonatomic, strong, readonly) RACSubject *itemsDidChangeFrame;

- (void)modifyWithDisplayItemDetail:(LookinDisplayItemDetail *)detail;

@end
