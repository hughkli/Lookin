//
//  LKPreferencePopupView.h
//  Lookin
//
//  Created by Li Kai on 2019/2/28.
//  https://lookin.work
//

#import "LKBaseView.h"

@interface LKPreferencePopupView : LKBaseView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message options:(NSArray<NSString *> *)options;

- (instancetype)initWithTitle:(NSString *)title messages:(NSArray<NSString *> *)messages options:(NSArray<NSString *> *)options;

@property(nonatomic, assign) NSUInteger selectedIndex;
@property(nonatomic, copy) void (^didChange)(NSUInteger selectedIndex);

@property(nonatomic, assign) BOOL isEnabled;

@property(nonatomic, assign) CGFloat buttonX;

@end
