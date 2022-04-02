//
//  LKMenuProgressIndicatorView.m
//  Lookin
//
//  Created by Li Kai on 2018/10/7.
//  https://lookin.work
//

#import "LKProgressIndicatorView.h"

const CGFloat InitialIndicatorProgressWhenFetchHierarchy = .7;

@interface LKProgressIndicatorView ()

@property(nonatomic, assign, readwrite) CGFloat progress;
@property(nonatomic, strong) CALayer *fillLayer;

@end

@implementation LKProgressIndicatorView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.fillLayer = [CALayer new];
        self.fillLayer.backgroundColor = [LKHelper accentColor].CGColor;
        [self.layer addSublayer:self.fillLayer];
        [self.fillLayer lookin_removeImplicitAnimations];
        
        self.progress = 0;
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.fillLayer).x(0).width(self.$width * self.progress).height(self.$height).y(0);
}

- (id)animationForKey:(NSAnimatablePropertyKey)key {
    if ([key isEqualToString:@"progress"]) {
        return [CABasicAnimation animation];
    }
    return [super animationForKey:key];
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    $(self.fillLayer).x(0).width(self.$width * progress).height(self.$height).y(0);
}

- (void)resetToZero {
    self.progress = 0;
}

- (void)animateToProgress:(CGFloat)progress {
    [self animateToProgress:progress duration:.5];
}

- (void)animateToProgress:(CGFloat)progress duration:(NSTimeInterval)duration {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = duration;
        self.animator.progress = progress;
    } completionHandler:nil];
}

- (void)finishWithCompletion:(void (^)(void))completionBlock {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = .1;
        self.animator.progress = 1;
    } completionHandler:^{
        if (completionBlock) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.progress = 0;
        });
    }];
}

@end
