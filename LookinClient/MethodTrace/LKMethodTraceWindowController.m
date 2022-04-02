//
//  LKMethodTraceWindowController.m
//  Lookin
//
//  Created by Li Kai on 2019/5/23.
//  https://lookin.work
//

#import "LKMethodTraceWindowController.h"
#import "LKWindow.h"
#import "LKMethodTraceViewController.h"
#import "LKWindowToolbarHelper.h"
#import "LKPreferenceManager.h"

@interface LKMethodTraceWindowController () <NSToolbarDelegate>

@property(nonatomic, strong) NSMutableDictionary<NSString *, NSToolbarItem *> *toolbarItemsMap;

@end

@implementation LKMethodTraceWindowController

- (instancetype)init {
    NSSize screenSize = [NSScreen mainScreen].frame.size;
    LKWindow *window = [[LKWindow alloc] initWithContentRect:NSMakeRect(0, 0, MIN(screenSize.width * .5, 800), MIN(screenSize.height * .5, 500)) styleMask:NSWindowStyleMaskFullSizeContentView|NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskResizable|NSWindowStyleMaskUnifiedTitleAndToolbar backing:NSBackingStoreBuffered defer:YES];
    window.backgroundColor = [NSColor clearColor];
    window.tabbingMode = NSWindowTabbingModeDisallowed;
    window.minSize = NSMakeSize(600, 300);
    [window center];
    [window setFrameUsingName:LKWindowSizeName_Methods];
    
    if (self = [self initWithWindow:window]) {
        LKMethodTraceViewController *vc = [LKMethodTraceViewController new];
        window.contentView = vc.view;
        self.contentViewController = vc;
    
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
    return @[LKToolBarIdentifier_Add, NSToolbarFlexibleSpaceItemIdentifier, LKToolBarIdentifier_Setting, NSToolbarSpaceItemIdentifier, LKToolBarIdentifier_Remove];
}

- (nullable NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    NSToolbarItem *item = self.toolbarItemsMap[itemIdentifier];
    if (!item) {
        if (!self.toolbarItemsMap) {
            self.toolbarItemsMap = [NSMutableDictionary dictionary];
        }
        item = [[LKWindowToolbarHelper sharedInstance] makeToolBarItemWithIdentifier:itemIdentifier preferenceManager:[LKPreferenceManager mainManager]];
        self.toolbarItemsMap[itemIdentifier] = item;
        
        if ([item.itemIdentifier isEqualToString:LKToolBarIdentifier_Add]) {
            item.label = NSLocalizedString(@"Add Method", nil);
            item.target = self.contentViewController;
            item.action = @selector(handleToolBarAddButton);
        } else if ([item.itemIdentifier isEqualToString:LKToolBarIdentifier_Remove]) {
            item.label = NSLocalizedString(@"Clear Logs", nil);
            item.target = self.contentViewController;
            item.action = @selector(handleToolBarRemoveButton);
        } else if ([item.itemIdentifier isEqualToString:LKToolBarIdentifier_Setting]) {
            item.label = NSLocalizedString(@"Stack Settings", nil);
            item.target = self;
            item.action = @selector(_handleSetting:);
        }
    }
    return item;
}

- (void)_handleSetting:(NSButton *)button {
    LKPreferenceManager *manager = [LKPreferenceManager mainManager];

    NSArray<NSNumber *> *options = @[@(LookinPreferredCallStackTypeDefault), @(LookinPreferredCallStackTypeFormattedCompletely), @(LookinPreferredCallStackTypeRaw)];
    NSUInteger selectedIdx = [options indexOfObject:@(manager.callStackType)];
    
    NSArray<NSString *> *strings = @[NSLocalizedString(@"Format stacks and hide frames in system libraries", nil), NSLocalizedString(@"Format stacks and show all frames", nil), NSLocalizedString(@"Show raw informations", nil)];
    
    NSMenu *menu = [NSMenu new];
    [strings enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMenuItem *item = [NSMenuItem new];
        if (idx == selectedIdx) {
            item.state = NSControlStateValueOn;
        } else {
            item.state = NSControlStateValueOff;
        }
        item.tag = idx;
        item.title = obj;
        item.image = [[NSImage alloc] initWithSize:NSMakeSize(1, 24)];
        item.target = self;
        item.action = @selector(_handleSettingMenuItem:);
        [menu addItem:item];
    }];
    
    [menu popUpMenuPositioningItem:nil atLocation:NSMakePoint(0, button.bounds.size.height) inView:button];
}

- (void)_handleSettingMenuItem:(NSMenuItem *)item {
    [LKPreferenceManager mainManager].callStackType = item.tag;
}

@end
