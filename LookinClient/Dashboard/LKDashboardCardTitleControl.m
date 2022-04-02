//
//  LKDashboardCardTitleControl.m
//  Lookin
//
//  Created by Li Kai on 2019/4/13.
//  https://lookin.work
//

#import "LKDashboardCardTitleControl.h"

@interface LKDashboardCardTitleControl ()

@end

@implementation LKDashboardCardTitleControl

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
//        self.layer.borderWidth = 1;
//        self.layer.borderColor = [NSColor redColor].CGColor;
        
        _iconImageView = [NSImageView new];
        [self addSubview:self.iconImageView];
        
        _label = [LKLabel new];
        self.label.textColor = [NSColor labelColor];
        self.label.font = NSFontMake(13);
        [self addSubview:self.label];
        
        _disclosureImageView = [NSImageView new];
        [self addSubview:self.disclosureImageView];
    }
    return self;
}

- (void)layout {
    [super layout];
    
    $(self.iconImageView).sizeToFit.verAlign.x(DashboardHorInset).offsetY(-1);
    $(self.label).sizeToFit.verAlign.offsetY(-1).x(self.iconImageView.$maxX + 3);
    $(self.disclosureImageView).sizeToFit.verAlign.x(self.label.$maxX + 3);
    
//    $(self.iconImageView, self.label, self.disclosureImageView).groupHorAlign;
}

@end
