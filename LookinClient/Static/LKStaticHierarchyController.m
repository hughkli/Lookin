//
//  LKHierarchyViewController.m
//  Lookin
//
//  Created by Li Kai on 2018/8/4.
//  https://lookin.work
//

#import "LKStaticHierarchyController.h"
#import "LKStaticHierarchyDataSource.h"
#import "LookinDisplayItem.h"

@implementation LKStaticHierarchyController

#pragma mark - LKHierarchyViewDelegate

- (void)hierarchyView:(LKHierarchyView *)view needToCancelPreviewOfItem:(LookinDisplayItem *)item {
    item.noPreview = YES;
    [((LKStaticHierarchyDataSource *)self.dataSource).itemDidChangeNoPreview sendNext:nil];
}

- (void)hierarchyView:(LKHierarchyView *)view needToShowPreviewOfItem:(LookinDisplayItem *)item {
    [item enumerateSelfAndAncestors:^(LookinDisplayItem *item, BOOL *stop) {
        if (item.noPreview) {
            item.noPreview = NO;
        }
    }];
    [((LKStaticHierarchyDataSource *)self.dataSource).itemDidChangeNoPreview sendNext:nil];
}

@end
