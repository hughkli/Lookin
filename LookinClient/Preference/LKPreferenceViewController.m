//
//  LKPreferenceViewController.m
//  Lookin
//
//  Created by Li Kai on 2019/1/4.
//  https://lookin.work
//

#import "LKPreferenceViewController.h"
#import "LKPreferenceManager.h"
#import "LKPreferenceSwitchView.h"
#import "LKPreferencePopupView.h"
#import "LKNavigationManager.h"
#import "LKNotificationManager.h"

@interface LKPreferenceViewController ()

@property(nonatomic, strong) LKPreferencePopupView *view_appearance;
@property(nonatomic, strong) LKPreferencePopupView *view_colorFormat;
@property(nonatomic, strong) LKPreferenceSwitchView *view_enableLog;

//@property(nonatomic, strong) NSButton *debugButton;
@property(nonatomic, strong) NSButton *resetButton;

@end

@implementation LKPreferenceViewController

- (void)setView:(NSView *)view {
    [super setView:view];
    
    CGFloat controlX = IsEnglish ? 94 : 84;
    
//    LKPreferenceManager *manager = [LKPreferenceManager mainManager];
//    
//    @weakify(self);
    self.view_colorFormat = [[LKPreferencePopupView alloc] initWithTitle:NSLocalizedString(@"Color Format:", nil) messages:@[NSLocalizedString(@"Color will be displayed in format like (255, 12, 34, 0.5). Alpha value is between 0 and 1.", nil), NSLocalizedString(@"Color will be displayed in format like #7e7e7eff. The components are #RRGGBBAA.", nil)] options:@[@"RGBA", @"HEX"]];
    self.view_colorFormat.buttonX = controlX;
    self.view_colorFormat.didChange = ^(NSUInteger selectedIndex) {
        [LKPreferenceManager mainManager].rgbaFormat = (selectedIndex == 0 ? YES : NO);
    };
    [self.view addSubview:self.view_colorFormat];
    
    self.view_appearance = [[LKPreferencePopupView alloc] initWithTitle:NSLocalizedString(@"Appearance:", nil) message:nil options:@[NSLocalizedString(@"Dark Mode", nil), NSLocalizedString(@"Light Mode", nil), NSLocalizedString(@"System Default", nil)]];
    self.view_appearance.buttonX = controlX;
    self.view_appearance.didChange = ^(NSUInteger selectedIndex) {
        [LKPreferenceManager mainManager].appearanceType = selectedIndex;
    };
    [self.view addSubview:self.view_appearance];
    
    self.view_enableLog = [[LKPreferenceSwitchView alloc] initWithTitle:NSLocalizedString(@"Share analytics with Lookin", nil) message:NSLocalizedString(@"Help to improve Lookin by automatically sending diagnostics and usage data.", nil)];
    self.view_enableLog.didChange = ^(BOOL isChecked) {
        [LKPreferenceManager mainManager].enableReport = isChecked;
    };
    [self.view addSubview:self.view_enableLog];
    
//    self.debugButton = [NSButton lk_normalButtonWithTitle:@"Debug" target:self action:@selector(_handleDebugButton)];
//    [self.view addSubview:self.debugButton];
    
    self.resetButton = [NSButton lk_normalButtonWithTitle:NSLocalizedString(@"Reset", nil) target:self action:@selector(_handleResetButton)];
    [self.view addSubview:self.resetButton];
    
    [self renderFromPreferenceManager];
}

- (void)renderFromPreferenceManager {
    LKPreferenceManager *manager = [LKPreferenceManager mainManager];
    
    if (manager.rgbaFormat) {
        self.view_colorFormat.selectedIndex = 0;
    } else {
        self.view_colorFormat.selectedIndex = 1;
    }

    self.view_appearance.selectedIndex = manager.appearanceType;
    self.view_enableLog.isChecked = manager.enableReport;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    
    NSEdgeInsets insets = NSEdgeInsetsMake(20, 30, 10, 30);
    
    $(self.view_appearance).x(insets.left).toRight(insets.right).y(insets.top).height(50);

    $(self.view_colorFormat).x(insets.left).toRight(insets.right).y(self.view_appearance.$maxY).height(80);
    
    __block CGFloat y = self.view_colorFormat.$maxY;
    [$(self.view_enableLog).array enumerateObjectsUsingBlock:^(NSView *  _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        $(view).x(115).toRight(insets.right).y(y).heightToFit;
        y = view.$maxY + 26;
    }];
    
    $(self.resetButton).width(120).bottom(insets.bottom).right(insets.right);
//    $(self.debugButton).bottom(insets.bottom).maxX(self.resetButton.$x - 15);
}

- (void)_handleResetButton {
    LKPreferenceManager *manager = [LKPreferenceManager mainManager];
    manager.appearanceType = LookinPreferredAppeanranceTypeSystem;
    manager.enableReport = YES;
    manager.rgbaFormat = YES;
    [self renderFromPreferenceManager];
    
#if DEBUG
    [[LKNotificationManager sharedInstance] reset];
#endif
}

- (void)_handleDebugButton {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
