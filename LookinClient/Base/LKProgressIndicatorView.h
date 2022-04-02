//
//  LKMenuProgressIndicatorView.h
//  Lookin
//
//  Created by Li Kai on 2018/10/7.
//  https://lookin.work
//

#import "LKBaseView.h"

extern const CGFloat InitialIndicatorProgressWhenFetchHierarchy;

@interface LKProgressIndicatorView : LKBaseView

@property(nonatomic, assign, readonly) CGFloat progress;

- (void)resetToZero;

/// 默认 duration 为 0.3
- (void)animateToProgress:(CGFloat)progress;

- (void)animateToProgress:(CGFloat)progress duration:(NSTimeInterval)duration;

- (void)finishWithCompletion:(void (^)(void))completionBlock;

@end
