//
//  LKPreferencePopupView.m
//  Lookin
//
//  Created by Li Kai on 2019/2/28.
//  https://lookin.work
//

#import "LKPreferencePopupView.h"

@interface LKPreferencePopupView ()

@property(nonatomic, strong) LKLabel *titleLabel;

@property(nonatomic, strong) NSPopUpButton *button;

@property(nonatomic, strong) LKLabel *messageLabel;

@property(nonatomic, strong) NSArray<NSString *> *messages;

@end

@implementation LKPreferencePopupView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message options:(NSArray<NSString *> *)options {
    NSArray<NSString *> *messages = [NSArray lookin_arrayWithCount:options.count block:^id(NSUInteger idx) {
        return message;
    }];
    return [self initWithTitle:title messages:messages options:options];
}

- (instancetype)initWithTitle:(NSString *)title messages:(NSArray<NSString *> *)messages options:(NSArray<NSString *> *)options {
    if (self = [self initWithFrame:NSZeroRect]) {
        
        _isEnabled = YES;
        self.messages = messages;
        
        self.titleLabel = [LKLabel new];
        self.titleLabel.stringValue = title;
        self.titleLabel.font = NSFontMake(IsEnglish ? 13 : 15);
        [self addSubview:self.titleLabel];
        
        self.button = [NSPopUpButton new];
        self.button.font = NSFontMake(IsEnglish ? 13 : 14);
        self.button.target = self;
        self.button.action = @selector(_handleButton);
        [self.button addItemsWithTitles:options];
        self.button.enabled = self.isEnabled;
        [self addSubview:self.button];
        
        self.messageLabel = [LKLabel new];
        self.messageLabel.font = NSFontMake(IsEnglish ? 12 : 13);
        self.messageLabel.textColor = [NSColor secondaryLabelColor];
        [self addSubview:self.messageLabel];
        
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.button).width(200).heightToFit.x(self.buttonX).y(0);
    $(self.messageLabel).x(self.button.$x).toRight(0).y(self.button.$maxY + 4).toBottom(0);
    $(self.titleLabel).sizeToFit.maxX(self.buttonX - 3).y(0);
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    self.messageLabel.stringValue = [self.messages lookin_hasIndex:selectedIndex] ? self.messages[selectedIndex] : @"";
    [self.button selectItemAtIndex:selectedIndex];
    if (self.didChange) {
        self.didChange(selectedIndex);
    }
}

- (void)_handleButton {
    self.selectedIndex = self.button.indexOfSelectedItem;
    if (self.didChange) {
        self.didChange(self.selectedIndex);
    }
}

- (void)setButtonX:(CGFloat)buttonX {
    _buttonX = buttonX;
    [self setNeedsLayout:YES];
}

- (void)setIsEnabled:(BOOL)isEnabled {
    _isEnabled = isEnabled;
    self.button.enabled = isEnabled;
}

@end
