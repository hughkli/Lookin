//
//  LKReadWindowController.m
//  Lookin
//
//  Created by Li Kai on 2019/5/12.
//  https://lookin.work
//

#import "LKReadWindowController.h"
#import "LKReadViewController.h"
#import "LKWindowToolbarHelper.h"
#import "LookinHierarchyFile.h"
#import "LKPreferenceManager.h"
#import "LKReadHierarchyDataSource.h"
#import "LookinHierarchyInfo.h"
#import "LKWindow.h"
#import "LKMenuPopoverSettingController.h"
#import "LKTutorialManager.h"
#import "LookinPreviewView.h"
#import "LKHierarchyView.h"

@interface LKReadWindowController () <NSToolbarDelegate>

@property(nonatomic, strong) LKReadViewController *viewController;

@property(nonatomic, strong) NSMutableDictionary<NSString *, NSToolbarItem *> *toolbarItemsMap;

@property(nonatomic, strong) LKPreferenceManager *preferenceManager;

@end

@implementation LKReadWindowController

- (instancetype)initWithFile:(LookinHierarchyFile *)file {
    NSSize screenSize = [NSScreen mainScreen].frame.size;
    LKWindow *window = [[LKWindow alloc] initWithContentRect:NSMakeRect(0, 0, screenSize.width * .7, screenSize.height * .7) styleMask:NSWindowStyleMaskFullSizeContentView|NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskResizable|NSWindowStyleMaskUnifiedTitleAndToolbar backing:NSBackingStoreBuffered defer:YES];
    window.backgroundColor = [NSColor clearColor];
    window.tabbingMode = NSWindowTabbingModeDisallowed;
    window.minSize = NSMakeSize(800, 500);
    [window center];
    
    if (self = [self initWithWindow:window]) {
        self.preferenceManager = [LKPreferenceManager new];
        _viewController = [[LKReadViewController alloc] initWithFile:file preferenceManager:self.preferenceManager];
        window.contentView = self.viewController.view;
        self.contentViewController = self.viewController;
        
        @weakify(self);
        [RACObserve(self.viewController.hierarchyDataSource, selectedItem) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            NSButton *measureButton = (NSButton *)self.toolbarItemsMap[LKToolBarIdentifier_Measure].view;
            BOOL canMeasure = !!x;
            measureButton.enabled = canMeasure;
        }];
        
        NSToolbar *toolbar = [[NSToolbar alloc] init];
        toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
        toolbar.sizeMode = NSToolbarSizeModeRegular;
        toolbar.delegate = self;
        window.toolbar = toolbar;
    }
    return self;
}

#pragma mark - NSToolbarDelegate

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return [self toolbarDefaultItemIdentifiers:toolbar];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return @[LKToolBarIdentifier_AppInReadMode, NSToolbarFlexibleSpaceItemIdentifier, LKToolBarIdentifier_Dimension, LKToolBarIdentifier_Rotation, LKToolBarIdentifier_Setting, NSToolbarFlexibleSpaceItemIdentifier, LKToolBarIdentifier_Scale, NSToolbarFlexibleSpaceItemIdentifier, LKToolBarIdentifier_Measure];
}

- (nullable NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    NSToolbarItem *item = self.toolbarItemsMap[itemIdentifier];
    if (!item) {
        if (!self.toolbarItemsMap) {
            self.toolbarItemsMap = [NSMutableDictionary dictionary];
        }
        if ([itemIdentifier isEqualToString:LKToolBarIdentifier_AppInReadMode]) {
            item = [[LKWindowToolbarHelper sharedInstance] makeAppInReadModeItemWithAppInfo:self.viewController.hierarchyDataSource.rawHierarchyInfo.appInfo];
        } else {
            item = [[LKWindowToolbarHelper sharedInstance] makeToolBarItemWithIdentifier:itemIdentifier preferenceManager:self.preferenceManager];
        }
        self.toolbarItemsMap[itemIdentifier] = item;
        
        if ([item.itemIdentifier isEqualToString:LKToolBarIdentifier_Setting]) {
            item.label = NSLocalizedString(@"View", nil);
            item.target = self;
            item.action = @selector(_handleSetting:);
        } else if ([item.itemIdentifier isEqualToString:LKToolBarIdentifier_Rotation]) {
            item.target = self;
            item.action = @selector(_handleFreeRotation);
        }
    }
    return item;
}
#pragma mark - Event Handler

- (void)_handleSetting:(NSButton *)button {
    NSPopover *popover = [[NSPopover alloc] init];
    popover.behavior = NSPopoverBehaviorTransient;
    popover.animates = NO;
    popover.contentSize = NSMakeSize(IsEnglish ? 270 : 350, 200);
    popover.contentViewController = [[LKMenuPopoverSettingController alloc] initWithPreferenceManager:self.preferenceManager];
    [popover showRelativeToRect:NSMakeRect(0, 0, button.bounds.size.width, button.bounds.size.height) ofView:button preferredEdge:NSRectEdgeMaxY];
}

- (void)_handleFreeRotation {
    LKPreferenceManager *manager = self.preferenceManager;
    BOOL boolValue = manager.freeRotation.currentBOOLValue;
    [manager.freeRotation setBOOLValue:!boolValue ignoreSubscriber:nil];
}

#pragma mark - <LKAppMenuManagerDelegate>

- (void)appMenuManagerDidSelectDimension {
    if (self.preferenceManager.previewDimension.currentIntegerValue == LookinPreviewDimension2D) {
        [self.preferenceManager.previewDimension setIntegerValue:LookinPreviewDimension3D ignoreSubscriber:nil];
    } else {
        [self.preferenceManager.previewDimension setIntegerValue:LookinPreviewDimension2D ignoreSubscriber:nil];
    }
}

- (void)appMenuManagerDidSelectZoomIn {
    LKPreferenceManager *manager = self.preferenceManager;
    double currentScale = manager.previewScale.currentDoubleValue;
    double targetScale = MIN(MAX(currentScale + 0.1, LookinPreviewMinScale), LookinPreviewMaxScale);
    [manager.previewScale setDoubleValue:targetScale ignoreSubscriber:nil];
}

- (void)appMenuManagerDidSelectZoomOut {
    LKPreferenceManager *manager = self.preferenceManager;
    double currentScale = manager.previewScale.currentDoubleValue;
    double targetScale = MIN(MAX(currentScale - 0.1, LookinPreviewMinScale), LookinPreviewMaxScale);
    [manager.previewScale setDoubleValue:targetScale ignoreSubscriber:nil];
}

- (void)appMenuManagerDidSelectDecreaseInterspace {
    LKPreferenceManager *manager = self.preferenceManager;
    double currentValue = manager.zInterspace.currentDoubleValue;
    double newValue = currentValue - 0.1;
    newValue = MIN(MAX(newValue, LookinPreviewMinZInterspace), LookinPreviewMaxZInterspace);
    [manager.zInterspace setDoubleValue:newValue ignoreSubscriber:nil];
}

- (void)appMenuManagerDidSelectIncreaseInterspace {
    LKPreferenceManager *manager = self.preferenceManager;
    double currentValue = manager.zInterspace.currentDoubleValue;
    double newValue = currentValue + 0.1;
    newValue = MIN(MAX(newValue, LookinPreviewMinZInterspace), LookinPreviewMaxZInterspace);
    [manager.zInterspace setDoubleValue:newValue ignoreSubscriber:nil];
}

- (void)appMenuManagerDidSelectExpansionIndex:(NSUInteger)index {
    [self.viewController.hierarchyDataSource adjustExpansionByIndex:index referenceDict:nil selectedItem:nil];
}

- (void)appMenuManagerDidSelectFilter {
    [[self.viewController currentHierarchyView] activateSearchBar];
}

@end
