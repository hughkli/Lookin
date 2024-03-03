//
//  LKStaticHierarchyDataSource.m
//  Lookin
//
//  Created by Li Kai on 2018/12/21.
//  https://lookin.work
//

#import "LKStaticHierarchyDataSource.h"
#import "LookinHierarchyInfo.h"
#import "LookinDisplayItem.h"
#import "LookinAttributesGroup.h"
#import "LookinAttribute.h"
#import "LKPreferenceManager.h"
#import "LKStaticAsyncUpdateManager.h"
#import "LookinDisplayItemDetail.h"
#import "LookinDisplayItem.h"
#import "LookinAppInfo.h"
#import "LKMessageManager.h"
#import "LKServerVersionRequestor.h"
#import "LKVersionComparer.h"
#import "LKAppsManager.h"
#import "LKDanceUIAttrMaker.h"
@import AppCenter;
@import AppCenterAnalytics;

@interface LKStaticHierarchyDataSource ()

@property(nonatomic, assign) BOOL shouldIgnoreFastModeAutoUpdate;
@property(nonatomic, assign) BOOL isUsingDanceUI;

@end

@implementation LKStaticHierarchyDataSource

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LKStaticHierarchyDataSource *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        _itemsDidChangeFrame = [RACSubject subject];
    }
    return self;
}

#pragma mark - Public

- (void)reloadWithHierarchyInfo:(LookinHierarchyInfo *)info keepState:(BOOL)keepState {
    [super reloadWithHierarchyInfo:info keepState:keepState];
    
    _appInfo = info.appInfo;
    
    NSAssert(info.appInfo.screenScale > 0, @"");
    CGFloat screenScale = MAX(info.appInfo.screenScale, 1);

    // SCNNode 的图片的长和宽均不能超过 16384px，这里再随手减掉 100，注意单位是 px 不是 pt
    CGFloat maxLengthInPx = LookinNodeImageMaxLengthInPx - 100;
    [self.flatItems enumerateObjectsUsingBlock:^(LookinDisplayItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat widthInPx = obj.frame.size.width * screenScale;
        CGFloat heightInPx = obj.frame.size.height * screenScale;
        if (widthInPx > maxLengthInPx || heightInPx > maxLengthInPx) {
            obj.doNotFetchScreenshotReason = LookinDoNotFetchScreenshotForTooLarge;
        }
    }];
    
    [self updateMessageStatus];

    BOOL shouldUpdateAll = (LKPreferenceManager.mainManager.fastMode.currentBOOLValue == NO);
    if (shouldUpdateAll) {
        [[LKStaticAsyncUpdateManager sharedInstance] updateAll];        
    }
}

- (void)modifyWithDisplayItemDetail:(LookinDisplayItemDetail *)detail {
    if (!detail) {
        return;
    }
    LookinDisplayItem *displayItem = [self displayItemWithOid:detail.displayItemOid];
    if (!displayItem) {
        NSAssert(NO, @"");
        return;
    }
    if (detail.customDisplayTitle) {
        displayItem.customDisplayTitle = detail.customDisplayTitle;
    }
    if (detail.danceUISource) {
        displayItem.danceuiSource = detail.danceUISource;
        
        if (!self.isUsingDanceUI) {
            self.isUsingDanceUI = YES;
            [MSACAnalytics trackEvent:@"UseDance"];
        }
    }
    if (detail.groupScreenshot) {
        displayItem.groupScreenshot = detail.groupScreenshot;
    }
    if (detail.soloScreenshot) {
        displayItem.soloScreenshot = detail.soloScreenshot;
    }
    
    if (detail.frameValue || detail.boundsValue) {
        [self _modifyDisplayItem:displayItem newFrame:[detail.frameValue rectValue] newBounds:[detail.boundsValue rectValue]];
    }
    
    BOOL didChangeHiddenAlpha = NO;
    if (detail.hiddenValue && detail.hiddenValue.boolValue != displayItem.isHidden) {
        displayItem.isHidden = [detail.hiddenValue boolValue];
        didChangeHiddenAlpha = YES;
    }
    if (detail.alphaValue && detail.alphaValue.floatValue != displayItem.alpha) {
        displayItem.alpha = [detail.alphaValue floatValue];
        didChangeHiddenAlpha = YES;
    }
    if (didChangeHiddenAlpha) {
        [self.itemDidChangeHiddenAlphaValue sendNext:displayItem];
    }

    BOOL attrChanged = NO;
    if (detail.attributesGroupList.count) {
        displayItem.attributesGroupList = detail.attributesGroupList;
        attrChanged = YES;
    }
    if (detail.customAttrGroupList.count) {
        displayItem.customAttrGroupList = detail.customAttrGroupList;
        attrChanged = YES;
    }
    if (attrChanged) {
        [self.itemDidChangeAttrGroup sendNext:displayItem];        
    }
    if (detail.subitems && (displayItem.subitems.count > 0 || detail.subitems.count > 0)) {
        // 如果没有这个标记位的话，待会儿的 buildDisplayingItem 在 fastMode 下会触发 update task，而此时上一个 update task 其实还没有结束（此时还在 sendTask 的 subscribe 阶段、还没有到 completion 阶段），因此就会同时有两个 update task，而 task 理论上是不能并发的。所以我们这里先简单的用一个标记位防止一下。
        self.shouldIgnoreFastModeAutoUpdate = YES;
        
        // 可能在 search 或 focus 状态，先退出，否则状态维护太麻烦
        switch (self.state) {
            case LKHierarchyDataSourceStateFocus:
                [self endFocus];
                break;
            case LKHierarchyDataSourceStateSearch:
                [self endSearch];
                break;
            default:
                break;
        }
        
        displayItem.subitems = detail.subitems;
        // 根据 subitems 属性打平为二维数组，同时给每个 item 设置 indentLevel
        self.rawFlatItems = [LookinDisplayItem flatItemsFromHierarchicalItems:self.rawHierarchyInfo.displayItems];
        self.flatItems = self.rawFlatItems;
        [self.didReloadHierarchyInfo sendNext:nil];
        
        [displayItem enumerateSelfAndChildren:^(LookinDisplayItem * _Nonnull obj) {
            if (obj == displayItem) {
                return;
            }
            if (!obj.isUserCustom && !obj.shouldCaptureImage) {
                [obj enumerateSelfAndChildren:^(LookinDisplayItem *item) {
                    item.noPreview = YES;
                    item.doNotFetchScreenshotReason = LookinDoNotFetchScreenshotForUserConfig;
                }];
            }
            if (obj.customInfo.danceuiSource.length > 0) {
                [LKDanceUIAttrMaker makeDanceUIJumpAttribute:obj danceSource:obj.customInfo.danceuiSource];
            }
        }];
        [self buildDisplayingFlatItems];
        self.shouldIgnoreFastModeAutoUpdate = NO;
    }
}

- (void)buildDisplayingFlatItems {
    [super buildDisplayingFlatItems];
    if ([LKPreferenceManager mainManager].fastMode.currentBOOLValue && !self.shouldIgnoreFastModeAutoUpdate) {
        [[LKStaticAsyncUpdateManager sharedInstance] updateForDisplayingItems];
    }
}

- (LKPreferenceManager *)preferenceManager {
    return [LKPreferenceManager mainManager];
}

#pragma mark - Private

- (void)_modifyDisplayItem:(LookinDisplayItem *)item newFrame:(CGRect)frame newBounds:(CGRect)bounds {
    if (!item) {
        NSAssert(NO, @"");
        return;
    }
    if (CGRectEqualToRect(item.frame, frame) && CGRectEqualToRect(item.bounds, bounds)) {
        return;
    }
    item.frame = frame;
    item.bounds = bounds;
    
    [self.itemsDidChangeFrame sendNext:item];
}

- (void)updateMessageStatus {
    if (self.serverSideIsSwiftProject && self.appInfo.swiftEnabledInLookinServer == -1) {
        [[LKMessageManager sharedInstance] addMessage:LKMessage_SwiftSubspec];
    } else {
        [[LKMessageManager sharedInstance] removeMessage:LKMessage_SwiftSubspec];
    }
    
    if ([self queryIfUsingNewestServerVersion]) {
        [[LKMessageManager sharedInstance] removeMessage:LKMessage_NewServerVersion];
    } else {
        [[LKMessageManager sharedInstance] addMessage:LKMessage_NewServerVersion];
    }
}

/// 如果 Server 端使用的是最新版，或者无法判断，那么就返回 YES
- (BOOL)queryIfUsingNewestServerVersion {
    NSString *newestVersion = [[LKServerVersionRequestor shared] query];
    if (!newestVersion) {
        return YES;
    }
    NSString *userVersion = [self.appInfo serverReadableVersion];
    if (!userVersion) {
        // LookinServer 1.2.3 之前的版本没有该字段
        return NO;
    }
    [MSACAnalytics trackEvent:@"ServerVersion" withProperties:@{@"version":userVersion}];
    BOOL isNew = [LKVersionComparer compareWithNewest:newestVersion user:userVersion];
    return isNew;
}

- (BOOL)isReadOnly {
    return NO;
}

@end
