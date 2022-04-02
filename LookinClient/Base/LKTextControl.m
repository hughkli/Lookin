//
//  LKTextControl.m
//  Lookin
//
//  Created by Li Kai on 2019/3/12.
//  https://lookin.work
//

#import "LKTextControl.h"

@interface LKTextControl ()

@property(nonatomic, strong) NSImageView *rightImageView;

@end

@implementation LKTextControl

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _label = [LKLabel new];
        self.label.alignment = NSTextAlignmentCenter;
        [self addSubview:self.label];
    }
    return self;
}

- (void)layout {
    [super layout];
    CGFloat labelMaxX = self.$width - self.insets.right;
    if (self.rightImageView) {
        $(self.rightImageView).sizeToFit.verAlign.right(self.insets.right).offsetY(self.rightImageOffsetY);
        labelMaxX = self.rightImageView.$x - self.spaceBetweenLabelAndImage;
    }
    $(self.label).x(self.insets.left).toMaxX(labelMaxX).heightToFit.verAlign;
    if (self.insets.top != self.insets.bottom) {
        $(self.label).offsetY(self.insets.top - self.insets.bottom);
    }
}

- (void)setInsets:(NSEdgeInsets)insets {
    _insets = insets;
    [self setNeedsLayout:YES];
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat labelMaxWidth = limitedSize.width - self.insets.left - self.insets.right;
    if (!self.rightImageView.hidden) {
        labelMaxWidth -= ([self.rightImageView bestWidth] + self.spaceBetweenLabelAndImage);
    }
    
    NSSize labelSize = [self.label sizeThatFits:NSMakeSize(labelMaxWidth, CGFLOAT_MAX)];
    
    CGFloat resultWidth = labelSize.width + self.insets.left + self.insets.right;
    if (!self.rightImageView.hidden) {
        resultWidth += ([self.rightImageView bestWidth] + self.spaceBetweenLabelAndImage);
    }
    CGFloat resultHeight = labelSize.height + self.insets.top + self.insets.bottom;
    
    return NSMakeSize(resultWidth, resultHeight);
}

- (void)setRightImage:(NSImage *)rightImage {
    _rightImage = rightImage;
    if (rightImage) {
        if (!self.rightImageView) {
            self.rightImageView = [NSImageView new];
            [self addSubview:self.rightImageView];
        }
        self.rightImageView.image = rightImage;
        
    } else {
        [self.rightImageView removeFromSuperview];
    }
    [self setNeedsLayout:YES];
}

- (void)setSpaceBetweenLabelAndImage:(CGFloat)spaceBetweenLabelAndImage {
    _spaceBetweenLabelAndImage = spaceBetweenLabelAndImage;
    [self setNeedsLayout:YES];
}

- (void)setRightImageOffsetY:(CGFloat)rightImageOffsetY {
    _rightImageOffsetY = rightImageOffsetY;
    [self setNeedsLayout:YES];
}

@end
