//
//  LookinDisplayItem+LookinClient.m
//  LookinClient
//
//  Created by likaimacbookhome on 2023/11/1.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "LookinDisplayItem+LookinClient.h"

@implementation LookinDisplayItem (LookinClient)

- (BOOL)isUserCustom {
    return self.customInfo != nil;
}

- (BOOL)hasPreviewBoxAbility {
    if (!self.customInfo) {
        return YES;
    }
    if ([self.customInfo hasValidFrame]) {
        return YES;
    }
    return NO;
}

- (BOOL)hasValidFrameToRoot {
    if (self.customInfo) {
        return [self.customInfo hasValidFrame];
    }
    return [LKHelper validateFrame:self.frame];
}

- (CGRect)calculateFrameToRoot {
    if (self.customInfo) {
        return [self.customInfo.frameInWindow rectValue];
    }
    if (!self.superItem) {
        return self.frame;
    }
    CGRect superFrameToRoot = [self.superItem calculateFrameToRoot];
    CGRect superBounds = self.superItem.bounds;
    CGRect selfFrame = self.frame;
    
    CGFloat x = selfFrame.origin.x - superBounds.origin.x + superFrameToRoot.origin.x;
    CGFloat y = selfFrame.origin.y - superBounds.origin.y + superFrameToRoot.origin.y;
    
    CGFloat width = selfFrame.size.width;
    CGFloat height = selfFrame.size.height;
    return CGRectMake(x, y, width, height);
}

@end
