//
//  LKTableRowView.h
//  Lookin
//
//  Created by Li Kai on 2019/4/20.
//  https://lookin.work
//

#import <Cocoa/Cocoa.h>

@interface LKTableRowView : NSTableRowView

@property(nonatomic, strong, readonly) LKLabel *titleLabel;
@property(nonatomic, strong, readonly) LKLabel *subtitleLabel;

@property(nonatomic, assign) BOOL isSelected;
@property(nonatomic, assign) BOOL isHovered;

@property(nonatomic, assign, readonly) BOOL isDarkMode;
/// 子类可在该方法里更新 UI
- (void)setIsDarkMode:(BOOL)isDarkMode NS_REQUIRES_SUPER;

/// 如果 LKTableView 的 canScrollHorizontally 为 YES，则 LKTableRowView 的子类要在渲染数据后手动设置该值。如果 canScrollHorizontally 为 NO，则无需设置该属性
@property(nonatomic, assign) CGFloat contentWidth;


@end

@interface LKTableBlankRowView : LKTableRowView

@end
