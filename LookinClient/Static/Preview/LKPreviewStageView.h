//
//  LKPreviewStageView.h
//  Lookin
//
//  Created by Li Kai on 2018/8/6.
//  https://lookin.work
//

#import "LKBaseView.h"

@class LKPreviewStageView;

@protocol LKPreviewStageViewDelegate <NSObject>

- (void)previewStageView:(LKPreviewStageView *)view mouseMoved:(NSEvent *)event;
- (void)didResetCursorRectsInPreviewStageView:(LKPreviewStageView *)view;

@end

@interface LKPreviewStageView : LKBaseView

@property(nonatomic, weak) id<LKPreviewStageViewDelegate> delegate;

@end
