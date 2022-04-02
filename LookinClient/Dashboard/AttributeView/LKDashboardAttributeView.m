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
