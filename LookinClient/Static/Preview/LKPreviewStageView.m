//
//  LKViewsPreviewStageView.m
//  Lookin
//
//  Created by Li Kai on 2018/8/6.
//  https://lookin.work
//

#import "LKPreviewStageView.h"

@implementation LKPreviewStageView

- (void)mouseMoved:(NSEvent *)event {
    [super mouseMoved:event];
    if ([self.delegate respondsToSelector:@selector(previewStageView:mouseMoved:)]) {
        [self.delegate previewStageView:self mouseMoved:event];
    }
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    [self.trackingAreas enumerateObjectsUsingBlock:^(NSTrackingArea * _Nonnull oldArea, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeTrackingArea:oldArea];
    }];
    
    NSTrackingArea *newArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseMoved|NSTrackingActiveInKeyWindow|NSTrackingInVisibleRect owner:self userInfo:nil];
    [self addTrackingArea:newArea];
}

- (void)resetCursorRects {
    [super resetCursorRects];
    if ([self.delegate respondsToSelector:@selector(didResetCursorRectsInPreviewStageView:)]) {
        [self.delegate didResetCursorRectsInPreviewStageView:self];
    }
}

@end
