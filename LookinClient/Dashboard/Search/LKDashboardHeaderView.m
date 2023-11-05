//
//  LKDashboardHeaderView.m
//  Lookin
//
//  Created by Li Kai on 2019/9/5.
//  https://lookin.work
//

#import "LKDashboardHeaderView.h"
#import "LKPreferenceManager.h"

@interface LKDashboardHeaderView () <NSTextFieldDelegate>

@property(nonatomic, strong) NSImageView *iconImageView;
@property(nonatomic, strong) NSTextField *textField;

@end

@implementation LKDashboardHeaderView {
    CGFloat _iconXWhenActive;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _iconXWhenActive = 11;
        
        self.layer.cornerRadius = DashboardCardCornerRadius;
        self.layer.borderWidth = 1;
        
        self.iconImageView = [NSImageView new];
        self.iconImageView.image = NSImageMake(@"icon_search");
        [self addSubview:self.iconImageView];
    
        self.textField = [NSTextField new];
        self.textField.placeholderString = @"搜索属性或方法";
        self.textField.delegate = self;
        self.textField.focusRingType = NSFocusRingTypeNone;
        self.textField.editable = YES;
        self.textField.bordered = NO;
        self.textField.bezeled = NO;
        self.textField.usesSingleLineMode = YES;
        self.textField.backgroundColor = [NSColor clearColor];
        self.textField.lineBreakMode = NSLineBreakByTruncatingTail;
        self.textField.font = NSFontMake(13);
        self.textField.hidden = YES;
        [self addSubview:self.textField];
        
        @weakify(self);
        [[self.textField.rac_textSignal throttle:0.3] subscribeNext:^(NSString * _Nullable x) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(dashboardHeaderView:didInputString:)]) {
                [self.delegate dashboardHeaderView:self didInputString:x];
            }
        }];
        
        [self updateColors];
    }
    return self;
}

- (void)layout {
    [super layout];
    if (self.isActive) {
        $(self.iconImageView).sizeToFit.x(_iconXWhenActive);
    } else {
        $(self.iconImageView).sizeToFit.centerAlign;
    }
    $(self.textField).x(30).toRight(2).heightToFit.verAlign;
}

- (void)updateColors {
    [super updateColors];
    if (self.isActive) {
        self.layer.borderColor = self.isDarkMode ? LookinColorMake(70, 71, 72).CGColor : LookinColorMake(198, 199, 200).CGColor;
    } else {
        self.layer.borderColor = self.isDarkMode ? LookinColorMake(47, 48, 49).CGColor : LookinColorMake(220, 221, 222).CGColor;
    }
}

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];
    self.isActive = YES;
}

- (NSString *)currentInputString {
    return self.textField.stringValue;
}

- (void)setIsActive:(BOOL)isActive {
    if (_isActive == isActive) {
        return;
    }
    _isActive = isActive;
    
    [self updateColors];
    
    if (isActive) {
        [self.iconImageView.animator setFrameOrigin:NSMakePoint(_iconXWhenActive, self.iconImageView.$y)];
        
        self.textField.animator.hidden = NO;
        [self.textField becomeFirstResponder];
        
    } else {
        [self.iconImageView.animator setFrameOrigin:NSMakePoint(self.$width / 2.0 - self.iconImageView.$width / 2.0, self.iconImageView.$y)];
        
        self.textField.animator.hidden = YES;
        self.textField.stringValue = @"";
    }
    
    if ([self.delegate respondsToSelector:@selector(dashboardHeaderView:didToggleActive:)]) {
        [self.delegate dashboardHeaderView:self didToggleActive:isActive];
    }
}

#pragma mark - <NSTextFieldDelegate>

- (void)controlTextDidEndEditing:(NSNotification *)obj {
    self.isActive = NO;
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == NSSelectorFromString(@"cancelOperation:")) {
        // 按下了 esc 键
        self.isActive = NO;
        return YES;
    }
    return NO;
}


@end
