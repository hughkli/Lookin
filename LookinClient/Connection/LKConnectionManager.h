//
//  LKConnectionManager.h
//  Lookin
//
//  Created by Li Kai on 2018/11/2.
//  https://lookin.work
//

#import <Foundation/Foundation.h>
#import "ECOChannelManager.h"
#import "Lookin_PTChannel.h"

@class LKConnectionRequest;

@protocol LookinChannelProtocol <NSObject>

@property (readonly) BOOL isConnected;

@property(nonatomic, strong) NSMutableSet<LKConnectionRequest *> *activeRequests;

@end

/**
 iOS 是 Server 端，macOS 是 Client 端
 
 - 把 app 退到后台不会 kill 掉 server channel，仍旧会占用着端口（但可能无法执行代码）
 - 把 app kill 掉后，server channel 也会被 kill，端口占用会被释放
 
 - 一台电脑上的所有模拟器里的所有 app 共享同一批端口（在 Lookin 里是 47164 ～ 47169 这 6 个），比如依次启动“模拟器 A 的 app1”、“模拟器 A 的 app2”、“模拟器 B 的 app3”，则它们依次会占用 47164、47165、47166 这几个端口
 - 一台真机上的所有 app 共享同一批端口（在 Lookin 里是 47175 ~ 47179 这 5 个），比如依次启动“真机 A 的 app1”、“真机 A 的 app2”、“真机 B 的 app3”，则它们依次会占用 47175、47176、47175（注意不是 47177）这几个端口
 
 */
@interface LKConnectionManager : NSObject

+ (instancetype)sharedInstance;

/// 尝试连接所有可能的 Simulator 和 USB 端口，data 为数组，内含所有成功连接的 Lookin_PTChannel（虽然成功连接但是 app 可能在后台之类的无法执行代码）
/// 该方法不会 sendError
- (RACSignal *)tryToConnectAllPorts;

/// 返回的 data 为 RACTuple<LookinConnectionResponseAttachment *, Lookin_PTChannel *>
/// 在调用该方法发请求时，如果已有相同 type 的旧 request 尚未返回结果，则之前的旧 request 会被报告 Error，然后被丢弃
- (RACSignal *)requestWithType:(unsigned int)requestType data:(NSObject *)requestData channel:(Lookin_PTChannel *)channel;

/// 取消先前使用 requestWithType:data:channel: 方法发送的尚未完成的 request，这个 request 会被报告为 completion
- (void)cancelRequestWithType:(unsigned int)requestType channel:(Lookin_PTChannel *)channel;

/// 如果发送的消息不需要 server 端回复，则请使用该方法而非 requestWithType:
/// 如果此时 server 端不在前台或处于断点等模式，则 server 端可能无法收到该消息
- (void)pushWithType:(unsigned int)pushType data:(NSObject *)requestData channel:(Lookin_PTChannel *)channel;

/// 即将关闭某个 channel，一般是因为 server 端断开（比如 iOS app 被 kill 掉或 USB 被拔掉）
@property(nonatomic, strong, readonly) RACSubject *channelWillEnd;

/// 收到了 server 端发送的 push 消息，tuple 分别为 channel, pushType, data
@property(nonatomic, strong, readonly) RACSubject *didReceivePush;

@end

@interface Lookin_PTChannel (LKConnection) <LookinChannelProtocol>

/// 已经发送但尚未收到全部回复的请求
@property(nonatomic, strong) NSMutableSet<LKConnectionRequest *> *activeRequests;

@end

@interface ECOChannelDeviceInfo (LKConnection) <LookinChannelProtocol>

/// 已经发送但尚未收到全部回复的请求
@property(nonatomic, strong) NSMutableSet<LKConnectionRequest *> *activeRequests;

@end
