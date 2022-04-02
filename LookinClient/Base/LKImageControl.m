//
//  LKImageButton.m
//  Lookin
//
//  Created by Li Kai on 2018/9/1.
//  https://lookin.work
//

#import "LKImageControl.h"

@interface LKImageControl ()

@end

@implementation LKImageControl

+  (instancetype)buttonWithImage:(NSImage *)image {
    LKImageControl *button = [[LKImageControl alloc] init];
    button.image = image;
    return button;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {        
        _imageView = [NSImageView new];
        _imageView.wantsLayer = YES;
        [self addSubview:_imageView];
    }
    return self;
}

- (void)setImage:(NSImage *)image {
    _image = image;
    _imageView.image = image;
    
    [self setNeedsLayout:YES];
}

- (void)layout {
    [super layout];
    _imageView.frame = self.bounds;
    _imageView.layer.anchorPoint = NSMakePoint(.5, .5);
    _imageView.layer.frame = _imageView.frame;
}

- (NSSize)sizeThatFits:(NSSize)size {
    return _imageView.image.size;
}

@end
