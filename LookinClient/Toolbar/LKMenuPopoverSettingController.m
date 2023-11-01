//
//  LKMenuPopoverSettingController.m
//  Lookin
//
//  Created by Li Kai on 2019/1/9.
//  https://lookin.work
//

#import "LKMenuPopoverSettingController.h"
#import "LKPreferenceManager.h"
#import "LKNavigationManager.h"
#import "LKPreviewView.h"

@interface LKMenuPopoverSettingController ()

@property(nonatomic, strong) LKPreferenceManager *manager;

@property(nonatomic, strong) NSButton *enableOutlineButton;
@property(nonatomic, strong) NSButton *showInvisiblesButton;

@property(nonatomic, strong) NSSlider *spaceSlider;
@property(nonatomic, strong) LKLabel *spaceSliderLabel;

@property(nonatomic, strong) NSButton *preferenceButton;

@end

@implementation LKMenuPopoverSettingController

- (instancetype)initWithPreferenceManager:(LKPreferenceManager *)manager {
    if (self = [self initWithContainerView:nil]) {
        self.manager = manager;
        
        self.enableOutlineButton = [NSButton new];
        [self.enableOutlineButton setButtonType:NSButtonTypeSwitch];
        self.enableOutlineButton.font = NSFontMake(14);
        self.enableOutlineButton.title = NSLocalizedString(@"Show layer outline", nil);
        self.enableOutlineButton.target = self;
        self.enableOutlineButton.action = @selector(_handleOutlineControl);
        [self.view addSubview:self.enableOutlineButton];
        if (manager.showOutline.currentBOOLValue) {
            self.enableOutlineButton.state = NSControlStateValueOn;
        } else {
            self.enableOutlineButton.state = NSControlStateValueOff;
        }
        
        self.showInvisiblesButton = [NSButton new];
        self.showInvisiblesButton.font = NSFontMake(14);
        self.showInvisiblesButton.title = NSLocalizedString(@"Show hidden UIView and CALayer", nil);
        [self.showInvisiblesButton setButtonType:NSButtonTypeSwitch];
        self.showInvisiblesButton.target = self;
        self.showInvisiblesButton.action = @selector(_handleShowInvisiblesControl);
        [self.view addSubview:self.showInvisiblesButton];
        if (manager.showHiddenItems.currentBOOLValue) {
            self.showInvisiblesButton.state = NSControlStateValueOn;
        } else {
            self.showInvisiblesButton.state = NSControlStateValueOff;
        }
        
        self.spaceSlider = [NSSlider new];
        self.spaceSlider.minValue = LookinPreviewMinZInterspace;
        self.spaceSlider.maxValue = LookinPreviewMaxZInterspace;
        self.spaceSlider.target = self;
        self.spaceSlider.action = @selector(_handleSpaceSlider:);
        [self.view addSubview:self.spaceSlider];
        
        self.spaceSliderLabel = [LKLabel new];
        self.spaceSliderLabel.font = NSFontMake(14);
        self.spaceSliderLabel.stringValue = NSLocalizedString(@"Item separation", nil);
        [self.view addSubview:self.spaceSliderLabel];
        
        self.preferenceButton = [NSButton lk_normalButtonWithTitle:NSLocalizedString(@"More…", nil) target:self action:@selector(_handlePreferenceButton)];
        [self.view addSubview:self.preferenceButton];
        
        [manager.zInterspace subscribe:self action:@selector(_handleZInterspaceDidChange:) relatedObject:nil sendAtOnce:YES];
    }
    return self;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    
    $(self.enableOutlineButton).x(15).toRight(0).height(24).y(15);
    $(self.showInvisiblesButton).x(15).toRight(0).height(24).y(self.enableOutlineButton.$maxY + 6);

    $(self.spaceSlider).x(15).toRight(15).height(26).y(self.showInvisiblesButton.$maxY + 22);
    $(self.spaceSliderLabel).sizeToFit.x(self.spaceSlider.$x + 3).y(self.spaceSlider.$maxY);
    
    $(self.preferenceButton).width(130).horAlign.bottom(4);
}

- (void)_handleOutlineControl {
    if (self.enableOutlineButton.state == NSControlStateValueOn) {
        [self.manager.showOutline setBOOLValue:YES ignoreSubscriber:nil];
    } else {
        [self.manager.showOutline setBOOLValue:NO ignoreSubscriber:nil];
    }
}

- (void)_handleShowInvisiblesControl {
    if (self.showInvisiblesButton.state == NSControlStateValueOn) {
        [self.manager.showHiddenItems setBOOLValue:YES ignoreSubscriber:nil];
    } else {
        [self.manager.showHiddenItems setBOOLValue:NO ignoreSubscriber:nil];
    }
}

- (void)_handleSpaceSlider:(NSSlider *)slider {
    double doubleValue = slider.doubleValue;
    [self.manager.zInterspace setDoubleValue:doubleValue ignoreSubscriber:self];
}

- (void)_handlePreferenceButton {
    [[LKNavigationManager sharedInstance] showPreference];
}

- (void)_handleZInterspaceDidChange:(LookinMsgActionParams *)param {
    double doubleValue = param.doubleValue;
    self.spaceSlider.doubleValue = doubleValue;
}

@end
