//
//  LKTextsMenuView.h
//  Lookin
//
//  Created by Li Kai on 2019/8/14.
//  https://lookin.work
//

#import "LKBaseView.h"

typedef NS_ENUM(NSInteger, LKTextsMenuViewType) {
    LKTextsMenuViewTypeJustified, // 左侧文字左对齐，右侧文字右对齐
    LKTextsMenuViewTypeCenter   // 居中显示
};

@interface LKTextsMenuView : LKBaseView

/// 默认为 {0, 3, 0, 3}
@property(nonatomic, assign) NSEdgeInsets insets;

@property(nonatomic, assign) LKTextsMenuViewType type;

@property(nonatomic, copy) NSArray<LookinStringTwoTuple *> *texts;

@property(nonatomic, strong) NSFont *font;

/// 默认为 2
@property(nonatomic, assign) CGFloat verSpace;
/// 默认为 10
@property(nonatomic, assign) CGFloat horSpace;

/// 在某一行的右侧加一个按钮，业务自己负责这个 button 的点击事件之类的
- (void)addButton:(NSButton *)button atIndex:(NSUInteger)idx;

@end
