//
//  LKOutlineRowView.m
//  Lookin
//
//  Created by Li Kai on 2019/4/20.
//  https://lookin.work
//

#import "LKOutlineRowView.h"

static CGFloat const kInsetRight = 15;
static CGFloat const kIndentUnitWidth = 14;
static CGFloat const kDisclosureWidth = 16;

@interface LKOutlineRowView ()

@property(nonatomic, assign) BOOL useCompactUI;

@end

@implementation LKOutlineRowView

- (instancetype)initWithCompactUI:(BOOL)compact {
    if (self = [super initWithFrame:NSZeroRect]) {
        self.useCompactUI = compact;
        
        if (compact) {
            _imageLeft = 5;
            _imageRight = 2;
            _titleLeft = 0;
            _subtitleLeft = 2;
        } else {
            _imageLeft = 5;
            _imageRight = 2;
            _titleLeft = 2;
            _subtitleLeft = 10;
        }
        
        _disclosureButton = [NSButton new];
        self.disclosureButton.bordered = NO;
        [self.disclosureButton setButtonType:NSButtonTypeMomentaryChange];
        [self addSubview:self.disclosureButton];
 
        _imageView = [NSImageView new];
        self.imageView.hidden = YES;
        [self addSubview:self.imageView];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    return [self initWithCompactUI:NO];
}

- (void)layout {
    [super layout];
    
    $(self.disclosureButton).width(kDisclosureWidth).fullHeight.midX([self.class dislosureMidXWithIndentLevel:self.indentLevel]).verAlign;
    
    CGFloat x = self.disclosureButton.$maxX;
    if (self.imageView.isVisible) {
        $(self.imageView).sizeToFit.verAlign.x(x + _imageLeft);
        x = self.imageView.$maxX + _imageRight;
    }
    
    $(self.titleLabel).sizeToFit.x(x + _titleLeft).verAlign;
    
    if (self.subtitleLabel.isVisible) {
        $(self.subtitleLabel).sizeToFit.x(self.titleLabel.$maxX + _subtitleLeft).verAlign;
    }
    $(self.disclosureButton, self.titleLabel, self.subtitleLabel).visibles.offsetY(-1);
}

- (void)updateContentWidth {
    CGFloat width = [self.class insetLeft] + kInsetRight + self.indentLevel * kIndentUnitWidth + kDisclosureWidth;
    
    if (self.imageView.isVisible) {
        width += [self.imageView sizeThatFits:NSSizeMax].width + _imageLeft + _imageRight;
    }
    
    width += _titleLeft + [self.titleLabel sizeThatFits:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)].width;
    
    if (self.subtitleLabel.isVisible) {
        width += self->_subtitleLeft + [self.subtitleLabel sizeThatFits:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)].width;
    }
    
    self.contentWidth = width;
}

- (void)setIndentLevel:(NSUInteger)indentLevel {
    _indentLevel = indentLevel;
    [self setNeedsLayout:YES];
}

- (void)setImage:(NSImage *)image {
    _image = image;
    self.imageView.image = image;
    self.imageView.hidden = !image;
    [self setNeedsLayout:YES];
}

- (void)setStatus:(LKOutlineRowViewStatus)status {
    _status = status;
    [self _updateDisclosureButton];
}

- (void)setIsSelected:(BOOL)isSelected {
    [super setIsSelected:isSelected];
    [self _updateDisclosureButton];
}

- (void)_updateDisclosureButton {
    if (self.status == LKOutlineRowViewStatusNotExpandable) {
        self.disclosureButton.hidden = YES;
        
    } else if (self.status == LKOutlineRowViewStatusExpanded) {
        self.disclosureButton.hidden = NO;
        if (self.isSelected) {
            self.disclosureButton.image = NSImageMake(@"icon_arrow_down_selected");
        } else {
            self.disclosureButton.image = NSImageMake(@"icon_arrow_down");
        }
    } else {
        self.disclosureButton.hidden = NO;
        if (self.isSelected) {
            self.disclosureButton.image = NSImageMake(@"icon_arrow_right_selected");
        } else {
            self.disclosureButton.image = NSImageMake(@"icon_arrow_right");
        }
    }
}

+ (CGFloat)dislosureMidXWithIndentLevel:(NSUInteger)level {
    return [self insetLeft] + level * kIndentUnitWidth + kDisclosureWidth / 2.0;
}

+ (CGFloat)insetLeft {
    return 6;
}

@end
