//
//  LKHierarchyDataSource+KeyDown.m
//  LookinClient
//
//  Created by Hares on 7/17/23.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "LKHierarchyDataSource+KeyDown.h"
#import "LookinDisplayItem.h"

@implementation LKHierarchyDataSource (KeyDown)

- (BOOL)keyDown:(NSEvent *)event {
    LookinDisplayItem *currentItem = self.selectedItem;
    NSInteger selectedRowIdx = [self.displayingFlatItems indexOfObject:self.selectedItem];
    if (selectedRowIdx == NSNotFound) {
        return false;
    }

    switch (event.keyCode) {
        case 125: {  // down
            LookinDisplayItem *willSelectedItem = [self.displayingFlatItems lookin_safeObjectAtIndex:selectedRowIdx + 1];
            if (willSelectedItem) {
                self.selectedItem = willSelectedItem;
                return true;
            }
        } break;
        case 126: { // up
            LookinDisplayItem *willSelectedItem = [self.displayingFlatItems lookin_safeObjectAtIndex:selectedRowIdx - 1];
            if (willSelectedItem) {
                self.selectedItem = willSelectedItem;
                return true;
            }
        } break;
        case 123: { // left
            if (currentItem.isExpandable && currentItem.isExpanded) {
                [self collapseItem:currentItem];
                return true;
            } else if (currentItem.superItem && [self.displayingFlatItems indexOfObject:currentItem.superItem] != NSNotFound) {
                [self collapseItem:currentItem.superItem];
                self.selectedItem = currentItem.superItem;
                return true;
            }
        } break;
        case 124: { // right
            if (currentItem.isExpandable && !currentItem.isExpanded) {
                [self expandItem:self.selectedItem];
                return true;
            } else {
                NSArray<LookinDisplayItem *> *displayItems = self.displayingFlatItems.copy;
                for (NSInteger i = selectedRowIdx + 1; i < displayItems.count; i++) {
                    LookinDisplayItem *next = displayItems[i];
                    if (!next.inHiddenHierarchy) {
                        self.selectedItem = next;
                        return true;
                    }
                }
            }
        } break;
        default:
            break;
    }

    return false;
}
@end
