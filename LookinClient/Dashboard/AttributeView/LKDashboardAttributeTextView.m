//
//  LKDashboardAttributeTextView.m
//  Lookin
//
//  Created by Li Kai on 2019/9/16.
//  https://lookin.work
//

#import "LKDashboardAttributeTextView.h"
#import "LKDashboardViewController.h"

@interface LKDashboardAttributeTextView () <NSTextViewDelegate>

@property(nonatomic, strong) NSScrollView *scrollView;
@property(nonatomic, strong) NSTextView *textView;

@end

@implementation LKDashboardAttributeTextView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.scrollView = [LKHelper scrollableTextView];
        self.scrollView.wantsLayer = YES;
        self.scrollView.layer.cornerRadius = DashboardCardControlCornerRadius;
        self.textView = self.scrollView.documentView;
        self.textView.font = NSFontMake(12);
        self.textView.backgroundColor = [NSColor colorNamed:@"DashboardCardValueBGColor"];
        self.textView.textContainerInset = NSMakeSize(2, 4);
        self.textView.delegate = self;
        [self addSubview:self.scrollView];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.scrollView).fullFrame;
}

- (void)renderWithAttribute {
    [super renderWithAttribute];
    /// nil 居然会 crash
    self.textView.string = self.attribute.value ? : @"";
    self.textView.editable = self.canEdit;
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    limitedSize.width -= self.textView.textContainerInset.width * 2;
    
    NSDictionary *attributes = @{NSFontAttributeName: self.textView.font};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[self.textView string] attributes:attributes];
    NSRect rect = [attributedString boundingRectWithSize:limitedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    limitedSize.height = MIN(rect.size.height + self.textView.textContainerInset.height * 2, 80);
    return limitedSize;
}

#pragma mark - <NSTextViewDelegate>

- (void)textDidEndEditing:(NSNotification *)notification {
    NSString *expectedValue = self.textView.string;
    
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

@end
