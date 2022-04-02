//
//  LKConsoleDataSourceRowItem.h
//  Lookin
//
//  Created by Li Kai on 2019/6/1.
//  https://lookin.work
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LKConsoleDataSourceRowItemType) {
    LKConsoleDataSourceRowItemTypeInput,
    LKConsoleDataSourceRowItemTypeSubmit,
    LKConsoleDataSourceRowItemTypeReturn,
};

@interface LKConsoleDataSourceRowItem : NSObject

@property(nonatomic, assign) LKConsoleDataSourceRowItemType type;

/// 仅 type 为 LKConsoleDataSourceRowItemTypeReturn 时，该属性有效
@property(nonatomic, copy) NSString *highlightText;

@property(nonatomic, copy) NSString *normalText;

@end
