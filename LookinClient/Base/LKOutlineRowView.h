//
//  LKOutlineRowView.h
//  Lookin
//
//  Created by Li Kai on 2019/4/20.
//  https://lookin.work
//

#import "LKTableRowView.h"

typedef NS_ENUM(NSUInteger, LKOutlineRowViewStatus) {
    LKOutlineRowViewStatusNotExpandable,
    LKOutlineRowViewStatusExpanded,
    LKOutlineRowViewStatusCollapsed
};

@interface LKOutlineRowView : LKTableRowView {
    @protected
    CGFloat _imageLeft;
    CGFloat _imageRight;
    CGFloat _titleLeft;
    CGFloat _subtitleLeft;
}

- (instancetype)initWithCompactUI:(BOOL)compact;

@property(nonatomic, strong, readonly) NSButton *disclosureButton;

@property(nonatomic, strong) NSImage *image;
@property(nonatomic, strong, readonly) NSImageView *imageView;

@property(nonatomic, assign) LKOutlineRowViewStatus status;

@property(nonatomic, assign) NSUInteger indentLevel;

- (void)updateContentWidth;

+ (CGFloat)dislosureMidXWithIndentLevel:(NSUInteger)level;

@end

@interface LKOutlineRowView (NSSubclassingHooks)

+ (CGFloat)insetLeft;

@end
