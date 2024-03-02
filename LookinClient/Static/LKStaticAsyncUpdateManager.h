//
//  LKStaticAsyncUpdateManager.h
//  Lookin
//
//  Created by Li Kai on 2019/2/19.
//  https://lookin.work
//

#import <Foundation/Foundation.h>

@class LookinDisplayItem, LookinStaticDisplayItem;

@protocol LKStaticAsyncUpdateManagerDelegate <NSObject>

/// 当剩余未完成的 task 数量变化时，该方法会被调用。表示当前一共有 totalCount 个任务，其中 finishedCount 已经完成。
- (void)detailUpdateTasksTotalCount:(NSUInteger)totalCount finishedCount:(NSUInteger)finishedCount;

- (void)detailUpdateReceivedError:(NSError *)error;

@end

@interface LKStaticAsyncUpdateManager : NSObject

+ (instancetype)sharedInstance;

@property(nonatomic, weak) id<LKStaticAsyncUpdateManagerDelegate> delegate;

/// 关闭“极速模式”时，reload 之后应该调用该方法来拉取所有 items 的 detail 数据
- (void)updateAll;

/// 打开“极速模式”时，每次 displayingItems 变化时，都应该调用该方法来拉取可见 items 的 detail 数据（已经拉取过 detail 的 items 不会再次被拉取）
- (void)updateForDisplayingItems;

/// 终止拉取
- (void)endUpdating;

- (void)updateAfterModifyingDisplayItem:(LookinStaticDisplayItem *)displayItem;
/// updateAfterModifyingDisplayItem 的更新进度，data 是 RACTwoTuple<NSNumber *>，分别为已经收到的图像数量、总的图像数量
@property(nonatomic, strong, readonly) RACSubject *modifyingUpdateProgressSignal;
/// updateAfterModifyingDisplayItem 遇到了错误，data 为 NSError
@property(nonatomic, strong, readonly) RACSubject *modifyingUpdateErrorSignal;

@end
