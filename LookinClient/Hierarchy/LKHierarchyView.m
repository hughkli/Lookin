//
//  LKHierarchyView.m
//  Lookin
//
//  Created by Li Kai on 2018/8/4.
//  https://lookin.work
//

#import "LKHierarchyView.h"
#import "LKStaticHierarchyDataSource.h"
#import "LookinDisplayItem.h"
#import "LKPreferenceManager.h"
#import "LKWindowController.h"
#import "LKTableView.h"
#import "LookinIvarTrace.h"
#import "LKNavigationManager.h"
#import "LKTutorialManager.h"
#import "LKTextFieldView.h"
#import "LKTipsView.h"

static NSString * const kMenuBindKey_RowView = @"view";
static CGFloat const kRowHeight = 28;
extern NSString *const LKAppShowConsoleNotificationName;

@interface LKHierarchyView () <LKTableViewDelegate, LKTableViewDataSource, NSMenuDelegate, NSTextFieldDelegate>

@property(nonatomic, strong) LKVisualEffectView *backgroundEffectView;

@property(nonatomic, strong) CAShapeLayer *guidesShapeLayer;

@property(nonatomic, strong) LKTextFieldView *searchTextFieldView;

@property(nonatomic, strong) LKLabel *emptyDataLabel;

@property(nonatomic, copy) NSArray<LookinDisplayItem *> *displayItems;

@property(nonatomic, assign) NSInteger minIndentLevel;

@end

@implementation LKHierarchyView

- (instancetype)initWithDataSource:(LKHierarchyDataSource *)dataSource {
    if (self = [super initWithFrame:CGRectZero]) {
        self.dataSource = dataSource;
        
        self.backgroundEffectView = [LKVisualEffectView new];
        self.backgroundEffectView.material = NSVisualEffectMaterialSidebar;
        self.backgroundEffectView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
        self.backgroundEffectView.state = NSVisualEffectStateActive;
        [self addSubview:self.backgroundEffectView];

        _tableView = [LKTableView new];
        self.tableView.adjustsSelectionAutomatically = NO;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self addSubview:self.tableView];
        [self.tableView reloadData];
        
        self.guidesShapeLayer = [CAShapeLayer layer];
        self.guidesShapeLayer.lineWidth = 1;
        self.guidesShapeLayer.hidden = YES;
        [self.guidesShapeLayer lookin_removeImplicitAnimations];
        [self.guidesShapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:2], [NSNumber numberWithInt:2], nil]];
        [self.tableView.contentView.documentView.layer addSublayer:self.guidesShapeLayer];
        
        self.searchTextFieldView = [LKTextFieldView new];
        self.searchTextFieldView.textField.placeholderString = NSLocalizedString(@"Filter", nil);
        [self.searchTextFieldView initCloseButton];
        self.searchTextFieldView.insets = NSEdgeInsetsMake(0, 7, 0, 1);
        self.searchTextFieldView.textField.font = NSFontMake(13);
        self.searchTextFieldView.textField.usesSingleLineMode = YES;
        self.searchTextFieldView.textField.lineBreakMode = NSLineBreakByTruncatingTail;
        self.searchTextFieldView.textField.drawsBackground = NO;
        self.searchTextFieldView.textField.bordered = NO;
        self.searchTextFieldView.textField.focusRingType = NSFocusRingTypeNone;
        self.searchTextFieldView.borderPosition = LKViewBorderPositionTop;
        self.searchTextFieldView.borderColors = LKColorsCombine(LookinColorMake(200, 201, 202), LookinColorMake(67, 68, 69));
        self.searchTextFieldView.image = NSImageMake(@"icon_hierarchy_search");
        self.searchTextFieldView.textField.delegate = self;
        [self addSubview:self.searchTextFieldView];
        @weakify(self);
        [[[self.searchTextFieldView.textField.rac_textSignal throttle:0.5] skip:1] subscribeNext:^(NSString * _Nullable x) {
            @strongify(self);
            x = [x stringByReplacingOccurrencesOfString:@"\\s" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, x.length)];    // 去掉所有空白字符
            if ([self.delegate respondsToSelector:@selector(hierarchyView:didInputSearchString:)]) {
                [self.delegate hierarchyView:self didInputSearchString:x];
            }
        }];
        self.searchTextFieldView.closeButton.target = self;
        self.searchTextFieldView.closeButton.action = @selector(_handleSearchCloseButton);
        
        [[RACObserve(self.tableView, contentInsets) distinctUntilChanged] subscribeNext:^(NSValue *x) {
            CGFloat insetTop = [x edgeInsetsValue].top;
            [LKNavigationManager sharedInstance].windowTitleBarHeight = insetTop;
        }];
        
        [RACObserve(dataSource, selectedItem) subscribeNext:^(LookinDisplayItem * _Nullable item) {
            @strongify(self);
            [self scrollToMakeItemVisible:item];
        }];
        
        [[RACObserve(self.dataSource, hoveredItem) distinctUntilChanged] subscribeNext:^(LookinDisplayItem * _Nullable x) {
            @strongify(self);
            [self updateGuidesWithHoveredItem:x];
        }];
        
        [RACObserve(dataSource, displayingFlatItems) subscribeNext:^(NSArray<LookinDisplayItem *> *x) {
            @strongify(self);
            [self renderWithDisplayItems:x];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self updateGuidesWithHoveredItem:self.dataSource.hoveredItem];
            });
        }];
        [[RACObserve(dataSource, displayingFlatItems) throttle:.75] subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self _bringGuidesLayerToFront];
        }];
        
        [self updateColors];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.backgroundEffectView).fullFrame;
    $(self.searchTextFieldView).fullWidth.height(25).bottom(0);

    $(self.tableView).fullFrame.y(self.searchTextFieldView.$y);
    $(self.tableView).fullFrame.toMaxY(self.searchTextFieldView.$y);

    $(self.guidesShapeLayer).frame(CGRectZero);
    
    if (self.emptyDataLabel.isVisible) {
        $(self.emptyDataLabel).sizeToFit.centerAlign;
    }
}

- (void)renderWithDisplayItems:(NSArray<LookinDisplayItem *> *)displayItems {
    self.displayItems = displayItems;
    
    _minIndentLevel = [[displayItems lookin_reduce:^NSNumber *(NSNumber *accumulator, NSUInteger idx, LookinDisplayItem *obj) {
        NSInteger res = accumulator ? MIN(accumulator.integerValue, obj.indentLevel):obj.indentLevel;
        return @(res);
    }] integerValue];
    
    [self.tableView reloadData];
    
    if (displayItems.count == 0) {
        if (!self.emptyDataLabel) {
            self.emptyDataLabel = [LKLabel new];
            self.emptyDataLabel.font = NSFontMake(15);
            self.emptyDataLabel.stringValue = NSLocalizedString(@"No Filter Results", nil);
            [self addSubview:self.emptyDataLabel];
        }
        self.emptyDataLabel.hidden = NO;
        [self setNeedsLayout:YES];
    } else {
        self.emptyDataLabel.hidden = YES;
    }
}

- (void)scrollToMakeItemVisible:(LookinDisplayItem *)item {
    if (!item)  {
        return;
    }
    NSUInteger row = [self.displayItems indexOfObject:item];
    if (row < 0 || row == NSNotFound) {
        return;
    }
    [self.tableView scrollRowToVisible:row];
}

- (void)updateColors {
    [super updateColors];
    self.guidesShapeLayer.strokeColor = self.isDarkMode ? LookinColorRGBAMake(255, 255, 255, .3).CGColor : LookinColorRGBAMake(0, 0, 0, .3).CGColor;
}

- (void)_exitAndClearSearch {    
    self.searchTextFieldView.textField.stringValue = @"";
    
    [self.window makeFirstResponder:nil];
    
    if ([self.delegate respondsToSelector:@selector(hierarchyView:didInputSearchString:)]) {
        [self.delegate hierarchyView:self didInputSearchString:nil];
    }
}

- (void)activateSearchBar {
    [self.searchTextFieldView.textField becomeFirstResponder];
}

#pragma mark - NSTableView

- (void)tableView:(LKTableView *)tableView didHoverAtRow:(NSInteger)row {
    // 注意这里 item 可能为 nil
    LookinDisplayItem *item = [self _safeItemAtRow:row];
    
    if ([self.delegate respondsToSelector:@selector(hierarchyView:didHoverAtItem:)]) {
        [self.delegate hierarchyView:self didHoverAtItem:item];
    }
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return kRowHeight;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.displayItems.count;
}

- (LKTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    LookinDisplayItem *item = [self _safeItemAtRow:row];
    if (!item) {
        NSAssert(NO, @"");
        return [LKTableBlankRowView new];
    }
    
    LKHierarchyRowView *view = [tableView makeViewWithIdentifier:@"cell" owner:self];
    if (!view) {
        view = [[LKHierarchyRowView alloc] init];
        view.disclosureButton.target = self;
        view.disclosureButton.action = @selector(_handleDisclosureButton:);
        view.identifier = @"cell";
        
        view.menu = [NSMenu new];
        view.menu.autoenablesItems = YES;
        [view.menu lookin_bindObjectWeakly:view forKey:kMenuBindKey_RowView];
        view.menu.delegate = self;
    }
    
    view.minIndentLevel = self.minIndentLevel;
    view.displayItem = item;
    
    view.disclosureButton.tag = row;
    return view;
}

- (void)tableView:(NSTableView *)tableView didSelectRow:(NSInteger)row {
    LookinDisplayItem *item = [self _safeItemAtRow:row];
    if (!item) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(hierarchyView:didSelectItem:)]) {
        [self.delegate hierarchyView:self didSelectItem:item];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self _bringGuidesLayerToFront];
    });
}

- (void)tableView:(NSTableView *)tableView didDoubleClickAtRow:(NSInteger)row {
    LookinDisplayItem *item = [self _safeItemAtRow:row];
    if (!item) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(hierarchyView:didDoubleClickItem:)]) {
        [self.delegate hierarchyView:self didDoubleClickItem:item];
    }
}

#pragma mark - <NSMenuDelegate>

- (void)menuNeedsUpdate:(NSMenu *)menu {
    LKHierarchyRowView *rowView = [menu lookin_getBindObjectForKey:kMenuBindKey_RowView];
    LookinDisplayItem *displayItem = rowView.displayItem;
    
    [menu removeAllItems];

    [menu addItem:({
        NSMenuItem *item = [NSMenuItem new];
        item.target = self;
        item.action = @selector(_handleFocusCurrentItem:);
        item.title = NSLocalizedString(@"Focus", nil);
        item;
    })];
    [menu addItem:({
        NSMenuItem *item = [NSMenuItem new];
        item.target = self;
        item.action = @selector(_handlePrintItem:);
        item.title = NSLocalizedString(@"Print", nil);
        item;
    })];

    [menu addItem:[NSMenuItem separatorItem]];

    if (displayItem.isExpandable) {
        [menu addItem:({
            NSMenuItem *item = [NSMenuItem new];
            item.target = self;
            item.action = @selector(_handleExpandRecursively:);
            item.title = NSLocalizedString(@"Expand recursively", nil);
            item;
        })];
        [menu addItem:({
            NSMenuItem *item = [NSMenuItem new];
            item.target = self;
            item.action = @selector(_handleCollapseChildren:);
            item.title = NSLocalizedString(@"Collapse children", nil);
            item;
        })];
    }

    // 显示和隐藏图像
    [menu addItem:[NSMenuItem separatorItem]];
    
    if (displayItem.inNoPreviewHierarchy) {
        [menu addItem:({
            NSMenuItem *item = [NSMenuItem new];
            item.target = self;
            item.action = @selector(_handleShowPreview:);
            if (displayItem.doNotFetchScreenshotReason == LookinFetchScreenshotPermitted) {
                item.title = NSLocalizedString(@"Show screenshot", nil);
            } else {
                item.title = NSLocalizedString(@"Show layer border", nil);
            }
            item;
        })];
    } else {
        [menu addItem:({
            NSMenuItem *item = [NSMenuItem new];
            item.target = self;
            item.action = @selector(_handleCancelPreview:);
            item.title = NSLocalizedString(@"Hide screenshot this time", nil);
            item;
        })];
    }
    
    if (displayItem.groupScreenshot) {
        [menu addItem:({
            NSMenuItem *item = [NSMenuItem new];
            item.target = self;
            item.action = @selector(_handleExportScreenshot:);
            item.title = NSLocalizedString(@"Export screenshot…", nil);
            item;
        })];        
    }

    // 复制文字
    NSMutableArray<NSString *> *stringsToCopy = [NSMutableArray array];
    
    BOOL doNotCopyTitle = NO;
    if ([displayItem.title hasPrefix:@"UI"] || [displayItem.title hasPrefix:@"CA"]) {
        if (displayItem.title.length < 10) {
            // 不显示常见的 UIView、CALayer 等系统类，避免干扰
            doNotCopyTitle = YES;
        }
    }
    if (!doNotCopyTitle) {
        [stringsToCopy addObject:displayItem.title];

    }
    NSString *hostViewControllerName = displayItem.hostViewControllerObject.shortSelfClassName;
    if (hostViewControllerName.length) {
        [stringsToCopy addObject:hostViewControllerName];
    }
    if (displayItem.displayingObject.ivarTraces.count) {
        NSArray<NSString *> *ivarNames = [[displayItem.displayingObject.ivarTraces lookin_map:^id(NSUInteger idx, LookinIvarTrace *value) {
            NSString *name = value.ivarName;
            if ([name hasPrefix:@"_"]) {
                name = [name substringFromIndex:1];
            }
            return name;
        }] lookin_nonredundantArray];
        if (ivarNames.count) {
            [stringsToCopy addObjectsFromArray:ivarNames];
        }
    }
    [stringsToCopy enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            [menu addItem:[NSMenuItem separatorItem]];
        }
        if (obj.length == 0) {
            NSAssert(NO, @"LKHierarchyView, menuNeedsUpdate, stringsToCopy length is zero.");
            return;
        }
        [menu addItem:({
            NSMenuItem *item = [NSMenuItem new];
            item.target = self;
            item.action = @selector(_handleCopyDisplayItemName:);
            item.representedObject = obj;
            item.title = [NSString stringWithFormat:NSLocalizedString(@"Copy text \"%@\"", nil), obj];
            item;
        })];
    }];
    
    if (!displayItem.inNoPreviewHierarchy) {
        [menu addItem:[NSMenuItem separatorItem]];
        [menu addItem:({
            NSMenuItem *item = [NSMenuItem new];
            item.target = self;
            item.action = @selector(_handleHideScreenshotForever);
            item.title = NSLocalizedString(@"Hide screenshot forever…", nil);
            item;
        })];
    }
}

#pragma mark - <NSTextFieldDelegate>

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == NSSelectorFromString(@"cancelOperation:")) {
        // 按下了 esc 键
        [self _exitAndClearSearch];
        return YES;
    }
    return NO;
}

#pragma mark - Events Handler
- (void)_handlePrintItem:(NSMenuItem *)menuItem {
    LKHierarchyRowView *view = [menuItem.menu lookin_getBindObjectForKey:kMenuBindKey_RowView];
    LookinDisplayItem *item = view.displayItem;
    [[NSNotificationCenter defaultCenter] postNotificationName:LKAppShowConsoleNotificationName object:item];
}

- (void)_handleFocusCurrentItem:(NSMenuItem *)menuItem {
    LKHierarchyRowView *view = [menuItem.menu lookin_getBindObjectForKey:kMenuBindKey_RowView];
    LookinDisplayItem *item = view.displayItem;
    if (!item) {
        NSAssert(NO, @"");
        return;
    }
    [self.dataSource focusDisplayItem:item];
}

- (void)_handleSearchCloseButton {
    [self _exitAndClearSearch];
}

- (void)_handleShowPreview:(NSMenuItem *)menuItem {
    [LKTutorialManager sharedInstance].togglePreview = YES;
    
    LKHierarchyRowView *view = [menuItem.menu lookin_getBindObjectForKey:kMenuBindKey_RowView];
    LookinDisplayItem *item = view.displayItem;
    if ([self.delegate respondsToSelector:@selector(hierarchyView:needToShowPreviewOfItem:)]) {
        [self.delegate hierarchyView:self needToShowPreviewOfItem:item];
    }
}

- (void)_handleCancelPreview:(NSMenuItem *)menuItem {
    [LKTutorialManager sharedInstance].togglePreview = YES;
    
    LKHierarchyRowView *view = [menuItem.menu lookin_getBindObjectForKey:kMenuBindKey_RowView];
    LookinDisplayItem *item = view.displayItem;
    if ([self.delegate respondsToSelector:@selector(hierarchyView:needToCancelPreviewOfItem:)]) {
        [self.delegate hierarchyView:self needToCancelPreviewOfItem:item];
    }
}

- (void)_handleExportScreenshot:(NSMenuItem *)menuItem {
    LKHierarchyRowView *view = [menuItem.menu lookin_getBindObjectForKey:kMenuBindKey_RowView];
    [LKExportManager exportScreenshotWithDisplayItem:view.displayItem];
}

- (void)_handleCopyDisplayItemName:(NSMenuItem *)menuItem {
    NSString *stringToCopy = menuItem.representedObject;
    
    NSPasteboard *paste = [NSPasteboard generalPasteboard];
    [paste clearContents];
    [paste writeObjects:@[stringToCopy]];
}

- (void)_handleExpandRecursively:(NSMenuItem *)menuItem {
    LKHierarchyRowView *view = [menuItem.menu lookin_getBindObjectForKey:kMenuBindKey_RowView];
    LookinDisplayItem *item = view.displayItem;
    NSAssert(item, @"");
    if ([self.delegate respondsToSelector:@selector(hierarchyView:needToExpandItem:recursively:)]) {
        [self.delegate hierarchyView:self needToExpandItem:item recursively:YES];
    }
}

- (void)_handleCollapseChildren:(NSMenuItem *)menuItem {
    LKHierarchyRowView *view = [menuItem.menu lookin_getBindObjectForKey:kMenuBindKey_RowView];
    LookinDisplayItem *item = view.displayItem;
    NSAssert(item, @"");
    if ([self.delegate respondsToSelector:@selector(hierarchyView:needToCollapseChildrenOfItem:)]) {
        [self.delegate hierarchyView:self needToCollapseChildrenOfItem:item];
    }
}

- (void)_handleDisclosureButton:(NSButton *)button {
    NSUInteger row = button.tag;
    LookinDisplayItem *item = [self _safeItemAtRow:row];
    if (!item.isExpandable) {
        NSAssert(NO, @"");
        return;
    }
    if (item.isExpanded) {
        if ([self.delegate respondsToSelector:@selector(hierarchyView:needToCollapseItem:)]) {
            [self.delegate hierarchyView:self needToCollapseItem:item];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(hierarchyView:needToExpandItem:recursively:)]) {
            [self.delegate hierarchyView:self needToExpandItem:item recursively:NO];
        }
    }
}

- (void)_handleHideScreenshotForever {
    [LKHelper openCustomConfigWebsite];
}

#pragma mark - Guides

- (void)updateGuidesWithHoveredItem:(LookinDisplayItem *)item {
    if (!item) {
        self.guidesShapeLayer.hidden = YES;
        return;
    }
    
    LookinDisplayItem *rootItem = item.superItem;
    NSUInteger rootRow = [self.displayItems indexOfObject:rootItem];
    NSArray<LookinDisplayItem *> *childrenItems = [rootItem.subitems lookin_filter:^BOOL(LookinDisplayItem *obj) {
        return [self.displayItems containsObject:obj];
    }];
    
    if (rootRow == NSNotFound || childrenItems.count == 0) {
        self.guidesShapeLayer.hidden = YES;
        return;
    }
    
    CGFloat rootX = [LKHierarchyRowView dislosureMidXWithIndentLevel:rootItem.indentLevel - self.minIndentLevel];
    CGFloat rootY = kRowHeight * rootRow + kRowHeight / 2.0;
    CGFloat rootMaxY = [self.displayItems indexOfObject:childrenItems.lastObject] * kRowHeight + kRowHeight / 2.0;

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, rootX, rootY);
    CGPathAddLineToPoint(path, NULL, rootX, rootMaxY);
    [childrenItems enumerateObjectsUsingBlock:^(LookinDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat childrenY = [self.displayItems indexOfObject:obj] * kRowHeight + kRowHeight / 2.0;
        CGPathMoveToPoint(path, NULL, rootX, childrenY);
        CGFloat maxX = obj.isExpandable ? (rootX + 10) : (rootX + 28);
        CGPathAddLineToPoint(path, NULL, maxX, childrenY);
    }];
    [self.guidesShapeLayer setPath:path];
    self.guidesShapeLayer.hidden = NO;
    CGPathRelease(path);
}

- (void)_bringGuidesLayerToFront {
    [self.guidesShapeLayer removeFromSuperlayer];
    [self.tableView.contentView.documentView.layer addSublayer:self.guidesShapeLayer];
}

#pragma mark - Others

- (LookinDisplayItem *)_safeItemAtRow:(NSInteger)row {
    return [self.displayItems lookin_hasIndex:row] ? self.displayItems[row] : nil;
}


@end
