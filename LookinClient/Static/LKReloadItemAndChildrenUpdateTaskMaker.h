//
//  LKReloadItemAndChildrenUpdateTaskMaker.h
//  LookinClient
//
//  Created by likai.123 on 2024/3/3.
//  Copyright © 2024 hughkli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LookinStaticAsyncUpdateTask.h"

@interface LKReloadItemAndChildrenUpdateTaskMaker : NSObject

+ (NSArray<LookinStaticAsyncUpdateTask *> *)makeWithItem:(LookinDisplayItem *)item;

@end
