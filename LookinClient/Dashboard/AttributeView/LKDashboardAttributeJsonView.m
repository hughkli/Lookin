//
//  LKDashboardAttributeJsonView.m
//  LookinClient
//
//  Created by likai.123 on 2023/11/30.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "LKDashboardAttributeJsonView.h"

@interface LKDashboardAttributeJsonView ()

@property(nonatomic, strong) NSScrollView *scrollView;
@property(nonatomic, strong) NSTextView *textView;

@end

@implementation LKDashboardAttributeJsonView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
//        self.layer.borderWidth = 1;
//        self.layer.borderColor = [NSColor redColor].CGColor;
        
        self.scrollView = [LKHelper scrollableTextView];
        self.scrollView.wantsLayer = YES;
        self.scrollView.layer.cornerRadius = DashboardCardControlCornerRadius;
        self.textView = self.scrollView.documentView;
        self.textView.font = NSFontMake(12);
        self.textView.backgroundColor = [NSColor colorNamed:@"DashboardCardValueBGColor"];
        self.textView.textContainerInset = NSMakeSize(2, 4);
        self.textView.editable = NO;
//        self.textView.delegate = self;
        [self addSubview:self.scrollView];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.scrollView).fullFrame;
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat height = 100;
    limitedSize.height = height;
    return limitedSize;
}

- (void)renderWithAttribute {
    [super renderWithAttribute];
    /// nil 居然会 crash
    NSString *json = self.attribute.value;
    if (![json isKindOfClass:[NSString class]]) {
        NSAssert(NO, @"");
        return;
    }

    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (error) {
        NSLog(@"转换失败: %@", error);
        NSAssert(NO, @"");
        return;
    }
    self.textView.string = json;
    
//    self.textView.string = self.initialText;
//    self.textView.editable = self.canEdit;
}

@end
