//
//  LKDashboardAttributeView.m
//  Lookin
//
//  Created by Li Kai on 2018/11/18.
//  https://lookin.work
//

#import "LKDashboardAttributeView.h"
#import "LookinDisplayItem.h"
#import "LKDashboardViewController.h"
#import "LookinDashboardBlueprint.h"

@implementation LKDashboardAttributeView

- (void)setAttribute:(LookinAttribute *)attribute {
    _attribute = attribute;
    [self renderWithAttribute];
}

- (BOOL)canEdit {
    if (self.attribute.isUserCustom) {
        if (self.attribute.customSetterID.length > 0) {
            return YES;
        } else {
            return NO;            
        }
    }
    SEL setter = [LookinDashboardBlueprint setterWithAttrID:self.attribute.identifier];
    return setter && self.dashboardViewController.isStaticMode;
}

- (void)renderWithAttribute {
    // do nothing
}

- (NSUInteger)numberOfColumnsOccupied {
    return 1;
}

@end
