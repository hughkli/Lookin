//
//  LKHierarchyRowView.m
//  Lookin
//
//  Created by Li Kai on 2018/8/4.
//  https://lookin.work
//

#import "LKHierarchyRowView.h"
#import "LookinDisplayItem.h"
#import "LookinIvarTrace.h"
#import "LookinDisplayItem.h"
#import "LKHierarchyHandlersPopoverController.h"
#import "LKNavigationManager.h"
#import "LKStaticWindowController.h"
#import "LKTutorialManager.h"

@interface LKHierarchyRowView () <LookinDisplayItemDelegate>

@property(nonatomic, strong) CALayer *strikethroughLayer;

@property(nonatomic, strong) CALayer *eventHandlerButtonColorLayer;
@property(nonatomic, assign) BOOL isFocusingHandlerButton;

@end

@implementation LKHierarchyRowView

- (void)layout {
    [super layout];
    
    $(self.eventHandlerButton).y(3).toBottom(3).width(10).x(3);
    [self _updateEventHandlerButtonLayout];
    
    if (self.strikethroughLayer && !self.strikethroughLayer.hidden) {
        CGFloat maxX = self.subtitleLabel.hidden ? (self.titleLabel.$maxX + 2) : self.subtitleLabel.$maxX + 2;
        $(self.strikethroughLayer).height(1).x(self.titleLabel.$x - 1).toMaxX(maxX).midY(self.titleLabel.$midY + 1);
    }
}

- (void)setDisplayItem:(LookinDisplayItem *)displayItem {
    if (_displayItem == displayItem) {
        return;
    }
    _displayItem = displayItem;
    
    displayItem.rowViewDelegate = self;
    
    // event handler
    if (displayItem.eventHandlers.count) {
        if (!self.eventHandlerButton) {
            _eventHandlerButton = [NSButton new];
            [self.eventHandlerButton setTitle:@""];
            self.eventHandlerButton.target = self;
            self.eventHandlerButton.action = @selector(_handleClickEventHandlerButton:);
            self.eventHandlerButton.wantsLayer = YES;
            self.eventHandlerButton.bordered = NO;
            [self.eventHandlerButton setBezelStyle:NSBezelStyleRoundRect];
            self.eventHandlerButton.layer.backgroundColor = [NSColor clearColor].CGColor;
            [self addSubview:self.eventHandlerButton];
        
            self.eventHandlerButtonColorLayer = [CALayer layer];
            self.eventHandlerButtonColorLayer.actions = @{NSStringFromSelector(@selector(contents)): [NSNull null]};
            [self.eventHandlerButton.layer addSublayer:self.eventHandlerButtonColorLayer];
        }
        self.eventHandlerButton.hidden = NO;
        [self _updateEventHandlerButtonColors];
    } else {
        self.eventHandlerButton.hidden = YES;
    }
    
    self.image = [self _iconWithDisplayItem:displayItem isSelected:displayItem.isSelected];
    self.indentLevel = displayItem.indentLevel - self.minIndentLevel;
    [self updateContentWidth];
    [self _updateLabelStringsAndImageViewAlpha];
    [self _updateLabelsFonts];

    [self setNeedsLayout:YES];
}

- (void)setIsSelected:(BOOL)isSelected {
    [super setIsSelected:isSelected];
    self.imageView.image = [self _iconWithDisplayItem:self.displayItem isSelected:isSelected];
    [self _updateEventHandlerButtonColors];
    [self _updateStrikethroughLayerColor];
    [self _updateLabelStringsAndImageViewAlpha];
    [self _updateLabelStringsAndImageViewAlpha];
}

- (void)setIsHovered:(BOOL)isHovered {
    [super setIsHovered:isHovered];
    [self _updateEventHandlerButtonColors];
}

- (void)viewDidChangeEffectiveAppearance {
    [super viewDidChangeEffectiveAppearance];
    [self _updateEventHandlerButtonColors];
}

#pragma mark - Event Handler

- (void)mouseMoved:(NSEvent *)event {
    [super mouseMoved:event];
    NSPoint rawPoint = [event locationInWindow];
    NSPoint point = [self convertPoint:rawPoint fromView:nil];
    if (point.x < 16) {
        self.isFocusingHandlerButton = YES;
    } else {
        self.isFocusingHandlerButton = NO;
    }
}

- (void)mouseExited:(NSEvent *)event {
    [super mouseExited:event];
    self.isFocusingHandlerButton = NO;
}

- (void)setIsFocusingHandlerButton:(BOOL)isFocusingHandlerButton {
    if (_isFocusingHandlerButton == isFocusingHandlerButton) {
        return;
    }
    _isFocusingHandlerButton = isFocusingHandlerButton;
    [self _updateEventHandlerButtonLayout];
    [self _updateEventHandlerButtonColors];
}

- (void)_handleClickEventHandlerButton:(NSButton *)button {
    TutorialMng.eventsHandler = YES;
    
    NSPopover *popover = [[NSPopover alloc] init];
    
    BOOL editable = NO;
    if (self.window == [LKNavigationManager sharedInstance].staticWindowController.window) {
        editable = YES;
    }
    
    LKHierarchyHandlersPopoverController *vc = [[LKHierarchyHandlersPopoverController alloc] initWithDisplayItem:self.displayItem editable:editable];
    popover.animates = NO;
    popover.behavior = NSPopoverBehaviorTransient;
    popover.contentSize = vc.neededSize;
    popover.contentViewController = vc;
    [popover showRelativeToRect:NSMakeRect(0, 0, button.bounds.size.width, button.bounds.size.height) ofView:button preferredEdge:NSRectEdgeMaxY];
}

- (void)_updateLabelStringsAndImageViewAlpha {
    NSColor *titleColor;
    NSColor *subtitleColor;
    
    if (self.isSelected) {
        titleColor = [NSColor whiteColor];
        subtitleColor = [NSColor whiteColor];
        self.imageView.alphaValue = 1;
        
    } else if (self.displayItem.inHiddenHierarchy ||
               self.displayItem.inNoPreviewHierarchy ||
               (self.displayItem.isInSearch && !self.displayItem.highlightedSearchString.length)) {
        titleColor = [NSColor tertiaryLabelColor];
        subtitleColor = [NSColor tertiaryLabelColor];
        self.imageView.alphaValue = .6;
        
    } else {
        titleColor = [NSColor labelColor];
        subtitleColor = [NSColor secondaryLabelColor];
        self.imageView.alphaValue = 1;
    }
    
    NSAttributedString *titleString = $(self.displayItem.title).textColor(titleColor).attrString;
    NSAttributedString *subtitleString = $(self.displayItem.subtitle).textColor(subtitleColor).attrString;
    
    if (self.displayItem.isInSearch && self.displayItem.highlightedSearchString.length) {
        // 搜索状态下，且命中了搜索词
        NSColor *bgColor = self.isDarkMode ? LookinColorMake(190, 120, 0) : LookinColorMake(255, 240, 100);
        NSDictionary<NSAttributedStringKey, id> *attrs = @{NSBackgroundColorAttributeName: bgColor, NSForegroundColorAttributeName: [NSColor labelColor]};
        
        NSRange titleHighlightRange = [titleString.string rangeOfString:self.displayItem.highlightedSearchString options:NSCaseInsensitiveSearch];
        if (titleHighlightRange.location != NSNotFound) {
            NSMutableAttributedString *titleString_m = titleString.mutableCopy;
            [titleString_m addAttributes:attrs range:titleHighlightRange];
            titleString = titleString_m;
        }
        
        NSRange subtitleHighlightRange = [subtitleString.string rangeOfString:self.displayItem.highlightedSearchString options:NSCaseInsensitiveSearch];
        if (subtitleHighlightRange.location != NSNotFound) {
            NSMutableAttributedString *subtitleString_m = subtitleString.mutableCopy;
            [subtitleString_m addAttributes:attrs range:subtitleHighlightRange];
            subtitleString = subtitleString_m;
        }
    }

    self.titleLabel.attributedStringValue = titleString;
    self.subtitleLabel.attributedStringValue = subtitleString;
}

#pragma mark - <LookinDisplayItemDelegate>

- (void)displayItem:(LookinDisplayItem *)displayItem propertyDidChange:(LookinDisplayItemProperty)property {
    if (property == LookinDisplayItemProperty_None || property == LookinDisplayItemProperty_IsSelected) {
        self.isSelected = displayItem.isSelected;
    }
    
    if (property == LookinDisplayItemProperty_None || property == LookinDisplayItemProperty_IsHovered) {
        self.isHovered = displayItem.isHovered;
    }

    if (property == LookinDisplayItemProperty_None ||
        property == LookinDisplayItemProperty_IsExpandable ||
        property == LookinDisplayItemProperty_IsExpanded) {
        if (!displayItem.isExpandable) {
            self.status = LKOutlineRowViewStatusNotExpandable;
        } else if (displayItem.isExpanded) {
            self.status = LKOutlineRowViewStatusExpanded;
        } else {
            self.status = LKOutlineRowViewStatusCollapsed;
        }
    }
    
    if (property == LookinDisplayItemProperty_None || property == LookinDisplayItemProperty_InNoPreviewHierarchy) {
        if (displayItem.inNoPreviewHierarchy) {
            if (!self.strikethroughLayer) {
                self.strikethroughLayer = [CALayer layer];
                [self.strikethroughLayer lookin_removeImplicitAnimations];
                [self _updateStrikethroughLayerColor];
                [self.layer addSublayer:self.strikethroughLayer];
            }
            self.strikethroughLayer.hidden = NO;
            [self setNeedsLayout:YES];
        } else {
            self.strikethroughLayer.hidden = YES;
        }
    }
    
    if (property == LookinDisplayItemProperty_InHiddenHierarchy ||
        property == LookinDisplayItemProperty_InNoPreviewHierarchy) {
        [self _updateLabelStringsAndImageViewAlpha];
        [self _updateLabelsFonts];
    }
    
    if (property == LookinDisplayItemProperty_None ||
        property == LookinDisplayItemProperty_IsInSearch ||
        property == LookinDisplayItemProperty_HighlightedSearchString) {
        [self _updateLabelStringsAndImageViewAlpha];
    }
}

- (void)_updateStrikethroughLayerColor {
    if (!self.strikethroughLayer) {
        return;
    }
    if (self.isSelected) {
        self.strikethroughLayer.backgroundColor = [[NSColor whiteColor] colorWithAlphaComponent:.75].CGColor;
    } else {
        self.strikethroughLayer.backgroundColor = self.isDarkMode ? LookinColorRGBAMake(255, 255, 255, .2).CGColor : LookinColorRGBAMake(0, 0, 0, .2).CGColor;
    }
}

- (void)setIsDarkMode:(BOOL)isDarkMode {
    [super setIsDarkMode:isDarkMode];
    [self _updateStrikethroughLayerColor];
}

- (void)_updateEventHandlerButtonColors {
    if (self.eventHandlerButton.hidden) {
        return;
    }
    NSColor *color;
    if (self.isSelected) {
        color = [NSColor whiteColor];
    } else {
        CGFloat alpha = self.isFocusingHandlerButton ? 1 :  .5;
        color = LookinColorRGBAMake(74, 144, 226, alpha);
    }
    self.eventHandlerButtonColorLayer.backgroundColor = color.CGColor;
}

- (void)_updateEventHandlerButtonLayout {
    CGFloat width = self.isFocusingHandlerButton ? 8 : 5;
    $(self.eventHandlerButtonColorLayer).fullHeight.width(width).horAlign;
    self.eventHandlerButtonColorLayer.cornerRadius = width / 2.0;
}

- (void)_updateLabelsFonts {
    if (self.displayItem.inNoPreviewHierarchy || self.displayItem.inHiddenHierarchy) {
        self.titleLabel.font = [LKHelper italicFontOfSize:13];
        self.subtitleLabel.font = [LKHelper italicFontOfSize:12];
    } else {
        self.titleLabel.font = NSFontMake(13);
        self.subtitleLabel.font = NSFontMake(12);
    }
    [self setNeedsLayout:YES];
}

#pragma mark - Others

- (NSImage *)_iconWithDisplayItem:(LookinDisplayItem *)item isSelected:(BOOL)isSelected {
    static dispatch_once_t viewOnceToken;
    static NSArray<NSDictionary<NSString *, NSString *> *> *viewsList = nil;
    dispatch_once(&viewOnceToken,^{
        viewsList = @[
                      @{@"UIWindow": @"hierarchy_window"},
                      @{@"UINavigationBar": @"hierarchy_navigationbar"},
                      @{@"UITabBar": @"hierarchy_tabbar"},
                      @{@"UITextView": @"hierarchy_textview"},
                      @{@"UITextField": @"hierarchy_textfield"},
                      @{@"UITableView": @"hierarchy_tableview"},
                      @{@"UICollectionView": @"hierarchy_collectionview"},
                      @{@"UICollectionViewCell": @"hierarchy_collectioncell"},
                      @{@"UICollectionReusableView": @"hierarchy_collectionreuseview"},
                      @{@"UITableViewCell": @"hierarchy_tablecell"},
                      @{@"UISlider": @"hierarchy_slider"},
                      @{@"WKWebView": @"hierarchy_webview"},
                      @{@"UIWebView": @"hierarchy_webview"},
                      @{@"_UITableViewCellSeparatorView": @"hierarchy_tablecellseparator"},
                      @{@"UITableViewCellContentView": @"hierarchy_cellcontent"},
                      @{@"_UITableViewHeaderFooterContentView": @"hierarchy_cellcontent"},
                      @{@"UITableViewHeaderFooterView": @"hierarchy_tableheaderfooter"},
                      @{@"UIScrollView": @"hierarchy_scrollview"},
                      @{@"UILabel": @"hierarchy_label"},
                      @{@"UIButton": @"hierarchy_button"},
                      @{@"UIImageView": @"hierarchy_imageview"},
                      @{@"UIControl": @"hierarchy_control"},
                      @{@"UIVisualEffectView": @"hierarchy_effectview"}
                      ];
    });
    
    __block NSString *imageName = nil;
    if (item.hostViewControllerObject) {
        imageName = @"hierarchy_controller";
        
    } else if (item.viewObject) {
        [item.viewObject.classChainList enumerateObjectsUsingBlock:^(NSString * _Nonnull className, NSUInteger idx, BOOL * _Nonnull stop) {
            imageName = [viewsList lookin_firstFiltered:^BOOL(NSDictionary<NSString *, NSString*> *obj) {
                return !!obj[className];
            }][className];
            
            if (imageName) {
                *stop = YES;
            }
        }];
        
        if (!imageName) {
            imageName = @"hierarchy_view";
        }
        
    } else if (item.layerObject) {
        [item.layerObject.classChainList enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:@"CAShapeLayer"]) {
                imageName = @"hierarchy_shapelayer";
                *stop = YES;
                return;
            }
            if ([obj isEqualToString:@"CAGradientLayer"]) {
                imageName = @"hierarchy_gradientlayer";
                *stop = YES;
                return;
            }
        }];
        if (!imageName) {
            imageName = @"hierarchy_layer";
        }
    }
    
    if (!imageName) {
        imageName = @"hierarchy_view";
    }

    if (isSelected) {
        NSString *selectedImageName = [imageName stringByAppendingString:@"_selected"];
        NSImage *selectedImage = NSImageMake(selectedImageName);
        if (selectedImage) {
            return selectedImage;
        } else {
            return NSImageMake(imageName);
        }
    } else {
        return NSImageMake(imageName);
    }
}

+ (CGFloat)insetLeft {
    return 13;
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    [self.trackingAreas enumerateObjectsUsingBlock:^(NSTrackingArea * _Nonnull oldArea, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeTrackingArea:oldArea];
    }];
    
    NSTrackingArea *newArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSEventTypeMouseExited|NSTrackingMouseMoved|NSTrackingActiveInKeyWindow|NSTrackingInVisibleRect owner:self userInfo:nil];
    [self addTrackingArea:newArea];
}

@end
