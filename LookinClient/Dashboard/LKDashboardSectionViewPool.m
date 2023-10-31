//
//  LKDashboardSectionViewPool.m
//  LookinClient
//
//  Created by LikaiMacStudioWork on 2023/10/31.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "LKDashboardSectionViewPool.h"
#import "LookinAttributesSection+LookinClient.h"
#import "LookinAttribute.h"

@interface LKDashboardSectionViewPool ()

/// 已经被使用的 views，不可以再 dequeue 了
@property(nonatomic, strong) NSMutableSet<LKDashboardSectionView *> *dequeuedViews;
/// 无论是否 dequeue，都会保存在这里
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<LKDashboardSectionView *> *> *cache;

@end

@implementation LKDashboardSectionViewPool

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dequeuedViews = [NSMutableSet set];
        self.cache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)recycleAll {
    [self.dequeuedViews removeAllObjects];
}

- (LKDashboardSectionView *)dequeViewForSection:(LookinAttributesSection *)section {
    NSString *key = [self cacheKeyForSection:section];
    if (!self.cache[key]) {
        self.cache[key] = [NSMutableArray array];
    }
    for (LKDashboardSectionView *v in self.cache[key]) {
        if ([self.dequeuedViews containsObject:v]) {
            continue;
        }
        [self.dequeuedViews addObject:v];
        return v;
    }
    LKDashboardSectionView *newView = [LKDashboardSectionView new];
    [self.dequeuedViews addObject:newView];
    [self.cache[key] addObject:newView];
    return newView;
}

- (NSString *)cacheKeyForSection:(LookinAttributesSection *)section {
    if (!section.isUserCustom) {
        return [section identifier];
    }
    NSString *key = [[section.attributes lookin_map:^id(NSUInteger idx, LookinAttribute *value) {
        return value.displayTitle;
    }] componentsJoinedByString:@","];
    return key;
}

@end
