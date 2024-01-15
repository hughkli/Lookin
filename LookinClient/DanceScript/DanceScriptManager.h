//
//  DanceScriptManager.h
//  LookinClient
//
//  Created by likai.123 on 2023/12/18.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DanceScriptManager : NSObject

+ (instancetype)shared;

- (void)handleText:(NSString *)text;

@end
