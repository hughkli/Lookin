//
//  LookinDisplayItem+LookinClient.m
//  LookinClient
//
//  Created by likaimacbookhome on 2023/11/1.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "LookinDisplayItem+LookinClient.h"

@implementation LookinDisplayItem (LookinClient)

- (NSString *)title {
    if (self.customInfo) {
        return self.customInfo.title;
    } else if (self.customDisplayTitle.length > 0) {
        return self.customDisplayTitle;
    } else if (self.viewObject) {
        return self.viewObject.lk_demangledNoModuleClassName;
    } else if (self.layerObject) {
        return self.layerObject.lk_demangledNoModuleClassName;
    } else {
        return nil;
    }
}

- (BOOL)representedForSystemClass {
    return [self.title hasPrefix:@"UI"] || [self.title hasPrefix:@"CA"] || [self.title hasPrefix:@"_"];
}

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

- (BOOL)isMatchedWithSearchString:(NSString *)string {
    if (string.length == 0) {
        NSAssert(NO, @"");
        return NO;
    }
    NSString *searchString = string.lowercaseString;
    if ([self.title.lowercaseString containsString:searchString]) {
        return YES;
    }
    if ([self.subtitle.lowercaseString containsString:searchString]) {
        return YES;
    }
    if ([self.viewObject.memoryAddress containsString:searchString]) {
        return YES;
    }
    if ([self.layerObject.memoryAddress containsString:searchString]) {
        return YES;
    }
    return NO;
}

@end
