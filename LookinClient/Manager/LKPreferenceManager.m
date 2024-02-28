//
//  LKPreferenceManager.m
//  Lookin
//
//  Created by Li Kai on 2019/1/8.
//  https://lookin.work
//

#import "LKPreferenceManager.h"
#import "LookinDashboardBlueprint.h"
#import "LKPreviewView.h"
#import "LKTutorialManager.h"
@import AppCenter;
@import AppCenterAnalytics;

NSString *const NotificationName_DidChangeSectionShowing = @"NotificationName_DidChangeSectionShowing";

NSString *const LKWindowSizeName_Dynamic = @"LKWindowSizeName_Dynamic";
NSString *const LKWindowSizeName_Static = @"LKWindowSizeName_Static";

const CGFloat LKInitialPreviewScale = 0.27;

static NSString * const Key_PreviousClientVersion = @"preVer";
static NSString * const Key_ShowOutline = @"showOutline";
static NSString * const Key_ShowHiddenItems = @"showHiddenItems";
static NSString * const Key_EnableReport = @"enableReport";
static NSString * const Key_RgbaFormat = @"egbaFormat";
static NSString * const Key_ZInterspace = @"zInterspace_v095";
static NSString * const Key_AppearanceType = @"appearanceType";
static NSString * const Key_DoubleClickBehavior = @"doubleClickBehavior";
static NSString * const Key_RefreshMode = @"refreshMode";
static NSString * const Key_ExpansionIndex = @"expansionIndex";
static NSString * const Key_ContrastLevel = @"contrastLevel";
static NSString * const Key_SectionsShow = @"ss";
static NSString * const Key_CollapsedGroups = @"collapsedGroups_918";
static NSString * const Key_PreferredExportCompression = @"preferredExportCompression";
static NSString * const Key_CallStackType = @"callStackType";
static NSString * const Key_SyncConsoleTarget = @"syncConsoleTarget";
static NSString * const Key_FreeRotation = @"FreeRotation";
static NSString * const Key_TurboMode = @"turboMode";
static NSString * const Key_ReceivingConfigTime_Color = @"ConfigTime_Color";
static NSString * const Key_ReceivingConfigTime_Class = @"ConfigTime_Class";

@interface LKPreferenceManager ()

@property(nonatomic, strong) NSMutableDictionary<LookinAttrSectionIdentifier, NSNumber *> *storedSectionShowConfig;

@end

@implementation LKPreferenceManager

+ (instancetype)mainManager {
    static dispatch_once_t onceToken;
    static LKPreferenceManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
        instance.shouldStoreToLocal = YES;
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _previewScale = [LookinDoubleMsgAttribute attributeWithDouble:LKInitialPreviewScale];
        _previewDimension = [LookinIntegerMsgAttribute attributeWithInteger:LookinPreviewDimension3D];
        _measureState = [LookinIntegerMsgAttribute attributeWithInteger:LookinMeasureState_no];
        _isQuickSelecting = [LookinBOOLMsgAttribute attributeWithBOOL:NO];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        // 如果本次 Lookin 客户端的 version 和上次不同，则该变量会被置为 YES
//        BOOL clientVersionHasChanged = NO;
        NSInteger prevClientVersion = [userDefaults integerForKey:Key_PreviousClientVersion];
        if (prevClientVersion != LOOKIN_CLIENT_VERSION) {
//            clientVersionHasChanged = YES;
            [[NSUserDefaults standardUserDefaults] setInteger:LOOKIN_CLIENT_VERSION forKey:Key_PreviousClientVersion];
        }
        
        NSNumber *obj_showOutline = [userDefaults objectForKey:Key_ShowOutline];
        if (obj_showOutline != nil) {
            _showOutline = [LookinBOOLMsgAttribute attributeWithBOOL:[obj_showOutline boolValue]];
        } else {
            _showOutline = [LookinBOOLMsgAttribute attributeWithBOOL:YES];
            [userDefaults setObject:@(YES) forKey:Key_ShowOutline];
        }
        [self.showHiddenItems subscribe:self action:@selector(_handleShowOutlineDidChange:) relatedObject:nil];
        
        NSNumber *obj_showHiddenItems = [userDefaults objectForKey:Key_ShowHiddenItems];
        if (obj_showHiddenItems != nil) {
            _showHiddenItems = [LookinBOOLMsgAttribute attributeWithBOOL:[obj_showHiddenItems boolValue]];
        } else {
            _showHiddenItems = [LookinBOOLMsgAttribute attributeWithBOOL:NO];
            [userDefaults setObject:@(NO) forKey:Key_ShowHiddenItems];
        }
        [self.showHiddenItems subscribe:self action:@selector(_handleShowHiddenItemsChange:) relatedObject:nil];
        
        NSNumber *obj_enableReport = [userDefaults objectForKey:Key_EnableReport];
        if (obj_enableReport != nil) {
            _enableReport = [obj_enableReport boolValue];
        } else {
            _enableReport = YES;
            [userDefaults setObject:@(_enableReport) forKey:Key_EnableReport];
        }
        
        NSNumber *obj_doubleClickBehavior = [userDefaults objectForKey:Key_DoubleClickBehavior];
        if (obj_doubleClickBehavior) {
            _doubleClickBehavior = [obj_doubleClickBehavior intValue];
        } else {
            _doubleClickBehavior = LookinDoubleClickBehaviorCollapse;
            [userDefaults setObject:@(_doubleClickBehavior) forKey:Key_DoubleClickBehavior];
        }
        
        NSNumber *obj_refreshMode = [userDefaults objectForKey:Key_RefreshMode];
        if (obj_refreshMode) {
            _refreshMode = [obj_refreshMode intValue];
        } else {
            _refreshMode = LookinRefreshModeAllItems;
            [userDefaults setObject:@(_refreshMode) forKey:Key_RefreshMode];
        }
        
        NSNumber *obj_rgbaFormat = [userDefaults objectForKey:Key_RgbaFormat];
        if (obj_rgbaFormat != nil) {
            _rgbaFormat = [obj_rgbaFormat boolValue];
        } else {
            _rgbaFormat = YES;
            [userDefaults setObject:@(_rgbaFormat) forKey:Key_RgbaFormat];
        }
        
        double zInterspaceValue;
        NSNumber *obj_zInterspace = [userDefaults objectForKey:Key_ZInterspace];
        if (obj_zInterspace != nil) {
            zInterspaceValue = [obj_zInterspace doubleValue];
        } else {
            /// 默认值为 0.22
            zInterspaceValue = .22;
            [userDefaults setObject:@(zInterspaceValue) forKey:Key_ZInterspace];
        }
        zInterspaceValue = MAX(MIN(zInterspaceValue, LookinPreviewMaxZInterspace), LookinPreviewMinZInterspace);
        _zInterspace = [LookinDoubleMsgAttribute attributeWithDouble:zInterspaceValue];
        [self.zInterspace subscribe:self action:@selector(_handleZInterspaceDidChange:) relatedObject:nil];
        
        NSNumber *obj_appearanceType = [userDefaults objectForKey:Key_AppearanceType];
        if (obj_appearanceType != nil) {
            _appearanceType = [obj_appearanceType integerValue];
        } else {
            _appearanceType = LookinPreferredAppeanranceTypeSystem;
            [userDefaults setObject:@(_appearanceType) forKey:Key_AppearanceType];
        }
        
        NSNumber *obj_expansionIndex = [userDefaults objectForKey:Key_ExpansionIndex];
        if (obj_expansionIndex != nil) {
            _expansionIndex = [obj_expansionIndex integerValue];
        } else {
            _expansionIndex = 3;
            [userDefaults setObject:@(_expansionIndex) forKey:Key_ExpansionIndex];
        }
        
        NSNumber *obj_contrastLevel = [userDefaults objectForKey:Key_ContrastLevel];
        if (obj_contrastLevel != nil) {
            _imageContrastLevel = [obj_contrastLevel integerValue];
        } else {
            _imageContrastLevel = 0;
            [userDefaults setObject:@(_imageContrastLevel) forKey:Key_ContrastLevel];
        }
        
        NSNumber *obj_syncConsoleTarget = [userDefaults objectForKey:Key_SyncConsoleTarget];
        if (obj_syncConsoleTarget != nil) {
            _syncConsoleTarget = [obj_syncConsoleTarget boolValue];
        } else {
            _syncConsoleTarget = YES;
            [userDefaults setObject:@(_syncConsoleTarget) forKey:Key_SyncConsoleTarget];
        }
        
        NSNumber *obj_freeRotation = [userDefaults objectForKey:Key_FreeRotation];
        if (obj_freeRotation != nil) {
            _freeRotation = [LookinBOOLMsgAttribute attributeWithBOOL:obj_freeRotation.boolValue];
        } else {
            _freeRotation = [LookinBOOLMsgAttribute attributeWithBOOL:YES];
            [userDefaults setObject:@(_freeRotation.currentBOOLValue) forKey:Key_FreeRotation];
        }
        [self.freeRotation subscribe:self action:@selector(_handleFreeRotationDidChange:) relatedObject:nil];
        
        NSNumber *obj_turboMode = [userDefaults objectForKey:Key_TurboMode];
        if (obj_turboMode != nil) {
            _turboMode = [LookinBOOLMsgAttribute attributeWithBOOL:obj_turboMode.boolValue];
        } else {
            _turboMode = [LookinBOOLMsgAttribute attributeWithBOOL:NO];
            [userDefaults setObject:@(_turboMode.currentBOOLValue) forKey:Key_FreeRotation];
        }
        [self.turboMode subscribe:self action:@selector(_handleTurboModeDidChange:) relatedObject:nil];
        
        self.storedSectionShowConfig = [[userDefaults objectForKey:Key_SectionsShow] mutableCopy];
        if (!self.storedSectionShowConfig) {
            self.storedSectionShowConfig = [NSMutableDictionary dictionary];
        }
        
        _collapsedAttrGroups = [userDefaults objectForKey:Key_CollapsedGroups];
        if (!_collapsedAttrGroups) {
            _collapsedAttrGroups = @[LookinAttrGroup_Class];
        }
        
        NSNumber *obj_preferredExportCompression = [userDefaults objectForKey:Key_PreferredExportCompression];
        if (obj_preferredExportCompression != nil) {
            _preferredExportCompression = [obj_preferredExportCompression doubleValue];
        } else {
            /// 这里的默认值需要在 LKExportAccessory.m 里定义的选项里面
            _preferredExportCompression = .5;
            [userDefaults setObject:@(_preferredExportCompression) forKey:Key_PreferredExportCompression];
        }
        
        _receivingConfigTime_Color = [userDefaults doubleForKey:Key_ReceivingConfigTime_Color];
        _receivingConfigTime_Class = [userDefaults doubleForKey:Key_ReceivingConfigTime_Class];
    }
    return self;
}

- (void)_handleShowOutlineDidChange:(LookinMsgActionParams *)param {
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(param.boolValue) forKey:Key_ShowOutline];
    }
}

- (void)_handleShowHiddenItemsChange:(LookinMsgActionParams *)param {
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(param.boolValue) forKey:Key_ShowHiddenItems];
    }
}

- (void)setEnableReport:(BOOL)enableReport {
    if (_enableReport == enableReport) {
        return;
    }
    _enableReport = enableReport;
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(enableReport) forKey:Key_EnableReport];
    }
    
    MSACAppCenter.enabled = enableReport;
}

- (void)setRgbaFormat:(BOOL)rgbaFormat {
    if (_rgbaFormat == rgbaFormat) {
        return;
    }
    _rgbaFormat = rgbaFormat;
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(rgbaFormat) forKey:Key_RgbaFormat];
    }
}

- (void)setDoubleClickBehavior:(LookinDoubleClickBehavior)doubleClickBehavior {
    _doubleClickBehavior = doubleClickBehavior;
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(doubleClickBehavior) forKey:Key_DoubleClickBehavior];
    }
}

- (void)setRefreshMode:(LookinRefreshMode)refreshMode {
    _refreshMode = refreshMode;
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(refreshMode) forKey:Key_RefreshMode];
    }
}

- (void)setAppearanceType:(LookinPreferredAppeanranceType)appearanceType {
    if (_appearanceType == appearanceType) {
        return;
    }
    _appearanceType = appearanceType;
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(appearanceType) forKey:Key_AppearanceType];
    }
}

- (void)setExpansionIndex:(NSInteger)expansionIndex {
    if (_expansionIndex == expansionIndex) {
        return;
    }
    _expansionIndex = expansionIndex;
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(expansionIndex) forKey:Key_ExpansionIndex];
    }
}

- (void)setImageContrastLevel:(NSInteger)imageContrastLevel {
    if (_imageContrastLevel == imageContrastLevel) {
        return;
    }
    _imageContrastLevel = imageContrastLevel;
    
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(imageContrastLevel) forKey:Key_ContrastLevel];
    }
}

- (void)setCollapsedAttrGroups:(NSArray<NSNumber *> *)collapsedAttrGroups {
    _collapsedAttrGroups = collapsedAttrGroups.copy;
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:collapsedAttrGroups forKey:Key_CollapsedGroups];
    }
}

- (void)setPreferredExportCompression:(CGFloat)preferredExportCompression {
    if (_preferredExportCompression == preferredExportCompression) {
        return;
    }
    _preferredExportCompression = preferredExportCompression;
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(preferredExportCompression) forKey:Key_PreferredExportCompression];
    }
}

- (void)setCallStackType:(LookinPreferredCallStackType)callStackType {
    if (callStackType < 0 || callStackType > 2) {
        NSAssert(NO, @"");
        callStackType = 0;
    }
    _callStackType = callStackType;
}

- (void)setSyncConsoleTarget:(BOOL)syncConsoleTarget {
    if (_syncConsoleTarget == syncConsoleTarget) {
        return;
    }
    _syncConsoleTarget = syncConsoleTarget;
    if (self.shouldStoreToLocal) {
        [[NSUserDefaults standardUserDefaults] setObject:@(syncConsoleTarget) forKey:Key_SyncConsoleTarget];
    }
}

- (void)setReceivingConfigTime_Class:(NSTimeInterval)receivingConfigTime_Class {
    _receivingConfigTime_Class = receivingConfigTime_Class;
    [[NSUserDefaults standardUserDefaults] setDouble:receivingConfigTime_Class forKey:Key_ReceivingConfigTime_Class];
}

- (void)setReceivingConfigTime_Color:(NSTimeInterval)receivingConfigTime_Color {
    _receivingConfigTime_Color = receivingConfigTime_Color;
    [[NSUserDefaults standardUserDefaults] setDouble:receivingConfigTime_Color forKey:Key_ReceivingConfigTime_Color];
}

- (void)_handleFreeRotationDidChange:(LookinMsgActionParams *)param {
    if (!self.shouldStoreToLocal) {
        return;
    }
    BOOL boolValue = param.boolValue;
    [[NSUserDefaults standardUserDefaults] setObject:@(boolValue) forKey:Key_FreeRotation];
}

- (void)_handleTurboModeDidChange:(LookinMsgActionParams *)param {
    if (!self.shouldStoreToLocal) {
        return;
    }
    BOOL boolValue = param.boolValue;
    [[NSUserDefaults standardUserDefaults] setObject:@(boolValue) forKey:Key_TurboMode];
}


- (void)_handleZInterspaceDidChange:(LookinMsgActionParams *)param {
    if (!self.shouldStoreToLocal) {
        return;
    }
    double doubleValue = param.doubleValue;
    [[NSUserDefaults standardUserDefaults] setObject:@(doubleValue) forKey:Key_ZInterspace];
}

/// 返回某个 section 是否应该被显示在主界面上
- (BOOL)isSectionShowing:(LookinAttrSectionIdentifier)secID {
    if (self.storedSectionShowConfig[secID] != nil) {
        return [self.storedSectionShowConfig[secID] boolValue];
    }
    NSSet<LookinAttrSectionIdentifier> *showingSecIDs = [self _showingSecIDsInDefault];
    if ([showingSecIDs containsObject:secID]) {
        return YES;
    } else {
        return NO;
    }
}

/// 把某个 section 显示在主界面上
- (void)showSection:(LookinAttrSectionIdentifier)secID {
    if ([self isSectionShowing:secID]) {
        NSAssert(NO, @"");
        return;
    }
    self.storedSectionShowConfig[secID] = @(YES);
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationName_DidChangeSectionShowing object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:self.storedSectionShowConfig.copy forKey:Key_SectionsShow];
}

/// 把某个 section 从主界面上移除
- (void)hideSection:(LookinAttrSectionIdentifier)secID {
    if (![self isSectionShowing:secID]) {
        NSAssert(NO, @"");
        return;
    }
    self.storedSectionShowConfig[secID] = @(NO);
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationName_DidChangeSectionShowing object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:self.storedSectionShowConfig.copy forKey:Key_SectionsShow];
}

/// 返回默认情况下，哪些 section 应该被显示在主界面上
- (NSSet<LookinAttrSectionIdentifier> *)_showingSecIDsInDefault {
    static dispatch_once_t onceToken;
    static NSSet *targetSet = nil;
    dispatch_once(&onceToken,^{
        NSArray<LookinAttrSectionIdentifier> *array = @[LookinAttrSec_Class_Class,
                                                        
                                                        LookinAttrSec_Relation_Relation,
                                                        
                                                        LookinAttrSec_Layout_Frame,
                                                        LookinAttrSec_Layout_Bounds,
                                                        
                                                        LookinAttrSec_AutoLayout_Hugging,
                                                        LookinAttrSec_AutoLayout_Resistance,
                                                        LookinAttrSec_AutoLayout_Constraints,
                                                        LookinAttrSec_AutoLayout_IntrinsicSize,
                                                        
                                                        LookinAttrSec_ViewLayer_Visibility,
                                                        LookinAttrSec_ViewLayer_InterationAndMasks,
                                                        LookinAttrSec_ViewLayer_Corner,
                                                        LookinAttrSec_ViewLayer_BgColor,
                                                        LookinAttrSec_ViewLayer_Border,
                                                        LookinAttrSec_ViewLayer_Shadow,
                                                        
                                                        LookinAttrSec_UIStackView_Axis,
                                                        LookinAttrSec_UIStackView_Alignment,
                                                        LookinAttrSec_UIStackView_Distribution,
                                                        LookinAttrSec_UIStackView_Spacing,
                                                        
                                                        LookinAttrSec_UIVisualEffectView_Style,
                                                        LookinAttrSec_UIVisualEffectView_QMUIForegroundColor,
                                                        
                                                        LookinAttrSec_UIImageView_Name,
                                                        LookinAttrSec_UIImageView_Open,
                                                        
                                                        LookinAttrSec_UILabel_Text,
                                                        LookinAttrSec_UILabel_Font,
                                                        LookinAttrSec_UILabel_NumberOfLines,
                                                        LookinAttrSec_UILabel_TextColor,
                                                        LookinAttrSec_UILabel_BreakMode,
                                                        LookinAttrSec_UILabel_Alignment,
                                                        
                                                        LookinAttrSec_UIControl_EnabledSelected,
                                                        LookinAttrSec_UIControl_QMUIOutsideEdge,
                                                        
                                                        LookinAttrSec_UIButton_ContentInsets,
                                                        
                                                        LookinAttrSec_UIScrollView_ContentInset,
                                                        LookinAttrSec_UIScrollView_AdjustedInset,
                                                        LookinAttrSec_UIScrollView_IndicatorInset,
                                                        LookinAttrSec_UIScrollView_Offset,
                                                        LookinAttrSec_UIScrollView_ContentSize,
                                                        LookinAttrSec_UIScrollView_Behavior,
                                                        
                                                        LookinAttrSec_UITableView_Style,
                                                        LookinAttrSec_UITableView_SectionsNumber,
                                                        LookinAttrSec_UITableView_RowsNumber,
                                                        
                                                        LookinAttrSec_UITextView_Text,
                                                        LookinAttrSec_UITextView_Font,
                                                        LookinAttrSec_UITextView_TextColor,
                                                        LookinAttrSec_UITextView_Alignment,
                                                        LookinAttrSec_UITextView_ContainerInset,
                                                        
                                                        LookinAttrSec_UITextField_Text,
                                                        LookinAttrSec_UITextField_Font,
                                                        LookinAttrSec_UITextField_TextColor,
                                                        LookinAttrSec_UITextField_Alignment
        ];
        targetSet = [NSSet setWithArray:array];
    });
    return targetSet;
}

+ (BOOL)popupToAskDoubleClickBehaviorIfNeededWithWindow:(NSWindow *)window {
    if (!window) {
        return NO;
    }
    if ([LKTutorialManager sharedInstance].hasAskedDoubleClickBehavior) {
        return NO;
    }
    NSAlert *alert = [NSAlert new];
    alert.messageText = NSLocalizedString(@"What do you want to happen when you double click the layer?", nil);
    alert.informativeText = NSLocalizedString(@"You can change it at any time in your Preferences.", nil);
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:NSLocalizedString(@"Expand or collapse layer", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"Focus on layer", nil)];
    [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            // collapse
            [LKPreferenceManager mainManager].doubleClickBehavior = LookinDoubleClickBehaviorCollapse;
        } else {
            // focus
            [LKPreferenceManager mainManager].doubleClickBehavior = LookinDoubleClickBehaviorFocus;
        }
    }];
    [LKTutorialManager sharedInstance].hasAskedDoubleClickBehavior = YES;
    return YES;
}

- (void)reset {
    [LKTutorialManager sharedInstance].hasAskedDoubleClickBehavior = NO;
}

- (void)reportStatistics {
    [MSACAnalytics trackEvent:@"Preference" withProperties:@{
        @"DoubleClick": [NSString stringWithFormat:@"%@", @(self.doubleClickBehavior)],
        @"ShowHidden": [NSString stringWithFormat:@"%@", @(self.showHiddenItems.currentBOOLValue)],
        @"RGBA": [NSString stringWithFormat:@"%@", @(self.rgbaFormat)],
        @"FreeRotation": [NSString stringWithFormat:@"%@", @(self.freeRotation.currentBOOLValue)],
    }];
}

@end
