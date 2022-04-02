//
//  LKConsoleInputRowView.h
//  Lookin
//
//  Created by Li Kai on 2019/6/1.
//  https://lookin.work
//

#import "LKTableRowView.h"

@class LKConsoleDataSource;

@interface LKConsoleInputRowView : LKTableRowView

- (instancetype)initWithDataSource:(LKConsoleDataSource *)dataSource;

- (void)makeTextFieldAsFirstResponder;

@end
