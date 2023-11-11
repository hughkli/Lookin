//
//  LKEnumListRegistry.m
//  Lookin
//
//  Created by Li Kai on 2018/11/21.
//  https://lookin.work
//

#import "LKEnumListRegistry.h"

#define MakeItemWithVersion(descArg, valueArg, availableMinOSVersion) [LKEnumListRegistryKeyValueItem itemWithDesc:descArg value:valueArg availableOSVersion:availableMinOSVersion]
#define MakeItem(descArg, valueArg) MakeItemWithVersion(descArg, valueArg, 0)

@implementation LKEnumListRegistryKeyValueItem

+ (instancetype)itemWithDesc:(NSString *)desc value:(long)value availableOSVersion:(NSInteger)osVersion {
    LKEnumListRegistryKeyValueItem *MakeItem = [LKEnumListRegistryKeyValueItem new];
    MakeItem.desc = desc;
    MakeItem.value = value;
    MakeItem.availableOSVersion = osVersion;
    return MakeItem;
}

@end;

@interface LKEnumListRegistry ()

@property(nonatomic, copy) NSDictionary<NSString *, NSArray<LKEnumListRegistryKeyValueItem *> *> *data;

@end

@implementation LKEnumListRegistry

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LKEnumListRegistry *instance = nil;
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
        NSMutableDictionary *mData = [NSMutableDictionary dictionary];
        
        mData[@"UIControlContentVerticalAlignment"] = @[MakeItem(@"UIControlContentVerticalAlignmentCenter", 0),
                                                        MakeItem(@"UIControlContentVerticalAlignmentTop", 1),
                                                        MakeItem(@"UIControlContentVerticalAlignmentBottom", 2),
                                                        MakeItem(@"UIControlContentVerticalAlignmentFill", 3)];
        
        mData[@"UIControlContentHorizontalAlignment"] = @[MakeItem(@"UIControlContentHorizontalAlignmentCenter", 0),
                                                          MakeItem(@"UIControlContentHorizontalAlignmentLeft", 1),
                                                          MakeItem(@"UIControlContentHorizontalAlignmentRight", 2),
                                                          MakeItem(@"UIControlContentHorizontalAlignmentFill", 3),
                                                          MakeItemWithVersion(@"UIControlContentHorizontalAlignmentLeading", 4, 11),
                                                          MakeItemWithVersion(@"UIControlContentHorizontalAlignmentTrailing", 5, 11)];
        
        mData[@"UIViewContentMode"] = @[MakeItem(@"UIViewContentModeScaleToFill", 0),
                                        MakeItem(@"UIViewContentModeScaleAspectFit", 1),
                                        MakeItem(@"UIViewContentModeScaleAspectFill", 2),
                                        MakeItem(@"UIViewContentModeRedraw", 3),
                                        MakeItem(@"UIViewContentModeCenter", 4),
                                        MakeItem(@"UIViewContentModeTop", 5),
                                        MakeItem(@"UIViewContentModeBottom", 6),
                                        MakeItem(@"UIViewContentModeLeft", 7),
                                        MakeItem(@"UIViewContentModeRight", 8),
                                        MakeItem(@"UIViewContentModeTopLeft", 9),
                                        MakeItem(@"UIViewContentModeTopRight", 10),
                                        MakeItem(@"UIViewContentModeBottomLeft", 11),
                                        MakeItem(@"UIViewContentModeBottomRight", 12)];
        
        mData[@"UIViewTintAdjustmentMode"] = @[MakeItem(@"UIViewTintAdjustmentModeAutomatic", 0),
                                               MakeItem(@"UIViewTintAdjustmentModeNormal", 1),
                                               MakeItem(@"UIViewTintAdjustmentModeDimmed", 2)];
        
        mData[@"NSTextAlignment"] = @[MakeItem(@"NSTextAlignmentLeft", 0),
                                      MakeItem(@"NSTextAlignmentCenter", 1),
                                      MakeItem(@"NSTextAlignmentRight", 2),
                                      MakeItem(@"NSTextAlignmentJustified", 3),
                                      MakeItem(@"NSTextAlignmentNatural", 4)];
        
        mData[@"NSLineBreakMode"] = @[MakeItem(@"NSLineBreakByWordWrapping", 0),
                                      MakeItem(@"NSLineBreakByCharWrapping", 1),
                                      MakeItem(@"NSLineBreakByClipping", 2),
                                      MakeItem(@"NSLineBreakByTruncatingHead", 3),
                                      MakeItem(@"NSLineBreakByTruncatingTail", 4),
                                      MakeItem(@"NSLineBreakByTruncatingMiddle", 5)];
        
        mData[@"UIScrollViewContentInsetAdjustmentBehavior"] = @[
            MakeItem(@"UIScrollViewContentInsetAdjustmentAutomatic", 0),
            MakeItem(@"UIScrollViewContentInsetAdjustmentScrollableAxes", 1),
            MakeItem(@"UIScrollViewContentInsetAdjustmentNever", 2),
            MakeItem(@"UIScrollViewContentInsetAdjustmentAlways", 3)];
        
        mData[@"UITableViewStyle"] = @[MakeItem(@"UITableViewStylePlain", 0),
                                       MakeItem(@"UITableViewStyleGrouped", 1)];
        
        mData[@"UITextFieldViewMode"] = @[MakeItem(@"UITextFieldViewModeNever", 0),
                                          MakeItem(@"UITextFieldViewModeWhileEditing", 1),
                                          MakeItem(@"UITextFieldViewModeUnlessEditing", 2),
                                          MakeItem(@"UITextFieldViewModeAlways", 3)];
        
        mData[@"UIAccessibilityNavigationStyle"] = @[
            MakeItem(@"UIAccessibilityNavigationStyleAutomatic", 0),
            MakeItem(@"UIAccessibilityNavigationStyleSeparate", 1),
            MakeItem(@"UIAccessibilityNavigationStyleCombined", 2)];
        
        mData[@"QMUIButtonImagePosition"] = @[
            MakeItem(@"QMUIButtonImagePositionTop", 0),
            MakeItem(@"QMUIButtonImagePositionLeft", 1),
            MakeItem(@"QMUIButtonImagePositionBottom", 2),
            MakeItem(@"QMUIButtonImagePositionRight", 3)];
        
        mData[@"UITableViewCellSeparatorStyle"] = @[
            MakeItem(@"UITableViewCellSeparatorStyleNone", 0),
            MakeItem(@"UITableViewCellSeparatorStyleSingleLine", 1),
            MakeItem(@"UITableViewCellSeparatorStyleSingleLineEtched", 2)];
        
        mData[@"UIBlurEffectStyle"] = @[
            MakeItem(@"UIBlurEffectStyleExtraLight", 0),
            MakeItem(@"UIBlurEffectStyleLight", 1),
            MakeItem(@"UIBlurEffectStyleDark", 2),
//            MakeItem(@"UIBlurEffectStyleExtraDark", 3), // 该值被官方标注了 API_UNAVAILABLE(ios)，因此这里跳过
            MakeItemWithVersion(@"UIBlurEffectStyleRegular", 4, 10),
            MakeItemWithVersion(@"UIBlurEffectStyleProminent", 5, 10),
            MakeItemWithVersion(@"UIBlurEffectStyleSystemUltraThinMaterial", 6, 13),
            MakeItemWithVersion(@"UIBlurEffectStyleSystemThinMaterial", 7, 13),
            MakeItemWithVersion(@"UIBlurEffectStyleSystemMaterial", 8, 13),
            MakeItemWithVersion(@"UIBlurEffectStyleSystemThickMaterial", 9, 13),
            MakeItemWithVersion(@"UIBlurEffectStyleSystemChromeMaterial", 10, 13),
            MakeItemWithVersion(@"UIBlurEffectStyleSystemUltraThinMaterialLight", 11, 13),
            MakeItemWithVersion(@"UIBlurEffectStyleSystemThinMaterialLight", 12, 13),
            MakeItemWithVersion(@"UIBlurEffectStyleSystemMaterialLight", 13, 13),
            MakeItemWithVersion(@"UIBlurEffectStyleSystemThickMaterialLight", 14, 13),
            MakeItemWithVersion(@"UIBlurEffectStyleSystemChromeMaterialLight", 15, 13),
            MakeItemWithVersion(@"UIBlurEffectStyleSystemUltraThinMaterialDark", 16, 13),
            MakeItemWithVersion(@"UIBlurEffectStyleSystemThinMaterialDark", 17, 13),
            MakeItemWithVersion(@"UIBlurEffectStyleSystemMaterialDark", 18, 13),
            MakeItemWithVersion(@"UIBlurEffectStyleSystemThickMaterialDark", 19, 13),
            MakeItemWithVersion(@"UIBlurEffectStyleSystemChromeMaterialDark", 20, 13),
        ];
        
        mData[@"UILayoutConstraintAxis"] = @[
            MakeItem(@"UILayoutConstraintAxisHorizontal", 0),
            MakeItem(@"UILayoutConstraintAxisVertical", 1),
        ];
        
        mData[@"UIStackViewDistribution"] = @[
            MakeItem(@"UIStackViewDistributionFill", 0),
            MakeItem(@"UIStackViewDistributionFillEqually", 1),
            MakeItem(@"UIStackViewDistributionFillProportionally", 2),
            MakeItem(@"UIStackViewDistributionEqualSpacing", 3),
            MakeItem(@"UIStackViewDistributionEqualCentering", 4)
        ];
        
        mData[@"UIStackViewAlignment"] = @[
            MakeItem(@"UIStackViewAlignmentFill", 0),
            MakeItem(@"UIStackViewAlignmentLeading (Top)", 1),
            MakeItem(@"UIStackViewAlignmentFirstBaseline", 2),
            MakeItem(@"UIStackViewAlignmentCenter", 3),
            MakeItem(@"UIStackViewAlignmentTrailing (Bottom)", 4),
            MakeItem(@"UIStackViewAlignmentLastBaseline", 5)
        ];
        
        self.data = mData;
    }
    return self;
}

- (NSArray<LKEnumListRegistryKeyValueItem *> *)itemsForEnumName:(NSString *)enumName {
    NSArray<LKEnumListRegistryKeyValueItem *> *items = self.data[enumName];
    return items;
}

- (NSString *)descForEnumName:(NSString *)enumName value:(long)value {
    NSArray<LKEnumListRegistryKeyValueItem *> *items = [self itemsForEnumName:enumName];
    if (!items) {
        NSAssert(NO, @"");
        return nil;
    }
    LKEnumListRegistryKeyValueItem *MakeItem = [items lookin_firstFiltered:^BOOL(LKEnumListRegistryKeyValueItem *obj) {
        return (obj.value == value);
    }];
    return MakeItem.desc;
}

@end
