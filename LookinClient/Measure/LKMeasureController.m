//
//  LKMeasureController.m
//  Lookin
//
//  Created by Li Kai on 2019/10/18.
//  https://lookin.work
//

#import "LKMeasureController.h"
#import "LKHierarchyDataSource.h"
#import "LKPreferenceManager.h"
#import "LookinDisplayItem.h"
#import "LKTextFieldView.h"
#import "LKMeasureTutorialView.h"
#import "LKMeasureResultView.h"
#import "LKNavigationManager.h"
#import "LKPreferenceSwitchView.h"
@import AppCenter;
@import AppCenterAnalytics;

@interface LKMeasureController ()

@property(nonatomic, strong) LKMeasureTutorialView *tutorialView;
@property(nonatomic, strong) LKMeasureResultView *resultView;
@property(nonatomic, strong) LKHierarchyDataSource *dataSource;
@property(nonatomic, strong) LKLabel *shortcutLabel;
@property(nonatomic, strong) NSButton *lockSwitchButton;

@end

@implementation LKMeasureController

- (instancetype)initWithDataSource:(LKHierarchyDataSource *)dataSource {
    if (self = [self initWithContainerView:nil]) {
        self.dataSource = dataSource;
        
        self.tutorialView = [LKMeasureTutorialView new];
        [self.view addSubview:self.tutorialView];
        
        self.resultView = [LKMeasureResultView new];
        [self.view addSubview:self.resultView];
        
        [dataSource.preferenceManager.measureState subscribe:self action:@selector(_measureStatePropertyDidChange:) relatedObject:nil];
        
        @weakify(self);
        [[RACObserve(dataSource, selectedItem) combineLatestWith:RACObserve(dataSource, hoveredItem)] subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self _reRender];
        }];
    }
    return self;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    
    CGFloat titleHeight = [LKNavigationManager sharedInstance].windowTitleBarHeight;
    
    NSView *contentView = nil;
    if (self.tutorialView.isVisible) {
        $(self.tutorialView).fullWidth.heightToFit.verAlign.offsetY(titleHeight / 2.0);
        contentView = self.tutorialView;
    }
    if (self.resultView.isVisible) {
        $(self.resultView).fullWidth.heightToFit.verAlign.offsetY(titleHeight / 2.0);
        contentView = self.resultView;
    }
    if (self.shortcutLabel) {
        $(self.shortcutLabel).sizeToFit.horAlign.y(contentView.$maxY + 5);
    }
    if (self.lockSwitchButton) {
        $(self.lockSwitchButton).sizeToFit.horAlign.y(contentView.$maxY + 5);
    }
}

- (void)_measureStatePropertyDidChange:(LookinMsgActionParams *)params {
    self.shortcutLabel.hidden = YES;
    
    LookinMeasureState state = params.integerValue;
    switch (state) {
        case LookinMeasureState_no:
            self.lockSwitchButton.hidden = YES;
            self.lockSwitchButton.state = NSControlStateValueOff;
            break;
            
        case LookinMeasureState_unlocked:
            // 由快捷键触发
            [MSACAnalytics trackEvent:@"Start Measure" withProperties:@{@"shortcut":@"YES"}];
            
            if (!self.lockSwitchButton) {
                self.lockSwitchButton = [NSButton new];
                [self.lockSwitchButton setButtonType:NSButtonTypeSwitch];
                self.lockSwitchButton.font = NSFontMake(15);
                self.lockSwitchButton.title = NSLocalizedString(@"Cancel measure after key up.", nil);
                self.lockSwitchButton.target = self;
                self.lockSwitchButton.action = @selector(handleLockSwitchButton);
                [self.view addSubview:self.lockSwitchButton];
            }
            self.lockSwitchButton.state = NSControlStateValueOn;
            self.lockSwitchButton.hidden = NO;
            break;
            
        case LookinMeasureState_locked: {
            [MSACAnalytics trackEvent:@"Start Measure" withProperties:@{@"shortcut":@"NO"}];
            
            if (!self.shortcutLabel) {
                self.shortcutLabel = [LKLabel new];
                self.shortcutLabel.stringValue = NSLocalizedString(@"shortcut: holding \"option\" key", nil);
                self.shortcutLabel.textColor = [NSColor secondaryLabelColor];
                [self.view addSubview:self.shortcutLabel];
            }
            self.shortcutLabel.hidden = NO;
            break;
        }
    }
    [self _reRender];
}

- (void)_reRender {
    if (self.dataSource.preferenceManager.measureState.currentIntegerValue == LookinMeasureState_no) {
        return;
    }
    if (!self.dataSource.selectedItem) {
        return;
    }
    if (!self.dataSource.hoveredItem || (self.dataSource.selectedItem == self.dataSource.hoveredItem)) {
        NSString *format = NSLocalizedString(@"to measure between it and selected %@.", nil);
        NSString *subtitle = [NSString stringWithFormat:format, self.dataSource.selectedItem.title];
        
        self.resultView.hidden = YES;
        self.tutorialView.hidden = NO;
        [self.tutorialView renderWithImage:NSImageMake(@"measure_hover") title:NSLocalizedString(@"Hover on a layer", nil) subtitle:subtitle];
        [self.view setNeedsLayout:YES];
        return;
    }
    
    NSString *sizeInvalidClass = nil;
    NSString *sizeInvalidProperty = nil;
    CGRect selectedItemFrame = [self.dataSource.selectedItem calculateFrameToRoot];
    CGRect hoveredItemFrame = [self.dataSource.hoveredItem calculateFrameToRoot];
    
    if (selectedItemFrame.size.width <= 0) {
        sizeInvalidClass = self.dataSource.selectedItem.title;
        sizeInvalidProperty = @"width";
    } else if (selectedItemFrame.size.height <= 0) {
        sizeInvalidClass = self.dataSource.selectedItem.title;
        sizeInvalidProperty = @"height";
    } else if (hoveredItemFrame.size.width <= 0) {
        sizeInvalidClass = self.dataSource.hoveredItem.title;
        sizeInvalidProperty = @"width";
    } else if (hoveredItemFrame.size.height <= 0) {
        sizeInvalidClass = self.dataSource.hoveredItem.title;
        sizeInvalidProperty = @"height";
    }
    if (sizeInvalidClass || sizeInvalidProperty) {
        NSString *subtitleFormat = NSLocalizedString(@"Selected %@'s %@ is less than or equal to 0.", nil);
        NSString *subtitle = [NSString stringWithFormat:subtitleFormat, sizeInvalidClass, sizeInvalidProperty];
        
        self.resultView.hidden = YES;
        self.tutorialView.hidden = NO;
        [self.tutorialView renderWithImage:NSImageMake(@"measure_info") title:NSLocalizedString(@"Invalid Size", nil) subtitle:subtitle];
        [self.view setNeedsLayout:YES];
        return;
    }
    
    self.tutorialView.hidden = YES;
    self.resultView.hidden = NO;
    [self.resultView renderWithMainRect:selectedItemFrame mainImage:self.dataSource.selectedItem.groupScreenshot referRect:hoveredItemFrame referImage:self.dataSource.hoveredItem.groupScreenshot];
    [self.view setNeedsLayout:YES];
}

- (void)handleLockSwitchButton {
    if (!self.lockSwitchButton) {
        return;
    }
    if (self.lockSwitchButton.state == NSControlStateValueOn) {
        [self.dataSource.preferenceManager.measureState setIntegerValue:LookinMeasureState_unlocked ignoreSubscriber:self];
    } else {
        [self.dataSource.preferenceManager.measureState setIntegerValue:LookinMeasureState_locked ignoreSubscriber:self];
    }
}

@end
