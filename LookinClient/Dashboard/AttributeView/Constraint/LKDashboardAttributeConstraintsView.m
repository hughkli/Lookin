//
//  LKDashboardAttributeConstraintsView.m
//  Lookin
//
//  Created by Li Kai on 2019/9/12.
//  https://lookin.work
//

#import "LKDashboardAttributeConstraintsView.h"
#import "LookinObject.h"
#import "LKDashboardAttributeConstraintsItemControl.h"
#import "LookinAutoLayoutConstraint.h"
#import "LKConstraintPopoverController.h"
#import "LKDashboardViewController.h"
#import "LKHierarchyDataSource.h"
#import "LookinDisplayItem.h"

@interface LKDashboardAttributeConstraintsView ()

@property(nonatomic, strong) NSMutableArray<LKDashboardAttributeConstraintsItemControl *> *textControls;

@end

@implementation LKDashboardAttributeConstraintsView {
    CGFloat _verInterSpace;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _verInterSpace = 8;
        
        self.textControls = [NSMutableArray array];
    }
    return self;
}

- (void)renderWithAttribute {
    [super renderWithAttribute];
    
    NSArray<LookinAutoLayoutConstraint *> *rawData = self.attribute.value;
    NSArray<LookinAutoLayoutConstraint *> *sortedRawData = [self _sortedRawDataFromData:rawData];
    
    [self.textControls lookin_dequeueWithCount:sortedRawData.count add:^LKDashboardAttributeConstraintsItemControl *(NSUInteger idx) {
        LKDashboardAttributeConstraintsItemControl *control = [LKDashboardAttributeConstraintsItemControl new];
        [control addTarget:self clickAction:@selector(_handleClickItem:)];
        [self addSubview:control];
        return control;
        
    } notDequeued:^(NSUInteger idx, LKDashboardAttributeConstraintsItemControl *control) {
        control.hidden = YES;
        
    } doNext:^(NSUInteger idx, LKDashboardAttributeConstraintsItemControl *control) {
        control.hidden = NO;
        control.constraint = sortedRawData[idx];
        [control setNeedsLayout:YES];
    }];
    [self setNeedsLayout:YES];
}

- (void)layout {
    [super layout];
    
    __block CGFloat y = 0;
    [self.textControls enumerateObjectsUsingBlock:^(LKTextControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.hidden) {
            return;
        }
        $(obj).fullFrame.heightToFit.y(y);
        y = obj.$maxY + self->_verInterSpace;
    }];
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    NSArray<LKTextControl *> *visibleControls = [self.textControls lookin_filter:^BOOL(LKTextControl *obj) {
        return !obj.hidden;
    }];
    limitedSize.height = [visibleControls lookin_reduceCGFloat:^CGFloat(CGFloat accumulator, NSUInteger idx, LKTextControl *obj) {
        CGFloat labelHeight = [obj sizeThatFits:limitedSize].height;
        accumulator += labelHeight;
        if (idx) {
            accumulator += self->_verInterSpace;
        }
        return accumulator;
    } initialAccumlator:0];
    return limitedSize;
}

- (NSArray<LookinAutoLayoutConstraint *> *)_sortedRawDataFromData:(NSArray<LookinAutoLayoutConstraint *> *)rawData {
    return [rawData sortedArrayUsingComparator:^NSComparisonResult(LookinAutoLayoutConstraint *obj1, LookinAutoLayoutConstraint *obj2) {
        if (obj1.effective != obj2.effective) {
            if (obj1.effective) {
                return NSOrderedAscending;
            } else {
                return NSOrderedDescending;
            }
        }
        
        if (obj1.firstItemType > obj2.firstItemType) {
            return NSOrderedDescending;
        } else if (obj1.firstItemType < obj2.firstItemType) {
            return NSOrderedAscending;
        }
        
        if (obj1.firstAttribute > obj2.firstAttribute) {
            return NSOrderedDescending;
        } else if (obj1.firstAttribute < obj2.firstAttribute) {
            return NSOrderedAscending;
        }
        
        return NSOrderedSame;
    }];
}

- (void)_handleClickItem:(LKDashboardAttributeConstraintsItemControl *)control {
    LookinAutoLayoutConstraint *constraint = control.constraint;
    LKConstraintPopoverController *vc = [[LKConstraintPopoverController alloc] initWithConstraint:constraint];
    
    NSPopover *popover = [[NSPopover alloc] init];
    popover.animates = NO;
    popover.behavior = NSPopoverBehaviorTransient;
    popover.contentSize = [vc contentSize];
    popover.contentViewController = vc;
    @weakify(popover);
    vc.requestJumpingToObject = ^(LookinObject *lookinObj) {
        @strongify(popover);
        [popover close];
        
        LKHierarchyDataSource *dataSource = [self.dashboardViewController currentDataSource];
        LookinDisplayItem *item = [dataSource displayItemWithOid:lookinObj.oid];
        // 注意这里要先 expand 然后再 select 以使得可以滚动到目标位置
        if (!item.displayingInHierarchy) {
            [dataSource expandToShowItem:item];
        }
        dataSource.selectedItem = item;
    };
    [popover showRelativeToRect:NSMakeRect(0, 0, control.bounds.size.width, control.bounds.size.height) ofView:control preferredEdge:NSRectEdgeMaxX];
}

@end
