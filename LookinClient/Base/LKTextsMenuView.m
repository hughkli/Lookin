//
//  LKTextsMenuView.m
//  Lookin
//
//  Created by Li Kai on 2019/8/14.
//  https://lookin.work
//

#import "LKTextsMenuView.h"

@interface LKTextsMenuView ()

@property(nonatomic, strong) NSMutableArray<LKLabel *> *leftLabels;
@property(nonatomic, strong) NSMutableArray<LKLabel *> *rightLabels;

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSButton *> *buttons;

@end

@implementation LKTextsMenuView {
    CGFloat _buttonMarginLeft;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _buttonMarginLeft = 4;
        _verSpace = 2;
        _horSpace = 10;
        _insets = NSEdgeInsetsMake(0, 3, 0, 5);
        
        self.leftLabels = [NSMutableArray array];
        self.rightLabels = [NSMutableArray array];
    }
    return self;
}

- (void)layout {
    [super layout];
    
    NSArray<LKLabel *> *visibleRightLabels = self.rightLabels.lk_visibleViews;
    NSArray<LKLabel *> *visibleLeftLabels = self.leftLabels.lk_visibleViews;
    
    if (self.type == LKTextsMenuViewTypeCenter) {
        __block CGFloat leftLabelMaxWidth = self.insets.left;
        [visibleLeftLabels enumerateObjectsUsingBlock:^(LKLabel * _Nonnull leftLabel, NSUInteger idx, BOOL * _Nonnull stop) {
            LKLabel *prevLeftLabel = (idx > 0 ? visibleLeftLabels[idx - 1] : nil);
            CGFloat y = prevLeftLabel ? (prevLeftLabel.$maxY + self.verSpace) : 0;
            $(leftLabel).sizeToFit.y(y);
            leftLabelMaxWidth = MAX(leftLabelMaxWidth, leftLabel.$width + self.insets.left);
        }];
        [visibleLeftLabels enumerateObjectsUsingBlock:^(LKLabel * _Nonnull leftLabel, NSUInteger idx, BOOL * _Nonnull stop) {
            $(leftLabel).maxX(leftLabelMaxWidth);
            
            CGFloat midY = leftLabel.$midY;
            
            LKLabel *rightLabel = visibleRightLabels[idx];
            $(rightLabel).x(leftLabelMaxWidth + self.horSpace).sizeToFit.midY(midY);
        
            NSButton *button = self.buttons[@(idx)];
            if (button) {
                CGFloat x = rightLabel.$maxX;
                if (rightLabel.stringValue.length > 0) {
                    x += (self->_buttonMarginLeft);
                }
                $(button).sizeToFit.x(x).midY(midY + 1);
            }
        }];
        
    } else {
        [visibleRightLabels enumerateObjectsUsingBlock:^(LKLabel * _Nonnull rightLabel, NSUInteger idx, BOOL * _Nonnull stop) {
            LKLabel *prevLeftLabel = (idx > 0 ? visibleLeftLabels[idx - 1] : nil);
            
            LKLabel *leftLabel = visibleLeftLabels[idx];
            CGFloat y = prevLeftLabel ? (prevLeftLabel.$maxY + self.verSpace) : 0;
            $(leftLabel).sizeToFit.x(0).y(y);
            
            CGFloat rightLabelMaxX = self.$width;
            NSButton *button = self.buttons[@(idx)];
            if (button) {
                $(button).sizeToFit.right(0).midY(leftLabel.$midY);
                rightLabelMaxX = button.$x - (self -> _buttonMarginLeft);
            }
            $(rightLabel).x(leftLabel.$maxX + self.horSpace).toMaxX(rightLabelMaxX).heightToFit.midY(leftLabel.$midY);
        }];
    }
}

- (void)setTexts:(NSArray<LookinStringTwoTuple *> *)texts {
    _texts = texts.copy;
    
    [self.leftLabels lookin_dequeueWithCount:texts.count add:^LKLabel *(NSUInteger idx) {
        LKLabel *label = [LKLabel new];
        label.selectable = YES;
        label.font = self.font;
        label.maximumNumberOfLines = 1;
        label.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:label];
        return label;
    } notDequeued:^(NSUInteger idx, LKLabel *obj) {
        obj.hidden = YES;
    } doNext:^(NSUInteger idx, LKLabel *obj) {
        obj.hidden = NO;
        obj.stringValue = texts[idx].first;
    }];

    [self.rightLabels lookin_dequeueWithCount:texts.count add:^LKLabel *(NSUInteger idx) {
        LKLabel *label = [LKLabel new];
        label.selectable = YES;
        label.font = self.font;
        label.maximumNumberOfLines = 1;
        label.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:label];
        return label;
    } notDequeued:^(NSUInteger idx, LKLabel *obj) {
        obj.hidden = YES;
    } doNext:^(NSUInteger idx, LKLabel *obj) {
        obj.hidden = NO;
        obj.stringValue = texts[idx].second;
    }];

    NSAssert(self.leftLabels.count == self.rightLabels.count, @"");
    
    [self updateColors];
    [self _updateAlignments];
    [self setNeedsLayout:YES];
}

- (void)setType:(LKTextsMenuViewType)type {
    _type = type;
    [self _updateAlignments];
}

- (void)_updateAlignments {
    [self.leftLabels enumerateObjectsUsingBlock:^(LKLabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.type == LKTextsMenuViewTypeJustified) {
            obj.alignment = NSTextAlignmentLeft;
        } else {
            obj.alignment = NSTextAlignmentRight;
        }
    }];
    [self.rightLabels enumerateObjectsUsingBlock:^(LKLabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.type == LKTextsMenuViewTypeJustified) {
            obj.alignment = NSTextAlignmentRight;
        } else {
            obj.alignment = NSTextAlignmentLeft;
        }
    }];
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    __block CGFloat resultHeight = 0;
    
    __block CGFloat leftMaxWidth = 0;
    __block CGFloat rightMaxWidth = 0;
    [self.leftLabels.lk_visibleViews enumerateObjectsUsingBlock:^(LKLabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSSize size = [obj bestSize];
        leftMaxWidth = MAX(leftMaxWidth, size.width);
        resultHeight += size.height;
        if (idx > 0) {
            resultHeight += self.verSpace;
        }
    }];
    [self.rightLabels.lk_visibleViews enumerateObjectsUsingBlock:^(LKLabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat width = [obj bestWidth];
        
        NSButton *button = self.buttons[@(idx)];
        if (button) {
            width += [button bestWidth];
            if (obj.stringValue.length > 0) {
                width += (self -> _buttonMarginLeft);
            }
        }
        
        rightMaxWidth = MAX(rightMaxWidth, width);
    }];
    
    /// 这里多给个 1 的冗余量，来抵消 ShortCocoa 布局时取整带来的误差
    CGFloat resultWidth = leftMaxWidth + rightMaxWidth + self.horSpace + self.insets.left + self.insets.right;
    return NSMakeSize(resultWidth, resultHeight);
}

- (void)updateColors {
    [super updateColors];
    [self.leftLabels enumerateObjectsUsingBlock:^(LKLabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.textColor = [(self.isDarkMode ? NSColorGray9 : NSColorGray1) colorWithAlphaComponent:.7];
    }];
    [self.rightLabels enumerateObjectsUsingBlock:^(LKLabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.textColor = self.isDarkMode ? NSColorWhite : NSColorBlack;
    }];
}

- (void)addButton:(NSButton *)button atIndex:(NSUInteger)idx {
    if (!button) {
        NSAssert(NO, @"");
        return;
    }
    if (self.buttons[@(idx)]) {
        NSAssert(NO, @"");
        return;
    }
    if (!self.buttons) {
        self.buttons = [NSMutableDictionary dictionary];
    }
    self.buttons[@(idx)] = button;
    [self addSubview:button];
    [self setNeedsLayout:YES];
}

@end
