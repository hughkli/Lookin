//
//  LKConnectionRequest.m
//  Lookin
//
//  Created by Li Kai on 2019/6/24.
//  https://lookin.work
//

#import "LKConnectionRequest.h"

@implementation LKConnectionRequest

- (void)resetTimeoutCount {
    [self endTimeoutCount];
    if (self.timeoutInterval > 0) {
        [self performSelector:@selector(_handleTimeout) withObject:nil afterDelay:self.timeoutInterval];
    } else {
        NSAssert(NO, @"timeoutInterval 为 0");
    }
}

- (void)endTimeoutCount {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)_handleTimeout {
    if (self.timeoutBlock) {
        self.timeoutBlock(self);
    }
}

@end
