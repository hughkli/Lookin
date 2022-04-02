//
//  LKTutorialPopoverController.m
//  Lookin
//
//  Created by Li Kai on 2019/7/17.
//  https://lookin.work
//

#import "LKTutorialPopoverController.h"

@interface LKTutorialPopoverController ()

@property(nonatomic, strong) NSImageView *imageView;
@property(nonatomic, strong) LKLabel *label;
@property(nonatomic, strong) NSButton *closeButton;

@property(nonatomic, weak) NSPopover *popover;

@end

@implementation LKTutorialPopoverController {
    NSEdgeInsets _insets;
    CGFloat _labelMarginLeft;
}

- (instancetype)initWithText:(NSString *)text popover:(NSPopover *)popover {
    if (self = [self initWithContainerView:nil]) {
        _insets = NSEdgeInsetsMake(12, 8, 10, 8);
        _labelMarginLeft = 5;
        
        self.label.stringValue = text;
        
        self.popover = popover;
    }
    return self;
}

- (NSView *)makeContainerView {
    NSView *containerView = [super makeContainerView];
    
    self.imageView = [NSImageView new];
    self.imageView.image = NSImageMake(@"Icon_Inspiration");
    [containerView addSubview:self.imageView];
    
    self.label = [LKLabel new];
    self.label.font = NSFontMake(13);
    [containerView addSubview:self.label];

    self.closeButton = [NSButton lk_normalButtonWithTitle:NSLocalizedString(@"Do not show again", nil) target:self action:@selector(_handleCloseButton)];
    [containerView addSubview:self.closeButton];
    
    return containerView;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    $(self.imageView).sizeToFit.x(_insets.left);
    $(self.label).x(self.imageView.$maxX + _labelMarginLeft).toRight(_insets.right).heightToFit.y(_insets.top);
    $(self.imageView).midY(self.label.$midY - 1);
    $(self.closeButton).sizeToFit.horAlign.bottom(_insets.bottom);
}

- (NSSize)contentSize {
    CGFloat imageWidth = self.imageView.image.size.width;

    CGFloat maxWidth = 400;
    CGFloat labelMaxWidth = maxWidth - imageWidth - _insets.left - _insets.right - _labelMarginLeft;
    NSSize labelSize = [self.label sizeThatFits:NSMakeSize(labelMaxWidth, CGFLOAT_MAX)];
    
    NSSize size = NSMakeSize(imageWidth + _insets.left + _insets.right + labelSize.width + _labelMarginLeft, labelSize.height + 60);
    return size;
}

- (void)_handleCloseButton {
    self.hasClickedCloseButton = YES;
    [self.popover close];
}

@end
