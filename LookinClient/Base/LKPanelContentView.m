//
//  LKPanelContentView.m
//  Lookin
//
//  Created by Li Kai on 2019/5/24.
//  https://lookin.work
//

#import "LKPanelContentView.h"

@interface LKPanelContentView ()

@property(nonatomic, strong) NSImageView *titleImageView;
@property(nonatomic, strong) LKLabel *titleLabel;
@property(nonatomic, strong) LKBaseView *titleContainerView;

@property(nonatomic, strong) NSButton *cancelButton;

@end

@implementation LKPanelContentView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.backgroundColorName = @"DashboardBackgroundColor";
        
        self.titleContainerView = [LKBaseView new];
        self.titleContainerView.backgroundColorName = @"PanelTitleBackgroundColor";
        [self addSubview:self.titleContainerView];
        
        self.titleImageView = [NSImageView new];
        [self.titleContainerView addSubview:self.titleImageView];
        
        self.titleLabel = [LKLabel new];
        self.titleLabel.font = NSFontMake(13);
        [self.titleContainerView addSubview:self.titleLabel];
        
        self.cancelButton = [NSButton lk_normalButtonWithTitle:NSLocalizedString(@"Cancel", nil) target:self action:@selector(_handleCancelButton)];
        // esc
        self.cancelButton.keyEquivalent = [NSString stringWithFormat:@"%C", 0x1b];
        [self addSubview:self.cancelButton];
        
        _submitButton = [NSButton lk_normalButtonWithTitle:NSLocalizedString(@"Done", nil) target:self action:@selector(_handleSubmitButton)];
        self.submitButton.keyEquivalent = @"\r";
        [self addSubview:self.submitButton];
        
        _contentView = [LKBaseView new];
        self.contentView.layer.masksToBounds = NO;
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)layout {
    [super layout];
    
    NSEdgeInsets insets = NSEdgeInsetsMake(0, 14, 6, 14);
    
    $(self.titleContainerView).fullWidth.height(40).y(0);
    $(self.titleImageView).sizeToFit.x(insets.left).verAlign;
    $(self.titleLabel).sizeToFit.x(self.titleImageView.$maxX + 6).verAlign;
    
    $(self.submitButton).right(insets.right).bottom(insets.bottom);
    $(self.cancelButton).maxX(self.submitButton.$x - 5).bottom(insets.bottom);
    
    $(self.contentView).x(insets.left).toRight(insets.right).y(self.titleContainerView.$maxY + 10).toMaxY(self.submitButton.$y - 10);
}

- (void)setTitleImage:(NSImage *)titleImage {
    _titleImage = titleImage;
    self.titleImageView.image = titleImage;
    [self setNeedsLayout:YES];
}

- (void)setTitleText:(NSString *)titleText {
    _titleText = titleText.copy;
    self.titleLabel.stringValue = titleText;
    [self setNeedsLayout:YES];
}

- (void)_handleCancelButton {
    if (self.needExit) {
        self.needExit();
    }
}

- (void)_handleSubmitButton {
    [self didClickSubmitButton];
}

- (void)didClickSubmitButton {
    NSAssert(NO, @"should implement by subclass");
}

@end
