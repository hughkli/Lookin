//
//  LKImageButton.h
//  Lookin
//
//  Created by Li Kai on 2018/9/1.
//  https://lookin.work
//

#import "LKBaseControl.h"

@interface LKImageControl : LKBaseControl {
    @protected
    NSImageView *_imageView;
}

@property(nonatomic, strong) NSImage *image;

@end
