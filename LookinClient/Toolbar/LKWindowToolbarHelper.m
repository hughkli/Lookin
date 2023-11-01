//
//  LKWindowToolbarHelper.m
//  Lookin
//
//  Created by Li Kai on 2019/5/8.
//  https://lookin.work
//

#import "LKWindowToolbarHelper.h"
#import "LKPreferenceManager.h"
#import "LKMenuPopoverSettingController.h"
#import "LKAppsManager.h"
#import "LKNavigationManager.h"
#import "LKPreviewView.h"
#import "LKWindowToolbarScaleView.h"
#import "LKWindowToolbarAppButton.h"

NSToolbarItemIdentifier const LKToolBarIdentifier_Dimension = @"0";
NSToolbarItemIdentifier const LKToolBarIdentifier_Scale = @"1";
NSToolbarItemIdentifier const LKToolBarIdentifier_Setting = @"2";
NSToolbarItemIdentifier const LKToolBarIdentifier_Reload = @"3";
NSToolbarItemIdentifier const LKToolBarIdentifier_App = @"5";
NSToolbarItemIdentifier const LKToolBarIdentifier_AppInReadMode = @"12";
NSToolbarItemIdentifier const LKToolBarIdentifier_Add = @"13";
NSToolbarItemIdentifier const LKToolBarIdentifier_Remove = @"14";
NSToolbarItemIdentifier const LKToolBarIdentifier_Console = @"15";
NSToolbarItemIdentifier const LKToolBarIdentifier_Rotation = @"16";
NSToolbarItemIdentifier const LKToolBarIdentifier_Measure = @"17";
NSToolbarItemIdentifier const LKToolBarIdentifier_Message = @"18";

static NSString * const Key_BindingPreferenceManager = @"PreferenceManager";
static NSString * const Key_BindingAppInfo = @"AppInfo";

@interface LKWindowToolbarHelper ()

@end

@implementation LKWindowToolbarHelper

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LKWindowToolbarHelper *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (NSToolbarItem *)makeToolBarItemWithIdentifier:(NSToolbarItemIdentifier)identifier preferenceManager:(LKPreferenceManager *)manager {
    NSAssert(![identifier isEqualToString:LKToolBarIdentifier_AppInReadMode], @"请使用 makeAppInReadModeItemWithAppInfo: 方法");
    
    if ([identifier isEqualToString:LKToolBarIdentifier_Measure]) {
        NSImage *image = NSImageMake(@"icon_measure");
        image.template = YES;
        
        NSButton *button = [NSButton new];
        [button setImage:image];
        button.bezelStyle = NSBezelStyleTexturedRounded;
        [button setButtonType:NSButtonTypePushOnPushOff];
        button.target = self;
        button.action = @selector(_handleToggleMeasureButton:);
        [button lookin_bindObject:manager forKey:@"manager"];
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:LKToolBarIdentifier_Measure];
        item.label = NSLocalizedString(@"Measure", nil);
        item.view = button;
        item.minSize = NSMakeSize(48, 34);

        [manager.isMeasuring subscribe:self action:@selector(_handleMeasureDidChange:) relatedObject:button sendAtOnce:YES];
        
        return item;
    }
    
    if ([identifier isEqualToString:LKToolBarIdentifier_Rotation]) {
        NSImage *image = NSImageMake(@"icon_rotation");
        image.template = YES;
        
        NSButton *button = [NSButton new];
        [button setImage:image];
        button.bezelStyle = NSBezelStyleTexturedRounded;
        [button setButtonType:NSButtonTypePushOnPushOff];
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:LKToolBarIdentifier_Rotation];
        item.label = NSLocalizedString(@"Free Rotation", nil);
        item.view = button;
        item.minSize = NSMakeSize(48, 34);

        [manager.freeRotation subscribe:self action:@selector(_handleFreeRotationDidChange:) relatedObject:button sendAtOnce:YES];
        
        return item;
    }
    
    if ([identifier isEqualToString:LKToolBarIdentifier_Dimension]) {
        NSImage *image_2d = NSImageMake(@"icon_2d");
        image_2d.template = YES;
        NSImage *image_3d = NSImageMake(@"icon_3d");
        image_3d.template = YES;
        
        NSSegmentedControl *control = [NSSegmentedControl segmentedControlWithImages:@[image_2d, image_3d] trackingMode:NSSegmentSwitchTrackingSelectOne target:self action:@selector(_handleDimension:)];
        [control lookin_bindObjectWeakly:manager forKey:Key_BindingPreferenceManager];
        control.segmentDistribution = NSSegmentDistributionFillEqually;
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:LKToolBarIdentifier_Dimension];
        item.label = @"2D / 3D";
        item.view = control;
        item.minSize = NSMakeSize(90, 34);

        [manager.previewDimension subscribe:self action:@selector(_handleDimensionDidChange:) relatedObject:control sendAtOnce:YES];

        return item;
    }
    
    if ([identifier isEqualToString:LKToolBarIdentifier_Scale]) {
        double scale = manager.previewScale.currentDoubleValue;
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:LKToolBarIdentifier_Scale];
        LKWindowToolbarScaleView *scaleView = [LKWindowToolbarScaleView new];
        scaleView.slider.minValue = LookinPreviewMinScale;
        scaleView.slider.maxValue = LookinPreviewMaxScale;
        scaleView.slider.doubleValue = scale;
        scaleView.slider.target = self;
        scaleView.slider.action = @selector(_handleScaleSlider:);
        scaleView.increaseButton.target = self;
        scaleView.increaseButton.action = @selector(_handleScaleIncreaseButton:);
        scaleView.decreaseButton.target = self;
        scaleView.decreaseButton.action = @selector(_handleScaleDecreaseButton:);
        [scaleView.slider lookin_bindObjectWeakly:manager forKey:Key_BindingPreferenceManager];
        [scaleView.increaseButton lookin_bindObjectWeakly:manager forKey:Key_BindingPreferenceManager];
        [scaleView.decreaseButton lookin_bindObjectWeakly:manager forKey:Key_BindingPreferenceManager];
        
        item.label = NSLocalizedString(@"Zoom", nil);
        item.view = scaleView;
        item.minSize = NSMakeSize(160, 34);
        
        [manager.previewScale subscribe:self action:@selector(_handlePreviewScaleDidChange:) relatedObject:scaleView.slider sendAtOnce:YES];
        
        return item;
    }
    
    if ([identifier isEqualToString:LKToolBarIdentifier_Setting]) {
        NSImage *image = NSImageMake(@"icon_setting");
        image.template = YES;
        
        NSButton *button = [NSButton new];
        [button setImage:image];
        button.bezelStyle = NSBezelStyleTexturedRounded;
        [button lookin_bindObjectWeakly:manager forKey:Key_BindingPreferenceManager];
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:LKToolBarIdentifier_Setting];
        item.view = button;
        item.minSize = NSMakeSize(48, 34);
        return item;
    }
    
    if ([identifier isEqualToString:LKToolBarIdentifier_Reload]) {
        NSImage *image = NSImageMake(@"icon_reload");
        image.template = YES;
        
        NSButton *button = [NSButton new];
        [button setImage:image];
        button.bezelStyle = NSBezelStyleTexturedRounded;
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:LKToolBarIdentifier_Reload];
        item.label = NSLocalizedString(@"Reload", nil);
        item.view = button;
        item.minSize = NSMakeSize(68, 34);
        return item;
    }
    
    if ([identifier isEqualToString:LKToolBarIdentifier_App]) {
        LKWindowToolbarAppButton *button = [LKWindowToolbarAppButton new];
        button.bezelStyle = NSBezelStyleTexturedRounded;
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:LKToolBarIdentifier_App];
        item.label = NSLocalizedString(@"Select App", nil);
        item.view = button;
        
        [[RACObserve([LKAppsManager sharedInstance], inspectingApp) takeUntil:item.rac_willDeallocSignal] subscribeNext:^(LKInspectableApp *app) {
            button.appInfo = app.appInfo;
            if (app) {
                item.minSize = NSMakeSize(button.bestWidth + 6, 34);
                item.maxSize = item.minSize;
            } else {
                item.minSize = NSMakeSize(42, 34);
                item.maxSize = item.minSize;
            }
        }];
        return item;
    }
    
    if ([identifier isEqualToString:LKToolBarIdentifier_Console]) {
        NSImage *image = NSImageMake(@"icon_console");
        image.template = YES;

        NSButton *button = [NSButton new];
        [button setImage:image];
        button.bezelStyle = NSBezelStyleTexturedRounded;
        [button setButtonType:NSButtonTypePushOnPushOff];
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:LKToolBarIdentifier_Console];
        item.label = NSLocalizedString(@"Console", nil);
        item.view = button;
        item.minSize = NSMakeSize(48, 34);
        return item;
    }
    
    if ([identifier isEqualToString:LKToolBarIdentifier_Add]) {
        NSImage *image = [NSImage imageNamed:NSImageNameAddTemplate];
        image.template = YES;
        
        NSButton *button = [NSButton new];
        [button setImage:image];
        button.bezelStyle = NSBezelStyleTexturedRounded;
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:LKToolBarIdentifier_Add];
        item.view = button;
        item.minSize = NSMakeSize(48, 34);
        return item;
    }
    
    if ([identifier isEqualToString:LKToolBarIdentifier_Remove]) {
        NSImage *image = NSImageMake(@"icon_delete");
        image.template = YES;
        
        NSButton *button = [NSButton new];
        [button setImage:image];
        button.bezelStyle = NSBezelStyleTexturedRounded;
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:LKToolBarIdentifier_Remove];
        item.view = button;
        item.minSize = NSMakeSize(48, 34);
        return item;
    }
    
    if ([identifier isEqualToString:LKToolBarIdentifier_Message]) {
        NSImage *image = NSImageMake(@"icon_notification");
        image.template = YES;
        
        NSButton *button = [NSButton new];
        [button setImage:image];
        button.bezelStyle = NSBezelStyleTexturedRounded;
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:LKToolBarIdentifier_Message];
        item.view = button;
        item.minSize = NSMakeSize(48, 34);
        return item;
    }
    
    NSAssert(NO, @"");
    return nil;
}

- (NSToolbarItem *)makeAppInReadModeItemWithAppInfo:(LookinAppInfo *)appInfo {
    LKWindowToolbarAppButton *button = [LKWindowToolbarAppButton new];
    button.bezelStyle = NSBezelStyleTexturedRounded;
    [button lookin_bindObject:appInfo forKey:Key_BindingAppInfo];
    button.appInfo = appInfo;
    
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:LKToolBarIdentifier_AppInReadMode];
    item.label = @"iOS App";
    item.view = button;
    item.minSize = NSMakeSize(button.bestWidth + 6, 34);
    
    item.maxSize = item.minSize;
    return item;
}

- (void)_handleDimension:(NSSegmentedControl *)control {
    LKPreferenceManager *manager = [control lookin_getBindObjectForKey:Key_BindingPreferenceManager];
    NSUInteger index = control.selectedSegment;
    [manager.previewDimension setIntegerValue:index ignoreSubscriber:self];
}

- (void)_handleScaleSlider:(NSSlider *)slider {
    LKPreferenceManager *manager = [slider lookin_getBindObjectForKey:Key_BindingPreferenceManager];
    [manager.previewScale setDoubleValue:slider.doubleValue ignoreSubscriber:self];
}

- (void)_handleScaleIncreaseButton:(NSButton *)button {
    LKPreferenceManager *manager = [button lookin_getBindObjectForKey:Key_BindingPreferenceManager];
    double currentScale = manager.previewScale.currentDoubleValue;
    double targetScale = MIN(MAX(currentScale + 0.1, LookinPreviewMinScale), LookinPreviewMaxScale);
    [manager.previewScale setDoubleValue:targetScale ignoreSubscriber:nil];
}

- (void)_handleScaleDecreaseButton:(NSButton *)button {
    LKPreferenceManager *manager = [button lookin_getBindObjectForKey:Key_BindingPreferenceManager];
    double currentScale = manager.previewScale.currentDoubleValue;
    double targetScale = MIN(MAX(currentScale - 0.1, LookinPreviewMinScale), LookinPreviewMaxScale);
    [manager.previewScale setDoubleValue:targetScale ignoreSubscriber:nil];
}

- (void)_handlePreviewScaleDidChange:(LookinMsgActionParams *)param {
    NSSlider *slider = param.relatedObject;
    CGFloat scale = param.doubleValue;
    slider.doubleValue = scale;
}

- (void)_handleDimensionDidChange:(LookinMsgActionParams *)param {
    LookinPreviewDimension newDimension = param.integerValue;
    NSSegmentedControl *control = param.relatedObject;
    control.selectedSegment = newDimension;
}

- (void)_handleFreeRotationDidChange:(LookinMsgActionParams *)param {
    NSButton *button = param.relatedObject;
    BOOL boolValue = param.boolValue;
    button.state = boolValue ? NSControlStateValueOn : NSControlStateValueOff;
}

- (void)_handleToggleMeasureButton:(NSButton *)button {
    LKPreferenceManager *manager = [button lookin_getBindObjectForKey:@"manager"];
    [manager.isMeasuring setBOOLValue:((button.state == NSControlStateValueOn) ? YES : NO) ignoreSubscriber:self];
}

- (void)_handleMeasureDidChange:(LookinMsgActionParams *)param {
    NSButton *button = param.relatedObject;
    BOOL boolValue = param.boolValue;
    button.state = boolValue ? NSControlStateValueOn : NSControlStateValueOff;
}

@end
