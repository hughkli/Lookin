//
//  LKJSONAttributeItem.h
//  LookinClient
//
//  Created by likai.123 on 2023/12/4.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKJSONAttributeItem : NSObject

@property(nonatomic, copy) NSString *titleText;
@property(nonatomic, copy) NSString *desc;
@property(nonatomic, assign) BOOL expanded;
@property(nonatomic, assign) NSUInteger indentation;

@property(nonatomic, strong) NSArray<LKJSONAttributeItem *> *subItems;

- (NSArray<LKJSONAttributeItem *> *)flatItems;

@end
