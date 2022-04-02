//
//  LKLaunchAppView.h
//  Lookin
//
//  Created by Li Kai on 2018/11/3.
//  https://lookin.work
//

#import "LKBaseView.h"

@class LKInspectableApp;

@interface LKLaunchAppView : LKBaseControl

/// 默认为 NO
@property(nonatomic, assign) BOOL compactLayout;

@property(nonatomic, strong) LKInspectableApp *app;

@end
