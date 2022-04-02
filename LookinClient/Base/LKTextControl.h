//
//  LKTextControl.h
//  Lookin
//
//  Created by Li Kai on 2019/3/12.
//  https://lookin.work
//

#import "LKBaseControl.h"

@interface LKTextControl : LKBaseControl

@property(nonatomic, strong, readonly) LKLabel *label;

@property(nonatomic, assign) NSEdgeInsets insets;

@property(nonatomic, strong) NSImage *rightImage;
@property(nonatomic, assign) CGFloat spaceBetweenLabelAndImage;
@property(nonatomic, assign) CGFloat rightImageOffsetY;

@end
