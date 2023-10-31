//
//  LKDashboardSectionViewPool.h
//  LookinClient
//
//  Created by LikaiMacStudioWork on 2023/10/31.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LookinAttributesSection.h"
#import "LKDashboardSectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LKDashboardSectionViewPool : NSObject

- (void)recycleAll;

- (LKDashboardSectionView *)dequeViewForSection:(LookinAttributesSection *)section;

@end

NS_ASSUME_NONNULL_END
