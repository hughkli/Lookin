//
//  LookinObject+LookinAutoLayoutConstraint.m
//  LookinClient
//
//  Created by likai.123 on 2024/1/14.
//  Copyright © 2024 hughkli. All rights reserved.
//

#import "LookinAutoLayoutConstraint+LookinClient.h"

@implementation LookinAutoLayoutConstraint (LookinAutoLayoutConstraint)


+ (NSString *)descriptionWithItemObject:(LookinObject *)object type:(LookinConstraintItemType)type detailed:(BOOL)detailed {
    switch (type) {
        case LookinConstraintItemTypeNil:
            return detailed ? @"Nil" : @"nil";
            
        case LookinConstraintItemTypeSelf:
            return detailed ? @"Self" : @"self";
            
        case LookinConstraintItemTypeSuper:
            return detailed ? @"Superview" : @"super";
            
        case LookinConstraintItemTypeView:
        case LookinConstraintItemTypeLayoutGuide:
            return detailed ? [NSString stringWithFormat:@"<%@: %@>", object.rawClassName, object.memoryAddress] : [NSString stringWithFormat:@"(%@*)", object.lk_demangledNoModuleClassName];
            
        default:
            NSAssert(NO, @"");
            return detailed ? [NSString stringWithFormat:@"<%@: %@>", object.rawClassName, object.memoryAddress] : [NSString stringWithFormat:@"(%@*)", object.rawClassName];
    }
}

+ (NSString *)descriptionWithAttribute:(NSLayoutAttribute)attribute {
    switch (attribute) {
        case 0 :
            // 在某些业务里确实会出现这种情况，在 Reveal 和 UI Debugger 里也是这么显示的
            return @"notAnAttribute";
        case 1:
            return @"left";
        case 2:
            return @"right";
        case 3:
            return @"top";
        case 4:
            return @"bottom";
        case 5:
            return @"leading";
        case 6:
            return @"trailing";
        case 7:
            return @"width";
        case 8:
            return @"height";
        case 9:
            return @"centerX";
        case 10:
            return @"centerY";
        case 11:
            return @"lastBaseline";
        case 12:
            return @"baseline";
        case 13:
            return @"firstBaseline";
        case 14:
            return @"leftMargin";
        case 15:
            return @"rightMargin";
        case 16:
            return @"topMargin";
        case 17:
            return @"bottomMargin";
        case 18:
            return @"leadingMargin";
        case 19:
            return @"trailingMargin";
        case 20:
            return @"centerXWithinMargins";
        case 21:
            return @"centerYWithinMargins";
            
            // 以下都是和 AutoResizingMask 有关的，这里的定义是从系统 UI Debugger 里抄过来的，暂时没在官方文档里发现它们的公开定义
        case 32:
            return @"minX";
        case 33:
            return @"minY";
        case 34:
            return @"midX";
        case 35:
            return @"midY";
        case 36:
            return @"maxX";
        case 37:
            return @"maxY";
        default:
            NSAssert(NO, @"");
            return [NSString stringWithFormat:@"unknownAttr(%@)", @(attribute)];
    }
}

+ (NSString *)symbolWithRelation:(NSLayoutRelation)relation {
    switch (relation) {
        case -1:
            return @"<=";
        case 0:
            return @"=";
        case 1:
            return @">=";
        default:
            NSAssert(NO, @"");
            return @"?";
    }
}

+ (NSString *)descriptionWithRelation:(NSLayoutRelation)relation {
    switch (relation) {
        case -1:
            return @"LessThanOrEqual";
        case 0:
            return @"Equal";
        case 1:
            return @"GreaterThanOrEqual";
        default:
            NSAssert(NO, @"");
            return @"?";
    }
}

@end
