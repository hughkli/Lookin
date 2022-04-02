//
//  LKTextFieldView.m
//  Lookin
//
//  Created by Li Kai on 2019/2/27.
//  https://lookin.work
//

#import "LKTextFieldView.h"

@interface LKTextFieldView ()

@property(nonatomic, strong) NSImageView *imageView;


@end

@implementation LKTextFieldView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {        
        _textField = [NSTextField new];
        [self addSubview:self.textField];
    }
    return self;
}

+ (instancetype)labelView {
    LKTextFieldView *view = [LKTextFieldView new];
    view.textField.wantsLayer = YES;
    view.textField.backgroundColor = [NSColor clearColor];
    [view.textField setBezeled:NO];
    [view.textField setDrawsBackground:YES];
    [view.textField setEditable:NO];
    [view.textField setSelectable:NO];
    return view;
}

- (void)layout {
    [super layout];
    if (self.imageView) {
        if (self.textField.editable) {
            // 比如 hierarchy 底部的搜索框
            $(self.imageView).sizeToFit.x(self.insets.left).verAlign.offsetY(1);
            if (self.closeButton) {
                $(self.closeButton).y(1).toBottom(0).width(100).right(self.insets.right);
                $(self.textField).x(self.imageView.$maxX + 5).toMaxX(self.closeButton.$x - 5).heightToFit.verAlign;
            } else {
                $(self.textField).x(self.imageView.$maxX + 5).toRight(self.insets.right).heightToFit.verAlign;
            }
            
        } else {
            // 纯 label，比如 autoLayout popover 的标题
            $(self.imageView, self.textField).sizeToFit.verAlign;
            $(self.textField).x(self.imageView.$maxX);
            $(self.imageView, self.textField).groupHorAlign;
        }
    } else {
        $(self.textField).x(self.insets.left).toRight(self.insets.right).heightToFit.verAlign.offsetY(self.insets.top - self.insets.bottom);
    }
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat textFieldMaxWidth = limitedSize.width - self.insets.left - self.insets.right;
    if (self.imageView) {
        textFieldMaxWidth -= self.image.size.width;
    }
    NSSize textFieldSize = [self.textField sizeThatFits:NSMakeSize(textFieldMaxWidth, CGFLOAT_MAX)];
    
    CGFloat resultHeight = textFieldSize.height + self.insets.top + self.insets.bottom;
    CGFloat resultWidth = textFieldSize.width + self.insets.left + self.insets.right;
    if (self.imageView) {
        resultWidth += self.image.size.width;
    }
    return NSMakeSize(resultWidth, resultHeight);
}

- (void)setInsets:(NSEdgeInsets)insets {
    _insets = insets;
    [self setNeedsLayout:YES];
}

- (void)updateColors {
    [super updateColors];
    if (self.textColors) {
        self.textField.textColor = self.textColors.color;
    }
}

- (void)setTextColors:(LKTwoColors *)textColors {
    _textColors = textColors;
    [self updateColors];
}

- (void)setImage:(NSImage *)image {
    _image = image;
    if (image) {
        if (!self.imageView) {
            self.imageView = [NSImageView new];
            [self addSubview:self.imageView];
        }
        self.imageView.image = image;
    } else {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
    [self setNeedsLayout:YES];
}

- (void)initCloseButton {
    if (self.closeButton) {
        return;
    }
    
    _closeButton = [NSButton new];
    self.closeButton.title = NSLocalizedString(@"CancelSearch", nil);
    self.closeButton.bezelStyle = NSBezelStyleRegularSquare;
    [self addSubview:self.closeButton];
    [self setNeedsLayout:YES];
    
    @weakify(self);
    // rac_textSignal 只能监测到用户手动输入文字，observe stringValue 只能监测到代码手动设置文字（比如业务逻辑里按下 esc 来清除文字），这二者配合恰好
    [[self.textField.rac_textSignal combineLatestWith:RACObserve(self.textField, stringValue)] subscribeNext:^(RACTwoTuple<NSString *,id> * _Nullable x) {
        @strongify(self);
        self.closeButton.hidden = (self.textField.stringValue.length == 0);
    }];
}

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];
    // 如果不加这个逻辑的话，非编辑状态下点击到了右侧 closeButton 的位置就会无法激活输入框令用户困惑
    if (self.textField.isEditable) {
        [self.textField becomeFirstResponder];
    }
}

@end
