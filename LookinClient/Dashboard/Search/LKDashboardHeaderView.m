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

@property(nonatomic, strong) NSView *inputBorderView;
@property(nonatomic, strong) NSImageView *iconImageView;
@property(nonatomic, strong) NSTextField *textField;
@property(nonatomic, strong) NSButton *addButton;

@end

@implementation LKDashboardHeaderView {
    CGFloat _iconXWhenActive;
    CGFloat _iconXWhenInactive;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _iconXWhenActive = 11;
        _iconXWhenInactive = 89;
        
        self.inputBorderView = [NSView new];
        self.inputBorderView.wantsLayer = YES;
        self.inputBorderView.layer.cornerRadius = DashboardCardCornerRadius;
        self.inputBorderView.layer.borderWidth = 1;
        [self addSubview:self.inputBorderView];
        
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
        
        self.addButton = [NSButton new];
        self.addButton.image = [NSImage imageNamed:NSImageNameAddTemplate];
        self.addButton.bezelStyle = NSBezelStyleRounded;
        self.addButton.target = self;
        self.addButton.action = @selector(handleAddButton);
        self.addButton.frame = NSMakeRect(0, 0, 84, 40);
        [self addSubview:self.addButton];
        
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
        $(self.inputBorderView).fullFrame;
        $(self.iconImageView).sizeToFit.x(_iconXWhenActive);
    } else {
        $(self.addButton).width(50).fullHeight.right(-6).offsetY(1);
        $(self.inputBorderView).x(0).toRight(48).fullHeight;
        $(self.iconImageView).sizeToFit.verAlign.x(_iconXWhenInactive);
    }
    $(self.textField).x(30).toRight(2).heightToFit.verAlign;
}

- (void)updateColors {
    [super updateColors];
    if (self.isActive) {
        self.inputBorderView.layer.borderColor = self.isDarkMode ? LookinColorMake(70, 71, 72).CGColor : LookinColorMake(198, 199, 200).CGColor;
    } else {
        self.inputBorderView.layer.borderColor = self.isDarkMode ? LookinColorMake(47, 48, 49).CGColor : LookinColorMake(220, 221, 222).CGColor;
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
        [self.addButton.animator setAlphaValue:0];
        [self.inputBorderView.animator setFrameSize:self.$size];
        [self.iconImageView.animator setFrameOrigin:NSMakePoint(_iconXWhenActive, self.iconImageView.$y)];
        
        self.textField.animator.hidden = NO;
        [self.textField becomeFirstResponder];
        
    } else {
        [self.addButton.animator setAlphaValue:1];
        [self.inputBorderView.animator setFrameSize:NSMakeSize(self.$width - 48, self.$height)];
        [self.iconImageView.animator setFrameOrigin:NSMakePoint(_iconXWhenInactive, self.iconImageView.$y)];
        
        self.textField.animator.hidden = YES;
        self.textField.stringValue = @"";
    }
    
    if ([self.delegate respondsToSelector:@selector(dashboardHeaderView:didToggleActive:)]) {
        [self.delegate dashboardHeaderView:self didToggleActive:isActive];
    }
}

- (void)handleAddButton {
    NSMenu *menu = [NSMenu new];
    
    NSMenuItem *menuItem = [NSMenuItem new];
    menuItem.image = NSImageMake(@"Icon_Inspiration_small"); //[[NSImage alloc] initWithSize:NSMakeSize(1, 22)];
    menuItem.title = NSLocalizedString(@"How to add custom properties…", nil);
    menuItem.target = self;
    menuItem.action = @selector(handleAddCustomAttr);
    [menu addItem:menuItem];
    
    [NSMenu popUpContextMenu:menu withEvent:NSApplication.sharedApplication.currentEvent forView:self.addButton];
}

- (void)handleAddCustomAttr {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://bytedance.feishu.cn/docx/TRridRXeUoErMTxs94bcnGchnlb"]];
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
