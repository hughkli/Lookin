//
//  LKMeasureResultView.h
//  Lookin
//
//  Created by Li Kai on 2019/10/21.
//  https://lookin.work
//

#import "LKBaseView.h"

@interface LKMeasureResultView : LKBaseView

- (void)renderWithMainRect:(CGRect)mainRect mainImage:(LookinImage *)mainImage referRect:(CGRect)referRect referImage:(LookinImage *)referImage;

@end
