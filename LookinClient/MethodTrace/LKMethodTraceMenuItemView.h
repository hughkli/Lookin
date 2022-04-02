//
//  LKMethodTraceMenuItemView.h
//  Lookin
//
//  Created by Li Kai on 2019/5/24.
//  https://lookin.work
//

#import "LKBaseView.h"

@class LKMethodTraceMenuItemView;

@protocol LKMethodTraceMenuItemViewDelegate <NSObject>

- (void)methodTraceMenuItemViewDidClickDelete:(LKMethodTraceMenuItemView *)view;

@end

@interface LKMethodTraceMenuItemView : LKBaseView

// 如果为 YES 表示代表一个 Class，如果为 NO 则代表一个 Method
@property(nonatomic, assign) BOOL representedAsClass;

@property(nonatomic, copy) NSString *representedClassName;
@property(nonatomic, copy) NSString *representedSelName;

@property(nonatomic, weak) id<LKMethodTraceMenuItemViewDelegate> delegate;

@end
