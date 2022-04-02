//
//  LKNumberInputView.h
//  Lookin
//
//  Created by Li Kai on 2019/2/22.
//  https://lookin.work
//

#import "LKBaseView.h"
#import "LookinAttrType.h"

typedef NS_ENUM(NSUInteger, LKNumberInputViewStyle) {
    LKNumberInputViewStyleHorizontal,    // titleLabel 在输入框内部的右侧
    LKNumberInputViewStyleVertical     // titleLabel 在输入框的下面
};

@class LKTextFieldView;

extern const CGFloat LKNumberInputHorizontalHeight;
extern const CGFloat LKNumberInputVerticalHeight;

@interface LKNumberInputView : LKBaseView

@property(nonatomic, assign) LKNumberInputViewStyle viewStyle;

@property(nonatomic, copy) NSString *title;

@property(nonatomic, strong, readonly) LKTextFieldView *textFieldView;

/// 将当前 string 转换成 attrType 格式的对象并返回，如果返回 nil 则说明转换失败
+ (id)parsedValueWithString:(NSString *)string attrType:(LookinAttrType)attrType;

@end
