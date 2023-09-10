//
//  LKConsoleDataSource.h
//  Lookin
//
//  Created by Li Kai on 2019/6/1.
//  https://lookin.work
//

#import <Foundation/Foundation.h>

@class LKConsoleDataSourceRowItem, LookinObject, LKHierarchyDataSource;

@interface LKConsoleDataSource : NSObject

- (instancetype)initWithHierarchyDataSource:(LKHierarchyDataSource *)hierarchyDataSource;

@property(nonatomic, copy) NSArray<LKConsoleDataSourceRowItem *> *rowItems;

@property(nonatomic, strong, readonly) LookinObject *currentObject;
- (RACSignal *)makeObjectAsCurrent:(LookinObject *)obj;
- (NSArray<NSString *> *)currentObjectSelectorNameList;

- (RACSignal *)submit:(NSString *)text;
- (RACSignal *)submitWithObj:(LookinObject *)obj text:(NSString *)text;

/// 越晚被加入的 object 在 recentObjects 数组中的 idx 越小，tuple.first 是 LookinObject，tuple.second 是当初返回这个对象时输入的命令文字
@property(nonatomic, strong, readonly) NSMutableArray<RACTwoTuple *> *recentObjects;

/// 当前在主窗口中高亮选择的 View/Layer/ViewController 对象
@property(nonatomic, strong, readonly) NSArray<LookinObject *> *selectedObjects;

/// 清空记录
- (void)clearHistoryContents;

/// 当 console 被显示和隐藏时请及时设置该属性，当该属性为 YES 时，该 dataSource 会自动拉取当前所选 UI 对象的数据（当 syncConsoleTarget 为 YES 时）
@property(nonatomic, assign) BOOL isShowingConsole;

@end
