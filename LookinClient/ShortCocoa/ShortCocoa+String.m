//
//  ShortCocoa+String.m
//  ShortCocoa
//
//  Copyright © 2018年 hughkli. All rights reserved.
//

#import "ShortCocoa+String.h"
#import "ShortCocoa+Private.h"

@implementation ShortCocoa (String)

- (NSString *)string {
    NSString *string = self.cachedAttrString.string;
    return string;
}

- (NSAttributedString *)attrString {
    NSAttributedString *string = [self.cachedAttrString copy];
    return string;
}

- (NSMutableAttributedString *)mAttrString {
    return self.cachedAttrString;
}

- (ShortCocoa * (^)(ShortCocoaString))prepend {
    return ^(ShortCocoaString string) {
        if (string) {
            NSMutableAttributedString *attrString = [ShortCocoaHelper attrStringFromShortCocoaString:string];
            [self.cachedAttrString insertAttributedString:attrString atIndex:0];
        }
        return self;
    };
}

- (ShortCocoa * (^)(_Nullable ShortCocoaString, NSUInteger location))insert {
    return ^(ShortCocoaString string, NSUInteger location) {
        if (string) {
            NSMutableAttributedString *attrString = [ShortCocoaHelper attrStringFromShortCocoaString:string];
            [self.cachedAttrString insertAttributedString:attrString atIndex:location];
        }
        return self;
    };
}

- (ShortCocoa * (^)(ShortCocoaString))add {
    return ^(ShortCocoaString string) {
        if (string) {
            NSMutableAttributedString *attrString = [ShortCocoaHelper attrStringFromShortCocoaString:string];
            [self.cachedAttrString appendAttributedString:attrString];
        }
        return self;
    };
}

- (ShortCocoa * (^)(ShortCocoaImage image, CGFloat baselineOffset, CGFloat marginLeft, CGFloat marginRight))addImage {
    return ^(ShortCocoaImage image, CGFloat baselineOffset, CGFloat marginLeft, CGFloat marginRight) {
        id UI_or_NS_Image = [ShortCocoaHelper imageFromShortCocoaImage:image];
        NSAttributedString *attrString = [self attributedStringWithImage:UI_or_NS_Image baselineOffset:baselineOffset leftMargin:marginLeft rightMargin:marginRight];
        [self.cachedAttrString appendAttributedString:attrString];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))addSpace {
    return ^(CGFloat width) {
        NSAttributedString *attrString = [self attributedStringWithFixedSpace:width];
        [self.cachedAttrString appendAttributedString:attrString];
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))lineHeight {
    return ^(CGFloat lineHeight) {
        if ([self.cachedAttrString length]) {
            NSMutableParagraphStyle *paraStyle = [ShortCocoaHelper paragraphStyleForAttributedString:self.cachedAttrString];
            paraStyle.minimumLineHeight = lineHeight;
            paraStyle.maximumLineHeight = lineHeight;
            [self.cachedAttrString addAttribute:NSParagraphStyleAttributeName value:paraStyle.copy range:NSMakeRange(0, self.cachedAttrString.length)];
        }
        return self;
    };
}

- (ShortCocoa * (^)(CGFloat))baselineOffset {
    return ^(CGFloat value) {
        if (self.cachedAttrString.length) {
            [self.cachedAttrString addAttribute:NSBaselineOffsetAttributeName value:@(value) range:NSMakeRange(0, self.cachedAttrString.length)];
        }
        return self;
    };
}

- (ShortCocoa *)strikethrough {
    if (self.cachedAttrString.length) {
        [self.cachedAttrString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, self.cachedAttrString.length)];
    }
    return self;
}

- (ShortCocoa * (^)(CGFloat))kern {
    return ^(CGFloat value) {
        if (self.cachedAttrString.length) {
            [self.cachedAttrString addAttribute:NSKernAttributeName value:@(value) range:NSMakeRange(0, self.cachedAttrString.length)];
        }
        return self;
    };
}

- (ShortCocoa *)underline {
    if (self.cachedAttrString.length) {
        [self.cachedAttrString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, self.cachedAttrString.length)];
    }
    return self;
}

#pragma mark - Private

#if TARGET_OS_IPHONE
- (NSAttributedString *)attributedStringWithImage:(UIImage *)image baselineOffset:(CGFloat)baselineOffset leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin {
#elif TARGET_OS_MAC
- (NSAttributedString *)attributedStringWithImage:(NSImage *)image baselineOffset:(CGFloat)baselineOffset leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin {
#endif
    if (!image) {
        return nil;
    }
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    NSMutableAttributedString *string = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
    [string addAttribute:NSBaselineOffsetAttributeName value:@(baselineOffset) range:NSMakeRange(0, string.length)];
    if (leftMargin > 0) {
        [string insertAttributedString:[self attributedStringWithFixedSpace:leftMargin] atIndex:0];
    }
    if (rightMargin > 0) {
        [string appendAttributedString:[self attributedStringWithFixedSpace:rightMargin]];
    }
    return string;
}
    
- (NSAttributedString *)attributedStringWithFixedSpace:(CGFloat)width {
#if TARGET_OS_IPHONE
    UIGraphicsBeginImageContext(CGSizeMake(width, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
#elif TARGET_OS_MAC
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width, 1)];
#endif
    return [self attributedStringWithImage:image baselineOffset:0 leftMargin:0 rightMargin:0];
}
    
@end
