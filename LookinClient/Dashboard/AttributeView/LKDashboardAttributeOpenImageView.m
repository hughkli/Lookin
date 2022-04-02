//
//  LKDashboardAttributeOpenImageView.m
//  Lookin
//
//  Created by Li Kai on 2019/10/7.
//  https://lookin.work
//

#import "LKDashboardAttributeOpenImageView.h"
#import "LKNumberInputView.h"
#import "LKDashboardViewController.h"
#import "LKAppsManager.h"

@interface LKDashboardAttributeOpenImageView ()

@property(nonatomic, strong) LKTextControl *control;

@end

@implementation LKDashboardAttributeOpenImageView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = DashboardCardControlCornerRadius;
        self.borderColors = LKColorsCombine(LookinColorMake(181, 181, 181), LookinColorMake(83, 83, 83));
        
        self.control = [LKTextControl new];
        self.control.adjustAlphaWhenClick = YES;
        self.control.label.stringValue = NSLocalizedString(@"Open Image with Preview…", nil);
        self.control.label.font = NSFontMake(11);
        [self.control addTarget:self clickAction:@selector(_handleClick)];
        [self addSubview:self.control];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.control).fullFrame;
}

- (void)renderWithAttribute {
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    limitedSize.height = LKNumberInputHorizontalHeight;
    return limitedSize;
}

- (void)_handleClick {
    NSNumber *imageViewOid_num = self.attribute.value;
    if (imageViewOid_num == nil) {
        AlertError(LookinErr_Inner, self.window);
        NSAssert(NO, @"");
        return;
    }
    
    unsigned long imageViewOid = [imageViewOid_num unsignedLongValue];

    LKDashboardViewController *dashController = self.dashboardViewController;
    if (!dashController.isStaticMode) {
        AlertErrorText(NSLocalizedString(@"The feature is not available in current mode.", nil), NSLocalizedString(@"You must connect Lookin with target iOS app before using this feature.", nil), self.window);
        return;
    }

    if (!InspectingApp) {
        AlertError(LookinErr_NoConnect, self.window);
        return;
    }
    
    @weakify(self);
    [[InspectingApp fetchImageWithImageViewOid:imageViewOid] subscribeNext:^(NSData *imageData) {
        @strongify(self);
        if (!imageData) {
            AlertErrorText(NSLocalizedString(@"Operation failed. The image property value of selected UIImageView is nil.", nil), @"", self.window);
            return;
        }
        
        NSString *fileName = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Lookin_UIImageView_%@.png", fileName]];
        NSError *writeError;
        BOOL writeSucc = [imageData writeToFile:filePath options:0 error:&writeError];
        if (!writeSucc) {
            NSAssert(NO, @"");
            AlertError(writeError, self.window);
            return;
        }
        [[NSWorkspace sharedWorkspace] openFile:filePath withApplication:@"preview"];
        
        // 记录临时文件地址以在 Lookin 退出时清理
        if (![LKHelper sharedInstance].tempImageFiles) {
            [LKHelper sharedInstance].tempImageFiles = [NSMutableArray array];
        }
        [[LKHelper sharedInstance].tempImageFiles addObject:filePath];
        
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        AlertError(error, self.window);
    }];
}

@end
