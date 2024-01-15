//
//  LKDashboardAttributeStringArrayView.m
//  Lookin
//
//  Created by Li Kai on 2019/6/15.
//  https://lookin.work
//

#import "LKDashboardAttributeStringArrayView.h"
#import "DanceScriptManager.h"

@interface LKDashboardAttributeStringArrayView ()

@property(nonatomic, copy) NSArray<LKLabel *> *labels;
@property(nonatomic, copy) NSArray<CALayer *> *sepLayers;
@property(nonatomic, strong) NSButton *danceButton;

@end

@implementation LKDashboardAttributeStringArrayView {
    CGFloat _labelsVerInterSpace;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _labelsVerInterSpace = 10;
    
//        [self showDebugBorder];
        
        self.labels = [NSArray array];
        self.sepLayers = [NSArray array];
    }
    return self;
}

- (void)layout {
    [super layout];
    [self.labels enumerateObjectsUsingBlock:^(LKLabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LKLabel *prevLabel = (idx > 0 ? self.labels[idx - 1] : nil);
        $(obj).fullFrame.heightToFit.y(prevLabel ? (prevLabel.$maxY + self -> _labelsVerInterSpace) : 0);
        
        if (idx > 0) {
            if ([self.sepLayers lookin_hasIndex:(idx - 1)]) {
                $(self.sepLayers[idx - 1]).fullFrame.height(1).y(obj.$y - self -> _labelsVerInterSpace / 2.0 + 1);
            } else {
                NSAssert(NO, @"");
            }
        }
    }];
    if (self.danceButton.isVisible) {
        $(self.danceButton).width(150).horAlign.height(25).bottom(0);
    }
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    limitedSize.height = [self.labels lookin_reduceCGFloat:^CGFloat(CGFloat accumulator, NSUInteger idx, LKLabel *obj) {
        CGFloat labelHeight = [obj sizeThatFits:limitedSize].height;
        accumulator += labelHeight;
        if (idx) {
            accumulator += self->_labelsVerInterSpace;
        }
        return accumulator;
    } initialAccumlator:0];
    if (self.danceButton.isVisible) {
        limitedSize.height += 35;
    }
    return limitedSize;
}

- (NSArray<NSString *> *)stringListWithAttribute:(LookinAttribute *)attribute {
    NSAssert(NO, @"should implement by subclass");
    return nil;
}

- (void)renderWithAttribute {
    NSArray<NSString *> *lists = [self stringListWithAttribute:self.attribute];
    self.labels = [self.labels lookin_resizeWithCount:lists.count add:^LKLabel *(NSUInteger idx) {
        LKLabel *label = [LKLabel new];
        label.selectable = YES;
        label.allowsEditingTextAttributes = YES;
        [self addSubview:label];
        return label;
        
    } remove:^(NSUInteger idx, LKLabel *label) {
        [label removeFromSuperview];
        
    } doNext:^(NSUInteger idx, LKLabel *label) {
        NSString *string = lists[idx];
        label.attributedStringValue = $(string).textColor([NSColor labelColor]).font(NSFontMake(12)).lineHeight(18).attrString;
    }];
    
    if (lists.count > 1) {
        self.sepLayers = [self.sepLayers lookin_resizeWithCount:(lists.count - 1) add:^CALayer *(NSUInteger idx) {
            CALayer *layer = [CALayer new];
            [layer lookin_removeImplicitAnimations];
            [self.layer addSublayer:layer];
            return layer;
        } remove:^(NSUInteger idx, CALayer *layer) {
            [layer removeFromSuperlayer];
            
        } doNext:^(NSUInteger idx, CALayer *layer) {
            
        }];
        [self updateColors];
        
    } else {
        [self.sepLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperlayer];
        }];
        self.sepLayers = @[];
    }
    
    [self.danceButton setHidden:YES];
    if ([self.attribute.identifier isEqualToString:LookinAttr_Class_Class_Class]) {
        NSString *danceSource = self.attribute.targetDisplayItem.danceuiSource;
        if (!danceSource) {
            danceSource = self.attribute.targetDisplayItem.customInfo.danceuiSource;
        }
        if (danceSource) {
            [self addDanceButtonIfNeeded];
            self.danceButton.title = NSLocalizedString(@"Navigate…", nil);
            [self.danceButton setHidden:NO];
        }
    }
    
    [self setNeedsLayout:YES];
}

- (void)updateColors {
    [super updateColors];
    [self.sepLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.backgroundColor = self.isDarkMode ? SeparatorDarkModeColor.CGColor : SeparatorLightModeColor.CGColor;
    }];
}

- (void)addDanceButtonIfNeeded {
    if (self.danceButton) {
        return;
    }
    self.danceButton = [NSButton lk_normalButtonWithTitle:@"" target:self action:@selector(handleDanceButton)];
    self.danceButton.font = NSFontMake(12);
    [self addSubview:self.danceButton];
}

- (void)handleDanceButton {
    NSString *json = self.attribute.targetDisplayItem.danceuiSource;
    if (!json) {
        json = self.attribute.targetDisplayItem.customInfo.danceuiSource;
    }
    [[DanceScriptManager shared] handleText:json];
}

@end
