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

@interface LKStaticHierarchyDataSource ()

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
            obj.avoidSyncScreenshot = YES;
        }
    }];
    
    [[LKStaticAsyncUpdateManager sharedInstance] updateAll];
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
    
    if (detail.attributesGroupList.count) {
        displayItem.attributesGroupList = detail.attributesGroupList;
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

@end
