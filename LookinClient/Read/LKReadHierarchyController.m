//
//  LKReadHierarchyController.m
//  Lookin
//
//  Created by Li Kai on 2019/5/13.
//  https://lookin.work
//

#import "LKReadHierarchyController.h"
#import "LKReadHierarchyDataSource.h"
#import "LookinDisplayItem.h"

@interface LKReadHierarchyController ()

@end

@implementation LKReadHierarchyController

- (void)hierarchyView:(LKHierarchyView *)view needToCancelPreviewOfItem:(LookinDisplayItem *)item {
    item.noPreview = YES;
    [((LKReadHierarchyDataSource *)self.dataSource).itemDidChangeNoPreview sendNext:nil];
}

- (void)hierarchyView:(LKHierarchyView *)view needToShowPreviewOfItem:(LookinDisplayItem *)item {
    [item enumerateSelfAndAncestors:^(LookinDisplayItem *item, BOOL *stop) {
        if (item.noPreview) {
            item.noPreview = NO;
        }
    }];
    [((LKReadHierarchyDataSource *)self.dataSource).itemDidChangeNoPreview sendNext:nil];
}

@end
