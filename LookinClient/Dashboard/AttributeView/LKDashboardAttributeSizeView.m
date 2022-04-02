//
//  LKDashboardAttributeSizeView.m
//  Lookin
//
//  Created by Li Kai on 2019/6/11.
//  https://lookin.work
//

#import "LKDashboardAttributeSizeView.h"
#import "LKNumberInputView.h"
#import "LKTextFieldView.h"
#import "LKDashboardViewController.h"

@interface LKDashboardAttributeSizeView () <NSTextFieldDelegate>

@property(nonatomic, copy) NSArray<LKNumberInputView *> *inputsView;

@end

@implementation LKDashboardAttributeSizeView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        //        self.layer.borderWidth = 1;
        //        self.layer.borderColor = [NSColor redColor].CGColor;
        
        NSArray<NSString *> *titles = @[@"W", @"H"];
        self.inputsView = [NSArray lookin_arrayWithCount:2 block:^id(NSUInteger idx) {
            LKNumberInputView *view = [LKNumberInputView new];
            view.title = titles[idx];
            view.viewStyle = LKNumberInputViewStyleHorizontal;
            view.textFieldView.textField.delegate = self;
            [self addSubview:view];
            return view;
        }];
    }
    return self;
}

- (void)layout {
    [super layout];
    CGFloat itemWidth = (self.$width - DashboardAttrItemHorInterspace) / 2.0;
    [self.inputsView enumerateObjectsUsingBlock:^(LKNumberInputView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat x = idx ? (itemWidth + DashboardAttrItemHorInterspace) : 0;
        $(view).width(itemWidth).height(LKNumberInputHorizontalHeight).x(x).y(0);
    }];
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat height = LKNumberInputHorizontalHeight;
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
    NSSize size = ((NSValue *)self.attribute.value).sizeValue;
    NSArray<NSString *> *mainStrs = @[[NSString lookin_stringFromDouble:size.width decimal:3],
                                      [NSString lookin_stringFromDouble:size.height decimal:3]];
    
    [self.inputsView enumerateObjectsUsingBlock:^(LKNumberInputView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.textFieldView.textField.editable = [self canEdit];
        obj.textFieldView.textField.stringValue = mainStrs[idx];
    }];
}

#pragma mark - <NSTextFieldDelegate>

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
    return self.canEdit;
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
    NSTextField *editingTextField = notification.object;
    NSNumber *inputValue = [LKNumberInputView parsedValueWithString:editingTextField.stringValue attrType:LookinAttrTypeDouble];
    if (inputValue == nil) {
        NSLog(@"输入格式校验不通过，驳回");
        [self renderWithAttribute];
        return;
    }
    
    double inputDouble = [inputValue doubleValue];
    NSUInteger editingTextFieldIdx = [[self.inputsView lookin_map:^id(NSUInteger idx, LKNumberInputView *value) {
        return value.textFieldView.textField;
    }] indexOfObject:editingTextField];
    
    NSSize expectedSize = ((NSValue *)self.attribute.value).sizeValue;
    switch (editingTextFieldIdx) {
        case 0:
            // width
            expectedSize.width = inputDouble;
            break;
        case 1:
            // height
            expectedSize.height = inputDouble;
            break;
        default:
            [self renderWithAttribute];
            NSAssert(NO, @"");
            break;
    }
    
    NSValue *expectedValue = [NSValue valueWithSize:expectedSize];
    if ([expectedValue isEqual:self.attribute.value]) {
        NSLog(@"修改没有变化，不做任何提交");
        [self renderWithAttribute];
        return;
    }
    
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
    [self.inputsView enumerateObjectsUsingBlock:^(LKNumberInputView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.textFieldView.backgroundColorName = @"DashboardCardValueBGColor";
    }];
}

@end
