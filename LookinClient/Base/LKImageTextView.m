//
//  LKImageTextView.m
//  Lookin
//
//  Created by Li Kai on 2019/6/19.
//  https://lookin.work
//

#import "LKImageTextView.h"

@implementation LKImageTextView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _imageView = [NSImageView new];
        [self addSubview:self.imageView];
        
        _label = [LKLabel new];
        [self addSubview:self.label];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.imageView).sizeToFit.x(self.imageMargins.left).verAlign;
    $(self.label).x(self.imageView.$maxX + self.imageMargins.right).toRight(0).heightToFit.verAlign;
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    NSSize labelSize = [self.label sizeThatFits:NSSizeMax];
    limitedSize.width = self.imageMargins.left + self.imageView.image.size.width + self.imageMargins.right + labelSize.width;
    limitedSize.height = MAX(self.imageView.image.size.height, labelSize.height);
    return limitedSize;
}

@end
