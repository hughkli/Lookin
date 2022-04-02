//
//  LKMeasureResultHorLineData.h
//  Lookin
//
//  Created by Li Kai on 2019/10/24.
//  https://lookin.work
//

#import <Foundation/Foundation.h>

@interface LKMeasureResultHorLineData : NSObject

+ (instancetype)dataWithStartX:(CGFloat)startX endX:(CGFloat)endX y:(CGFloat)y value:(CGFloat)value;

@property(nonatomic, assign) CGFloat startX;
@property(nonatomic, assign) CGFloat endX;
@property(nonatomic, assign) CGFloat y;

@property(nonatomic, assign) CGFloat displayValue;

@end

@interface LKMeasureResultVerLineData : NSObject

+ (instancetype)dataWithStartY:(CGFloat)startY endY:(CGFloat)endY x:(CGFloat)x value:(CGFloat)value;

@property(nonatomic, assign) CGFloat startY;
@property(nonatomic, assign) CGFloat endY;
@property(nonatomic, assign) CGFloat x;

@property(nonatomic, assign) CGFloat displayValue;

@end
