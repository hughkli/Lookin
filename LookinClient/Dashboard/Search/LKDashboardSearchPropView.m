//
//  LKDashboardSearchPropView.m
//  Lookin
//
//  Created by Li Kai on 2019/9/5.
//  https://lookin.work
//

#import "LKDashboardSearchPropView.h"
#import "LookinDashboardBlueprint.h"
#import "LookinAttribute.h"
#import "LKPreferenceManager.h"
#import "LKEnumListRegistry.h"

@interface LKDashboardSearchPropView ()

@property(nonatomic, strong) LKLabel *titleLabel;
@property(nonatomic, strong) LKLabel *contentLabel;
@property(nonatomic, strong) LKTextControl *revealControl;

@property(nonatomic, strong) LookinAttribute *attribute;

@end

@implementation LKDashboardSearchPropView {
    CGFloat _contentLabelY;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _contentLabelY = 21;
        
        self.titleLabel = [LKLabel new];
        self.titleLabel.font = NSFontMake(12);
        self.titleLabel.textColor = [NSColor secondaryLabelColor];
        [self addSubview:self.titleLabel];
    
        self.contentLabel = [LKLabel new];
        self.contentLabel.font = NSFontMake(15);
        [self addSubview:self.contentLabel];
        
        self.revealControl = [LKTextControl new];
        [self.revealControl addTarget:self clickAction:@selector(_handleRevealButton)];
        self.revealControl.adjustAlphaWhenClick = YES;
        [self addSubview:self.revealControl];
        
        [self updateColors];
    }
    return self;
}

- (void)layout {
    [super layout];
    
    CGFloat width = self.$width - DashboardSearchCardInset * 2;
    
    $(self.titleLabel).x(DashboardSearchCardInset).width(width).heightToFit.y(5);
    $(self.contentLabel).x(DashboardSearchCardInset).width(width).heightToFit.y(_contentLabelY);
    $(self.revealControl).sizeToFit.x(DashboardSearchCardInset).bottom(DashboardSearchCardInset);
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat width = limitedSize.width - DashboardSearchCardInset * 2;
    CGFloat height = _contentLabelY;
    height += [self.contentLabel heightForWidth:width] + DashboardSearchCardInset + 25;
    limitedSize.height = height;
    return limitedSize;
}

- (void)updateColors {
    [super updateColors];
    self.contentLabel.textColor = self.isDarkMode ? LookinColorMake(250, 251, 252) : LookinColorMake(56, 57, 58);
    
    self.revealControl.label.attributedStringValue = $(@"在主面板中显示").textColor(self.isDarkMode ? @"245, 166, 30" : @"229, 135, 67").font(@11).addImage(@"icon_arrowRight_orange", 0, 2, 0).attrString;
}

- (void)renderWithAttribute:(LookinAttribute *)attribute {
    self.attribute = attribute;
    self.titleLabel.stringValue = attribute.displayTitle ? : [LookinDashboardBlueprint fullTitleWithAttrID:attribute.identifier];
    self.contentLabel.stringValue = [self _stringValueFromAttribute:attribute];
    [self setNeedsLayout:YES];
}

- (void)_handleRevealButton {
    if ([self.delegate respondsToSelector:@selector(dashboardSearchPropView:didClickRevealAttribute:)]) {
        [self.delegate dashboardSearchPropView:self didClickRevealAttribute:self.attribute];
    }
}

- (NSString *)_stringValueFromAttribute:(LookinAttribute *)attribute {
    switch (attribute.attrType) {
        case LookinAttrTypeNone:
        case LookinAttrTypeVoid:
        case LookinAttrTypeCustomObj:
            NSAssert(NO, @"");
            return @"";
            
        case LookinAttrTypeChar:
        case LookinAttrTypeInt:
        case LookinAttrTypeShort:
        case LookinAttrTypeLong:
        case LookinAttrTypeLongLong:
        case LookinAttrTypeUnsignedChar:
        case LookinAttrTypeUnsignedInt:
        case LookinAttrTypeUnsignedShort:
        case LookinAttrTypeUnsignedLong:
        case LookinAttrTypeUnsignedLongLong:
        case LookinAttrTypeFloat:
        case LookinAttrTypeDouble:
        case LookinAttrTypeSel:
        case LookinAttrTypeClass:
        case LookinAttrTypeCGVector:
        case LookinAttrTypeCGAffineTransform:
        case LookinAttrTypeUIOffset:
            return [attribute.value description];
            
        case LookinAttrTypeBOOL: {
            BOOL boolValue = [(NSNumber *)attribute.value boolValue];
            return boolValue ? @"YES" : @"NO";
        }
            
        case LookinAttrTypeCGPoint:
            return [NSString lookin_stringFromPoint:[(NSValue *)attribute.value pointValue]];
        case LookinAttrTypeCGSize:
            return [NSString lookin_stringFromSize:[(NSValue *)attribute.value sizeValue]];
        case LookinAttrTypeCGRect:
            return [NSString lookin_stringFromRect:[(NSValue *)attribute.value rectValue]];
        case LookinAttrTypeUIEdgeInsets:
            return [NSString lookin_stringFromInset:[(NSValue *)attribute.value edgeInsetsValue]];
            
        case LookinAttrTypeNSString:
        case LookinAttrTypeEnumString:
            return attribute.value;
            
        case LookinAttrTypeEnumInt:
        case LookinAttrTypeEnumLong: {
            NSInteger enumValue = [attribute.value integerValue];
            NSString *enumListName = [LookinDashboardBlueprint enumListNameWithAttrID:attribute.identifier];
            NSString *enumString = [[LKEnumListRegistry sharedInstance] descForEnumName:enumListName value:enumValue];
            return enumString;
        }

        case LookinAttrTypeUIColor: {
            NSColor *color = [NSColor lk_colorFromRGBAComponents:attribute.value];
            if (color) {
                return [LKPreferenceManager mainManager].rgbaFormat ? color.rgbaString : color.hexString;
            } else {
                return @"nil";
            }
        }
    }
    
    NSAssert(NO, @"");
    return @"";
}

@end
