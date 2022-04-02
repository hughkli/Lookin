//
//  LKInputSearchView.m
//  Lookin
//
//  Created by Li Kai on 2019/6/2.
//  https://lookin.work
//

#import "LKInputSearchView.h"
#import "LKTextFieldView.h"
#import "LKInputSearchSuggestionWindowController.h"
#import "LKInputSearchSuggestionsContentView.h"
#import "LKInputSearchSuggestionItem.h"

@interface LKInputSearchView () <NSTextFieldDelegate>

@property(nonatomic, strong) LKTextFieldView *textFieldView;
@property(nonatomic, strong) LKInputSearchSuggestionWindowController *suggestionWc;

@property(nonatomic, copy) NSString *previousInput;

@end

@implementation LKInputSearchView

- (instancetype)initWithThrottleTime:(CGFloat)throttleTime {
    if (self = [self initWithFrame:NSZeroRect]) {
        self.textFieldView = [LKTextFieldView new];
        self.textFieldView.textField.delegate = self;
        self.textFieldView.insets = NSEdgeInsetsMake(0, 0, 0, 0);
        self.textFieldView.textField.editable = YES;
        self.textFieldView.textField.bordered = NO;
        self.textFieldView.textField.bezeled = NO;
        self.textFieldView.textField.usesSingleLineMode = YES;
        self.textFieldView.textField.backgroundColor = [NSColor clearColor];
        self.textFieldView.textField.lineBreakMode = NSLineBreakByTruncatingTail;
        self.textFieldView.textField.font = NSFontMake(13);
        [self addSubview:self.textFieldView];
        
        self.suggestionWc = [LKInputSearchSuggestionWindowController new];
        self.suggestionWc.suggestionsView.tableView.target = self;
        self.suggestionWc.suggestionsView.tableView.action = @selector(_handleClickTableView);
        
        @weakify(self);
        [[self.textFieldView.textField.rac_textSignal throttle:throttleTime] subscribeNext:^(NSString * _Nullable x) {
            @strongify(self);
            NSArray<LKInputSearchSuggestionItem *> *items;
            if ([self.delegate respondsToSelector:@selector(inputSearchView:suggestionsForString:)]) {
                items = [self.delegate inputSearchView:self suggestionsForString:x];
            } else {
                items = nil;
            }
            
            self.suggestionWc.suggestionsView.items = items;
            if (items.count && [self.textField.stringValue isEqualToString:x]) {
                [self.window addChildWindow:self.suggestionWc.window ordered:NSWindowAbove];
                [self setNeedsLayout:YES];
            } else {
                [self.suggestionWc close];
            }
        }];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.textFieldView).x(self.horizontalInset).toRight(self.horizontalInset).fullHeight;
    
    if (self.superview && self.window) {
        CGPoint selfOrigin = [self.window.contentView convertPoint:self.frame.origin fromView:self.superview];
        CGRect mainWindowFrame = self.window.frame;
        NSSize panelSize = self.suggestionWc.suggestionsView.bestSize;
        CGFloat panelHeight = panelSize.height;
        CGFloat panelWidth = MIN(panelSize.width, 500);
        
        CGFloat y = mainWindowFrame.origin.y + self.window.contentView.frame.size.height - selfOrigin.y - panelHeight - self.frame.size.height;
        if (y < 200) {
            // 底部空间不够，放到上面
            y += panelHeight + self.frame.size.height;
        }
        [self.suggestionWc.window setFrame:CGRectMake(mainWindowFrame.origin.x + selfOrigin.x, y, panelWidth, panelHeight) display:YES];
    }
}

- (NSTextField *)textField {
    return self.textFieldView.textField;
}

- (void)_handleClickTableView {
    LKInputSearchSuggestionItem *item = [self.suggestionWc.suggestionsView currentSelectedItem];
    if (item.text) {
        self.textField.stringValue = item.text;
        [self.suggestionWc close];
    }
}

- (void)clearContentAndSuggestions {
    if (self.textField.stringValue.length) {
        self.previousInput = self.textField.stringValue;
    }
    
    self.textField.stringValue = @"";
    [self.suggestionWc close];
}

#pragma mark - <NSTextFieldDelegate>

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(moveUp:)) {
        if (!self.suggestionWc.window.visible || !self.suggestionWc.suggestionsView.currentSelectedItem) {
            if (self.previousInput) {
                self.textField.stringValue = self.previousInput;
                return YES;
            }
        }
    }
    
    if (commandSelector == @selector(moveDown:) || commandSelector == @selector(moveUp:)) {
        if (self.suggestionWc.window.visible) {
            [self.suggestionWc.suggestionsView.tableView keyDown:[NSApp currentEvent]];
            return YES;
        }
    }
    
    if (commandSelector == @selector(insertNewline:)) {
        if (self.suggestionWc.window.visible) {
            LKInputSearchSuggestionItem *item = [self.suggestionWc.suggestionsView currentSelectedItem];
            if (item.text) {
                self.textField.stringValue = item.text;
                [self.suggestionWc close];
                return YES;
            }
        }
        
        NSString *input = [self.textField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (input.length) {
            if ([self.delegate respondsToSelector:@selector(inputSearchView:submitText:)]) {
                [self.delegate inputSearchView:self submitText:input];
            }
            return YES;
        }
        
        // 防止 textField失去焦点
        return YES;
    }
    return NO;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    [self.suggestionWc close];
    return YES;
}

@end
