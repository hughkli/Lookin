//
//  LKTutorialManager.m
//  Lookin
//
//  Created by Li Kai on 2019/6/27.
//  https://lookin.work
//

#import "LKTutorialManager.h"
#import "LKTutorialPopoverController.h"
#import "LKHelper.h"

static NSString * const Key_USBLowSpeed = @"Tut_1";
static NSString * const Key_TogglePreview = @"Tut_2";
static NSString * const Key_QuickSelection = @"Tut_5";
static NSString * const Key_MoveWithSpace = @"Tut_6";
static NSString * const Key_CopyTitle = @"Tut_8";
static NSString * const Key_EventsHandler = @"Tut_EventsHandler";
static NSString * const Key_DoubleClickBehavior = @"Tut_DoubleClickBehavior";

@interface LKTutorialManager () <NSPopoverDelegate>

@end

@implementation LKTutorialManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LKTutorialManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        _USBLowSpeed = [userDefaults boolForKey:Key_USBLowSpeed];
        _togglePreview = [userDefaults boolForKey:Key_TogglePreview];
        _quickSelection = [userDefaults boolForKey:Key_QuickSelection];
        _moveWithSpace = [userDefaults boolForKey:Key_MoveWithSpace];
        _copyTitle = [userDefaults boolForKey:Key_CopyTitle];
        _eventsHandler = [userDefaults boolForKey:Key_EventsHandler];
        _hasAskedDoubleClickBehavior = [userDefaults boolForKey:Key_DoubleClickBehavior];
    }
    return self;
}

- (void)setHasAskedDoubleClickBehavior:(BOOL)hasAskedDoubleClickBehavior {
    _hasAskedDoubleClickBehavior = hasAskedDoubleClickBehavior;
    [[NSUserDefaults standardUserDefaults] setBool:hasAskedDoubleClickBehavior forKey:Key_DoubleClickBehavior];
}

- (void)setUSBLowSpeed:(BOOL)USBLowSpeed {
    if (_USBLowSpeed == USBLowSpeed) {
        return;
    }
    _USBLowSpeed = USBLowSpeed;
    [[NSUserDefaults standardUserDefaults] setBool:USBLowSpeed forKey:Key_USBLowSpeed];
}

- (void)setTogglePreview:(BOOL)togglePreview {
    if (_togglePreview == togglePreview) {
        return;
    }
    _togglePreview = togglePreview;
    [[NSUserDefaults standardUserDefaults] setBool:togglePreview forKey:Key_TogglePreview];
}

- (void)setQuickSelection:(BOOL)quickSelection {
    if (_quickSelection == quickSelection) {
        return;
    }
    _quickSelection = quickSelection;
    [[NSUserDefaults standardUserDefaults] setBool:quickSelection forKey:Key_QuickSelection];
}

- (void)setMoveWithSpace:(BOOL)moveWithSpace {
    if (_moveWithSpace == moveWithSpace) {
        return;
    }
    _moveWithSpace = moveWithSpace;
    [[NSUserDefaults standardUserDefaults] setBool:moveWithSpace forKey:Key_MoveWithSpace];
}

- (void)setCopyTitle:(BOOL)copyTitle {
    if (_copyTitle == copyTitle) {
        return;
    }
    _copyTitle = copyTitle;
    [[NSUserDefaults standardUserDefaults] setBool:copyTitle forKey:Key_CopyTitle];
}

- (void)setEventsHandler:(BOOL)eventsHandler {
    if (_eventsHandler == eventsHandler) {
        return;
    }
    _eventsHandler = eventsHandler;
    [[NSUserDefaults standardUserDefaults] setBool:eventsHandler forKey:Key_EventsHandler];
}

- (void)showPopoverOfView:(NSView *)view text:(NSString *)text learned:(void (^)(void))learnedBlock {
    NSPopover *popover = [[NSPopover alloc] init];
    
    LKTutorialPopoverController *vc = [[LKTutorialPopoverController alloc] initWithText:text popover:popover];
    vc.learnedBlock = learnedBlock;
    popover.delegate = self;
    popover.animates = YES;
    popover.behavior = NSPopoverBehaviorTransient;
    popover.contentSize = [vc contentSize];
    popover.contentViewController = vc;
    [popover showRelativeToRect:NSMakeRect(0, 0, view.bounds.size.width, view.bounds.size.height) ofView:view preferredEdge:NSRectEdgeMaxY];
    vc.showTimestamp = CurrentTime;
}

#pragma mark - <NSPopoverDelegate>

- (void)popoverDidClose:(NSNotification *)notification {
    NSPopover *popover = notification.object;
    if (![popover isKindOfClass:[NSPopover class]]) {
        NSAssert(NO, @"");
        return;
    }
    NSViewController *vc = popover.contentViewController;
    if (![vc isKindOfClass:[LKTutorialPopoverController class]]) {
        NSAssert(NO, @"");
        return;
    }
    LKTutorialPopoverController *tutorialVC = (LKTutorialPopoverController *)vc;
    if (tutorialVC.hasClickedCloseButton || (CurrentTime - tutorialVC.showTimestamp > 1.8)) {
        if (tutorialVC.learnedBlock) {
            tutorialVC.learnedBlock();
        }
    }
}

@end
