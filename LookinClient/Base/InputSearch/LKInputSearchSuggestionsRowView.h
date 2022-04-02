//
//  LKInputSearchSuggestionsRowView.h
//  Lookin
//
//  Created by Li Kai on 2019/6/3.
//  https://lookin.work
//

#import <Cocoa/Cocoa.h>

@interface LKInputSearchSuggestionsRowView : NSTableRowView

@property(nonatomic, strong, readonly) LKLabel *titleLabel;
@property(nonatomic, strong, readonly) NSImageView *imageView;

- (CGFloat)bestWidth;

@end
