//
//  LKHierarchyHandlersPopoverItemView.m
//  Lookin
//
//  Created by Li Kai on 2019/8/11.
//  https://lookin.work
//

#import "LKHierarchyHandlersPopoverItemView.h"
#import "LookinEventHandler.h"
#import "LKTextsMenuView.h"
#import "LookinIvarTrace.h"
#import "LKAppsManager.h"
#import "LKNavigationManager.h"
#import "LKStaticWindowController.h"

@interface LKHierarchyHandlersPopoverItemView ()

@property(nonatomic, strong) LookinEventHandler *eventHandler;

@property(nonatomic, strong) NSImageView *iconImageView;

@property(nonatomic, strong) LKLabel *titleLabel;
@property(nonatomic, strong) LKLabel *subtitleLabel;
@property(nonatomic, strong) NSButton *recognizerEnableButton;


@property(nonatomic, strong) LKTextsMenuView *contentView;

@property(nonatomic, strong) CALayer *topSepLayer;


@end

@implementation LKHierarchyHandlersPopoverItemView {
    CGFloat _contentX;
    CGFloat _insetRight;
    CGFloat _verInset;
    CGFloat _contentMarginTop;
    CGFloat _subtitleMarginTop;
}

- (instancetype)initWithEventHandler:(LookinEventHandler *)eventHandler editable:(BOOL)editable {
    if (self = [self initWithFrame:NSZeroRect]) {
        _contentX = 28;
        _insetRight = 16;
        _verInset = 10;
        _contentMarginTop = 4;
        _subtitleMarginTop = 3;
        
        self.eventHandler = eventHandler;
        
        self.topSepLayer = [CALayer layer];
        [self.layer addSublayer:self.topSepLayer];
        
        self.iconImageView = [NSImageView new];
        [self addSubview:self.iconImageView];
        
        self.titleLabel = [LKLabel new];
        self.titleLabel.selectable = YES;
        self.titleLabel.maximumNumberOfLines = 1;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:self.titleLabel];
        
        self.contentView = [LKTextsMenuView new];
        self.contentView.font = NSFontMake(13);
        [self addSubview:self.contentView];
        
        self.topSepLayer.backgroundColor = self.isDarkMode ? LookinColorRGBAMake(255, 255, 255, .15).CGColor : LookinColorRGBAMake(0, 0, 0, .12).CGColor;
        
        NSMutableArray<LookinStringTwoTuple *> *texts = [NSMutableArray array];
        if (eventHandler.handlerType == LookinEventHandlerTypeGesture) {
            [texts addObject:[LookinStringTwoTuple tupleWithFirst:@"Enabled" second:@""]];

            if (editable) {
                self.recognizerEnableButton = [NSButton new];
                [self.recognizerEnableButton setButtonType:NSButtonTypeSwitch];
                self.recognizerEnableButton.title = @"";
                self.recognizerEnableButton.target = self;
                self.recognizerEnableButton.action = @selector(_handleGestureButton:);
                [self _renderRecognizerEnabledButton];
                [self.contentView addButton:self.recognizerEnableButton atIndex:0];
            } else {
                [texts addObject:[LookinStringTwoTuple tupleWithFirst:@"Enabled" second:(eventHandler.gestureRecognizerIsEnabled ? @"YES" : @"NO")]];
            }
            
            [texts addObject:[LookinStringTwoTuple tupleWithFirst:@"Delegate" second:(eventHandler.gestureRecognizerDelegator ? : @"nil")]];
            // gesture 的名字都太长了，把字号弄小一点
            self.titleLabel.font = [NSFont boldSystemFontOfSize:12];
        } else {
            self.titleLabel.font = [NSFont boldSystemFontOfSize:13];
        }
        
        if (eventHandler.targetActions.count == 0) {
            [texts addObject:[LookinStringTwoTuple tupleWithFirst:@"Target" second:@"nil"]];
            [texts addObject:[LookinStringTwoTuple tupleWithFirst:@"Action" second:@"NULL"]];
        } else if (eventHandler.targetActions.count == 1) {
            LookinStringTwoTuple *tuple = eventHandler.targetActions.firstObject;
            [texts addObject:[LookinStringTwoTuple tupleWithFirst:@"Target" second:tuple.first]];
            [texts addObject:[LookinStringTwoTuple tupleWithFirst:@"Action" second:tuple.second]];
        } else {
            [eventHandler.targetActions enumerateObjectsUsingBlock:^(LookinStringTwoTuple * _Nonnull tuple, NSUInteger idx, BOOL * _Nonnull stop) {
                [texts addObject:[LookinStringTwoTuple tupleWithFirst:[NSString stringWithFormat:@"Target %@", @(idx + 1)] second:tuple.first]];
                [texts addObject:[LookinStringTwoTuple tupleWithFirst:[NSString stringWithFormat:@"Action %@", @(idx + 1)] second:tuple.second]];
            }];
        }
        self.contentView.texts = texts;

        if (eventHandler.handlerType == LookinEventHandlerTypeGesture) {
            self.titleLabel.stringValue = eventHandler.eventName;
            self.iconImageView.image = NSImageMake(@"icon_gesture_tap");
        } else {
            self.titleLabel.stringValue = eventHandler.eventName;
            if ([eventHandler.eventName hasPrefix:@"UIControlEventEditing"]) {
                self.iconImageView.image = NSImageMake(@"icon_targetaction_edit");
            } else {
                self.iconImageView.image = NSImageMake(@"icon_targetaction_touch");
            }
        }
        
        if (eventHandler.handlerType == LookinEventHandlerTypeGesture) {
            NSMutableArray<NSString *> *texts = [NSMutableArray array];
            if (eventHandler.inheritedRecognizerName) {
                [texts addObject:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Inherits from", nil), eventHandler.inheritedRecognizerName]];
            }
            [texts addObjectsFromArray:eventHandler.recognizerIvarTraces];
            if (texts.count > 0) {
                NSString *text = [texts componentsJoinedByString:@"\n"];
                self.subtitleLabel = [LKLabel new];
                self.subtitleLabel.textColor = self.isDarkMode ? [NSColorGray9 colorWithAlphaComponent:.5] : [NSColorGray1 colorWithAlphaComponent:.6];
                self.subtitleLabel.stringValue = text;
                self.subtitleLabel.selectable = YES;
                self.subtitleLabel.font = NSFontMake(12);
                self.subtitleLabel.maximumNumberOfLines = 0;
                self.subtitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
                [self addSubview:self.subtitleLabel];
            }
        }
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.topSepLayer).x(_contentX).toRight(_insetRight).y(0).height(1);
    
    $(self.titleLabel).x(_contentX).toRight(_insetRight).heightToFit.y(_verInset);
    
    CGFloat y = self.titleLabel.$maxY;
    if (self.subtitleLabel) {
        $(self.subtitleLabel).x(_contentX).toRight(_insetRight).heightToFit.y(y + _subtitleMarginTop);
        y = self.subtitleLabel.$maxY;
    }
    
    $(self.contentView).x(_contentX).toRight(_insetRight).heightToFit.y(y + _contentMarginTop);
    $(self.iconImageView).sizeToFit.midX(_contentX / 2.0 + 1).midY(self.titleLabel.$midY);
}

- (void)setNeedTopBorder:(BOOL)needTopBorder {
    _needTopBorder = needTopBorder;
    self.topSepLayer.hidden = !needTopBorder;
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    NSSize titleSize = [self.titleLabel bestSize];
    NSSize contentSize = [self.contentView sizeThatFits:NSSizeMax];
    NSSize subtitleSize = [self.subtitleLabel bestSize];
    limitedSize.width = MAX(MAX(titleSize.width, contentSize.width), subtitleSize.width) + _contentX + _insetRight + 2; // 加个 2 冗余一下像素取整误差
    limitedSize.height = titleSize.height + contentSize.height + _contentMarginTop + _verInset * 2;
    if (self.subtitleLabel) {
        limitedSize.height += (_subtitleMarginTop + subtitleSize.height);
    }
    return limitedSize;
}

- (void)_handleGestureButton:(NSButton *)button {
    NSWindow *mainWindow = [LKNavigationManager sharedInstance].staticWindowController.window;
    
    if (!InspectingApp) {
        AlertError(LookinErr_NoConnect, mainWindow);
        [self _renderRecognizerEnabledButton];
        return;
    }
    BOOL shouldEnableRecognizer;
    if (button.state == NSControlStateValueOn) {
        shouldEnableRecognizer = YES;
    } else {
        shouldEnableRecognizer = NO;
    }
    @weakify(self);
    [[InspectingApp modifyGestureRecognizer:self.eventHandler.recognizerOid toBeEnabled:shouldEnableRecognizer] subscribeNext:^(NSNumber *enabled_number) {
        @strongify(self);
        BOOL isEnabled = [enabled_number boolValue];
        self.eventHandler.gestureRecognizerIsEnabled = isEnabled;
        [self _renderRecognizerEnabledButton];
        
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        AlertError(error, mainWindow);
        [self _renderRecognizerEnabledButton];
    }];
}

- (void)_renderRecognizerEnabledButton {
    self.recognizerEnableButton.state = (self.eventHandler.gestureRecognizerIsEnabled ? NSControlStateValueOn : NSControlStateValueOff);
}

@end
