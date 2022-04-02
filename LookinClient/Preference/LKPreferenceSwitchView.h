//
//  LKPreferenceSwitchView.h
//  Lookin
//
//  Created by Li Kai on 2019/2/28.
//  https://lookin.work
//

#import "LKBaseView.h"

@interface LKPreferenceSwitchView : LKBaseView

- (instancetype)initWithTitle:(NSString *)title checkedMessage:(NSString *)checkedMessage uncheckedMessage:(NSString *)uncheckedMessage;
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message;

@property(nonatomic, assign) BOOL isChecked;
@property(nonatomic, copy) void (^didChange)(BOOL isChecked);

@end
