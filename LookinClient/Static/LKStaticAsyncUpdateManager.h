//
//  LKStaticAsyncUpdateManager.h
//  Lookin
//
//  Created by Li Kai on 2019/2/19.
//  https://lookin.work
//

#import <Foundation/Foundation.h>

@class LookinDisplayItem, LookinStaticDisplayItem;

@interface LKStaticAsyncUpdateManager : NSObject

+ (instancetype)sharedInstance;

/// 开始拉取
- (void)updateAll;
/// 终止拉取
- (void)endUpdatingAll;
/// 部分刷新
- (BOOL)updateForItemIfNeed:(LookinDisplayItem *)item;
/// 调用 updateAll 后，该 signal 会不断发出信号。data 是 RACTuple，tuple.first 是 NSNumber，表示已经收到的数据总数，tuple.second 也是 NSNumber，表示预期会接收到的数据总数
@property(nonatomic, strong, readonly) RACSubject *updateAll_ProgressSignal;
/// 调用 updateAll 且数据全部接收完成后，或遇到 error 会发出该信号
@property(nonatomic, strong, readonly) RACSubject *updateAll_CompletionSignal;
/// 调用 updateAll 后遇到 error 会发出该信号
@property(nonatomic, strong, readonly) RACSubject *updateAll_ErrorSignal;

- (void)updateAfterModifyingDisplayItem:(LookinStaticDisplayItem *)displayItem;
/// updateAfterModifyingDisplayItem 的更新进度，data 是 RACTwoTuple<NSNumber *>，分别为已经收到的图像数量、总的图像数量
@property(nonatomic, strong, readonly) RACSubject *modifyingUpdateProgressSignal;
/// updateAfterModifyingDisplayItem 遇到了错误，data 为 NSError
@property(nonatomic, strong, readonly) RACSubject *modifyingUpdateErrorSignal;

@end
