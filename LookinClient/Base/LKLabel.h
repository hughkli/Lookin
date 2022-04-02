//
//  LKLabel.h
//  Lookin
//
//  Created by Li Kai on 2018/8/4.
//  https://lookin.work
//

#import <Cocoa/Cocoa.h>

@class LKTwoColors;

@interface LKLabel : NSTextField

/// 默认为 nil
@property(nonatomic, strong) LKTwoColors *textColors;
/// 默认为 nil
@property(nonatomic, strong) LKTwoColors *backgroundColors;


@end
