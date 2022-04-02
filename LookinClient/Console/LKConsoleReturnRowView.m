//
//  LKConsoleReturnRowView.m
//  Lookin
//
//  Created by Li Kai on 2019/6/1.
//  https://lookin.work
//

#import "LKConsoleReturnRowView.h"

@implementation LKConsoleReturnRowView {
    NSEdgeInsets _insets;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _insets = NSEdgeInsetsMake(0, ConsoleInsetLeft, 5, ConsoleInsetRight);
        
        self.titleLabel.selectable = YES;
        self.titleLabel.textColor = [NSColor labelColor];
        self.titleLabel.font = NSFontMake(13);
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.titleLabel.maximumNumberOfLines = 0;
        
//        self.layer.borderColor = [NSColor redColor].CGColor;
//        self.layer.borderWidth = 1;
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.titleLabel).x(_insets.left).toRight(_insets.right).heightToFit.y(_insets.top);
}

- (CGFloat)heightForWidth:(CGFloat)width {
    CGFloat height = [self.titleLabel sizeThatFits:NSMakeSize(width - _insets.left -_insets.right, CGFLOAT_MAX)].height;
    height += _insets.top + _insets.bottom;
    return height;
}

@end
