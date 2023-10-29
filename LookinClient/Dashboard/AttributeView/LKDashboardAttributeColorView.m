//
//  LKDashboardAttributeColorView.m
//  Lookin
//
//  Created by Li Kai on 2019/2/21.
//  https://lookin.work
//

#import "LKDashboardAttributeColorView.h"
#import "LKColorIndicatorLayer.h"
#import "LKDashboardCardView.h"
#import "LKPreferenceManager.h"
#import "LKDashboardViewController.h"
#import "LKHierarchyDataSource.h"

@interface LKDashboardAttributeColorContainerView : LKBaseView

@property(nonatomic, weak) id clickTarget;
@property(nonatomic, assign) SEL clickAction;

@end

@implementation LKDashboardAttributeColorContainerView

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];
    if (self.clickTarget && self.clickAction) {
        [NSApp sendAction:self.clickAction to:self.clickTarget from:event];
    }
}

@end

@interface LKDashboardAttributeColorView () <NSMenuDelegate>

@property(nonatomic, strong) LKColorIndicatorLayer *indicatorLayer;
@property(nonatomic, strong) LKLabel *descLabel;
@property(nonatomic, strong) LKDashboardAttributeColorContainerView *containerView;
@property(nonatomic, strong) NSImageView *iconImageView;
@property(nonatomic, strong) LKLabel *aliasLabel;

@property(nonatomic, copy) NSArray<LookinAttrIdentifier> *identifiersToHideAlias;

@end

@implementation LKDashboardAttributeColorView {
    CGFloat _mainContainerHeight;
    CGFloat _aliasLabelMarginTop;
    CGFloat _labelX;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
//        [self setBackgroundColor:[NSColor blueColor]];
        
        self.identifiersToHideAlias = @[LookinAttr_ViewLayer_Border_Color, LookinAttr_ViewLayer_Shadow_Color];
        
        _mainContainerHeight = 30;
        _aliasLabelMarginTop = 1;
        _labelX = 28;
        
        self.containerView = [LKDashboardAttributeColorContainerView new];
        self.containerView.layer.cornerRadius = DashboardCardControlCornerRadius;
        self.containerView.clickTarget = self;
        self.containerView.clickAction = @selector(_handleClick:);
        [self addSubview:self.containerView];
        
        self.indicatorLayer = [LKColorIndicatorLayer new];
        [self.containerView.layer addSublayer:self.indicatorLayer];
        
        self.iconImageView = [NSImageView new];
        self.iconImageView.image = NSImageMake(@"Icon_ArrowUpDown");
        [self.containerView addSubview:self.iconImageView];
        
        self.descLabel = [LKLabel new];
        self.descLabel.textColor = [NSColor colorNamed:@"DashboardCardValueColor"];
        self.descLabel.font = NSFontMake(13);
        [self.containerView addSubview:self.descLabel];
        
        @weakify(self);
        [[RACObserve([LKPreferenceManager mainManager], rgbaFormat) skip:1] subscribeNext:^(NSNumber *bool_rgbaFormat) {
            @strongify(self);
            [self renderWithAttribute];
        }];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.containerView).fullWidth.height(_mainContainerHeight).y(0);
    $(self.indicatorLayer).width(16).height(16).x(8).verAlign;
    $(self.descLabel).x(_labelX).toRight(20).heightToFit.verAlign.offsetY(-1);
    $(self.iconImageView).sizeToFit.verAlign.right(9);
    if (self.aliasLabel.isVisible) {
        $(self.aliasLabel).x(_labelX).toRight(0).y(self.containerView.$maxY + _aliasLabelMarginTop).heightToFit;
    }
}

- (void)renderWithAttribute {
    self.iconImageView.hidden = ![self canEdit];
    
    NSColor *color = [NSColor lk_colorFromRGBAComponents:self.attribute.value];
    self.indicatorLayer.color = color;
    
    if (color) {
        self.descLabel.stringValue = [LKPreferenceManager mainManager].rgbaFormat ? color.rgbaString : color.hexString;
    } else {
        self.descLabel.stringValue = @"nil";
    }
    
    LKHierarchyDataSource *dataSource = self.dashboardViewController.currentDataSource;
    NSArray<NSString *> *alias = [dataSource aliasForColor:color];
    if (alias && ![self.identifiersToHideAlias containsObject:self.attribute.identifier]) {
        if (!self.aliasLabel) {
            self.aliasLabel = [LKLabel new];
            self.aliasLabel.textColor = [NSColor colorNamed:@"DashboardCardValueColor"];
            [self addSubview:self.aliasLabel];
        }
        self.aliasLabel.hidden = NO;
        self.aliasLabel.attributedStringValue = $([alias componentsJoinedByString:@"\n"]).font(NSFontMake(11)).lineHeight(18).attrString;
    } else {
        self.aliasLabel.hidden = YES;
    }
    [self setNeedsLayout:YES];
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat height = _mainContainerHeight;
    if (self.aliasLabel.isVisible) {
        CGFloat width = limitedSize.width - _labelX;
        height += _aliasLabelMarginTop + [self.aliasLabel sizeThatFits:NSMakeSize(width, CGFLOAT_MAX)].height;
    }
    limitedSize.height = height;
    return limitedSize;
}


- (void)setDashboardViewController:(LKDashboardViewController *)dashboardViewController {
    [super setDashboardViewController:dashboardViewController];
    self.containerView.backgroundColorName = @"DashboardCardValueBGColor";
}

#pragma mark - <NSMenuDelegate>

- (void)_handleClick:(NSEvent *)event {
    if (!self.canEdit) {
        return;
    }
    
    LKHierarchyDataSource *dataSource = self.dashboardViewController.currentDataSource;
    NSMenu *menu = dataSource.selectColorMenu;
    menu.delegate = self;
    [NSMenu popUpContextMenu:menu withEvent:event forView:self.containerView];
}

- (void)menuNeedsUpdate:(NSMenu *)menu {
    [menu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem * _Nonnull menuItem, NSUInteger idx, BOOL * _Nonnull stop) {
        if (menuItem.hasSubmenu) {
            [menuItem.submenu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem * _Nonnull subMenuItem, NSUInteger idx, BOOL * _Nonnull stop) {
                [self _updateMenuItem:subMenuItem];
            }];
        } else {
            [self _updateMenuItem:menuItem];
        }
    }];
}

- (void)_updateMenuItem:(NSMenuItem *)menuItem {
    if (menuItem.tag == self.dashboardViewController.currentDataSource.customColorMenuItemTag) {
        // "自定义颜色"
        menuItem.state = NSControlStateValueOff;
        menuItem.target = self;
        menuItem.action = @selector(_handleCustomColorMenuItem);
        return;
    }
    
    if (menuItem.tag == self.dashboardViewController.currentDataSource.toggleColorFormatMenuItemTag) {
        menuItem.state = NSControlStateValueOff;
        menuItem.target = self;
        menuItem.action = @selector(_handleToggleColorFormatMenuItem);
        return;
    }

    menuItem.target = self;
    menuItem.action = @selector(_handlePresetMenuItem:);
    NSColor *color = menuItem.representedObject;
    if ([self.attribute.value isEqual:[color lk_rgbaComponents]] || self.attribute.value == color) {
        // if 中后面的 == 是用来判断二者都是 nil 的情况
        menuItem.state = NSControlStateValueOn;
    } else {
        menuItem.state = NSControlStateValueOff;
    }
}

- (void)_handlePresetMenuItem:(NSMenuItem *)item {
    [self _modifyToColor:item.representedObject];
}

- (void)_handleCustomColorMenuItem {
    NSColor *initialColor = [NSColor lk_colorFromRGBAComponents:self.attribute.value];
    
    NSColorPanel *panel = [NSColorPanel sharedColorPanel];
    [panel setShowsAlpha:YES];
    [panel setContinuous:NO];
    [panel setColor:initialColor];
    [panel setTarget:self];
    [panel setAction:@selector(_handleSystemColorPanel:)];
    [panel orderFront:self];
}

- (void)_handleToggleColorFormatMenuItem {
    BOOL isRGBA = [LKPreferenceManager mainManager].rgbaFormat;
    [LKPreferenceManager mainManager].rgbaFormat = !isRGBA;
}

- (void)_handleSystemColorPanel:(NSColorPanel *)panel {
    [self _modifyToColor:panel.color];
}

- (void)_modifyToColor:(NSColor *)targetColor {
    NSArray *expecetdValue = [(NSColor *)targetColor lk_rgbaComponents];
    if ([expecetdValue isEqual:self.attribute.value]) {
        NSLog(@"修改没有变化，不做任何提交");
        return;
    }
    // 提交修改
    [[self.dashboardViewController modifyAttribute:self.attribute newValue:expecetdValue] subscribeNext:^(id  _Nullable x) {
    }];
}

@end
