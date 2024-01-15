//
//  LKDanceUIAttrMaker.h
//  LookinClient
//
//  Created by likai.123 on 2023/12/21.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKDanceUIAttrMaker : NSObject

/// 给 item 的属性列表里填充上“跳转 DanceUI 文件”相关的信息
+ (void)makeDanceUIJumpAttribute:(LookinDisplayItem *)item danceSource:(NSString *)source;

@end
