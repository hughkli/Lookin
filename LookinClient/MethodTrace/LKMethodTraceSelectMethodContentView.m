//
//  LKMethodTraceSelectMethodContentView.m
//  Lookin
//
//  Created by Li Kai on 2019/5/24.
//  https://lookin.work
//

#import "LKMethodTraceSelectMethodContentView.h"
#import "LKMethodTraceDataSource.h"
#import "LKInputSearchView.h"
#import "LKInputSearchSuggestionItem.h"

@interface LKMethodTraceSelectMethodContentView () <LKInputSearchViewDelegate>

@property(nonatomic, strong) LKInputSearchView *classSearchView;
@property(nonatomic, strong) LKInputSearchView *selSearchView;

@property(nonatomic, strong) LKMethodTraceDataSource *dataSource;
@property(nonatomic, strong) NSArray<NSString *> *selCandidates;

@property(nonatomic, assign) BOOL isInputingClass;

@end

@implementation LKMethodTraceSelectMethodContentView

- (instancetype)initWithDataSource:(LKMethodTraceDataSource *)dataSource {
    if (self = [self initWithFrame:NSZeroRect]) {
        self.isInputingClass = YES;
        
        self.dataSource = dataSource;
        
        self.titleImage = NSImageMake(@"icon_class");
        self.titleText = NSLocalizedString(@"Input name of the class you want to monitor", nil);
        self.submitButton.title = NSLocalizedString(@"Next", nil);
        
        self.classSearchView = [[LKInputSearchView alloc] initWithThrottleTime:.2];
        self.classSearchView.horizontalInset = 5;
        self.classSearchView.delegate = self;
        self.classSearchView.textField.focusRingType = NSFocusRingTypeNone;
        self.classSearchView.textField.placeholderString = NSLocalizedString(@"e.g. UIViewController…", nil);
        self.classSearchView.backgroundColorName = @"DashboardCardValueBGColor";
        self.classSearchView.layer.borderWidth = 1;
        self.classSearchView.layer.cornerRadius = 3;
        [self.contentView addSubview:self.classSearchView];
        
        self.selSearchView = [[LKInputSearchView alloc] initWithThrottleTime:.2];
        self.selSearchView.horizontalInset = 5;
        self.selSearchView.delegate = self;
        self.selSearchView.textField.focusRingType = NSFocusRingTypeNone;
        self.selSearchView.textField.placeholderString = NSLocalizedString(@"e.g. initWithFrame: …", nil);
        self.selSearchView.backgroundColorName = @"DashboardCardValueBGColor";
        self.selSearchView.layer.borderWidth = 1;
        self.selSearchView.layer.cornerRadius = 3;
        self.selSearchView.alphaValue = 0;
        [self.contentView addSubview:self.selSearchView];
        
        [self updateColors];
    
        @weakify(self);
        RAC(self.submitButton, enabled) = [[RACSignal combineLatest:@[self.classSearchView.textField.rac_textSignal,
                                                                      self.selSearchView.textField.rac_textSignal,
                                                                      RACObserve(self, isInputingClass)]]
                                           map:^id _Nullable(RACTuple * _Nullable value) {
                                               @strongify(self);
                                               NSTextField *currentTextField = self.isInputingClass ? self.classSearchView.textField : self.selSearchView.textField;
                                               return @(currentTextField.stringValue.length > 0);
                                           }];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.classSearchView, self.selSearchView).fullWidth.height(30).y(0);
    if (self.isInputingClass) {
        $(self.classSearchView).x(0);
        $(self.selSearchView).x(self.$width);
    } else {
        $(self.classSearchView).x(-self.$width);
        $(self.selSearchView).x(0);
    }
}

- (void)updateColors {
    [super updateColors];
    NSColor *borderColor = self.isDarkMode ? [NSColor clearColor] : LookinColorRGBAMake(0, 0, 0, .1);
    self.classSearchView.layer.borderColor = borderColor.CGColor;
    self.selSearchView.layer.borderColor = borderColor.CGColor;
}

#pragma mark - Subclassing Hooks

- (void)didClickSubmitButton {
    if (self.isInputingClass) {
        NSString *classNameInput = self.classSearchView.textField.stringValue;
        @weakify(self);
        [[self.dataSource fetchSelectorNamesWithClass:classNameInput] subscribeNext:^(NSArray<NSString *> *selectors) {
            @strongify(self);
            self.isInputingClass = NO;

            self.selCandidates = selectors;
            [self.window makeFirstResponder:self.selSearchView.textField];
            self.titleImage = NSImageMake(@"icon_method");
            self.titleText = NSLocalizedString(@"Input name of the method you want to monitor", nil);
            self.submitButton.title = NSLocalizedString(@"Done", nil);
            
            [self.selSearchView.animator setFrameOrigin:NSMakePoint(0, 0)];
            self.selSearchView.animator.alphaValue = 1;

            self.classSearchView.animator.alphaValue = 0;
            [self.classSearchView.animator setFrameOrigin:NSMakePoint(-self.$width, 0)];
            
        } error:^(NSError * _Nullable error) {
            [[NSAlert alertWithError:error] beginSheetModalForWindow:self.window completionHandler:nil];
        }];
    
    } else {
        NSString *classNameInput = self.classSearchView.textField.stringValue;
        NSString *selNameInput = self.selSearchView.textField.stringValue;
        
        @weakify(self);
        [[self.dataSource addWithClassName:classNameInput selName:selNameInput] subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            if (self.needExit) {
                self.needExit();
            }
        } error:^(NSError * _Nullable error) {
            [[NSAlert alertWithError:error] beginSheetModalForWindow:self.window completionHandler:nil];
        }];
    }
}

#pragma mark - <LKInputSearchViewDelegate>

- (NSArray<LKInputSearchSuggestionItem *> *)inputSearchView:(LKInputSearchView *)view suggestionsForString:(NSString *)string {
    if (string.length < 3) {
        return nil;
    }

    if (view == self.classSearchView) {
        
        NSArray<NSString *> *candidates = self.dataSource.allClassNames;
        NSUInteger resultsMaxCount = 8;
        NSMutableArray<LKInputSearchSuggestionItem *> *results = [NSMutableArray arrayWithCapacity:resultsMaxCount];
        [candidates enumerateObjectsUsingBlock:^(NSString * _Nonnull candidate, NSUInteger idx, BOOL * _Nonnull stop) {
            if (results.count >= resultsMaxCount) {
                *stop = YES;
                return;
            }
            if ([candidate localizedCaseInsensitiveContainsString:string]) {
                LKInputSearchSuggestionItem *item = [LKInputSearchSuggestionItem new];
                item.image = NSImageMake(@"icon_class");
                item.text = candidate;
                [results addObject:item];
            }
        }];
        
        return results;
    }
    
    if (view == self.selSearchView) {
        NSArray<NSString *> *suggestions = [LKHelper bestMatchesInCandidates:self.selCandidates input:string maxResultsCount:8];
        NSArray<LKInputSearchSuggestionItem *> *results = [suggestions lookin_map:^id(NSUInteger idx, NSString *value) {
            LKInputSearchSuggestionItem *item = [LKInputSearchSuggestionItem new];
            item.image = NSImageMake(@"icon_method");
            item.text = value;
            return item;
        }];
        
        return results;
    }
    
    return nil;
}

- (void)inputSearchView:(LKInputSearchView *)view submitText:(NSString *)text {
    [self didClickSubmitButton];
}

@end
