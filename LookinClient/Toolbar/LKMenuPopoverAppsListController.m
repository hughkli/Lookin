//
//  LKMenuPopoverAppsListController.m
//  Lookin
//
//  Created by Li Kai on 2018/11/5.
//  https://lookin.work
//

#import "LKMenuPopoverAppsListController.h"
#import "LKAppsManager.h"
#import "LKLaunchAppView.h"
#import "LookinHierarchyInfo.h"
#import "LKStaticHierarchyDataSource.h"

@interface LKMenuPopoverAppsListController ()

@property(nonatomic, strong) NSArray<LKLaunchAppView *> *appViews;

@property(nonatomic, strong) LKLabel *titleLabel;
@property(nonatomic, strong) LKLabel *subtitleLabel;
@property(nonatomic, strong) LKTextControl *tutorialControl;

@end

@implementation LKMenuPopoverAppsListController {
    CGFloat _appViewInterSpace;
    NSEdgeInsets _insets;
    CGFloat _titleMarginBottom;
    CGFloat _subtitleMarginBottom;
}

- (instancetype)initWithApps:(NSArray<LKInspectableApp *> *)apps source:(MenuPopoverAppsListControllerEventSource)source {
    if (self = [self init]) {
        _insets = NSEdgeInsetsMake(9, 18, 35, 14);
        _titleMarginBottom = 3;
        _subtitleMarginBottom = 5;
        _appViewInterSpace = 1;
        
        NSString *title = nil;
        NSString *subtitle = nil;
        if (source == MenuPopoverAppsListControllerEventSourceReloadButton || source == MenuPopoverAppsListControllerEventSourceNoConnectionTips) {
            title = NSLocalizedString(@"Connection lost", nil);
            if (apps.count == 0) {
                subtitle = NSLocalizedString(@"And no inspectable app was found", nil);
            } else if (apps.count == 1) {
                subtitle = NSLocalizedString(@"Click the screenshot below to Change App", nil);
            } else {
                subtitle = [NSString stringWithFormat:NSLocalizedString(@"Other %@ apps were found", nil), @(apps.count)];
            }
            
        } else if (source == MenuPopoverAppsListControllerEventSourceAppButton) {
            if (apps.count) {
                if (apps.count == 1) {
                    title = NSLocalizedString(@"1 active app was found", nil);
                } else {
                    title = [NSString stringWithFormat:NSLocalizedString(@"%@ active apps were found", nil), @(apps.count)];
                }
                subtitle = NSLocalizedString(@"Click the screenshot below to inspect", nil);
            } else {
                title = NSLocalizedString(@"No inspectable app was found", nil);
            }
        } else {
            NSAssert(NO, @"");
        }
        
        if (apps.count) {
            self.appViews = [apps.rac_sequence map:^id _Nullable(LKInspectableApp *app) {
                LKLaunchAppView *view = [LKLaunchAppView new];
                view.compactLayout = YES;
                view.app = app;
                [view addTarget:self clickAction:@selector(handleClickAppView:)];
                [self.view addSubview:view];
                return view;
            }].array;
        }
        
        if (title.length) {
            self.titleLabel = [LKLabel new];
            self.titleLabel.alignment = NSTextAlignmentCenter;
            self.titleLabel.font = NSFontMake(14);
            self.titleLabel.textColor = [NSColor labelColor];
            self.titleLabel.stringValue = title;
            [self.view addSubview:self.titleLabel];
        }
    
        if (subtitle.length) {
            self.subtitleLabel = [LKLabel new];
            self.subtitleLabel.alignment = NSTextAlignmentCenter;
            self.subtitleLabel.font = NSFontMake(12);
            self.subtitleLabel.textColor = [NSColor labelColor];
            self.subtitleLabel.stringValue = subtitle;
            [self.view addSubview:self.subtitleLabel];
        }
        
        self.tutorialControl = [LKTextControl new];
        self.tutorialControl.layer.cornerRadius = 4;
        self.tutorialControl.label.stringValue = NSLocalizedString(@"Can't see your app ?", nil);
        self.tutorialControl.label.textColor = [NSColor linkColor];
        self.tutorialControl.label.font = NSFontMake(12);
        self.tutorialControl.adjustAlphaWhenClick = YES;
        [self.tutorialControl addTarget:self clickAction:@selector(_handleTutorial)];
        [self.view addSubview:self.tutorialControl];
    }
    return self;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    
    CGFloat y = _insets.top;
    if (self.titleLabel) {
        $(self.titleLabel).fullWidth.heightToFit.y(y);
        y = self.titleLabel.$maxY + _titleMarginBottom;
    }
    if (self.subtitleLabel) {
        $(self.subtitleLabel).fullWidth.heightToFit.y(y);
        y = self.subtitleLabel.$maxY + _subtitleMarginBottom;
    }
    
    if (self.appViews.count) {
        __block CGFloat posX = 0;
        [self.appViews enumerateObjectsUsingBlock:^(LKLaunchAppView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            $(obj).sizeToFit.x(posX).y(y);
            posX = obj.$maxX + self->_appViewInterSpace;
        }];
        $(self.appViews).groupHorAlign;
    
        $(self.tutorialControl).sizeToFit.horAlign.offsetX(3).bottom(10);
    } else {
        $(self.tutorialControl).sizeToFit.horAlign.offsetX(3);
        if (self.subtitleLabel.isVisible) {
            $(self.tutorialControl).y(y);
        } else {
            $(self.tutorialControl).y(y + 8);
        }
        $(self.titleLabel, self.subtitleLabel, self.tutorialControl).visibles.groupVerAlign;
    }
    
}

- (void)handleClickAppView:(LKLaunchAppView *)view {
    LKInspectableApp *app = view.app;
    if (self.didSelectApp) {
        self.didSelectApp(app);
    }
}

- (NSSize)bestSize {
    if (self.appViews.count <= 0) {
        return NSMakeSize(245, 80);
    }
    __block CGFloat width = _insets.left + _insets.right + (self.appViews.count - 1) * _appViewInterSpace;
    __block CGFloat appViewMaxHeight = 0;
    [self.appViews enumerateObjectsUsingBlock:^(LKLaunchAppView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        NSSize size = [view sizeThatFits:NSSizeMax];
        width += size.width;
        appViewMaxHeight = MAX(appViewMaxHeight, size.height);
    }];
    
    CGFloat height = _insets.top + _insets.bottom + appViewMaxHeight;
    if (self.titleLabel) {
        NSSize titleSize = [self.titleLabel sizeThatFits:NSSizeMax];
        height += titleSize.height + _titleMarginBottom;
        width = MAX(width, titleSize.width + _insets.left + _insets.right);
    }
    if (self.subtitleLabel) {
        NSSize subtitleSize = [self.subtitleLabel sizeThatFits:NSSizeMax];
        height += subtitleSize.height + _subtitleMarginBottom;
        width = MAX(width, subtitleSize.width + _insets.left + _insets.right);
    }
    
    return NSMakeSize(width, height);
}

- (void)_handleTutorial {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://lookin.work/faq/cannot-see/"]];
}

@end
