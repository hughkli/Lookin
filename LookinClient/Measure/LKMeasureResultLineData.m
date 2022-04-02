//
//  LKMeasureResultHorLineData.m
//  Lookin
//
//  Created by Li Kai on 2019/10/24.
//  https://lookin.work
//

#import "LKMeasureResultLineData.h"

@implementation LKMeasureResultHorLineData

+ (instancetype)dataWithStartX:(CGFloat)startX endX:(CGFloat)endX y:(CGFloat)y value:(CGFloat)value {
    LKMeasureResultHorLineData *data = [LKMeasureResultHorLineData new];
    data.startX = startX;
    data.endX = endX;
    data.y = y;
    data.displayValue = value;
    return data;
}

@end

@implementation LKMeasureResultVerLineData

+ (instancetype)dataWithStartY:(CGFloat)startY endY:(CGFloat)endY x:(CGFloat)x value:(CGFloat)value {
    LKMeasureResultVerLineData *data = [LKMeasureResultVerLineData new];
    data.startY = startY;
    data.endY = endY;
    data.x = x;
    data.displayValue = value;
    return data;
}

@end
