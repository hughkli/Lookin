//
//  LKTableViewHorizontalScrollWidthManager.h
//  LookinClient
//
//  Created by likaimacbookhome on 2023/12/17.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKTableViewHorizontalScrollWidthManager : NSObject

@property(nonatomic, assign) CGFloat maxRowWidth;

@property (nonatomic, copy) void (^didReachNewMaxWidth)(void);

- (void)rowDidLayoutWithWidth:(CGFloat)width;

@end
