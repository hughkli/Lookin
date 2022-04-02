//
//  LKPreferenceSwitchView.m
//  Lookin
//
//  Created by Li Kai on 2019/2/28.
//  https://lookin.work
//

#import "LKPreferenceSwitchView.h"

@interface LKPreferenceSwitchView ()

@property(nonatomic, strong) NSButton *button;
@property(nonatomic, strong) LKLabel *messageLabel;

@property(nonatomic, copy) NSString *checkedMessage;
@property(nonatomic, copy) NSString *uncheckedMessage;

@end

@implementation LKPreferenceSwitchView {
    CGFloat _messageMarginTop;
    CGFloat _messageX;
}

- (instancetype)initWithTitle:(NSString *)title checkedMessage:(NSString *)checkedMessage uncheckedMessage:(NSString *)uncheckedMessage {
    if (self = [self initWithFrame:NSZeroRect]) {
        _messageMarginTop = 3;
        _messageX = 19;
        
        self.checkedMessage = checkedMessage;
        self.uncheckedMessage = uncheckedMessage;
        
        self.button = [NSButton new];
        [self.button setButtonType:NSButtonTypeSwitch];
        self.button.font = NSFontMake(15);
        self.button.title = title;
        self.button.target = self;
        self.button.action = @selector(_handleButton);
        [self addSubview:self.button];
        
        self.messageLabel = [LKLabel new];
        self.messageLabel.font = NSFontMake(13);
        self.messageLabel.textColor = [NSColor secondaryLabelColor];
        self.messageLabel.maximumNumberOfLines = 0;
        [self addSubview:self.messageLabel];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message {
    return [self initWithTitle:title checkedMessage:message uncheckedMessage:message];
}

- (void)layout {
    [super layout];
    $(self.button).fullWidth.height([self.button sizeThatFits:NSSizeMax].height + 2).y(0);
    $(self.messageLabel).x(_messageX).toRight(0).heightToFit.y(self.button.$maxY + _messageMarginTop);
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    limitedSize.height = [self.button sizeThatFits:limitedSize].height + 2 + _messageMarginTop + [self.messageLabel sizeThatFits:NSMakeSize(limitedSize.width - _messageX, limitedSize.height)].height;
    return limitedSize;
}

- (void)setIsChecked:(BOOL)isChecked {
    _isChecked = isChecked;
    self.messageLabel.stringValue = isChecked ? self.checkedMessage : self.uncheckedMessage;
    self.button.state = (isChecked ? NSControlStateValueOn : NSControlStateValueOff);
    if (self.didChange) {
        self.didChange(isChecked);
    }
    [self setNeedsLayout:YES];
}

- (void)_handleButton {
    self.isChecked = (self.button.state == NSControlStateValueOn);
    if (self.didChange) {
        self.didChange(self.isChecked);
    }
}

@end

