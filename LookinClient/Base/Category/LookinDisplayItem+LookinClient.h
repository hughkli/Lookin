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

- (BOOL)isUserCustom;

/// 是否有能力显示图层框
- (BOOL)hasPreviewBoxAbility;

- (BOOL)hasValidFrameToRoot;

/// 当 hasValidFrameToRoot 返回 NO 时，该方法返回的值无意义
- (CGRect)calculateFrameToRoot;


@end

NS_ASSUME_NONNULL_END
