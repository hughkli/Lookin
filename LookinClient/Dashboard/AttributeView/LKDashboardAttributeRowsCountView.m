//
//  LKDashboardAttributeRowsCountView.m
//  Lookin
//
//  Created by Li Kai on 2019/6/12.
//  https://lookin.work
//

#import "LKDashboardAttributeRowsCountView.h"
#import "LKNumberInputView.h"
#import "LKTextFieldView.h"
#import "LKDashboardViewController.h"

@interface LKDashboardAttributeRowsCountView ()

@property(nonatomic, copy) NSArray<LKNumberInputView *> *inputsView;

@end

@implementation LKDashboardAttributeRowsCountView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        //        self.layer.borderWidth = 1;
        //        self.layer.borderColor = [NSColor redColor].CGColor;
        
        self.inputsView = [NSArray array];
    }
    return self;
}

- (void)layout {
    [super layout];
    [self.inputsView enumerateObjectsUsingBlock:^(LKNumberInputView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat y = idx * (LKNumberInputHorizontalHeight + DashboardAttrItemVerInterspace);
        $(view).fullWidth.height(LKNumberInputHorizontalHeight).y(y);
    }];
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat height = (LKNumberInputHorizontalHeight + DashboardAttrItemVerInterspace) * self.inputsView.count - DashboardAttrItemVerInterspace;
    limitedSize.height = MAX(height, 0);
    return limitedSize;
}

- (void)renderWithAttribute {
    if (!self.attribute) {
        NSAssert(NO, @"");
        return;
    }
    if (![self.attribute.value isKindOfClass:[NSArray class]]) {
        NSAssert(NO, @"");
        return;
    }
    
    NSArray<NSNumber *> *numbers = self.attribute.value;
    self.inputsView = [self.inputsView lookin_resizeWithCount:numbers.count add:^LKNumberInputView *(NSUInteger idx) {
        LKNumberInputView *view = [LKNumberInputView new];
        view.textFieldView.textField.editable = NO;
        view.viewStyle = LKNumberInputViewStyleHorizontal;
        view.textFieldView.backgroundColorName = @"DashboardCardValueBGColor";
        [self addSubview:view];
        return view;
        
    } remove:^(NSUInteger idx, LKNumberInputView *obj) {
        [obj removeFromSuperview];
        
    } doNext:^(NSUInteger idx, LKNumberInputView *obj) {
        obj.title = [NSString stringWithFormat:@"Section %@", @(idx)];
        obj.textFieldView.textField.stringValue = [NSString stringWithFormat:@"%@", numbers[idx]];
    }];
    
    [self setNeedsLayout:YES];
}

#pragma mark - Others

- (void)setDashboardViewController:(LKDashboardViewController *)dashboardViewController {
    [super setDashboardViewController:dashboardViewController];
    [self.inputsView enumerateObjectsUsingBlock:^(LKNumberInputView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.textFieldView.backgroundColorName = @"DashboardCardValueBGColor";
    }];
}

@end
