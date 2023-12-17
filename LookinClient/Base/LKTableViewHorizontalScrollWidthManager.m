//
//  LKTableViewHorizontalScrollWidthManager.m
//  LookinClient
//
//  Created by likaimacbookhome on 2023/12/17.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "LKTableViewHorizontalScrollWidthManager.h"

@implementation LKTableViewHorizontalScrollWidthManager

- (void)rowDidLayoutWithWidth:(CGFloat)width {
    if (width > self.maxRowWidth) {
        self.maxRowWidth = width;
        if (self.didReachNewMaxWidth) {
            self.didReachNewMaxWidth();            
        }
    }
}

@end
