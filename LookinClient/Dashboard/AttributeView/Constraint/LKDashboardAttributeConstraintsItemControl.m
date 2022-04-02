//
//  LKDashboardAttributeConstraintsItemControl.m
//  Lookin
//
//  Created by Li Kai on 2019/9/28.
//  https://lookin.work
//

#import "LKDashboardAttributeConstraintsItemControl.h"
#import "LookinAutoLayoutConstraint.h"
#import "LookinObject.h"

@implementation LKDashboardAttributeConstraintsItemControl

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        @weakify(self);
        self.label.alignment = NSTextAlignmentLeft;
        self.label.font = NSFontMake(12);
        self.didChangeAppearance = ^(LKBaseControl *control, BOOL isDarkMode) {
            @strongify(self);
            [self _updateLabelColor];
        };
    }
    return self;
}

- (void)setConstraint:(LookinAutoLayoutConstraint *)constraint {
    _constraint = constraint;
    self.label.stringValue = [self _stringFromConstraint:constraint];
    [self _updateLabelColor];
}

- (void)_updateLabelColor {
    if (self.constraint.effective) {
        self.label.textColor = [NSColor labelColor];
    } else {
        if ([self.effectiveAppearance lk_isDarkMode]) {
            self.label.textColor = LookinColorMake(130, 131, 132);
        } else {
            self.label.textColor = LookinColorMake(150, 151, 152);
        }
    }
}

- (NSString *)_stringFromConstraint:(LookinAutoLayoutConstraint *)constraint {
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"%@.%@ %@",
     [LookinAutoLayoutConstraint descriptionWithItemObject:constraint.firstItem type:constraint.firstItemType detailed:NO],
     [LookinAutoLayoutConstraint descriptionWithAttribute:constraint.firstAttribute],
     [LookinAutoLayoutConstraint symbolWithRelation:constraint.relation]];
    
    if (constraint.secondAttribute == 0) {
        [string appendFormat:@" %@", [NSString lookin_stringFromDouble:constraint.constant decimal:3]];
    } else {
        [string appendFormat:@" %@.%@",
         [LookinAutoLayoutConstraint descriptionWithItemObject:constraint.secondItem type:constraint.secondItemType detailed:NO],
         [LookinAutoLayoutConstraint descriptionWithAttribute:constraint.secondAttribute]];
        
        if (constraint.multiplier != 1) {
            [string appendFormat:@" * %@", [NSString lookin_stringFromDouble:constraint.multiplier decimal:3]];
        }
        if (constraint.constant > 0) {
            [string appendFormat:@" + %@", [NSString lookin_stringFromDouble:constraint.constant decimal:3]];
        } else if (constraint.constant < 0) {
            [string appendFormat:@" - %@", [NSString lookin_stringFromDouble:-constraint.constant decimal:3]];
        }
    }
    
    if (constraint.priority != 1000) {
        [string appendFormat:@" @ %@", @(constraint.priority)];
    }
    
    return string;
}

- (BOOL)shouldTrackMouseEnteredAndExited {
    return YES;
}

- (void)mouseEntered:(NSEvent *)event {
    [super mouseEntered:event];
    self.alphaValue = .5;
}

- (void)mouseExited:(NSEvent *)event {
    [super mouseExited:event];
    self.alphaValue = 1;
}

@end
