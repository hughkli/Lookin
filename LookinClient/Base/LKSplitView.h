//
//  LKSplitView.h
//  Lookin
//
//  Created by Li Kai on 2018/11/4.
//  https://lookin.work
//

#import <Cocoa/Cocoa.h>

@interface LKSplitView : NSSplitView

@property(nonatomic, copy) void (^didFinishFirstLayout)(LKSplitView *view);

@end
