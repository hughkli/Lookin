//
//  LKTableRowView.h
//  Lookin
//
//  Created by Li Kai on 2019/4/20.
//  https://lookin.work
//

#import <Cocoa/Cocoa.h>

@class LKTableViewHorizontalScrollWidthManager;

@interface LKTableRowView : NSTableRowView

@property(nonatomic, strong, readonly) LKLabel *titleLabel;
@property(nonatomic, strong, readonly) LKLabel *subtitleLabel;

@property(nonatomic, assign) BOOL isSelected;
@property(nonatomic, assign) BOOL isHovered;

@property(nonatomic, assign, readonly) BOOL isDarkMode;
/// 子类可在该方法里更新 UI
- (void)setIsDarkMode:(BOOL)isDarkMode NS_REQUIRES_SUPER;

@property(nonatomic, weak) LKTableViewHorizontalScrollWidthManager* horizontalScrollWidthManager;

@end

@interface LKTableBlankRowView : LKTableRowView

@end
