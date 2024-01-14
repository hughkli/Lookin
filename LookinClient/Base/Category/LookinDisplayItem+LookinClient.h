//
//  LookinDisplayItem+LookinClient.h
//  LookinClient
//
//  Created by likaimacbookhome on 2023/11/1.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "LookinDisplayItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface LookinDisplayItem (LookinClient)

/// 该 item 在左侧 hierarchy 中显示的字符串，通常是类名
- (NSString *)title;

- (NSString *)subtitle;

/// className 以 “UI”、“CA” 等开头时认为是系统类，该属性将返回 YES
@property(nonatomic, assign, readonly) BOOL representedForSystemClass;

- (BOOL)isUserCustom;

/// 是否有能力显示图层框
- (BOOL)hasPreviewBoxAbility;

- (BOOL)hasValidFrameToRoot;

/// 当 hasValidFrameToRoot 返回 NO 时，该方法返回的值无意义
- (CGRect)calculateFrameToRoot;

/// 在 string 这个搜索词下，如果该 displayItem 应该被搜索到，则该方法返回 YES。
/// string 字段不能为 nil 或空字符串
- (BOOL)isMatchedWithSearchString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
