//
//  LKAboutViewController.m
//  LookinClient
//
//  Created by 李凯 on 2019/10/30.
//  Copyright © 2019 hughkli. All rights reserved.
//

#import "LKAboutViewController.h"

@interface LKAboutViewController ()

@property(nonatomic, strong) NSImageView *logoImageView;
@property(nonatomic, strong) LKLabel *titleLabel;
@property(nonatomic, strong) LKLabel *versionLabel;

@property(nonatomic, strong) NSImageView *photoImageView;
@property(nonatomic, strong) LKBaseView *photoMaskView;

@property(nonatomic, copy) NSString *photoName;
@property(nonatomic, assign) CGFloat maskFinalAlpha;

@end

@implementation LKAboutViewController

- (instancetype)initWithContainerView:(NSView *)view {
    NSArray<NSDictionary<NSString *, id> *> *data = @[
        @{@"name":@"photo0", @"alpha":@(.85)},
        @{@"name":@"photo1", @"alpha":@(.85)},
        @{@"name":@"photo2", @"alpha":@(.7)},
        @{@"name":@"photo3", @"alpha":@(.8)}
    ];
    NSUInteger dataIdx = (arc4random() % (data.count));
    self.photoName = data[dataIdx][@"name"];
    self.maskFinalAlpha = ((NSNumber *)data[dataIdx][@"alpha"]).doubleValue;
    
    return [super initWithContainerView:view];
}

- (NSView *)makeContainerView {
    
    LKBaseView *containerView = [LKBaseView new];
    
    self.photoImageView = [NSImageView new];
    self.photoImageView.image = NSImageMake(self.photoName);
    self.photoImageView.imageScaling = NSImageScaleAxesIndependently;
    [containerView addSubview:self.photoImageView];
    
    self.photoMaskView = [LKBaseView new];
    self.photoMaskView.backgroundColors = LKColorsCombine([NSColor whiteColor], [NSColor blackColor]);
    self.photoMaskView.alphaValue = 1;
    [containerView addSubview:self.photoMaskView];
    
    self.logoImageView = [NSImageView new];
    self.logoImageView.image = NSImageMake(@"logo_jump");
    self.logoImageView.animates = YES;
    [containerView addSubview:self.logoImageView];
    
    self.titleLabel = [LKLabel new];
    self.titleLabel.stringValue = @"Lookin";
    self.titleLabel.textColors = LKColorsCombine([NSColor blackColor], [NSColor whiteColor]);
    self.titleLabel.font = [NSFont boldSystemFontOfSize:15];//NSFontMake(15);
    [containerView addSubview:self.titleLabel];
    
    NSString *dotVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *numberVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    self.versionLabel = [LKLabel new];
    self.versionLabel.stringValue = [NSString stringWithFormat:@"Version %@ (%@)", dotVersion, numberVersion];
    self.versionLabel.textColors = LKColorsCombine([NSColor blackColor], [NSColor whiteColor]);
    self.versionLabel.font = NSFontMake(13);
    [containerView addSubview:self.versionLabel];
    
    return containerView;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    $(self.photoImageView, self.photoMaskView).fullFrame;
    $(self.logoImageView).width(100).height(88).horAlign;
    $(self.titleLabel).sizeToFit.horAlign.y(self.logoImageView.$maxY - 6);
    $(self.versionLabel).sizeToFit.horAlign.y(self.titleLabel.$maxY + 3);
    $(self.logoImageView, self.titleLabel, self.versionLabel).groupVerAlign.offsetY(-10);
}

- (void)viewDidAppear {
    [super viewDidAppear];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.duration = 8;
            self.photoMaskView.animator.alphaValue = self.maskFinalAlpha;
        } completionHandler:nil];
    });
}

@end
