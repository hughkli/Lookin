//
//  LKMethodTraceLaunchView.h
//  Lookin
//
//  Created by Li Kai on 2019/6/27.
//  https://lookin.work
//

#import "LKBaseView.h"

@interface LKMethodTraceLaunchView : LKBaseView

@property(nonatomic, assign) BOOL showTutorial;

@property(nonatomic, copy) void (^didClickContinue)(void);

@end
