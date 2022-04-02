//
//  LKColorIndicatorLayer.m
//  Lookin
//
//  Created by Li Kai on 2019/1/19.
//  https://lookin.work
//

#import "LKColorIndicatorLayer.h"

@interface LKColorIndicatorLayer ()

@property(nonatomic, strong) CALayer *imageLayer;

@property(nonatomic, strong) CALayer *colorLayer;

@end

@implementation LKColorIndicatorLayer

- (instancetype)init {
    if (self = [super init]) {
        [self lookin_removeImplicitAnimations];
        
        self.borderWidth = 1;
        
        _color = LookinColorMake(0, 0, 0);
        self.colorLayer = [CALayer layer];
        self.colorLayer.backgroundColor = self.color.CGColor;
        [self.colorLayer lookin_removeImplicitAnimations];
        [self addSublayer:self.colorLayer];
        
        self.masksToBounds = YES;
    }
    return self;
}

- (void)setColor:(NSColor *)color {
    _color = color;
    
    if (color) {
        if ([color alphaComponent] < 1) {
            [self _createImageLayerIfNeeded];
            self.imageLayer.hidden = NO;
            self.imageLayer.contents = NSImageMake(@"Transparent_Background");
        } else {
            self.imageLayer.hidden = YES;
        }
        
    } else {
        [self _createImageLayerIfNeeded];
        self.imageLayer.hidden = NO;
        self.imageLayer.contents = NSImageMake(@"Nil_Color_Image");
    }
    self.colorLayer.backgroundColor = color.CGColor;

    self.borderColor = [self _contrastColorForColor:color].CGColor;
}

- (NSColor *)_contrastColorForColor:(NSColor *)color {
    if (!color) {
        return LookinColorMake(191, 191, 191);
    }
    
    CGFloat hue, saturation, brightness, alpha;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    CGFloat newBrightness = (brightness > .5) ? (brightness - .2) : (brightness + .2);
    CGFloat newAlpha = MIN(1, alpha + .3);
    
    NSColor *resultColor = [NSColor colorWithHue:hue saturation:saturation brightness:newBrightness alpha:newAlpha];
    return resultColor;
}

- (void)_createImageLayerIfNeeded {
    if (self.imageLayer) {
        return;
    }
    self.imageLayer = [CALayer layer];
    [self.imageLayer lookin_removeImplicitAnimations];
    [self insertSublayer:self.imageLayer atIndex:0];
    [self setNeedsLayout];
}

- (void)layoutSublayers {
    [super layoutSublayers];
    
    $(self.imageLayer, self.colorLayer).visibles.fullFrame;
    self.cornerRadius = MIN(self.$width, self.$height) / 2.0;
}

+ (NSImage *)imageWithColor:(NSColor *)color shapeSize:(NSSize)shapeSize insets:(NSEdgeInsets)insets {
    static LKColorIndicatorLayer *layer = nil;
    if (!layer) {
        layer = [LKColorIndicatorLayer new];
    }
    
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(shapeSize.width + insets.left + insets.right, shapeSize.height + insets.top + insets.bottom)];
    [image lockFocus];
    layer.frame = NSMakeRect(0, 0, shapeSize.width, shapeSize.height);
    layer.color = color;
    CGContextTranslateCTM([NSGraphicsContext currentContext].CGContext, insets.left, insets.top);
    [layer renderInContext:[NSGraphicsContext currentContext].CGContext];
    [image unlockFocus];
    return image;
}

@end
