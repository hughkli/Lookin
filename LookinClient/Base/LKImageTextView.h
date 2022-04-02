//
//  LKImageTextView.h
//  Lookin
//
//  Created by Li Kai on 2019/6/19.
//  https://lookin.work
//

#import "LKBaseView.h"

@interface LKImageTextView : LKBaseView

@property(nonatomic, strong, readonly) NSImageView *imageView;
@property(nonatomic, strong, readonly) LKLabel *label;

@property(nonatomic, assign) HorizontalMargins imageMargins;

@end
