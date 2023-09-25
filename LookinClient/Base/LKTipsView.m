//
//  LKTipsView.m
//  Lookin
//
//  Created by Li Kai on 2019/5/8.
//  https://lookin.work
//

#import "LKTipsView.h"

@interface LKTipsView ()

@property(nonatomic, strong) LKLabel *titleLabel;
@property(nonatomic, strong) NSImageView *imageView;
@property(nonatomic, strong) CALayer *sepLayer;

- (NSColor *)buttonTextColor;

@end

@implementation LKTipsView {
    CGFloat _insetLeft;
    CGFloat _insetRightWithButton;
    CGFloat _insetRightWithoutButton;
    CGFloat _imageRight;
    CGFloat _sepLeft;
    NSSize _imageSize;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _insetLeft = 12;
        _insetRightWithButton = 3;
        _insetRightWithoutButton = 8;
        _imageRight = 4;
        _sepLeft = 7;
        _imageSize = NSMakeSize(18, 18);
        
        self.layer.borderWidth = 1;
        
        self.imageView = [NSImageView new];
        self.imageView.hidden = YES;
        [self addSubview:self.imageView];
        
        self.titleLabel = [LKLabel new];
        self.titleLabel.font = NSFontMake(13);
        [self addSubview:self.titleLabel];
        
        _button = [NSButton new];
        self.button.font = NSFontMake(13);
        self.button.bordered = NO;
        [self.button setBezelStyle:NSBezelStyleSmallSquare];
        self.button.target = self;
        self.button.action = @selector(_handleButton);
        self.button.hidden = YES;
        [self addSubview:self.button];
        
        self.sepLayer = [CALayer layer];
        [self.sepLayer lookin_removeImplicitAnimations];
        self.sepLayer.hidden = YES;
        [self.layer addSublayer:self.sepLayer];
        
        [self updateColors];
    }
    return self;
}

- (void)layout {
    [super layout];
    self.layer.cornerRadius = self.$height / 2.0;

    CGFloat x = _insetLeft;
    if (!self.imageView.hidden) {
        $(self.imageView).size(_imageSize).verAlign.x(x);
        x = self.imageView.$maxX + _imageRight;
    }
    
    $(self.titleLabel).sizeToFit.verAlign.x(x);
    x = self.titleLabel.$maxX;
    
    if (!self.sepLayer.hidden) {
        $(self.sepLayer).width(1).fullHeight.x(x + _sepLeft);
        x = self.sepLayer.$maxX;
    }
    
    if (!self.button.hidden) {
        $(self.button).x(x).toRight(_insetRightWithButton).fullHeight;
    }
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat height = 28;
    
    CGFloat width = _insetLeft;
    if (!self.imageView.hidden) {
        width += _imageSize.width + _imageRight;
    }
    
    width += [self.titleLabel sizeThatFits:NSSizeMax].width;
    
    if (!self.sepLayer.hidden) {
        width += _sepLeft + 1;
    }
    
    if (!self.button.hidden) {
        width += [self.button sizeThatFits:NSSizeMax].width + 16;
    } else {
        width += _insetRightWithoutButton;
    }
    
    return NSMakeSize(width, height);
}

- (void)updateColors {
    [super updateColors];
    self.backgroundColor = self.isDarkMode ? LookinColorRGBAMake(0, 0, 0, .8) : LookinColorRGBAMake(255, 255, 255, .9);
    self.titleLabel.textColor = self.isDarkMode ? LookinColorMake(197, 198, 199) : LookinColorMake(108, 109, 110);
    
    NSColor *borderColor = self.isDarkMode ? LookinColorMake(43, 44, 45) : LookinColorMake(216, 217, 218);
    
    self.layer.borderColor = borderColor.CGColor;
    self.sepLayer.backgroundColor = borderColor.CGColor;
    [self _updateButton];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.stringValue = title;
}

- (void)setImage:(NSImage *)image {
    _image = image;
    self.imageView.image = image;
    self.imageView.hidden = !image;
}

- (void)setImageByDeviceType:(LookinAppInfoDevice)type {
    if (type == 0) {
        self.image = NSImageMake(@"icon_simulator_big");
    } else if (type == 1) {
        self.image = NSImageMake(@"icon_ipad_big");
    } else if (type == 2) {
        self.image = NSImageMake(@"icon_iphone_big");
    } else {
        NSAssert(NO, @"");
    }
}

- (void)setButtonText:(NSString *)buttonText {
    _buttonText = buttonText.copy;
    [self _updateButton];
}

- (void)setButtonImage:(NSImage *)buttonImage {
    _buttonImage = buttonImage;
    [self _updateButton];
}

-(void)setInternalInsetsRight:(CGFloat)value {
    _insetRightWithButton = value;
    _insetRightWithoutButton = value;
    _imageRight = value;
}

- (void)_handleButton {
    if (self.target && self.clickAction) {
        [NSApp sendAction:self.clickAction to:self.target from:self];
    }
    if (self.didClick) {
        self.didClick(self);
    }
}

- (void)_updateButton {
    self.button.hidden = NO;
    self.sepLayer.hidden = NO;
    
    if (self.buttonText) {
        self.button.attributedTitle = $(self.buttonText).textColor([self buttonTextColor]).attrString;
        self.button.image = nil;
    } else if (self.buttonImage) {
        self.button.title = @"";
        self.button.image = self.buttonImage;
    } else {
        self.button.hidden = YES;
        self.sepLayer.hidden = YES;
    }
    [self setNeedsLayout:YES];
}

- (NSColor *)buttonTextColor {
    return self.isDarkMode ? LookinColorMake(64, 134, 216) : LookinColorMake(74, 145, 228);
}

@end

@implementation LKRedTipsView

- (void)startAnimation {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    anim.fromValue = (id)LookinColorRGBAMake(208, 2, 27, .9).CGColor;
    anim.toValue = (id)LookinColorRGBAMake(208, 2, 27, .7).CGColor;
    anim.duration = .8;
    anim.repeatCount = HUGE_VALF;
    anim.autoreverses = YES;
    [self.layer removeAllAnimations];
    [self.layer addAnimation:anim forKey:nil];
}

- (void)endAnimation {
    [self.layer removeAllAnimations];
}

- (void)updateColors {
    [super updateColors];
    self.titleLabel.textColor = [NSColor whiteColor];
    self.layer.borderColor = [NSColor clearColor].CGColor;
    self.sepLayer.backgroundColor = LookinColorRGBAMake(255, 255, 255, .5).CGColor;
}

- (NSColor *)buttonTextColor {
    return [NSColor whiteColor];
}

@end
