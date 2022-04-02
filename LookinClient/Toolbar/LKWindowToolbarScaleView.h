//
//  LKWindowToolbarScaleView.h
//  Lookin
//
//  Created by Li Kai on 2019/10/14.
//  https://lookin.work
//

#import "LKBaseView.h"

@interface LKWindowToolbarScaleView : LKBaseView

@property(nonatomic, strong, readonly) NSSlider *slider;
@property(nonatomic, strong, readonly) NSButton *decreaseButton;
@property(nonatomic, strong, readonly) NSButton *increaseButton;

@end
