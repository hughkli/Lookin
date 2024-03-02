//
//  LKDashboardAttributeNumberInputView.m
//  Lookin
//
//  Created by Li Kai on 2019/2/21.
//  https://lookin.work
//

#import "LKDashboardAttributeNumberInputView.h"
#import "LKNumberInputView.h"
#import "LKTextFieldView.h"
#import "LKDashboardCardView.h"
#import "LKDashboardViewController.h"
#import "LookinDashboardBlueprint.h"
#import "LKDashboardTextControlEditingFlag.h"

@interface LKDashboardAttributeNumberInputView () <NSTextFieldDelegate>

@end

@implementation LKDashboardAttributeNumberInputView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _inputView = [LKNumberInputView new];
        self.inputView.textFieldView.textField.delegate = self;
        [self addSubview:self.inputView];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.inputView).fullFrame;
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    if (self.inputView.viewStyle == LKNumberInputViewStyleHorizontal) {
        limitedSize.height = LKNumberInputHorizontalHeight;
    } else if (self.inputView.viewStyle == LKNumberInputViewStyleVertical) {
        limitedSize.height = LKNumberInputVerticalHeight;
    } else {
        NSAssert(NO, @"");
    }
    return limitedSize;
}

- (void)renderWithAttribute {
    self.inputView.textFieldView.textField.editable = [self canEdit];
    
    if (self.attribute.isUserCustom) {
        self.inputView.title = nil;
    } else {
        NSString *briefTitle = [LookinDashboardBlueprint briefTitleWithAttrID:self.attribute.identifier];
        self.inputView.title = briefTitle;
    }
    
    double doubleValue = ((NSNumber *)self.attribute.value).doubleValue;
    
    if (self.attribute.isUserCustom) {
        self.inputView.viewStyle = LKNumberInputViewStyleHorizontal;
        self.inputView.textFieldView.textField.stringValue = [NSString lookin_stringFromDouble:doubleValue decimal:6];
        
    } else {
        static dispatch_once_t onceToken;
        static NSArray<LookinAttrIdentifier> *horizontalAttrs = nil;
        dispatch_once(&onceToken,^{
            horizontalAttrs = @[LookinAttr_ViewLayer_Visibility_Opacity,
                                LookinAttr_ViewLayer_Corner_Radius,
                                LookinAttr_ViewLayer_Tag_Tag,
                                LookinAttr_UILabel_Font_Size,
                                LookinAttr_UILabel_NumberOfLines_NumberOfLines,
                                LookinAttr_UITextView_Font_Size,
                                LookinAttr_UITextField_Font_Size,
                                LookinAttr_UITextField_CanAdjustFont_MinSize,
                                LookinAttr_ViewLayer_Border_Width,
                                LookinAttr_UITableView_SectionsNumber_Number,
                                LookinAttr_AutoLayout_Resistance_Ver,
                                LookinAttr_AutoLayout_Resistance_Hor,
                                LookinAttr_AutoLayout_Hugging_Ver,
                                LookinAttr_AutoLayout_Hugging_Hor,
                                LookinAttr_UIStackView_Spacing_Spacing];
        });
        if ([horizontalAttrs containsObject:self.attribute.identifier]) {
            self.inputView.viewStyle = LKNumberInputViewStyleHorizontal;
            self.inputView.textFieldView.textField.stringValue = [NSString lookin_stringFromDouble:doubleValue decimal:3];
        } else {
            self.inputView.viewStyle = LKNumberInputViewStyleVertical;
            self.inputView.textFieldView.textField.stringValue = [NSString lookin_stringFromDouble:doubleValue decimal:2];
        }
    }
}

- (NSUInteger)numberOfColumnsOccupied {
    if (self.attribute.isUserCustom) {
        return 1;
    }
    static dispatch_once_t onceToken;
    static NSDictionary<LookinAttrIdentifier, NSNumber *> *rawDict = nil;
    dispatch_once(&onceToken,^{
        rawDict = @{
                    LookinAttr_ViewLayer_Visibility_Opacity: @1,
                    LookinAttr_ViewLayer_Corner_Radius: @1,
                    LookinAttr_ViewLayer_Tag_Tag: @1,
                    LookinAttr_UITextView_Font_Size: @1,
                    LookinAttr_UITextField_Font_Size: @1,
                    LookinAttr_UITextField_CanAdjustFont_MinSize: @1,
                    LookinAttr_ViewLayer_Border_Width: @1,
                    LookinAttr_UITableView_SectionsNumber_Number: @1,
                    LookinAttr_UILabel_NumberOfLines_NumberOfLines: @1,
                    LookinAttr_UILabel_Font_Size: @1,
                    LookinAttr_UIStackView_Spacing_Spacing: @1,
                    
                    LookinAttr_AutoLayout_Resistance_Ver: @2,
                    LookinAttr_AutoLayout_Resistance_Hor: @2,
                    LookinAttr_AutoLayout_Hugging_Ver: @2,
                    LookinAttr_AutoLayout_Hugging_Hor: @2,
                    
                    LookinAttr_UIScrollView_Zoom_Scale: @3,
                    LookinAttr_UIScrollView_Zoom_MinScale: @3,
                    LookinAttr_UIScrollView_Zoom_MaxScale: @3,
                    };
    });
    
    NSNumber *num = rawDict[self.attribute.identifier];
    if (num != nil) {
        return [num integerValue];
    }
    return 4;
}

#pragma mark - <NSTextFieldDelegate>

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
    return self.canEdit;
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
    if (LKDashboardTextControlEditingFlag.sharedInstance.shouldIgnoreTextEditingChangeEvent) {
        NSLog(@"忽略 controlTextDidEndEditing 事件，驳回");
        return;
    }
    id expectedValue = [LKNumberInputView parsedValueWithString:self.inputView.textFieldView.textField.stringValue attrType:self.attribute.attrType];
    if (!expectedValue) {
        NSLog(@"输入格式校验不通过，驳回");
        [self renderWithAttribute];
        return;
    }
    
    if ([self.attribute.identifier isEqualToString:LookinAttr_ViewLayer_Visibility_Opacity] ||
        [self.attribute.identifier isEqualToString:LookinAttr_ViewLayer_Shadow_Opacity]) {
        double inputValue = ((NSNumber *)expectedValue).doubleValue;
        inputValue = MAX(MIN(inputValue, 1), 0);
        expectedValue = @(inputValue);
    }
    
    if ([expectedValue isEqual:self.attribute.value]) {
        NSLog(@"修改没有变化，不做任何提交");
        [self renderWithAttribute];
        return;
    }
//    if (self.attribute.valueType == LookinCodingValueTypeString && self.attribute.value == nil && [expectedValue isEqual:@""]) {
//        NSLog(@"特别处理：作为 string 类型，修改之前是 nil，修改之后是空字符串，此时认为用户仍然是想将值保留为 nil，而非想要修改为空字符串");
//        [self renderWithAttribute];
//        return;
//    }
    
    // 提交修改
    @weakify(self);
    [[self.dashboardViewController modifyAttribute:self.attribute newValue:expectedValue] subscribeError:^(NSError * _Nullable error) {
        @strongify(self);
        NSLog(@"修改返回 error");
        [self renderWithAttribute];
    }];
}

#pragma mark - Others

- (void)setDashboardViewController:(LKDashboardViewController *)dashboardViewController {
    [super setDashboardViewController:dashboardViewController];
    self.inputView.textFieldView.backgroundColorName = @"DashboardCardValueBGColor";
}

@end
