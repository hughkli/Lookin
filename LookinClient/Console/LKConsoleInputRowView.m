//
//  LKConsoleInputRowView.m
//  Lookin
//
//  Created by Li Kai on 2019/6/1.
//  https://lookin.work
//

#import "LKConsoleInputRowView.h"
#import "LKConsoleDataSource.h"
#import "LookinObject.h"
#import "LKInputSearchView.h"
#import "LKInputSearchSuggestionItem.h"
#import "LKConsoleSelectPopoverController.h"

@interface LKConsoleInputRowView () <LKInputSearchViewDelegate>

@property(nonatomic, strong) LKConsoleDataSource *dataSource;
@property(nonatomic, strong) NSButton *selectButton;
@property(nonatomic, strong) LKInputSearchView *inputView;
@property(nonatomic, strong) LKConsoleSelectPopoverController *selectPopoverController;

@end

@implementation LKConsoleInputRowView

- (instancetype)initWithDataSource:(LKConsoleDataSource *)dataSource {
    if (self = [self initWithFrame:NSZeroRect]) {
        self.dataSource = dataSource;
        
//        self.layer.borderColor = [NSColor greenColor].CGColor;
//        self.layer.borderWidth = 1;
        self.selectPopoverController = [[LKConsoleSelectPopoverController alloc] initWithDataSource:dataSource];
        @weakify(self);
        self.selectPopoverController.needShowError = ^(NSError *error) {
            @strongify(self);
            [[NSAlert alertWithError:error] beginSheetModalForWindow:self.window completionHandler:nil];
        };
        
        self.selectButton = [NSButton new];
        self.selectButton.font = NSFontMake(13);
        self.selectButton.imagePosition = NSImageRight;
        self.selectButton.bezelStyle = NSBezelStyleRoundRect;
        self.selectButton.bordered = NO;
        self.selectButton.image = NSImageMake(@"Console_UpDownArrow");
        self.selectButton.target = self;
        self.selectButton.action = @selector(_handleSelectButton);
        [self addSubview:self.selectButton];
        
        self.inputView = [[LKInputSearchView alloc] initWithThrottleTime:.15];
        self.inputView.delegate = self;
        self.inputView.textField.focusRingType = NSFocusRingTypeNone;
        [self addSubview:self.inputView];
        
        self.isDarkMode = self.effectiveAppearance.lk_isDarkMode;
        
        [RACObserve(self.dataSource, currentObject) subscribeNext:^(LookinObject *obj) {
            @strongify(self);
            [self _handleCurrentObjectDidChange];
        }];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.selectButton).fullHeight.widthToFit.lk_maxWidth(self.$width * .5).x(ConsoleInsetLeft);
    $(self.inputView).x(self.selectButton.$maxX + 5).toRight(ConsoleInsetRight).fullHeight;
}

- (void)setIsDarkMode:(BOOL)isDarkMode {
    [super setIsDarkMode:isDarkMode];
    // 更新 selectButton textColor
    [self _handleCurrentObjectDidChange];
}

- (void)makeTextFieldAsFirstResponder {
    [self.window makeFirstResponder:self.inputView.textField];
}

- (void)_handleSelectButton {
    [self.selectPopoverController reRender];
    NSPopover *popover = [[NSPopover alloc] init];
    popover.animates = NO;
    popover.behavior = NSPopoverBehaviorTransient;
    popover.contentSize = NSMakeSize(IsEnglish ? 465 : 400, [self.selectPopoverController bestHeight]);
    popover.contentViewController = self.selectPopoverController;
    [popover showRelativeToRect:NSMakeRect(0, 0, self.selectButton.bounds.size.width, self.selectButton.bounds.size.height) ofView:self.selectButton preferredEdge:NSRectEdgeMinY];
    
    @weakify(popover);
    self.selectPopoverController.needClose = ^{
        @strongify(popover);
        [popover close];
    };
}

- (void)_handleCurrentObjectDidChange {
    [self.inputView clearContentAndSuggestions];
    
    NSColor *selectButtonColor = self.isDarkMode ? LookinColorMake(85, 200, 95) : LookinColorMake(54, 155, 62);
    LookinObject *obj = self.dataSource.currentObject;
    if (obj) {
        NSString *string = [NSString stringWithFormat:@"<%@: %@>", obj.shortSelfClassName, obj.memoryAddress];
        self.selectButton.attributedTitle = $(string).textColor(selectButtonColor).attrString;
        self.inputView.textField.editable = YES;
        self.inputView.textField.placeholderString = NSLocalizedString(@"Type property or method name here", nil);
    } else {
        NSString *str = NSLocalizedString(@"Select target object", nil);
        self.selectButton.attributedTitle = $(str).textColor(selectButtonColor).attrString;
        self.inputView.textField.editable = NO;
        self.inputView.textField.placeholderString = @"";        
    }
    [self setNeedsLayout:YES];
}

#pragma mark - <LKInputSearchViewDelegate>

- (NSArray<LKInputSearchSuggestionItem *> *)inputSearchView:(LKInputSearchView *)view suggestionsForString:(NSString *)string {
    if (string.length < 3) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray array];
    
    NSArray<NSString *> *candidates = [self.dataSource currentObjectSelectorNameList];
    NSArray<NSString *> *suggestions = [LKHelper bestMatchesInCandidates:candidates input:string maxResultsCount:8];
    [suggestions enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LKInputSearchSuggestionItem *item = [LKInputSearchSuggestionItem new];
        item.image = NSImageMake(@"icon_method");
        item.text = obj;
        [array addObject:item];
    }];
    
    return array.copy;
}

- (void)inputSearchView:(LKInputSearchView *)view submitText:(NSString *)text {
    @weakify(view);
    [[self.dataSource submit:text] subscribeNext:^(id  _Nullable x) {
        @strongify(view);
        [view clearContentAndSuggestions];
        
    } error:^(NSError * _Nullable error) {
        AlertError(error, self.window);
    }];
}

@end
