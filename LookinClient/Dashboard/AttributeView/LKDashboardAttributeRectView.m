//
//  LKDashboardAttributeRectView.m
//  Lookin
//
//  Created by Li Kai on 2019/6/10.
//  https://lookin.work
//

#import "LKDashboardAttributeRectView.h"
#import "LKNumberInputView.h"
#import "LKTextFieldView.h"
#import "LKDashboardViewController.h"
#import "LKDashboardTextControlEditingFlag.h"

@interface LKDashboardAttributeRectView () <NSTextFieldDelegate>

@property(nonatomic, copy) NSArray<LKNumberInputView *> *mainInputsView;

@end

@implementation LKDashboardAttributeRectView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        //        self.layer.borderWidth = 1;
        //        self.layer.borderColor = [NSColor redColor].CGColor;
        
        NSArray<NSString *> *titles = @[@"X", @"Y", @"W", @"H"];
        self.mainInputsView = [NSArray lookin_arrayWithCount:4 block:^id(NSUInteger idx) {
            LKNumberInputView *view = [LKNumberInputView new];
            view.title = titles[idx];
            view.viewStyle = LKNumberInputViewStyleHorizontal;
            view.textFieldView.textField.delegate = self;
            view.textFieldView.backgroundColorName = @"DashboardCardValueBGColor";
            [self addSubview:view];
            return view;
        }];
    }
    return self;
}

- (void)layout {
    [super layout];
    CGFloat itemWidth = (self.$width - DashboardAttrItemHorInterspace) / 2.0;
    [self.mainInputsView enumerateObjectsUsingBlock:^(LKNumberInputView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat x, y;
        if (idx == 0 || idx == 2) {
            x = 0;
        } else {
            x = itemWidth + DashboardAttrItemHorInterspace;
        }
        if (idx == 0 || idx == 1) {
            y = 0;
        } else {
            y = LKNumberInputHorizontalHeight + DashboardAttrItemVerInterspace;
        }
        $(view).width(itemWidth).height(LKNumberInputHorizontalHeight).x(x).y(y);
    }];
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat height = LKNumberInputHorizontalHeight * 2 + DashboardAttrItemVerInterspace;
    limitedSize.height = height;
    return limitedSize;
}

- (void)renderWithAttribute {
    if (!self.attribute) {
        NSAssert(NO, @"");
        return;
    }
    if (![self.attribute.value isKindOfClass:[NSValue class]]) {
        NSAssert(NO, @"");
        return;
    }
    NSRect rect = ((NSValue *)self.attribute.value).rectValue;
    NSArray<NSString *> *mainStrs = @[[NSString lookin_stringFromDouble:rect.origin.x decimal:3],
                                  [NSString lookin_stringFromDouble:rect.origin.y decimal:3],
                                  [NSString lookin_stringFromDouble:rect.size.width decimal:3],
                                  [NSString lookin_stringFromDouble:rect.size.height decimal:3]];
    
    [self.mainInputsView enumerateObjectsUsingBlock:^(LKNumberInputView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.textFieldView.textField.editable = [self canEdit];
        obj.textFieldView.textField.stringValue = mainStrs[idx];
    }];
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
    
    NSTextField *editingTextField = notification.object;
    NSNumber *inputValue = [LKNumberInputView parsedValueWithString:editingTextField.stringValue attrType:LookinAttrTypeDouble];
    if (inputValue == nil) {
        NSLog(@"输入格式校验不通过，驳回");
        [self renderWithAttribute];
        return;
    }
    
    double inputDouble = [inputValue doubleValue];
    NSUInteger editingTextFieldIdx = [[self.mainInputsView lookin_map:^id(NSUInteger idx, LKNumberInputView *value) {
        return value.textFieldView.textField;
    }] indexOfObject:editingTextField];
    
    CGRect expectedRect = ((NSValue *)self.attribute.value).rectValue;
    switch (editingTextFieldIdx) {
        case 0:
            // x
            expectedRect.origin.x = inputDouble;
            break;
        case 1:
            // y
            expectedRect.origin.y = inputDouble;
            break;
        case 2:
            // width
            expectedRect.size.width = inputDouble;
            break;
        case 3:
            // height
            expectedRect.size.height = inputDouble;
            break;
        default:
            [self renderWithAttribute];
            NSAssert(NO, @"");
            break;
    }
    
    NSValue *expectedValue = [NSValue valueWithRect:expectedRect];
    if ([expectedValue isEqual:self.attribute.value]) {
        NSLog(@"修改没有变化，不做任何提交");
        [self renderWithAttribute];
        return;
    }

    // 提交修改
    @weakify(self);
    
    CGRect oldRect = [self.attribute.value rectValue];
    
    [[self.dashboardViewController modifyAttribute:self.attribute newValue:expectedValue] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        CGRect currentRect = [self.attribute.value rectValue];
        if ([self _rectA:oldRect isAlmostEqualToRectB:currentRect] && ![self _rectA:expectedRect isAlmostEqualToRectB:currentRect]) {
            // Lookin 更改了 value 之后，又被 iOS 里的业务改回去了，这个在修改 frame 时经常出现，就像 Lookin 更改失败了一样，为了避免用户迷惑，这里特意弹窗告知一下
            AlertErrorText(NSLocalizedString(@"The modification seems to have no effect.", nil), NSLocalizedString(@"After modifying successfully by Lookin, the value seems to be recovered by the code in your iOS app. For example, modifying \"frame\" of a view may trigger \"layoutSubviews\", and \"layoutSubviews\" may modify the value again.", nil), self.window);
        }
        
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        NSLog(@"修改返回 error");
        [self renderWithAttribute];
        
    }];
}

/// 比较 rectA 和 rectB 是否相等
- (BOOL)_rectA:(CGRect)rectA isAlmostEqualToRectB:(CGRect)rectB {
    if (ABS(rectA.origin.x - rectB.origin.x) > 0.1) {
        return NO;
    }
    if (ABS(rectA.origin.y - rectB.origin.y) > 0.1) {
        return NO;
    }
    if (ABS(rectA.size.width - rectB.size.width) > 0.1) {
        return NO;
    }
    if (ABS(rectA.size.height - rectB.size.height) > 0.1) {
        return NO;
    }
    return YES;
}

@end
