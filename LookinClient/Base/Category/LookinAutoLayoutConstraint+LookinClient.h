//
//  LookinAutoLayoutConstraint+LookinClient.h
//  LookinClient
//
//  Created by likai.123 on 2024/1/14.
//  Copyright © 2024 hughkli. All rights reserved.
//

#import "LookinAutoLayoutConstraint.h"

@interface LookinAutoLayoutConstraint (LookinClient)

+ (NSString *)descriptionWithItemObject:(LookinObject *)object type:(LookinConstraintItemType)type detailed:(BOOL)detailed;
+ (NSString *)descriptionWithAttribute:(NSLayoutAttribute)attribute;
+ (NSString *)symbolWithRelation:(NSLayoutRelation)relation;
+ (NSString *)descriptionWithRelation:(NSLayoutRelation)relation;

@end
