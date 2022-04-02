//
//  LKHierarchyRowView.h
//  Lookin
//
//  Created by Li Kai on 2018/8/4.
//  https://lookin.work
//

#import "LKOutlineRowView.h"

@class LookinDisplayItem;

@interface LKHierarchyRowView : LKOutlineRowView

/// 注意这里是 weak，因为 tableView 会缓存很多 rowView（macOS 下的 tableView 要比 iOS 里的 tableView 缓存的更多，因为屏幕大），如果这里是 strong 的话会导致 displayItem 不能随着 hierarchy reload 而被及时释放，而 displayItem 又 retain 了很多 image 这种占内存的东西，所以这里要写成 weak
@property(nonatomic, weak) LookinDisplayItem *displayItem;

/// 左侧的小蓝条图标
@property(nonatomic, strong, readonly) NSButton *eventHandlerButton;

@end
