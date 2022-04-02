//
//  LKConnectionRequest.h
//  Lookin
//
//  Created by Li Kai on 2019/6/24.
//  https://lookin.work
//

#import <Foundation/Foundation.h>

@interface LKConnectionRequest : NSObject

@property(nonatomic, assign) uint32_t type;

@property(nonatomic, assign) uint32_t tag;

@property(nonatomic, assign) NSUInteger receivedDataCount;

@property(nonatomic, copy) void (^succBlock)(id);

@property(nonatomic, copy) void (^completionBlock)(void);

@property(nonatomic, copy) void (^failBlock)(NSError *);

/**
 调用 resetTimeoutCount 开始倒计时，如果 timeoutInterval 时间内没有通过 endTimeoutCount 结束倒计时，则 timeoutBlock 会被调用
 */

/// 超时时间，必须先设置该属性
@property(nonatomic, assign) NSTimeInterval timeoutInterval;
/// 超时后，该 block 会被调用
@property(nonatomic, copy) void (^timeoutBlock)(LKConnectionRequest *request);
/// 开始或重设倒计时
- (void)resetTimeoutCount;
/// 结束倒计时。在试图销毁该 LKConnectionRequest 对象前必须先调用该方法结束倒计时
- (void)endTimeoutCount;

@end
