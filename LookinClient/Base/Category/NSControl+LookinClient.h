//
//  NSControl+LookinClient.h
//  Lookin
//
//  Created by Li Kai on 2019/8/13.
//  https://lookin.work
//

#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>

@interface NSControl (LookinClient)

- (CGFloat)heightForWidth:(CGFloat)width;

- (CGFloat)bestHeight;

- (CGFloat)bestWidth;

- (NSSize)bestSize;

@end
