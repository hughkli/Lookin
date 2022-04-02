//
//  LKDashboardAccessoryWindowController.m
//  Lookin
//
//  Created by Li Kai on 2019/8/30.
//  https://lookin.work
//

#import "LKDashboardAccessoryWindowController.h"
#import "LKDashboardSectionView.h"
#import "LookinAttributesSection.h"
#import "LookinDashboardBlueprint.h"
#import "LKPopPanel.h"

@interface LKDashboardAccessoryWindowController () <NSWindowDelegate>

@property(nonatomic, copy) LookinAttrGroupIdentifier groupID;
@property(nonatomic, weak) LKDashboardViewController *dashboardController;
/// key 是 LookinAttrSectionIdentifier
@property(nonatomic, strong) NSMutableDictionary<LookinAttrSectionIdentifier, LKDashboardSectionView *> *sectionViews;

@end

@implementation LKDashboardAccessoryWindowController

- (instancetype)initWithDashboardController:(LKDashboardViewController *)dashboardController attrGroupID:(LookinAttrGroupIdentifier)groupID {
    self.groupID = groupID;
    self.dashboardController = dashboardController;
    self.sectionViews = [NSMutableDictionary dictionary];
    
    LKPopPanel *panel = [[LKPopPanel alloc] initWithSize:NSMakeSize(400, 100)];
    panel.delegate = self;

    return [self initWithWindow:panel];
}

- (NSSize)renderWithAttrSections:(NSArray<LookinAttributesSection *> *)sections {
    NSMutableArray<LKDashboardSectionView *> *needlessViews = [self.sectionViews allValues].mutableCopy;
    
    [sections enumerateObjectsUsingBlock:^(LookinAttributesSection * _Nonnull attrSec, NSUInteger idx, BOOL * _Nonnull stop) {
        LKDashboardSectionView *view = self.sectionViews[attrSec.identifier];
        if (view) {
            [needlessViews removeObject:view];
            view.hidden = NO;
        } else {
            view = [LKDashboardSectionView new];
            self.sectionViews[attrSec.identifier] = view;
        }
        
        view.dashboardViewController = self.dashboardController;
        view.manageState = LKDashboardSectionManageState_CanAdd;
        view.attrSection = attrSec;
        view.showTopSeparator = (idx != 0);
        [self.window.contentView addSubview:view];
    }];
    
    [needlessViews enumerateObjectsUsingBlock:^(LKDashboardSectionView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    
    // layout
    CGFloat normalSecWidth = DashboardViewWidth - DashboardHorInset * 2;
    __block CGFloat y = 8;
    [[LookinDashboardBlueprint sectionIDsForGroupID:self.groupID] enumerateObjectsUsingBlock:^(LookinAttrSectionIdentifier _Nonnull secID, NSUInteger idx, BOOL * _Nonnull stop) {
        LKDashboardSectionView *view = self.sectionViews[secID];
        if (!view || view.hidden) {
            return;
        }
        $(view).x(DashboardHorInset).width(normalSecWidth - DashboardHorInset * 2).heightToFit.y(y);
        y = view.$maxY + DashboardSectionMarginTop;
    }];
    
    return NSMakeSize(normalSecWidth + 23, y);
}

#pragma mark - <NSWindowDelegate>

- (void)windowWillClose:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(dashboardAccessoryWindowControllerWillClose:)]) {
        [self.delegate dashboardAccessoryWindowControllerWillClose:self];
    }
}

@end
