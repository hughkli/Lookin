//
//  LKDashboardCardView.m
//  Lookin
//
//  Created by Li Kai on 2018/11/18.
//  https://lookin.work
//

#import "LKDashboardCardView.h"
#import "LookinAttributesGroup.h"
#import "LookinAttributesSection.h"
#import "LKDashboardAttributeNumberInputView.h"
#import "LKDashboardAttributeSwitchView.h"
#import "LKDashboardAttributeColorView.h"
#import "LKDashboardAttributeEnumsView.h"
#import "LKDashboardViewController.h"
#import "LKDashboardSectionView.h"
#import "LookinDashboardBlueprint.h"
#import "LKPreferenceManager.h"
#import "LKDashboardCardTitleControl.h"
#import "LKDashboardAccessoryWindowController.h"
#import "LKUserActionManager.h"
#import "LookinAttributesGroup+LookinClient.h"
#import "LookinAttributesSection+LookinClient.h"
#import "LKDashboardSectionViewPool.h"

@interface LKDashboardCardView () <LKUserActionManagerDelegate, LKDashboardAccessoryWindowControllerDelegate>

@property(nonatomic, strong) LKVisualEffectView *backgroundEffectView;
@property(nonatomic, strong) LKDashboardCardTitleControl *titleControl;
@property(nonatomic, strong) NSButton *detailButton;

@property(nonatomic, strong) LKBaseView *fadeView;

@property(nonatomic, strong) LKDashboardSectionViewPool *sectionViewPool;
@property(nonatomic, strong) NSMutableArray<LKDashboardSectionView *> *sectionViews;

@property(nonatomic, strong) LKDashboardAccessoryWindowController *accessoryWC;


@end

@implementation LKDashboardCardView {
    CGFloat _titleHeight;
    CGFloat _contentsY;
    CGFloat _insetBottom;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _titleHeight = 30;
        _contentsY = 35;
        _insetBottom = 12;
        self.sectionViews = [NSMutableArray array];
        
        self.layer.cornerRadius = DashboardCardCornerRadius;
        
        self.backgroundEffectView = [LKVisualEffectView new];
        self.backgroundEffectView.blendingMode = NSVisualEffectBlendingModeWithinWindow;
        self.backgroundEffectView.state = NSVisualEffectStateActive;
        [self addSubview:self.backgroundEffectView];
 
        self.titleControl = [LKDashboardCardTitleControl new];
        [self.titleControl addTarget:self clickAction:@selector(_handleClickTitle)];
        [self addSubview:self.titleControl];
        
        self.detailButton = [NSButton buttonWithImage:NSImageMake(@"icon_more") target:self action:@selector(_handleClickDetailButton)];
        self.detailButton.bezelStyle = NSBezelStyleRoundRect;
        self.detailButton.bordered = NO;
        [self addSubview:self.detailButton];
        
        self.sectionViewPool = [LKDashboardSectionViewPool new];
        
        [self updateColors];
        
        [[LKUserActionManager sharedInstance] addDelegate:self];
    }
    return self;
}

- (void)layout {
    [super layout];
    
    $(self.backgroundEffectView).fullFrame;
    $(self.titleControl).fullWidth.height(_titleHeight).y(0);
    if (self.detailButton.isVisible) {
        $(self.detailButton).width(50).height(28).right(-3).y(0);
    }
    
    if (!self.attrGroup || !self.sectionViews.count) {
        return;
    }
    
    __block CGFloat y = _contentsY;
    [self.sectionViews enumerateObjectsUsingBlock:^(LKDashboardSectionView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        $(view).x(DashboardHorInset).toRight(DashboardHorInset).heightToFit.y(y);
        y = view.$maxY + DashboardSectionMarginTop;
    }];
//    [[LookinDashboardBlueprint sectionIDsForGroupID:self.attrGroup.identifier] enumerateObjectsUsingBlock:^(LookinAttrSectionIdentifier _Nonnull secID, NSUInteger idx, BOOL * _Nonnull stop) {
//        LKDashboardSectionView *view = self.sectionViews[secID];
//        if (!view.isVisible) {
//            return;
//        }
//        $(view).x(DashboardHorInset).toRight(DashboardHorInset).heightToFit.y(y);
//        y = view.$maxY + DashboardSectionMarginTop;
//    }];
}

- (CGSize)sizeThatFits:(NSSize)limitedSize {
    if (self.isCollapsed) {
        limitedSize.height = _titleHeight;
        return limitedSize;
    }
    limitedSize.width -= DashboardHorInset * 2;
    __block CGFloat height = _contentsY;
    [self.sectionViews enumerateObjectsUsingBlock:^(LKDashboardSectionView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat sectionHeight = [obj sizeThatFits:limitedSize].height;
        height += (sectionHeight + DashboardSectionMarginTop);
    }];
    height -= DashboardSectionMarginTop;
    height += _insetBottom;
    
    limitedSize.height = height;
    return limitedSize;
}

- (void)render {
    if (!self.attrGroup) {
        NSAssert(NO, @"");
        return;
    }
    if ([self.attrGroup.identifier isEqualToString:LookinAttrGroup_Class]) {
        _contentsY = 28;
    } else if ([self.attrGroup.identifier isEqualToString:LookinAttrGroup_Relation]) {
        _contentsY = 30;
    } else {
        _contentsY = 35;
    }
    
    self.titleControl.label.stringValue = [self.attrGroup queryDisplayTitle];
    self.titleControl.iconImageView.image = [LKDashboardCardView imageWithAttrGroup:self.attrGroup];
    [self.titleControl setNeedsLayout:YES];
    
    self.detailButton.hidden = ![self _shouldShowDetailButtonWithGroupID:self.attrGroup.identifier];
    
    [self.sectionViews enumerateObjectsUsingBlock:^(LKDashboardSectionView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.sectionViews removeAllObjects];
    [self.sectionViewPool recycleAll];

    [self.attrGroup.attrSections enumerateObjectsUsingBlock:^(LookinAttributesSection * _Nonnull sec, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!sec.isUserCustom && ![[LKPreferenceManager mainManager] isSectionShowing:sec.identifier]) {
            return;
        }
        
        LKDashboardSectionView *secView = [self.sectionViewPool dequeViewForSection:sec];
        [self.sectionViews addObject:secView];
        [self addSubview:secView];
        secView.dashboardViewController = self.dashboardViewController;
        secView.attrSection = sec;
        secView.showTopSeparator = (idx > 0);
        
        if (self.accessoryWC) {
            secView.manageState = LKDashboardSectionManageState_CanRemove;
        } else {
            secView.manageState = LKDashboardSectionManageState_None;
        }
    }];
    
    if (self.accessoryWC) {
        [self _renderAccessoryWindowController];
    }
    
    [self setNeedsLayout:YES];
}

- (void)setIsCollapsed:(BOOL)isCollapsed {
    _isCollapsed = isCollapsed;
    self.titleControl.disclosureImageView.image = isCollapsed ? NSImageMake(@"icon_arrow_right") : NSImageMake(@"icon_arrow_down");
}

- (void)playFadeAnimationWithHighlightRect:(CGRect)rect {
    if (self.fadeView) {
        return;
    }

    self.fadeView = [LKBaseView new];
    self.fadeView.backgroundColor = self.isDarkMode ? LookinColorRGBAMake(0, 0, 0, .7) : LookinColorRGBAMake(0, 0, 0, .6);
    self.fadeView.alphaValue = 0;
    self.fadeView.frame = self.bounds;
    [self addSubview:self.fadeView];

    
    if (!CGRectEqualToRect(rect, CGRectZero)) {
        CGFloat totalHeight = self.fadeView.$height;
        if (totalHeight <= 0) {
            NSAssert(NO, @"");
            totalHeight = 1;
        }

        CAGradientLayer *maskLayer = [CAGradientLayer layer];
        maskLayer.colors = @[(id)[NSColor blackColor].CGColor,
                             (id)[NSColor blackColor].CGColor,
                             (id)[[NSColor clearColor] CGColor],
                             (id)[[NSColor clearColor] CGColor],
                             (id)[NSColor blackColor].CGColor,
                             (id)[NSColor blackColor].CGColor];
        maskLayer.startPoint = CGPointMake(0, 0);
        maskLayer.endPoint = CGPointMake(0, 1);
        maskLayer.locations = @[@0,
                                @((CGRectGetMinY(rect) - 4) / totalHeight),
                                @((CGRectGetMinY(rect) + 10) / totalHeight),
                                @((CGRectGetMaxY(rect) + 2) / totalHeight),
                                @((CGRectGetMaxY(rect) + 16) / totalHeight),
                                @1];
        maskLayer.frame = self.fadeView.bounds;
        self.fadeView.layer.mask = maskLayer;
    }
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = .3;
        self.fadeView.animator.alphaValue = 1;
    } completionHandler:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _removeFadeAnimation];
        });
    }];
}

- (void)_removeFadeAnimation {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = .3;
        self.fadeView.animator.alphaValue = 0;
    } completionHandler:^{
        [self.fadeView removeFromSuperview];
        self.fadeView = nil;
    }];
}

- (void)_handleClickTitle {
    if ([self.delegate respondsToSelector:@selector(dashboardCardViewNeedToggleCollapse:)]) {
        [self.delegate dashboardCardViewNeedToggleCollapse:self];
    }
}

+ (NSImage *)imageWithAttrGroup:(LookinAttributesGroup *)group {
    static dispatch_once_t onceToken;
    static NSDictionary<LookinAttrGroupIdentifier, NSImage *> *dict = nil;
    dispatch_once(&onceToken,^{
        dict = @{
                 LookinAttrGroup_Class: NSImageMake(@"dashboard_class"),
                 LookinAttrGroup_Relation: NSImageMake(@"dashboard_relation"),
                 LookinAttrGroup_Layout: NSImageMake(@"dashboard_layout"),
                 LookinAttrGroup_AutoLayout: NSImageMake(@"dashboard_autolayout"),
                 LookinAttrGroup_ViewLayer: NSImageMake(@"dashboard_layer"),
                 LookinAttrGroup_UIImageView: NSImageMake(@"dashboard_imageview"),
                 LookinAttrGroup_UILabel: NSImageMake(@"dashboard_label"),
                 LookinAttrGroup_UIButton: NSImageMake(@"dashboard_button"),
                 LookinAttrGroup_UIControl: NSImageMake(@"dashboard_control"),
                 LookinAttrGroup_UIScrollView: NSImageMake(@"dashboard_scrollview"),
                 LookinAttrGroup_UITableView: NSImageMake(@"dashboard_tableview"),
                 LookinAttrGroup_UITextView: NSImageMake(@"dashboard_textview"),
                 LookinAttrGroup_UITextField: NSImageMake(@"dashboard_textfield"),
                 LookinAttrGroup_UIVisualEffectView: NSImageMake(@"dashboard_effectview"),
                 LookinAttrGroup_UserCustom: NSImageMake(@"dashboard_effectview")
                 };
    });
    NSImage *image = dict[group.identifier];
    NSAssert(image, @"");
    return image;
}

#pragma mark - Others

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];
    [[LKUserActionManager sharedInstance] sendAction:LKUserActionType_DashboardClick];
}

#pragma mark - <LKUserActionManagerDelegate>

- (void)LKUserActionManager:(LKUserActionManager *)manager didAct:(LKUserActionType)type {
    if (!self.accessoryWC) {
        return;
    }
    NSArray<NSNumber *> *validTypes = @[@(LKUserActionType_PreviewOperation), @(LKUserActionType_DashboardClick), @(LKUserActionType_SelectedItemChange)];
    if (![validTypes containsObject:@(type)]) {
        return;
    }
    [self.accessoryWC close];
}

#pragma mark - Accessory

- (void)_handleClickDetailButton {
    if (self.accessoryWC) {
        [self.accessoryWC close];
        return;
    }
    
    [[LKUserActionManager sharedInstance] sendAction:LKUserActionType_DashboardClick];
    
    if (self.isCollapsed) {
        /// 如果当前是折叠状态，则展开
        if ([self.delegate respondsToSelector:@selector(dashboardCardViewNeedToggleCollapse:)]) {
            [self.delegate dashboardCardViewNeedToggleCollapse:self];
        }
    }
    
    self.accessoryWC = [[LKDashboardAccessoryWindowController alloc] initWithDashboardController:self.dashboardViewController attrGroupID:self.attrGroup.identifier];
    self.accessoryWC.delegate = self;
    
    [self _renderAccessoryWindowController];
    
    [self.window addChildWindow:self.accessoryWC.window ordered:NSWindowAbove];
}

- (void)_renderAccessoryWindowController {
    if (!self.accessoryWC) {
        NSAssert(NO, @"");
        return;
    }
    
    [self.sectionViews enumerateObjectsUsingBlock:^(LKDashboardSectionView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.manageState = LKDashboardSectionManageState_CanRemove;
    }];
    
    NSArray<LookinAttrSectionIdentifier> *allSecIDs = [LookinDashboardBlueprint sectionIDsForGroupID:self.attrGroup.identifier];
    NSArray<LookinAttrSectionIdentifier> *hiddenSecIDs = [allSecIDs lookin_filter:^BOOL(LookinAttrSectionIdentifier obj) {
        return ![[LKPreferenceManager mainManager] isSectionShowing:obj];
    }];
    if (hiddenSecIDs.count == 0) {
        self.accessoryWC.window.contentView.hidden = YES;
        return;
    }
    self.accessoryWC.window.contentView.hidden = NO;
    
    NSArray<LookinAttributesSection *> *sections = [hiddenSecIDs lookin_map:^id(NSUInteger idx, LookinAttrSectionIdentifier secID) {
        LookinAttributesSection *sec = [self.attrGroup.attrSections lookin_firstFiltered:^BOOL(LookinAttributesSection *obj) {
            return [obj.identifier isEqualToString:secID];
        }];
        return sec;
    }];
    
    NSSize contentSize = [self.accessoryWC renderWithAttrSections:sections];
    
    // 这里是左上角坐标系，比如 cardView 顶部恰好和窗口顶部重合时，y 为 0
    CGRect selfFrameInWindow = [self.window.contentView convertRect:self.frame fromView:self.superview];
    // 这里是左下角坐标系
    CGRect selfWindowFrame = self.window.frame;
    // 做个 MAX 以防止超出下边缘屏幕
    CGFloat panelY = MAX(selfWindowFrame.origin.y + (selfWindowFrame.size.height - selfFrameInWindow.origin.y) - contentSize.height, 0);
    CGFloat panelX = CGRectGetMaxX(selfWindowFrame) + 5;
    CGFloat panelMaxX = panelX + contentSize.width;
    if (panelMaxX > self.window.screen.frame.size.width) {
        // 防止超出屏幕右侧
        panelX = selfWindowFrame.origin.x + CGRectGetMinX(selfFrameInWindow) - contentSize.width - 5;
    }
    CGRect panelFrame = CGRectMake(panelX, panelY, contentSize.width, contentSize.height);
    // panelFrame 是左下角坐标系。虽然这里的 controller.window 是 self.window 的 childWindow，但 panelFrame 仍然是相对于 screen 的坐标，换句话说，如果 panelFrame.y 是 0，则 panel 的底部会和屏幕底部重合
    [self.accessoryWC.window setFrame:panelFrame display:YES];
}

- (void)dashboardAccessoryWindowControllerWillClose:(LKDashboardAccessoryWindowController *)controller {
    [self.sectionViews enumerateObjectsUsingBlock:^(LKDashboardSectionView * _Nonnull secView, NSUInteger idx, BOOL * _Nonnull stop) {
        secView.manageState = LKDashboardSectionManageState_None;
    }];
    self.accessoryWC = nil;
}

- (BOOL)_shouldShowDetailButtonWithGroupID:(LookinAttrGroupIdentifier)identifier {
    if ([identifier isEqualToString:LookinAttrGroup_UserCustom]) {
        return NO;
    }
    NSUInteger sectionCount = [LookinDashboardBlueprint sectionIDsForGroupID:identifier].count;
    if (sectionCount > 1) {
        return YES;
    } else {
        return NO;
    }
}

@end
