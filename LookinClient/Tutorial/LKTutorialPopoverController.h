//
//  LKTutorialPopoverController.h
//  Lookin
//
//  Created by Li Kai on 2019/7/17.
//  https://lookin.work
//

#import "LKBaseViewController.h"

@interface LKTutorialPopoverController : LKBaseViewController

- (instancetype)initWithText:(NSString *)text popover:(NSPopover *)popover;

- (NSSize)contentSize;

/// 外部可通过该属性来记录 popover 打开的时间
@property(nonatomic, assign) NSTimeInterval showTimestamp;
/// 在点击了 closeButton 后，该属性会被置为 YES
@property(nonatomic, assign) BOOL hasClickedCloseButton;

@property(nonatomic, copy) void (^learnedBlock)(void);

@end
