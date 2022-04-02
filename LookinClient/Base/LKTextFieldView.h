//
//  LKTextFieldView.h
//  Lookin
//
//  Created by Li Kai on 2019/2/27.
//  https://lookin.work
//

#import "LKBaseView.h"

@interface LKTextFieldView : LKBaseView

+ (instancetype)labelView;

@property(nonatomic, strong, readonly) NSTextField *textField;

@property(nonatomic, assign) NSEdgeInsets insets;

@property(nonatomic, strong) LKTwoColors *textColors;

@property(nonatomic, strong) NSImage *image;

/// 调用该方法后，当输入框内有文字时右侧会有 closeButton
- (void)initCloseButton;
@property(nonatomic, strong, readonly) NSButton *closeButton;

@end
