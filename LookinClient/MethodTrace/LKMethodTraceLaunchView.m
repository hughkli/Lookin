//
//  LKMethodTraceLaunchView.m
//  Lookin
//
//  Created by Li Kai on 2019/6/27.
//  https://lookin.work
//

#import "LKMethodTraceLaunchView.h"

@interface LKMethodTraceLaunchContentView : LKBaseView

@property(nonatomic, strong) NSImageView *imageView;
@property(nonatomic, strong) LKLabel *titleLabel;
@property(nonatomic, strong) LKLabel *detailLabel;
@property(nonatomic, strong) LKTextControl *submitControl;

@end

@implementation LKMethodTraceLaunchContentView {
    NSEdgeInsets _insets;
    CGFloat _iconMarginRight;
    CGFloat _detailMarginTop;
    CGFloat _controlMarginTop;
    CGFloat _controlHeight;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _insets = NSEdgeInsetsMake(10, 45, 0, 10);
        _iconMarginRight = 20;
        _detailMarginTop = IsEnglish ? 10 : 24;
        _controlMarginTop = 24;
        _controlHeight = 34;
        
        self.imageView = [NSImageView new];
        self.imageView.image = NSImageMake(@"Icon_Inspiration");
        [self addSubview:self.imageView];
        
        self.titleLabel = [LKLabel new];
        self.titleLabel.font = [NSFont boldSystemFontOfSize:17];
        self.titleLabel.textColor = [NSColor labelColor];
        self.titleLabel.stringValue = NSLocalizedString(@"Print stacks when the method you're interested in was invoked.", nil);
        [self addSubview:self.titleLabel];
        
        self.detailLabel = [LKLabel new];
        self.detailLabel.font = [NSFont systemFontOfSize:13];
        self.detailLabel.textColor = [NSColor secondaryLabelColor];
        self.detailLabel.stringValue = NSLocalizedString(@"Use this tool to debug when Xcode is unavailable, or find method invoker from the class that you cannot easily override.", nil);
        [self addSubview:self.detailLabel];
        
        self.submitControl = [LKTextControl new];
        self.submitControl.layer.cornerRadius = 6;
        self.submitControl.label.stringValue = NSLocalizedString(@"Start", nil);
        self.submitControl.label.textColor = [NSColor whiteColor];
        self.submitControl.label.font = [NSFont boldSystemFontOfSize:15];
        self.submitControl.layer.backgroundColor = [LKHelper accentColor].CGColor;
        self.submitControl.adjustAlphaWhenClick = YES;
        [self addSubview:self.submitControl];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.titleLabel).x(_insets.left).toRight(_insets.right).heightToFit.y(_insets.top);
    CGFloat y = self.titleLabel.$maxY;
    if (self.detailLabel.isVisible) {
        $(self.detailLabel).x(_insets.left).toRight(_insets.right).heightToFit.y(self.titleLabel.$maxY + _detailMarginTop);
        y = self.detailLabel.$maxY;
    }
    $(self.submitControl).width(190).height(_controlHeight).x(_insets.left).y(y + _controlMarginTop);
    $(self.imageView).sizeToFit.maxX(_insets.left - 5).midY(self.titleLabel.$midY - 2);
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat labelWidth = limitedSize.width - _insets.left - _insets.right;
    CGFloat height = _insets.top;
    height += [self.titleLabel sizeThatFits:NSMakeSize(labelWidth, CGFLOAT_MAX)].height;
    if (self.detailLabel.isVisible) {
        height += _detailMarginTop;
        height += [self.detailLabel sizeThatFits:NSMakeSize(labelWidth, CGFLOAT_MAX)].height;
    }
    height += _controlMarginTop + _controlHeight;
    limitedSize.height = height;
    return limitedSize;
}

@end

@interface LKMethodTraceLaunchView ()

@property(nonatomic, strong) LKMethodTraceLaunchContentView *contentView;

@end

@implementation LKMethodTraceLaunchView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.contentView = [LKMethodTraceLaunchContentView new];
        [self.contentView.submitControl addTarget:self clickAction:@selector(_handleClick)];
        [self addSubview:self.contentView];
        
        [self updateColors];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.contentView).x(20).toRight(20).heightToFit.midY(self.$height * .4);
    if (self.contentView.$y < 20) {
        $(self.contentView).verAlign;
    }
}

- (void)setShowTutorial:(BOOL)showTutorial {
    _showTutorial = showTutorial;
    self.contentView.detailLabel.hidden = !showTutorial;
    self.contentView.submitControl.label.stringValue = showTutorial ? NSLocalizedString(@"Start", nil) : NSLocalizedString(@"Add Method", nil);
    [self setNeedsLayout:YES];
}

- (void)_handleClick {
    if (self.didClickContinue) {
        self.didClickContinue();
    }
}

- (void)updateColors {
    [super updateColors];
    self.backgroundColor = self.isDarkMode ? [NSColor blackColor] : [NSColor whiteColor];
}

@end
