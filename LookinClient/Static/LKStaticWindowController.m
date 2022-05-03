//
//  LKStaticWindowController.m
//  Lookin
//
//  Created by Li Kai on 2018/11/4.
//  https://lookin.work
//

#import "LKStaticWindowController.h"
#import "LKStaticViewController.h"
#import "LKMenuPopoverSettingController.h"
#import "LKStaticHierarchyDataSource.h"
#import "LKNavigationManager.h"
#import "LKPreferenceManager.h"
#import "LKAppsManager.h"
#import "LKMenuPopoverAppsListController.h"
#import "LKProgressIndicatorView.h"
#import "LookinDisplayItem.h"
#import "LookinObject.h"
#import "LKWindowToolbarHelper.h"
#import "LKExportManager.h"
#import "LookinHierarchyInfo.h"
#import "LKExportAccessoryView.h"
#import "LKWindow.h"
#import "LKStaticAsyncUpdateManager.h"
#import "LKTutorialManager.h"
#import "LookinHierarchyFile.h"
#import "LookinPreviewView.h"
#import "LKHierarchyView.h"
#import "LKPerformanceReporter.h"
@import AppCenter;
@import AppCenterAnalytics;

@interface LKStaticWindowController () <NSToolbarDelegate>

@property(nonatomic, strong) NSMutableDictionary<NSString *, NSToolbarItem *> *toolbarItemsMap;

/// 当拉取 hierarchy 和更新截图时，该属性为 YES
@property(nonatomic, assign) BOOL isFetchingHierarchy;
@property(nonatomic, assign) BOOL isSyncingScreenshots;

@property(nonatomic, strong) RACSubject *removeDelayReloadCounting_Signal;

@end

@implementation LKStaticWindowController

- (instancetype)init {
    NSSize screenSize = [NSScreen mainScreen].frame.size;
    LKWindow *window = [[LKWindow alloc] initWithContentRect:NSMakeRect(0, 0, screenSize.width * .7, screenSize.height * .7) styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskResizable|NSWindowStyleMaskFullSizeContentView backing:NSBackingStoreBuffered defer:YES];
    window.tabbingMode = NSWindowTabbingModeDisallowed;
    window.titleVisibility = NSWindowTitleHidden;
    if (@available(macOS 11.0, *)) {
        window.toolbarStyle = NSWindowToolbarStyleUnified;
    }
    window.minSize = NSMakeSize(HierarchyMinWidth + DashboardViewWidth + 200, 500);
    [window center];
    [window setFrameUsingName:LKWindowSizeName_Static];
    
    if (self = [self initWithWindow:window]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleInspectingAppDidEnd:) name:LKInspectingAppDidEndNotificationName object:nil];
        
        _viewController = [[LKStaticViewController alloc] init];
        window.contentView = self.viewController.view;
        self.contentViewController = self.viewController;
        
        NSToolbar *toolbar = [[NSToolbar alloc] init];
        toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
        toolbar.sizeMode = NSToolbarSizeModeRegular;
        toolbar.delegate = self;
        window.toolbar = toolbar;
        
        NSToolbarItem *reloadItem = self.toolbarItemsMap[LKToolBarIdentifier_Reload];
        NSButton *reloadButton = (NSButton *)reloadItem.view;
        @weakify(self);
        LKStaticAsyncUpdateManager *updateManager = [LKStaticAsyncUpdateManager sharedInstance];
        [updateManager.updateAll_ProgressSignal subscribeNext:^(RACTuple *  _Nullable x) {
            @strongify(self);
            NSNumber *received = (NSNumber *)x.first;
            NSNumber *total = (NSNumber *)x.second;
            reloadItem.label = [NSString stringWithFormat:@"%@ / %@", received, total];
            
            if (!self.isSyncingScreenshots) {
                self.isSyncingScreenshots = YES;
                
                NSImage *image = NSImageMake(@"icon_stop");
                image.template = YES;
                reloadButton.image = image;
            }
            
            [self _showUSBLowSpeedTipsIfNeeded];
        }];
        [updateManager.updateAll_CompletionSignal subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            self.isSyncingScreenshots = NO;
            reloadItem.label = NSLocalizedString(@"Reload", nil);
            
            NSImage *image = NSImageMake(@"icon_reload");
            image.template = YES;
            reloadButton.image = image;
        }];
        
        [[[RACSignal combineLatest:@[RACObserve(self, isFetchingHierarchy),
                                     RACObserve(self, isSyncingScreenshots)]] distinctUntilChanged] subscribeNext:^(RACTuple * _Nullable x) {
            @strongify(self);
            [@[LKToolBarIdentifier_App, LKToolBarIdentifier_Console] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSToolbarItem *item = self.toolbarItemsMap[obj];
                if (self.isFetchingHierarchy || self.isSyncingScreenshots) {
                    item.enabled = NO;
                } else {
                    item.enabled = YES;
                }
            }];
        }];
        [[RACObserve(self, isFetchingHierarchy) distinctUntilChanged] subscribeNext:^(NSNumber *x) {
            reloadItem.enabled = ![x boolValue];
        }];
        
        [RACObserve([LKStaticHierarchyDataSource sharedInstance], selectedItem) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            NSButton *measureButton = (NSButton *)self.toolbarItemsMap[LKToolBarIdentifier_Measure].view;
            BOOL canMeasure = !!x;
            measureButton.enabled = canMeasure;
        }];
        
        self.removeDelayReloadCounting_Signal = [RACSubject subject];
        [self.removeDelayReloadCounting_Signal subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self.viewController removeDelayReloadTip];
        }];
    }
    return self;
}

- (void)popupAllInspectableAppsWithSource:(MenuPopoverAppsListControllerEventSource)source {
    NSView *appItemView = [self.toolbarItemsMap objectForKey:LKToolBarIdentifier_App].view;
    
    @weakify(self);
    [[[[LKAppsManager sharedInstance] fetchAppInfosWithImage:YES localInfos:nil] deliverOnMainThread] subscribeNext:^(NSArray<LKInspectableApp *> *apps) {
        @strongify(self);
        LKMenuPopoverAppsListController *vc = [[LKMenuPopoverAppsListController alloc] initWithApps:apps source:source];
        NSPopover *popover = [[NSPopover alloc] init];
        @weakify(popover);
        vc.didSelectApp = ^(LKInspectableApp *app) {
            @strongify(popover);
            [popover close];
            
            if (app.serverVersionError) {
                if (app.serverVersionError.code == LookinErrCode_ServerIsPrivate ||
                    app.serverVersionError.code == LookinErrCode_ClientIsPrivate) {
                    // nothing;
                    
                } else if (app.serverVersionError.code == LookinErrCode_ServerVersionTooLow) {
                    [LKHelper openLookinWebsiteWithPath:@"faq/server-version-too-low/"];
                } else {
                    [LKHelper openLookinWebsiteWithPath:@"faq/server-version-too-high/"];
                }
                
            } else {
                [self.viewController.progressView animateToProgress:InitialIndicatorProgressWhenFetchHierarchy];
                
                BOOL isTheSameApp = [[LKAppsManager sharedInstance].inspectingApp.appInfo isEqualToAppInfo:app.appInfo];
                
                [[app fetchHierarchyData] subscribeNext:^(LookinHierarchyInfo *info) {
                    [self.viewController.progressView finishWithCompletion:nil];
                    [LKAppsManager sharedInstance].inspectingApp = app;
                    [[LKStaticHierarchyDataSource sharedInstance] reloadWithHierarchyInfo:info keepState:isTheSameApp];
                    
                } error:^(NSError * _Nullable error) {
                    AlertError(error, self.window);
                    [self.viewController.progressView resetToZero];
                }];
            }
        };
        
        popover.behavior = NSPopoverBehaviorTransient;
        popover.animates = NO;
        popover.contentSize = vc.bestSize;
        popover.contentViewController = vc;
        [popover showRelativeToRect:NSMakeRect(0, 0, appItemView.bounds.size.width, appItemView.bounds.size.height) ofView:appItemView preferredEdge:NSRectEdgeMaxY];
        
    } error:^(NSError * _Nullable error) {
        NSAssert(NO, @"该方法不应该 sendError");
    }];
}

#pragma mark - NSToolbarDelegate

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return [self toolbarDefaultItemIdentifiers:toolbar];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return @[LKToolBarIdentifier_Reload, LKToolBarIdentifier_App, NSToolbarFlexibleSpaceItemIdentifier, LKToolBarIdentifier_Dimension, LKToolBarIdentifier_Rotation, LKToolBarIdentifier_Setting, NSToolbarFlexibleSpaceItemIdentifier, LKToolBarIdentifier_Scale, NSToolbarFlexibleSpaceItemIdentifier, LKToolBarIdentifier_Measure, LKToolBarIdentifier_Console];
}

- (nullable NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    NSToolbarItem *item = self.toolbarItemsMap[itemIdentifier];
    if (!item) {
        if (!self.toolbarItemsMap) {
            self.toolbarItemsMap = [NSMutableDictionary dictionary];
        }
        item = [[LKWindowToolbarHelper sharedInstance] makeToolBarItemWithIdentifier:itemIdentifier preferenceManager:[LKPreferenceManager mainManager]];
        self.toolbarItemsMap[itemIdentifier] = item;
        
        if ([item.itemIdentifier isEqualToString:LKToolBarIdentifier_Reload]) {
            item.target = self;
            item.action = @selector(_handleReload);
        } else if ([item.itemIdentifier isEqualToString:LKToolBarIdentifier_App]) {
            item.target = self;
            item.action = @selector(_handleApp);
        } else if ([item.itemIdentifier isEqualToString:LKToolBarIdentifier_Rotation]) {
            item.target = self;
            item.action = @selector(_handleFreeRotation);
        } else if ([item.itemIdentifier isEqualToString:LKToolBarIdentifier_Setting]) {
            item.label = NSLocalizedString(@"View", nil);
            item.target = self;
            item.action = @selector(_handleSetting:);
        } else if ([item.itemIdentifier isEqualToString:LKToolBarIdentifier_Console]) {
            item.target = self;
            item.action = @selector(_handleConsole);
            
            [[[RACObserve(self.viewController, showConsole) distinctUntilChanged] skip:1] subscribeNext:^(NSNumber *x) {
                ((NSButton *)item.view).state = x.boolValue ? NSControlStateValueOn : NSControlStateValueOff;
            }];
            
        }
    }
    return item;
}

#pragma mark - Event Handler

- (void)_handleInspectingAppDidEnd:(id)obj {
    self.isFetchingHierarchy = NO;
    self.isSyncingScreenshots = NO;
}

- (void)_handleReload {
    // 停止可能存在的刷新倒计时
    [self.removeDelayReloadCounting_Signal sendNext:nil];
    
    if (self.isSyncingScreenshots) {
        // 停止拉取
        [[LKStaticAsyncUpdateManager sharedInstance] endUpdatingAll];
        return;
    }
    
    LKInspectableApp *app = [LKAppsManager sharedInstance].inspectingApp;
    if (!app) {
        [self popupAllInspectableAppsWithSource:MenuPopoverAppsListControllerEventSourceReloadButton];
        return;
    }
    
    if (self.isFetchingHierarchy || self.isSyncingScreenshots) {
        return;
    }
    
    self.isFetchingHierarchy = YES;
    
    [self.viewController.progressView animateToProgress:InitialIndicatorProgressWhenFetchHierarchy];
    
    [LKPerformanceReporter.sharedInstance willStartReload];
    @weakify(self);
    [[app fetchHierarchyData] subscribeNext:^(LookinHierarchyInfo *info) {
        [self.viewController.progressView finishWithCompletion:nil];
        [[LKStaticHierarchyDataSource sharedInstance] reloadWithHierarchyInfo:info keepState:YES];
        self.isFetchingHierarchy = NO;
        
        [LKPerformanceReporter.sharedInstance didFetchHierarchy];
        
    } error:^(NSError * _Nullable error) {
        // error
        @strongify(self);
        [self.viewController.progressView resetToZero];
        self.isFetchingHierarchy = NO;
        
        [[NSAlert alertWithError:error] beginSheetModalForWindow:self.window completionHandler:nil];
    }];
}

- (void)_handleApp {
    // 停止可能存在的刷新倒计时
    [self.removeDelayReloadCounting_Signal sendNext:nil];
    
    [self popupAllInspectableAppsWithSource:MenuPopoverAppsListControllerEventSourceAppButton];
}

- (void)_handleSetting:(NSButton *)button {
    NSPopover *popover = [[NSPopover alloc] init];
    popover.behavior = NSPopoverBehaviorTransient;
    popover.animates = NO;
    popover.contentSize = NSMakeSize(IsEnglish ? 270 : 350, 200);
    popover.contentViewController = [[LKMenuPopoverSettingController alloc] initWithPreferenceManager:[LKPreferenceManager mainManager]];
    [popover showRelativeToRect:NSMakeRect(0, 0, button.bounds.size.width, button.bounds.size.height) ofView:button preferredEdge:NSRectEdgeMaxY];
}

- (void)_handleConsole {
    self.viewController.showConsole = !self.viewController.showConsole;
}

- (void)_handleFreeRotation {
    BOOL boolValue = [LKPreferenceManager mainManager].freeRotation.currentBOOLValue;
    [[LKPreferenceManager mainManager].freeRotation setBOOLValue:!boolValue ignoreSubscriber:nil];
}

#pragma mark - Others

- (void)_showUSBLowSpeedTipsIfNeeded {
    if (TutorialMng.hasAlreadyShowedTipsThisLaunch || TutorialMng.USBLowSpeed) {
        return;
    }
    if (!InspectingApp || InspectingApp.appInfo.deviceType == LookinAppInfoDeviceSimulator || [LKStaticHierarchyDataSource sharedInstance].flatItems.count < 170) {
        return;
    }
    
    TutorialMng.hasAlreadyShowedTipsThisLaunch = YES;
    [[LKTutorialManager sharedInstance] showPopoverOfView:self.toolbarItemsMap[LKToolBarIdentifier_Reload].view text:NSLocalizedString(@"Inspecting via USB is slower than inspecting a Xcode simulator.", nil) learned:^{
        [LKTutorialManager sharedInstance].USBLowSpeed = YES;
    }];
}

#pragma mark - <LKAppMenuManagerDelegate>

- (void)appMenuManagerDidSelectReload {    
    if (self.isFetchingHierarchy) {
        return;
    }
    if (self.isSyncingScreenshots) {
        NSError *error = LookinErrorMake(NSLocalizedString(@"Cannot reload at this time", NIL), NSLocalizedString(@"Please wait until current sync is completed. You can get sync progress in the upper-left corner of this window.", nil));
        [[NSAlert alertWithError:error] beginSheetModalForWindow:self.window completionHandler:nil];
        return;
    }
    [self _handleReload];
}

- (void)appMenuManagerDidSelectDimension {
    LKPreferenceManager *manager = [LKPreferenceManager mainManager];
    if (manager.previewDimension.currentIntegerValue == LookinPreviewDimension2D) {
        [manager.previewDimension setIntegerValue:LookinPreviewDimension3D ignoreSubscriber:nil];
    } else {
        [manager.previewDimension setIntegerValue:LookinPreviewDimension2D ignoreSubscriber:nil];
    }
}

- (void)appMenuManagerDidSelectZoomIn {
    LKPreferenceManager *manager = [LKPreferenceManager mainManager];
    double currentScale = manager.previewScale.currentDoubleValue;
    double targetScale = MIN(MAX(currentScale + 0.1, LookinPreviewMinScale), LookinPreviewMaxScale);
    [manager.previewScale setDoubleValue:targetScale ignoreSubscriber:nil];
}

- (void)appMenuManagerDidSelectZoomOut {
    LKPreferenceManager *manager = [LKPreferenceManager mainManager];
    double currentScale = manager.previewScale.currentDoubleValue;
    double targetScale = MIN(MAX(currentScale - 0.1, LookinPreviewMinScale), LookinPreviewMaxScale);
    [manager.previewScale setDoubleValue:targetScale ignoreSubscriber:nil];
}

- (void)appMenuManagerDidSelectDecreaseInterspace {
    LKPreferenceManager *manager = [LKPreferenceManager mainManager];
    double currentValue = manager.zInterspace.currentDoubleValue;
    double newValue = currentValue - 0.1;
    newValue = MIN(MAX(newValue, LookinPreviewMinZInterspace), LookinPreviewMaxZInterspace);
    [manager.zInterspace setDoubleValue:newValue ignoreSubscriber:nil];
}

- (void)appMenuManagerDidSelectIncreaseInterspace {
    LKPreferenceManager *manager = [LKPreferenceManager mainManager];
    double currentValue = manager.zInterspace.currentDoubleValue;
    double newValue = currentValue + 0.1;
    newValue = MIN(MAX(newValue, LookinPreviewMinZInterspace), LookinPreviewMaxZInterspace);
    [manager.zInterspace setDoubleValue:newValue ignoreSubscriber:nil];
}

- (void)appMenuManagerDidSelectExpansionIndex:(NSUInteger)index {    
    [[LKStaticHierarchyDataSource sharedInstance] adjustExpansionByIndex:index referenceDict:nil selectedItem:nil];

    if (!TutorialMng.hasAlreadyShowedTipsThisLaunch && !TutorialMng.quickSelection && index <= 1) {
        [self.viewController showQuickSelectionTutorialTips];
    }
}

- (void)appMenuManagerDidSelectExport {
    LKExportManager *exportManager = [LKExportManager sharedInstance];
    LookinHierarchyInfo *hierarchyInfo = [LKStaticHierarchyDataSource sharedInstance].rawHierarchyInfo;
    
    __block NSString *fileName;
    __block NSData *exportedData = nil;
    
    LKExportAccessoryView *accessoryView = [LKExportAccessoryView new];
    $(accessoryView).sizeToFit;
    [RACObserve([LKPreferenceManager mainManager], preferredExportCompression) subscribeNext:^(NSNumber *num) {
        CGFloat compression = num.doubleValue;
        exportedData = [exportManager dataFromHierarchyInfo:hierarchyInfo imageCompression:compression fileName:&fileName];
        accessoryView.dataSize = exportedData.length;
    }];
    
    NSSavePanel *panel = [NSSavePanel savePanel];
    panel.accessoryView = accessoryView;
    [panel setNameFieldStringValue:fileName];
    [panel setAllowsOtherFileTypes:NO];
    [panel setAllowedFileTypes:@[@"lookin"]];
    [panel setExtensionHidden:YES];
    [panel setCanCreateDirectories:YES];
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSString *path = [[panel URL] path];
            NSError *writeError;
            if (!exportedData) {
                NSAssert(NO, @"LookinClient - write fail, no data");
                return;
            }
            BOOL writeSucc = [exportedData writeToFile:path options:0 error:&writeError];
            if (!writeSucc) {
                NSLog(@"LookinClient - write fail:%@", writeError);
            }
        }
    }];
    
    [MSACAnalytics trackEvent:@"Export Document"];
}

- (void)appMenuManagerDidSelectOpenInNewWindow {
    LookinHierarchyInfo *newHierarchyInfo = [LKStaticHierarchyDataSource sharedInstance].rawHierarchyInfo.copy;
    LookinHierarchyFile *file = [LookinHierarchyFile new];
    file.serverVersion = newHierarchyInfo.serverVersion;
    file.hierarchyInfo = newHierarchyInfo;
    [[LKNavigationManager sharedInstance] showReaderWithHierarchyFile:file title:nil];
    
    [MSACAnalytics trackEvent:@"Open New Window"];

}

- (void)appMenuManagerDidSelectFilter {
    [[self.viewController currentHierarchyView] activateSearchBar];
}

- (void)appMenuManagerDidSelectDelayReload {
    [self.removeDelayReloadCounting_Signal sendNext:nil];

    __block NSUInteger seconds = 5;
    [self.viewController showDelayReloadTipWithSeconds:seconds];
    @weakify(self);
    [[[[RACSignal interval:1 onScheduler:[RACScheduler scheduler]] takeUntil:self.removeDelayReloadCounting_Signal] deliverOnMainThread] subscribeNext:^(NSDate * _Nullable x) {
        @strongify(self);
        seconds--;
        if (seconds <= 0) {
            [self.removeDelayReloadCounting_Signal sendNext:nil];
            [self appMenuManagerDidSelectReload];
        } else {
            [self.viewController showDelayReloadTipWithSeconds:seconds];
        }
    }];
    
    [MSACAnalytics trackEvent:@"Delay Reload"];
}

- (void)appMenuManagerDidSelectMethodTrace {
    [[LKNavigationManager sharedInstance] showMethodTrace];
}

@end
