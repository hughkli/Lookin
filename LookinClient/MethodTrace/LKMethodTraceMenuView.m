//
//  LKMethodTraceMenuView.m
//  Lookin
//
//  Created by Li Kai on 2019/5/24.
//  https://lookin.work
//

#import "LKMethodTraceMenuView.h"
#import "LKMethodTraceMenuItemView.h"
#import "LKMethodTraceDataSource.h"
#import "LKNavigationManager.h"

@interface LKMethodTraceMenuView () <LKMethodTraceMenuItemViewDelegate>

@property(nonatomic, strong) LKVisualEffectView *backgroundEffectView;
@property(nonatomic, copy) NSArray<LKMethodTraceMenuItemView *> *itemViews;

@property(nonatomic, strong) LKMethodTraceDataSource *dataSource;

@end

@implementation LKMethodTraceMenuView

- (instancetype)initWithDataSource:(LKMethodTraceDataSource *)dataSource {
    if (self = [self initWithFrame:NSZeroRect]) {
        self.dataSource = dataSource;
        
        self.backgroundEffectView = [LKVisualEffectView new];
        self.backgroundEffectView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
        self.backgroundEffectView.state = NSVisualEffectStateActive;
        [self addSubview:self.backgroundEffectView];
        
        self.itemViews = [NSArray array];
        
        @weakify(self);
        [RACObserve(dataSource, menuData) subscribeNext:^(NSArray<NSDictionary<NSString *, id> *> *x) {
            @strongify(self);
            [self _renderWithData:x];
        }];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.backgroundEffectView).fullFrame;
    
    CGFloat itemHeight = 26;
    __block CGFloat y = [LKNavigationManager sharedInstance].windowTitleBarHeight + 8;
    [self.itemViews enumerateObjectsUsingBlock:^(LKMethodTraceMenuItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > 0 && obj.representedAsClass) {
            y += 5;
        }
        $(obj).fullWidth.height(itemHeight).y(y);
        y = obj.$maxY;
    }];
}

- (void)_renderWithData:(NSArray<NSDictionary<NSString *, id> *> *)data {
    [self.itemViews enumerateObjectsUsingBlock:^(LKMethodTraceMenuItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    
    NSMutableArray<LKMethodTraceMenuItemView *> *newViews = self.itemViews.mutableCopy;
    
    __block NSUInteger enumeratedIdx = 0;
    [data enumerateObjectsUsingBlock:^(NSDictionary<NSString *, id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *className = obj[@"class"];
        NSArray<NSString *> *sels = obj[@"sels"];
        
        LKMethodTraceMenuItemView *view = [newViews lookin_safeObjectAtIndex:enumeratedIdx];
        if (!view) {
            view = [LKMethodTraceMenuItemView new];
            view.delegate = self;
            [newViews addObject:view];
            [self addSubview:view];
        }
        view.hidden = NO;
        view.representedAsClass = YES;
        view.representedClassName = className;
        view.representedSelName = nil;
        
        enumeratedIdx++;
        
        [sels enumerateObjectsUsingBlock:^(NSString * _Nonnull selName, NSUInteger idx, BOOL * _Nonnull stop) {
            LKMethodTraceMenuItemView *view = [newViews lookin_safeObjectAtIndex:enumeratedIdx];
            if (!view) {
                view = [LKMethodTraceMenuItemView new];
                view.delegate = self;
                [newViews addObject:view];
                [self addSubview:view];
            }
            view.hidden = NO;
            view.representedAsClass = NO;
            view.representedClassName = className;
            view.representedSelName = selName;
            
            enumeratedIdx++;
        }];
    }];
    self.itemViews = newViews;
    [self setNeedsLayout:YES];
}

#pragma mark - <LKMethodTraceMenuItemViewDelegate>

- (void)methodTraceMenuItemViewDidClickDelete:(LKMethodTraceMenuItemView *)view {
    [self.dataSource deleteWithClassName:view.representedClassName selName:view.representedSelName];
}

@end
