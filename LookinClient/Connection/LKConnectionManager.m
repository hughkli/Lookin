//
//  LKConnectionManager.m
//  Lookin
//
//  Created by Li Kai on 2018/11/2.
//  https://lookin.work
//

#import "LKConnectionManager.h"
#import "Lookin_PTChannel.h"
#import "LookinDefines.h"
#import "LookinConnectionResponseAttachment.h"
#import "LKPreferenceManager.h"
#import "LookinAppInfo.h"
#import "LKConnectionRequest.h"
#import "LKServerVersionRequestor.h"

static NSIndexSet * PushFrameTypeList() {
    static NSIndexSet *list;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        list = set.copy;
    });
    return list;
}

@interface Lookin_PTChannel (LKConnection)

/// 已经发送但尚未收到全部回复的请求
@property(nonatomic, strong) NSMutableSet<LKConnectionRequest *> *activeRequests;

@end

@implementation Lookin_PTChannel (LKConnection)

- (void)setActiveRequests:(NSMutableSet<LKConnectionRequest *> *)activeRequests {
    [self lookin_bindObject:activeRequests forKey:@"activeRequest"];
}

- (NSMutableSet<LKConnectionRequest *> *)activeRequests {
    return [self lookin_getBindObjectForKey:@"activeRequest"];
}

@end

@interface LKSimulatorConnectionPort : NSObject

@property(nonatomic, assign) int portNumber;

@property(nonatomic, strong) Lookin_PTChannel *connectedChannel;

@end

@implementation LKSimulatorConnectionPort

- (NSString *)description {
    return [NSString stringWithFormat:@"number:%@", @(self.portNumber)];
}

@end

@interface LKUSBConnectionPort : NSObject

@property(nonatomic, assign) int portNumber;

@property(nonatomic, strong) NSNumber *deviceID;

@property(nonatomic, strong) Lookin_PTChannel *connectedChannel;

@end

@implementation LKUSBConnectionPort

- (NSString *)description {
    return [NSString stringWithFormat:@"number:%@, deviceID:%@, connectedChannel:%@", @(self.portNumber), self.deviceID, self.connectedChannel];
}

@end

@interface LKConnectionManager () <Lookin_PTChannelDelegate>

@property(nonatomic, copy) NSArray<LKSimulatorConnectionPort *> *allSimulatorPorts;
@property(nonatomic, strong) NSMutableArray<LKUSBConnectionPort *> *allUSBPorts;

@end

@implementation LKConnectionManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LKConnectionManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        _channelWillEnd = [RACSubject subject];
        _didReceivePush = [RACSubject subject];
        
        self.allSimulatorPorts = ({
            NSMutableArray<LKSimulatorConnectionPort *> *ports = [NSMutableArray array];
            for (int number = LookinSimulatorIPv4PortNumberStart; number <= LookinSimulatorIPv4PortNumberEnd; number++) {
                LKSimulatorConnectionPort *port = [LKSimulatorConnectionPort new];
                port.portNumber = number;
                [ports addObject:port];
            }
            ports;
        });
        self.allUSBPorts = [NSMutableArray array];
        
        [self _startListeningForUSBDevices];
        
        [[LKServerVersionRequestor shared] preload];
    }
    return self;
}

#pragma mark - Ports Connect

- (RACSignal *)tryToConnectAllPorts {
    return [[RACSignal zip:@[[self _tryToConnectAllSimulatorPorts],
                            [self _tryToConnectAllUSBDevices]]] map:^id _Nullable(RACTuple * _Nullable value) {
        RACTupleUnpack(NSArray<Lookin_PTChannel *> *simulatorChannels, NSArray<Lookin_PTChannel *> *usbChannels) = value;
        NSArray *connectedChannels = [simulatorChannels arrayByAddingObjectsFromArray:usbChannels];
        return connectedChannels;
    }];
}

/// 返回的 x 为所有已成功链接的 Lookin_PTChannel 数组，该方法不会 sendError:
- (RACSignal *)_tryToConnectAllSimulatorPorts {
    NSArray<RACSignal *> *tries = [self.allSimulatorPorts lookin_map:^id(NSUInteger idx, LKSimulatorConnectionPort *port) {
        return [[self _connectToSimulatorPort:port] catch:^RACSignal * _Nonnull(NSError * _Nonnull error) {
            return [RACSignal return:nil];
        }];
    }];
    return [[RACSignal zip:tries] map:^id _Nullable(RACTuple * _Nullable value) {
        NSArray<Lookin_PTChannel *> *connectedChannels = [value.allObjects lookin_filter:^BOOL(id obj) {
            return (obj != [NSNull null]);
        }];
        return connectedChannels;
    }];
}

/// 返回的 x 为成功链接的 Lookin_PTChannel
/// 注意，如果某个 app 被退到了后台但是没有被 kill，则在这个方法里它的 channel 仍然会被成功连接
- (RACSignal *)_connectToSimulatorPort:(LKSimulatorConnectionPort *)port {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        if (port.connectedChannel) {
            // 该 port 本来就已经成功连接
            [subscriber sendNext:port.connectedChannel];
            [subscriber sendCompleted];
            return nil;
        }
        
        Lookin_PTChannel *localChannel = [Lookin_PTChannel channelWithDelegate:self];
        [localChannel connectToPort:port.portNumber IPv4Address:INADDR_LOOPBACK callback:^(NSError *error, Lookin_PTAddress *address) {
            if (error) {
                if (error.domain == NSPOSIXErrorDomain && (error.code == ECONNREFUSED || error.code == ETIMEDOUT)) {
                    // 没有 iOS 客户端
                } else {
                    // 意外
                }
                [localChannel close];
                [subscriber sendError:error];
            } else {
                port.connectedChannel = localChannel;
                [subscriber sendNext:localChannel];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

/// 返回的 x 为所有已成功链接的 Lookin_PTChannel 数组，该方法不会 sendError:
- (RACSignal *)_tryToConnectAllUSBDevices {
    if (!self.allUSBPorts.count) {
        return [RACSignal return:[NSArray array]];
    }
    NSArray<RACSignal *> *tries = [self.allUSBPorts lookin_map:^id(NSUInteger idx, LKUSBConnectionPort *port) {
        return [[self _connectToUSBPort:port] catch:^RACSignal * _Nonnull(NSError * _Nonnull error) {
            return [RACSignal return:nil];
        }];
    }];
    return [[RACSignal zip:tries] map:^id _Nullable(RACTuple * _Nullable value) {
        NSArray<Lookin_PTChannel *> *connectedChannels = [value.allObjects lookin_filter:^BOOL(id obj) {
            return (obj != [NSNull null]);
        }];
        return connectedChannels;
    }];
}

/// 返回的 x 为成功链接的 Lookin_PTChannel
- (RACSignal *)_connectToUSBPort:(LKUSBConnectionPort *)port {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        if (port.connectedChannel) {
            // 该 port 本来就已经成功连接
            [subscriber sendNext:port.connectedChannel];
            [subscriber sendCompleted];
            return nil;
        }
        
        Lookin_PTChannel *channel = [Lookin_PTChannel channelWithDelegate:self];
        [channel connectToPort:port.portNumber overUSBHub:Lookin_PTUSBHub.sharedHub deviceID:port.deviceID callback:^(NSError *error) {
            if (error) {
                if (error.domain == Lookin_PTUSBHubErrorDomain && error.code == PTUSBHubErrorConnectionRefused) {
                    // error
                } else {
                    // error
                }
                [channel close];
                [subscriber sendError:error];
            } else {
                // succ
                port.connectedChannel = channel;
                [subscriber sendNext:channel];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

#pragma mark - Request

- (void)pushWithType:(unsigned int)pushType data:(NSObject *)data channel:(Lookin_PTChannel *)channel {
    if (!channel || !channel.isConnected) {
        return;
    }
    NSError *archiveError = nil;
    dispatch_data_t payload = [[NSKeyedArchiver archivedDataWithRootObject:data requiringSecureCoding:YES error:&archiveError] createReferencingDispatchData];
    if (archiveError) {
        NSAssert(NO, @"");
    }
    NSLog(@"LookinClient - pushData, type:%@", @(pushType));
    [channel sendFrameOfType:pushType tag:0 withPayload:payload callback:nil];
}

- (RACSignal *)requestWithType:(unsigned int)requestType data:(NSObject *)requestData channel:(Lookin_PTChannel *)channel {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        //        NSLog(@"LookinClient, level1 - will ping for request:%@, port:%@", @(type), @(channel.portNumber));
        NSTimeInterval timeoutInterval;
        if (requestType == LookinRequestTypeApp) {
            // 如果某个 iOS app 连接上了 channel 却又处于后台的话，而这个 timeout 时间又过长的话，就会导致初次进入 launch 时非常慢（因为必须等到 timeoutInterval 结束），因此这里为了体验缩小这个时间
            timeoutInterval = .5;
        } else {
            timeoutInterval = 2;
        }
        
        [self _requestWithType:LookinRequestTypePing channel:channel data:nil timeoutInterval:timeoutInterval succ:^(LookinConnectionResponseAttachment *pingResponse) {
            // ping 成功了
            // NSLog(@"LookinClient, level1 - ping succ, will send request:%@, port:%@", @(type), @(channel.portNumber));
            NSError *versionErr = [self _checkServerVersionWithResponse:pingResponse];
            if (versionErr) {
                // LookinServer 版本有问题
                [subscriber sendError:versionErr];
            } else {
                // 没问题，开始发真正请求
                [self _requestWithType:requestType channel:channel data:requestData timeoutInterval:5 succ:^(id responseData) {
                    RACTuple *tupleResult = [RACTuple tupleWithObjects:responseData, channel, nil];
                    [subscriber sendNext:tupleResult];
                } fail:^(NSError *error) {
                    [subscriber sendError:error];
                } completion:^{
                    [subscriber sendCompleted];
                }];
            }
            
        } fail:^(NSError *error) {
            // ping 失败了
            [subscriber sendError:error];
            
        } completion:nil];
        return nil;
    }];
}

- (NSError *)_checkServerVersionWithResponse:(LookinConnectionResponseAttachment *)pingResponse {
    int serverVersion = pingResponse.lookinServerVersion;
    if (serverVersion == -1 || serverVersion == 100) {
        // 说明用的还是旧版本的内部版本 LookinServer，这里兼容一下
        NSError *versionErr = [NSError errorWithDomain:LookinErrorDomain code:LookinErrCode_ServerVersionTooLow userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Fail to inspect this iOS app due to a version problem.", nil), NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"Please update LookinServer.framework linked with target iOS App to a newer version. Visit the website below to get detailed instructions:\nhttps://lookin.work/faq/server-version-too-low/", nil)}];
        return versionErr;
    }
    
    if (serverVersion > LOOKIN_SUPPORTED_SERVER_MAX) {
        // server 版本过高，需要升级 client
        NSError *versionErr = [NSError errorWithDomain:LookinErrorDomain code:LookinErrCode_ServerVersionTooHigh userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Lookin app version is too low.", nil), NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"Target iOS app is linked with a higher version LookinServer.framework. Please click \"Lookin\"-\"Check for Updates\" near the top-left corner or visit https://lookin.work to update your Lookin app.", nil)}];
        return versionErr;
        
    }
    
    if (serverVersion < LOOKIN_SUPPORTED_SERVER_MIN) {
        // server 版本过低，需要升级 server
        NSError *versionErr = [NSError errorWithDomain:LookinErrorDomain code:LookinErrCode_ServerVersionTooLow userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Fail to inspect this iOS app due to a version problem.", nil), NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"Please update LookinServer.framework linked with target iOS App to a newer version. Visit the website below to get detailed instructions:\nhttps://lookin.work/faq/server-version-too-low/", nil)}];
        return versionErr;
    }
    
    return nil;
}

#pragma mark - Private

- (void)_requestWithType:(unsigned int)requestType channel:(Lookin_PTChannel *)channel data:(NSObject *)data timeoutInterval:(NSTimeInterval)timeoutInterval succ:(void (^)(id data))succBlock fail:(void (^)(NSError *error))failBlock completion:(void (^)(void))completionBlock {
    if (!channel) {
        NSAssert(NO, @"");
        if (failBlock) {
            failBlock(LookinErr_Inner);
        }
        return;
    }
    if (!channel.isConnected) {
        if (failBlock) {
            failBlock(LookinErr_NoConnect);
        }
        return;
    }
    if (channel.activeRequests.count && requestType != LookinRequestTypePing) {
        // 检查是否有相同 type 的旧请求尚在进行中，如果有则移除之前的旧请求（旧请求会被报告 error）
        NSSet<LKConnectionRequest *> *requestsToBeDiscarded = [channel.activeRequests lookin_filter:^BOOL(LKConnectionRequest *obj) {
            return (obj.type == requestType);
        }];
        [requestsToBeDiscarded enumerateObjectsUsingBlock:^(LKConnectionRequest * _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj.failBlock) {
                NSError *error = [NSError errorWithDomain:LookinErrorDomain code:LookinErrCode_Discard userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"The request is discarded due to a newer same request.", nil)}];
                obj.failBlock(error);
            }
            [obj endTimeoutCount];
            [channel.activeRequests removeObject:obj];
            
            NSLog(@"LookinClient - will discard request, type:%@, tag:%@", @(obj.type), @(obj.tag));
        }];
    }
    
    LKConnectionRequest *request = [[LKConnectionRequest alloc] init];
    request.type = requestType;
    request.tag = (uint32_t)[[NSDate date] timeIntervalSince1970];
    request.succBlock = succBlock;
    request.failBlock = failBlock;
    request.completionBlock = completionBlock;
    request.timeoutInterval = timeoutInterval;
    @weakify(channel);
    request.timeoutBlock = ^(LKConnectionRequest *selfRequest) {
        @strongify(channel);
        NSError *error = [NSError errorWithDomain:LookinErrorDomain code:LookinErrCode_Timeout userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Request timeout", nil), NSLocalizedRecoverySuggestionErrorKey:LookinErrorText_Timeout}];
        selfRequest.failBlock(error);
        [channel.activeRequests removeObject:selfRequest];
    };
    
    LookinConnectionAttachment *attachment = [LookinConnectionAttachment new];
    attachment.data = data;
    NSError *archiveError = nil;
    dispatch_data_t payload = [[NSKeyedArchiver archivedDataWithRootObject:attachment requiringSecureCoding:YES error:&archiveError] createReferencingDispatchData];
    if (archiveError) {
        NSAssert(NO, @"");
    }
    [channel sendFrameOfType:requestType tag:request.tag withPayload:payload callback:^(NSError *error) {
//        NSLog(@"LookinClient - sendRequest, type:%@", @(requestType));
        if (error) {
            if (failBlock) {
                NSError *error = [NSError errorWithDomain:LookinErrorDomain code:LookinErrCode_PeerTalk userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"The operation failed due to an inner error.", nil)}];
                failBlock(error);
            }
        } else {
            // 成功发出了该 request
            if (!channel.activeRequests) {
                channel.activeRequests = [NSMutableSet set];
            }
            [channel.activeRequests addObject:request];
            [request resetTimeoutCount];
        }
    }];
}

- (void)cancelRequestWithType:(unsigned int)requestType channel:(Lookin_PTChannel *)channel {
    LKConnectionRequest *activeRequest = [channel.activeRequests lookin_firstFiltered:^BOOL(LKConnectionRequest *obj) {
        return obj.type == requestType;
    }];
    if (!activeRequest) {
        return;
    }
    [activeRequest endTimeoutCount];
    [channel.activeRequests removeObject:activeRequest];
    if (activeRequest.completionBlock) {
        activeRequest.completionBlock();
    }
    NSLog(@"Lookin - 用户手动取消 request, type:%@", @(requestType));
}

- (void)_startListeningForUSBDevices {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserverForName:Lookin_PTUSBDeviceDidAttachNotification object:Lookin_PTUSBHub.sharedHub queue:nil usingBlock:^(NSNotification *note) {
        NSNumber *deviceID = [note.userInfo objectForKey:@"DeviceID"];
        
        /// 仅一台真机 device 上的所有 app 共享同一批端口（在 Lookin 里是 47175 ~ 47179 这 5 个），不同真机互不影响。比如依次启动“真机 A 的 app1”、“真机 A 的 app2”、“真机 B 的 app3”，则它们依次会占用 47175、47176、47175（注意不是 47177）这几个端口
        for (int number = LookinUSBDeviceIPv4PortNumberStart; number <= LookinUSBDeviceIPv4PortNumberEnd; number++) {
            LKUSBConnectionPort *port = [LKUSBConnectionPort new];
            port.portNumber = number;
            port.deviceID = deviceID;
            [self.allUSBPorts addObject:port];
        }
        NSLog(@"Lookin - USB 设备插入，DeviceID: %@", deviceID);
    }];
    
    [nc addObserverForName:Lookin_PTUSBDeviceDidDetachNotification object:Lookin_PTUSBHub.sharedHub queue:nil usingBlock:^(NSNotification *note) {
        NSNumber *deviceID = [note.userInfo objectForKey:@"DeviceID"];
        [self.allUSBPorts.copy enumerateObjectsUsingBlock:^(LKUSBConnectionPort * _Nonnull port, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([port.deviceID isEqual:deviceID]) {
                [self.allUSBPorts removeObject:port];
            }
        }];
        NSLog(@"Lookin - USB 设备拔出，DeviceID: %@", deviceID);
    }];
}

#pragma mark - <Lookin_PTChannelDelegate>

- (BOOL)ioFrameChannel:(Lookin_PTChannel*)channel shouldAcceptFrameOfType:(uint32_t)type tag:(uint32_t)tag payloadSize:(uint32_t)payloadSize {
    if ([PushFrameTypeList() containsIndex:type]) {
        return YES;
    }
    
    LKConnectionRequest *activeRequest = [channel.activeRequests lookin_firstFiltered:^BOOL(LKConnectionRequest *obj) {
        return (obj.type == type && obj.tag == tag);
    }];
    if (activeRequest) {
        return YES;
    } else {
        NSLog(@"LookinClient - will refuse, type:%@, tag:%@", @(type), @(tag));
        return NO;
    }
}

- (void)ioFrameChannel:(Lookin_PTChannel*)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(Lookin_PTData*)payload {
    if ([PushFrameTypeList() containsIndex:type]) {
        NSData *data = [NSData dataWithContentsOfDispatchData:payload.dispatchData];
        NSError *unarchiveError = nil;
        NSObject *unarchivedData = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSObject class] fromData:data error:&unarchiveError];
        if (unarchiveError) {
            //        NSAssert(NO, @"");
        }
        
        RACTuple *tuple = [RACTuple tupleWithObjects:channel, @(type), unarchivedData, nil];
        [self.didReceivePush sendNext:tuple];
        return;
    }
    
//    NSLog(@"LookinClient - did receive, port:%@, type:%@, tag:%@", @(channel.portNumber), @(type), @(tag));
    LKConnectionRequest *activeRequest = [channel.activeRequests lookin_firstFiltered:^BOOL(LKConnectionRequest *obj) {
        return (obj.type == type && obj.tag == tag);
    }];
    if (!activeRequest) {
        // 也许在 shouldAcceptFrameOfType 和 didReceiveFrame 两个时机之间，该 request 因为超时而被销毁了？有点玄学但确实偶尔会走到这里。
        return;
    }

    NSData *data = [NSData dataWithContentsOfDispatchData:payload.dispatchData];
    NSError *unarchiveError = nil;
    LookinConnectionResponseAttachment *attachment = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSObject class] fromData:data error:&unarchiveError];
    if (unarchiveError) {
        NSLog(@"Error:%@", unarchiveError);
//        NSAssert(NO, @"");
    }
    
    if (attachment.appIsInBackground) {
        // app 处于后台模式
        
        [activeRequest endTimeoutCount];
        [channel.activeRequests removeObject:activeRequest];

        if (activeRequest.failBlock) {
            NSError *error = [NSError errorWithDomain:LookinErrorDomain code:LookinErrCode_PingFailForBackgroundState userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"The operation failed because target iOS app has entered to the background state.", nil)}];
            activeRequest.failBlock(error);
        }
        
        NSLog(@"Lookin - iOS app 报告自己处于后台，request fail");
        
        return;
    }
    
    if (activeRequest.succBlock) {
        activeRequest.succBlock(attachment);
    }
    
    static NSUInteger dataSize = 0;
    static CFTimeInterval startTime = 0;
    if (activeRequest.receivedDataCount == 0) {
        dataSize = 0;
        startTime = CACurrentMediaTime();
    }
    dataSize += data.length;
    
    BOOL hasReceivedAllResponses = NO;
    if (attachment.dataTotalCount > 0) {
        activeRequest.receivedDataCount += attachment.currentDataCount;
        if (activeRequest.receivedDataCount >= attachment.dataTotalCount) {
            hasReceivedAllResponses = YES;
        }
    } else {
        hasReceivedAllResponses = YES;
    }
    
    if (hasReceivedAllResponses) {
        [activeRequest endTimeoutCount];
        [channel.activeRequests removeObject:activeRequest];
        if (activeRequest.completionBlock) {
            activeRequest.completionBlock();
        }
        
        CFTimeInterval timeDuration = CACurrentMediaTime() - startTime;
        CGFloat totalSize = dataSize / 1024.0 / 1024.0;
        if (totalSize > 0.5) {
            NSMutableString *logString = [[NSMutableString alloc] initWithString:@"Lookin - "];
            [logString appendFormat:@"已收到全部请求 %@ / %@，总耗时:%.2f, 数据总大小:%.2fM", @(activeRequest.receivedDataCount), @(attachment.dataTotalCount), timeDuration, totalSize];
            NSLog(@"%@", logString);
        }
    } else {
        /// 对于多 response 的请求，每收到一次 response 则重置 timeout 倒计时
        [activeRequest resetTimeoutCount];
//        NSLog(@"Lookin - 收到请求 %@ / %@", @(activeRequest.receivedDataCount), @(attachment.dataTotalCount));
    }
}

- (void)ioFrameChannel:(Lookin_PTChannel*)channel didEndWithError:(NSError*)error {
    // iOS 客户端断开
    [self.allSimulatorPorts enumerateObjectsUsingBlock:^(LKSimulatorConnectionPort * _Nonnull port, NSUInteger idx, BOOL * _Nonnull stop) {
        if (port.connectedChannel == channel) {
            port.connectedChannel = nil;
        }
    }];
    [self.allUSBPorts enumerateObjectsUsingBlock:^(LKUSBConnectionPort * _Nonnull port, NSUInteger idx, BOOL * _Nonnull stop) {
        if (port.connectedChannel == channel) {
            port.connectedChannel = nil;
        }
    }];
    [self.channelWillEnd sendNext:channel];
    
    [channel close];
}

@end
