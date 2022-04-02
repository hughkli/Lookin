//
//  NSPointerArray+LookinClient.h
//  Lookin
//
//  Created by Li Kai on 2019/5/9.
//  https://lookin.work
//

#import <Foundation/Foundation.h>

@interface NSPointerArray (LookinClient)

- (NSUInteger)lk_indexOfPointer:(void *)pointer;

- (BOOL)lk_containsPointer:(void *)pointer;

@end
