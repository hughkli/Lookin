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
#import "LKPreferenceManager.h"
@import AppCenter;
@import AppCenterAnalytics;

@interface LKStaticHierarchyDataSource ()

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
    
    [[LKStaticAsyncUpdateManager sharedInstance] updateAll];
    [self updateMessageStatus];
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

#pragma mark - override
- (void)reloadWithItems:(NSArray<LookinDisplayItem *> *)items {
    if ([LKPreferenceManager mainManager].refreshMode == LookinRefreshModeDisplayingItems && [[LKStaticAsyncUpdateManager sharedInstance] updateForItemsIfNeed:items]) {
        [self updateMessageStatus];
    }
}

@end
