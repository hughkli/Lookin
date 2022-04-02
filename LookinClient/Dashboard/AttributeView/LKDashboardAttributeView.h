//
//  LKDashboardAttributeView.h
//  Lookin
//
//  Created by Li Kai on 2018/11/18.
//  https://lookin.work
//

#import "LookinAttribute.h"
#import "LookinDefines.h"
#import "LookinAttributesGroup.h"

@class LookinDisplayItem, LKDashboardAttributeValueView, LKDashboardViewController;

@interface LKDashboardAttributeView : LKBaseView

@property(nonatomic, strong) LookinAttribute *attribute;

@property(nonatomic, strong) id valueView;

@property(nonatomic, weak) LKDashboardViewController *dashboardViewController;

- (BOOL)canEdit;

@end

/// 除了下面这两个方法外，子类还需要继承重写 sizeThatFits: 方法
@interface LKDashboardAttributeView (NSSubclassingHooks)

/// 方法实现应该是读取 self.attribute 并渲染
- (void)renderWithAttribute;

/// 每行可以摆放该 AttrView 的数量，返回 1 则表示独占一行，返回 0 表示宽度根据内容的变化而变化。子类不重写则默认为 1
- (NSUInteger)numberOfColumnsOccupied;

@end
