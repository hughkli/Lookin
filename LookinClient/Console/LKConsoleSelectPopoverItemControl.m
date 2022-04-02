//
//  LKConsoleSelectPopoverItemControl.m
//  Lookin
//
//  Created by Li Kai on 2019/6/19.
//  https://lookin.work
//

#import "LKConsoleSelectPopoverItemControl.h"

@interface LKConsoleSelectPopoverItemControl ()

@property(nonatomic, strong) NSImageView *imageView;
@property(nonatomic, strong) LKLabel *titleLabel;
@property(nonatomic, strong) LKLabel *subtitleLabel;

@end

@implementation LKConsoleSelectPopoverItemControl {
    CGFloat _subtitleMarginTop;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _subtitleMarginTop = 0;
        
        self.imageView = [NSImageView new];
        self.imageView.image = NSImageMake(@"Console_Checked");
        [self addSubview:self.imageView];
        
        self.titleLabel = [LKLabel new];
        self.titleLabel.font = NSFontMake(12);
        self.titleLabel.maximumNumberOfLines = 1;
        self.titleLabel.textColor = [NSColor labelColor];
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:self.titleLabel];
    
        self.subtitleLabel = [LKLabel new];
        self.subtitleLabel.maximumNumberOfLines = 1;
        self.subtitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        self.subtitleLabel.font = NSFontMake(11);
        self.subtitleLabel.textColor = [NSColor secondaryLabelColor];
        self.subtitleLabel.hidden = YES;
        [self addSubview:self.subtitleLabel];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.imageView).sizeToFit.x(3).verAlign;
    $(self.titleLabel).x(self.imageView.$maxX + 4).toRight(0).heightToFit;
    if (self.subtitleLabel.isVisible) {
        $(self.subtitleLabel).x(self.titleLabel.$x).toRight(0).heightToFit.y(self.titleLabel.$maxY + _subtitleMarginTop);
    }
    $(self.titleLabel, self.subtitleLabel).visibles.groupVerAlign;
}

- (NSSize)sizeThatFits:(NSSize)size {
    CGFloat imageHeight = self.imageView.image.size.height;
    CGFloat textHeight = [self.titleLabel sizeThatFits:NSSizeMax].height;
    if (self.subtitleLabel.isVisible) {
        textHeight += [self.subtitleLabel sizeThatFits:NSSizeMax].height + _subtitleMarginTop;
    }
    size.height = MAX(imageHeight, textHeight);
    return size;
}

- (void)sizeToFit {
    $(self).size([self sizeThatFits:NSSizeMax]);
}

- (void)setTitle:(NSString *)title {
    _title = title.copy;
    self.titleLabel.stringValue = title;
    [self setNeedsLayout:YES];
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle.copy;
    self.subtitleLabel.stringValue = subtitle;
    self.subtitleLabel.hidden = !subtitle.length;
    [self setNeedsLayout:YES];
}

- (void)setIsChecked:(BOOL)isChecked {
    _isChecked = isChecked;
    self.imageView.hidden = !isChecked;
}

- (void)setRepresentedObject:(LookinObject *)representedObject {
    _representedObject = representedObject;
    self.titleLabel.textColor = representedObject ? [NSColor labelColor] : [NSColor secondaryLabelColor];
}

@end
