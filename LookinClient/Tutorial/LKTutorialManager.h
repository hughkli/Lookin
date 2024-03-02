//
//  LKTutorialManager.h
//  Lookin
//
//  Created by Li Kai on 2019/6/27.
//  https://lookin.work
//

#import <Foundation/Foundation.h>

@interface LKTutorialManager : NSObject

+ (instancetype)sharedInstance;

@property(nonatomic, assign) BOOL togglePreview;

@property(nonatomic, assign) BOOL quickSelection;

@property(nonatomic, assign) BOOL moveWithSpace;

@property(nonatomic, assign) BOOL copyTitle;

@property(nonatomic, assign) BOOL eventsHandler;

@property(nonatomic, assign) BOOL hasAskedDoubleClickBehavior;

/// 当用户点击了“知道了，不再提示”导致弹框关闭，或者弹框出现 2 秒后才被关闭时，learnedBlock 会被调用
- (void)showPopoverOfView:(NSView *)view text:(NSString *)text learned:(void (^)(void))learnedBlock;

/// 标记 Lookin 本次启动之后是否有展示过任何 tutorial tips，每次启动尽量只显示一次 tutorial tips
@property(nonatomic, assign) BOOL hasAlreadyShowedTipsThisLaunch;

@end
