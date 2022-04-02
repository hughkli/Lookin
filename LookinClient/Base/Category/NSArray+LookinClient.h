//
//  NSArray+LookinClient.h
//  Lookin
//
//  Created by Li Kai on 2019/8/14.
//  https://lookin.work
//

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

@interface NSArray<__covariant ValueType> (LookinClient)

- (NSArray<ValueType> *)lk_visibleViews;

@end
