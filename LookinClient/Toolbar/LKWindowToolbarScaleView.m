//
//  LKWindowToolbarScaleView.m
//  Lookin
//
//  Created by Li Kai on 2019/10/14.
//  https://lookin.work
//

#import "LKWindowToolbarScaleView.h"

@implementation LKWindowToolbarScaleView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _slider = [NSSlider new];
        [self addSubview:self.slider];
        
        _decreaseButton = [NSButton lk_buttonWithImage:NSImageMake(@"icon_decrease") target:nil action:nil];
        [self addSubview:self.decreaseButton];
        
        _increaseButton = [NSButton lk_buttonWithImage:NSImageMake(@"icon_increase") target:nil action:nil];
        [self addSubview:self.increaseButton];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.decreaseButton).width(20).fullHeight.x(0);
    $(self.increaseButton).width(20).fullHeight.right(0);
    $(self.slider).fullHeight.x(self.decreaseButton.$maxX).toMaxX(self.increaseButton.$x);
}

@end
