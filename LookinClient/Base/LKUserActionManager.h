//
//  LKUserActionManager.h
//  Lookin
//
//  Created by Li Kai on 2019/8/30.
//  https://lookin.work
//

#import <Foundation/Foundation.h>

@class LKUserActionManager;

typedef NS_ENUM(NSInteger, LKUserActionType) {
    LKUserActionType_None,
    LKUserActionType_PreviewOperation,  // 在 preview 里执行了 click、double click、pan 之类的操作
    LKUserActionType_DashboardClick,    // 点击了 dashboard
    LKUserActionType_SelectedItemChange,    // selectedItem 改变了
};

@protocol LKUserActionManagerDelegate <NSObject>

/// 当 sendAction 被业务调用时，该 delegate 方法也会被调用
- (void)LKUserActionManager:(LKUserActionManager *)manager didAct:(LKUserActionType)type;

@end

@interface LKUserActionManager : NSObject

+ (instancetype)sharedInstance;

/// 业务调用该方法
- (void)sendAction:(LKUserActionType)type;

/// delegate 不会被该类强引用，也无需在 delegate 对象被 dealloc 时设法 removeDelegate 之类的，相同的 delegate 被重复添加只会视为被添加一次
- (void)addDelegate:(id<LKUserActionManagerDelegate>)delegate;

@end
