//
//  LKWarningItem.h
//  LookinClient
//
//  Created by LikaiMacStudioWork on 2024/3/28.
//  Copyright © 2024 hughkli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKWarningItem : NSObject

@property(nonatomic, copy) NSString *itemID;
@property(nonatomic, copy) NSString *warnIfServerLessThan;
@property(nonatomic, copy) NSString *chineseText;
@property(nonatomic, copy) NSString *englishText;
@property(nonatomic, copy) NSString *webLink;

+ (instancetype)parseDict:(NSDictionary *)dict;

@end
