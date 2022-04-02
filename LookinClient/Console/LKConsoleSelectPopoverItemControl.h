//
//  LKConsoleSelectPopoverItemControl.h
//  Lookin
//
//  Created by Li Kai on 2019/6/19.
//  https://lookin.work
//

#import "LKBaseControl.h"

@class LookinObject;

@interface LKConsoleSelectPopoverItemControl : LKBaseControl

@property(nonatomic, assign) BOOL isChecked;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;

@property(nonatomic, strong) LookinObject *representedObject;

@end
