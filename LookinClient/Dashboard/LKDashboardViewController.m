//
//  LKDashboardViewController.m
//  Lookin
//
//  Created by Li Kai on 2018/8/6.
//  https://lookin.work
//

#import "LKDashboardViewController.h"
#import "LKStaticHierarchyDataSource.h"
#import "LKDashboardCardView.h"
#import "LookinDefines.h"
#import "LKAppsManager.h"
#import "LKPreferenceManager.h"
#import "LKStaticAsyncUpdateManager.h"
#import "LKReadHierarchyDataSource.h"
#import "LookinDashboardBlueprint.h"
#import "LKUserActionManager.h"
#import "LKDashboardSearchInputView.h"
#import "LKDashboardSearchPropView.h"
#import "LookinAttributesSection.h"
#import "LKDashboardSectionView.h"
#import "LKDashboardSearchMethodsView.h"
#import "LKDashboardSearchMethodsDataSource.h"

@interface LKDashboardViewController () <LKDashboardCardViewDelegate, LKDashboardSearchInputViewDelegate, LKDashboardSearchPropViewDelegate, LKDashboardSearchMethodsViewDelegate>

@property(nonatomic, strong) NSScrollView *scrollView;
@property(nonatomic, strong) LKBaseView *documentView;
@property(nonatomic, strong) LKBaseView *cardContainerView;

@property(nonatomic, copy) NSArray<LookinAttributesGroup *> *groupList;
/// key 是 group.uniqueKey
@property(nonatomic, strong) NSMutableDictionary<NSString *, LKDashboardCardView *> *cardViews;

@property(nonatomic, strong) LKBaseView *searchContainerView;
@property(nonatomic, strong) LKDashboardSearchInputView *searchInputView;
@property(nonatomic, strong) NSMutableArray<LKDashboardSearchPropView *> *searchPropViews;
@property(nonatomic, strong) LKDashboardSearchMethodsView *searchMethodsView;
@property(nonatomic, strong) LKDashboardSearchMethodsDataSource *methodsDataSource;

@property(nonatomic, strong) LKStaticHierarchyDataSource *staticDataSource;
@property(nonatomic, strong) LKReadHierarchyDataSource *readDataSource;

@end

@implementation LKDashboardViewController

- (instancetype)initWithStaticDataSource:(LKStaticHierarchyDataSource *)dataSource {
    if (self = [self initWithContainerView:nil]) {
        self.staticDataSource = dataSource;
        _isStaticMode = YES;
        [self _didInitialized];
        
    }
    return self;
}

- (instancetype)initWithReadDataSource:(LKReadHierarchyDataSource *)dataSource {
    if (self = [self initWithContainerView:nil]) {
        self.readDataSource = dataSource;
        _isStaticMode = NO;
        [self _didInitialized];
    }
    return self;
}

- (NSView *)makeContainerView {
    LKBaseView *containerView = [LKBaseView new];
    
    self.documentView = [LKBaseView new];
    
    self.scrollView = [[NSScrollView alloc] init];
    self.scrollView.drawsBackground = NO;
    self.scrollView.hasVerticalScroller = YES;
    self.scrollView.hasHorizontalScroller = NO;
    self.scrollView.autohidesScrollers = YES;
    self.scrollView.contentView.documentView = self.documentView;
    [containerView addSubview:self.scrollView];
    
    self.searchInputView = [LKDashboardSearchInputView new];
    self.searchInputView.delegate = self;
    [self.documentView addSubview:self.searchInputView];
    
    self.cardContainerView = [LKBaseView new];
    [self.documentView addSubview:self.cardContainerView];
    
    self.searchContainerView = [LKBaseView new];
    self.searchContainerView.hidden = YES;
    [self.documentView addSubview:self.searchContainerView];
    
    return containerView;
}

- (void)_didInitialized {
    self.cardViews = [NSMutableDictionary dictionary];
    self.searchPropViews = [NSMutableArray array];
    
    @weakify(self);
    if (self.staticDataSource) {
        [[[RACSignal merge:@[RACObserve(self.staticDataSource, selectedItem)]] deliverOnMainThread] subscribeNext:^(id x) {
            @strongify(self);
            [self reloadWithGroupList:[self.staticDataSource.selectedItem queryAllAttrGroupList]];
        }];
        
        [[self.staticDataSource.itemDidChangeAttrGroup deliverOnMainThread] subscribeNext:^(LookinDisplayItem *displayItem) {
            @strongify(self);
            if (self.staticDataSource.selectedItem == displayItem) {
                [self reloadWithGroupList:[displayItem queryAllAttrGroupList]];
            }
        }];
        
        self.methodsDataSource = [LKDashboardSearchMethodsDataSource new];
        [self.staticDataSource.didReloadHierarchyInfo subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self.methodsDataSource clearAllCache];
        }];
        
    } else if (self.readDataSource) {
        [[[RACSignal merge:@[RACObserve(self.readDataSource, selectedItem)]] deliverOnMainThread] subscribeNext:^(id x) {
            @strongify(self);
            [self reloadWithGroupList:[self.readDataSource.selectedItem queryAllAttrGroupList]];
        }];
    }

    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationName_DidChangeSectionShowing object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self);
        [self reloadWithGroupList:[[self currentDataSource].selectedItem queryAllAttrGroupList]];
    }];
}

- (void)viewDidLayout {
    [super viewDidLayout];

    $(self.scrollView).fullFrame;
    
    CGFloat verMargin = 10;
    CGFloat contentWidth = DashboardViewWidth - DashboardHorInset * 2;
    
    $(self.searchInputView).width(contentWidth).x(DashboardHorInset).height(23).y(10);
    
    if (!self.cardContainerView.hidden) {
        $(self.cardContainerView).width(contentWidth).x(DashboardHorInset).y(self.searchInputView.$maxY + verMargin);
    
        __block CGFloat y = 0;
        
        [self.groupList enumerateObjectsUsingBlock:^(LookinAttributesGroup * _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop) {
            LKDashboardCardView *view = self.cardViews[group.uniqueKey];
            if (view && !view.hidden) {
                $(view).width(contentWidth).y(y).heightToFit;
                y = view.$maxY + verMargin;
            }
        }];
    
        $(self.cardContainerView).height(y);
        $(self.documentView).fullWidth.y(0).toMaxY(self.cardContainerView.$maxY);
    }
    
    if (!self.searchContainerView.hidden) {
        $(self.searchContainerView).width(contentWidth).x(DashboardHorInset).y(self.searchInputView.$maxY + verMargin);
    
        __block CGFloat y = 0;
        [self.searchPropViews enumerateObjectsUsingBlock:^(LKDashboardSearchPropView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!view.hidden) {
                $(view).width(contentWidth).x(0).heightToFit.y(y);
                y = view.$maxY + verMargin;
            }
        }];
        
        if (self.searchMethodsView.isVisible) {
            $(self.searchMethodsView).width(contentWidth).y(y).heightToFit;
            y = self.searchMethodsView.$maxY;
        }
        
        $(self.searchContainerView).height(y);
        $(self.documentView).fullWidth.y(0).toMaxY(self.searchContainerView.$maxY);
    }
}

- (void)reloadWithGroupList:(NSArray<LookinAttributesGroup *> *)list {
    self.groupList = list;
    
    if (list.count > 0) {
        self.scrollView.hidden = NO;
    } else {
        self.scrollView.hidden = YES;
        return;
    }
    
    NSMutableArray<LKDashboardCardView *> *needlessViews = [self.cardViews allValues].mutableCopy;
    
    [list enumerateObjectsUsingBlock:^(LookinAttributesGroup * _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop) {
        LKDashboardCardView *cardView = self.cardViews[group.uniqueKey];
        if (cardView) {
            [needlessViews removeObject:cardView];
        } else {
            cardView = [LKDashboardCardView new];
            cardView.dashboardViewController = self;
            cardView.delegate = self;
            self.cardViews[group.uniqueKey] = cardView;
            [self.cardContainerView addSubview:cardView];
        }
        cardView.hidden = NO;
        cardView.attrGroup = group;
        cardView.isCollapsed = [[LKPreferenceManager mainManager].collapsedAttrGroups containsObject:group.identifier];
        [cardView render];
    }];
    
    [needlessViews enumerateObjectsUsingBlock:^(LKDashboardCardView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    
    [self.view setNeedsLayout:YES];
}

- (RACSignal *)modifyAttribute:(LookinAttribute *)attribute newValue:(id)newValue {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self);
        LookinDisplayItem *modifyingItem = attribute.targetDisplayItem;
        
        LookinAttributeModification *modification = [LookinAttributeModification new];
        if ([LookinDashboardBlueprint isUIViewPropertyWithAttrID:attribute.identifier]) {
            modification.targetOid = modifyingItem.viewObject.oid;
        } else {
            modification.targetOid = modifyingItem.layerObject.oid;
        }
        modification.setterSelector = [LookinDashboardBlueprint setterWithAttrID:attribute.identifier];
        modification.attrType = attribute.attrType;
        modification.value = newValue;
        
        if (!modification.setterSelector) {
            NSAssert(NO, @"");
            AlertError(LookinErr_Inner, self.view.window);
            [subscriber sendError:LookinErr_Inner];
        }
        
        if (![LKAppsManager sharedInstance].inspectingApp) {
            AlertError(LookinErr_NoConnect, self.view.window);
            [subscriber sendError:LookinErr_NoConnect];
        }
        
        @weakify(self);
        [[[LKAppsManager sharedInstance].inspectingApp submitModification:modification] subscribeNext:^(LookinDisplayItemDetail *detail) {
            NSLog(@"modification - succ");
            @strongify(self);
            if (self.staticDataSource) {
                [self.staticDataSource modifyWithDisplayItemDetail:detail];
                if ([LookinDashboardBlueprint needPatchAfterModificationWithAttrID:attribute.identifier]) {
                    [[LKStaticAsyncUpdateManager sharedInstance] updateAfterModifyingDisplayItem:(LookinStaticDisplayItem *)modifyingItem];
                }

            } else {
                NSAssert(NO, @"");
            }
            [subscriber sendNext:nil];
            
        } error:^(NSError * _Nullable error) {
            @strongify(self);
            AlertError(error, self.view.window);
            [subscriber sendError:error];
        }];
        
        return nil;
    }];
}

- (LKHierarchyDataSource *)currentDataSource {
    if (self.staticDataSource) {
        return self.staticDataSource;
    }
    if (self.readDataSource) {
        return self.readDataSource;
    }
    NSAssert(NO, @"");
    return nil;
}

#pragma mark - <LKDashboardCardViewDelegate>

- (void)dashboardCardViewNeedToggleCollapse:(LKDashboardCardView *)view {
    LKPreferenceManager *manager = self.currentDataSource.preferenceManager;
    if ([manager.collapsedAttrGroups containsObject:view.attrGroup.identifier]) {
        view.isCollapsed = NO;
        manager.collapsedAttrGroups = [manager.collapsedAttrGroups lookin_arrayByRemovingObject:view.attrGroup.identifier];
    } else {
        view.isCollapsed = YES;
        manager.collapsedAttrGroups = [manager.collapsedAttrGroups arrayByAddingObject:view.attrGroup.identifier];;
    }
    [self.view setNeedsLayout:YES];
}

#pragma mark - <LKDashboardSearchInputViewDelegate>

- (void)dashboardSearchInputView:(LKDashboardSearchInputView *)view didInputString:(NSString *)searchString {
    if (searchString.length < 3) {
        self.searchContainerView.hidden = YES;
        return;
    }
    
    searchString = searchString.lowercaseString;
    
    // 以下是在渲染 attrs
    
    NSMutableArray<LookinAttribute *> *resultAttrs = [NSMutableArray array];
    [[self.currentDataSource.selectedItem queryAllAttrGroupList]  enumerateObjectsUsingBlock:^(LookinAttributesGroup * _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop) {
        [group.attrSections enumerateObjectsUsingBlock:^(LookinAttributesSection * _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
            [section.attributes enumerateObjectsUsingBlock:^(LookinAttribute * _Nonnull attr, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *title;
                if (attr.isUserCustom) {
                    title = attr.displayTitle;
                } else {
                    title = [LookinDashboardBlueprint fullTitleWithAttrID:attr.identifier];
                }
                if ([title.lowercaseString containsString:searchString]) {
                    [resultAttrs addObject:attr];
                }
            }];
        }];
    }];
    
    [self.searchPropViews lookin_dequeueWithCount:resultAttrs.count add:^LKDashboardSearchPropView *(NSUInteger idx) {
        LKDashboardSearchPropView *view = [LKDashboardSearchPropView new];
        view.delegate = self;
        [self.searchContainerView addSubview:view];
        return view;
        
    } notDequeued:^(NSUInteger idx, LKDashboardSearchPropView *view) {
        view.hidden = YES;
        
    } doNext:^(NSUInteger idx, LKDashboardSearchPropView *view) {
        LookinAttribute *attribute = resultAttrs[idx];
        [view renderWithAttribute:attribute];
        view.hidden = NO;
    }];
    
    // 以下是在渲染 methods
    
    if (self.currentDataSource != self.staticDataSource) {
        self.searchContainerView.hidden = NO;
        self.searchMethodsView.hidden = YES;
        [self.view setNeedsLayout:YES];
        return;
    }
    
    if (!self.searchMethodsView) {
        self.searchMethodsView = [LKDashboardSearchMethodsView new];
        self.searchMethodsView.delegate = self;
        [self.searchContainerView addSubview:self.searchMethodsView];
    }
    
    LookinObject *selectedObj = self.currentDataSource.selectedItem.viewObject ? : self.currentDataSource.selectedItem.layerObject;
    NSString *selectedClassName = [selectedObj completedSelfClassName];
    @weakify(self);
    [[self.methodsDataSource fetchNonArgMethodsListWithClass:selectedClassName] subscribeNext:^(NSArray<NSString *> *methodsList) {
        @strongify(self);
        if (![searchString isEqualToString:[self.searchInputView currentInputString]]) {
            return;
        }
        NSArray<NSString *> *searchedMethods = [LKHelper bestMatchesInCandidates:methodsList input:searchString maxResultsCount:5];
        [self.searchMethodsView renderWithMethods:searchedMethods oid:selectedObj.oid];
        self.searchContainerView.hidden = NO;
        [self.view setNeedsLayout:YES];
        
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        if (![searchString isEqualToString:[self.searchInputView currentInputString]]) {
            return;
        }
        [self.searchMethodsView renderWithError:error];
        self.searchContainerView.hidden = NO;
        [self.view setNeedsLayout:YES];
    }];
}

- (void)dashboardSearchInputView:(LKDashboardSearchInputView *)view didToggleActive:(BOOL)isActive {
    if (isActive) {
        self.cardContainerView.animator.hidden = YES;
        self.currentDataSource.shouldAvoidChangingPreviewSelectionDueToDashboardSearch = YES;
    
    } else {
        self.cardContainerView.animator.hidden = NO;
        self.searchContainerView.animator.hidden = YES;
        [self.view setNeedsLayout:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 这个 0.25 的延时是关键，想象这个场景：用户想要结束搜索于是点击了空白图像处，此时程序会先走到这里的 resignActive 逻辑，然后再走到 preview 那边的取消图层选中逻辑（这两者时差大概在 0.1s 左右），但此时用户应该是并不想取消图层选中的，所以这里要用一个 flag 保护一下这种情况
            if (!view.isActive) {
                self.currentDataSource.shouldAvoidChangingPreviewSelectionDueToDashboardSearch = NO;
            }
        });
    }
}

#pragma mark - <LKDashboardSearchMethodsViewDelegate>

- (void)dashboardSearchMethodsView:(LKDashboardSearchMethodsView *)view requestToInvokeMethod:(NSString *)method oid:(unsigned long)oid {
    RACSignal *signal;
    if (oid == 0 || method.length == 0) {
        signal = [RACSignal error:LookinErr_Inner];
    } else if (![LKAppsManager sharedInstance].inspectingApp) {
        signal = [RACSignal error:LookinErr_NoConnect];
    } else {
        signal = [[LKAppsManager sharedInstance].inspectingApp invokeMethodWithOid:oid text:method];
    }
    
    [signal subscribeNext:^(NSDictionary *value) {
        NSAlert *alert = [NSAlert new];
        alert.messageText = method;
        alert.informativeText = value[@"description"];
        alert.alertStyle = NSAlertStyleInformational;
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {

        }];
        
    } error:^(NSError * _Nullable error) {
        AlertError(error, self.view.window);
    }];
    
}

#pragma mark - <LKDashboardSearchPropViewDelegate>

- (void)dashboardSearchPropView:(LKDashboardSearchPropView *)view didClickRevealAttribute:(LookinAttribute *)clickedAttr {
    self.searchInputView.isActive = NO;
    
    __block LookinAttributesGroup *targetGroup = nil;
    __block LookinAttributesSection *targetSection = nil;
    
    [[self.currentDataSource.selectedItem queryAllAttrGroupList] enumerateObjectsUsingBlock:^(LookinAttributesGroup * _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop0) {
        [group.attrSections enumerateObjectsUsingBlock:^(LookinAttributesSection * _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop1) {
            [section.attributes enumerateObjectsUsingBlock:^(LookinAttribute * _Nonnull attr, NSUInteger idx, BOOL * _Nonnull stop2) {
                if (attr == clickedAttr) {
                    *stop0 = YES;
                    *stop1 = YES;
                    *stop2 = YES;
                    
                    BOOL isAlreadyAdded = [[LKPreferenceManager mainManager] isSectionShowing:section.identifier];
                    if (!isAlreadyAdded) {
                        // 把这个属性添加到主面板上
                        [[LKPreferenceManager mainManager] showSection:section.identifier];
                    }
                    
                    targetGroup = group;
                    targetSection = section;
                }
            }];
        }];
    }];
    
    if (!targetGroup || !targetSection) {
        NSAssert(NO, @"");
        return;
    }
    LKDashboardCardView *targetCardView = self.cardViews[targetGroup.uniqueKey];
    if (!targetCardView) {
        NSAssert(NO, @"");
        return;
    }
    if (targetCardView.isCollapsed) {
        // 如果在折叠状态则展开
        [self dashboardCardViewNeedToggleCollapse:targetCardView];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LKDashboardSectionView *targetSecView = [targetCardView querySectionViewWithSection:targetSection];
        [self.scrollView.contentView.animator scrollRectToVisible:[self.scrollView.contentView convertRect:targetSecView.frame fromView:targetSecView.superview]];
        
        [self.cardViews.allValues enumerateObjectsUsingBlock:^(LKDashboardCardView * _Nonnull cardView, NSUInteger idx, BOOL * _Nonnull stop) {
            if (cardView.hidden) {
                return;
            }
            if (cardView == targetCardView) {
                [cardView playFadeAnimationWithHighlightRect:[cardView convertRect:targetSecView.frame fromView:targetSecView.superview]];
            } else {
                [cardView playFadeAnimationWithHighlightRect:CGRectZero];
            }
        }];
    });
}

@end
