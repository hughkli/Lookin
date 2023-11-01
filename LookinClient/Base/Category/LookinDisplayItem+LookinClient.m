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

@end
