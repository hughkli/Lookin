//
//  LKReadWindowController.h
//  Lookin
//
//  Created by Li Kai on 2019/5/12.
//  https://lookin.work
//

#import "LKWindowController.h"

@class LookinHierarchyFile, LKPreferenceManager;

@interface LKReadWindowController : LKWindowController

- (instancetype)initWithFile:(LookinHierarchyFile *)file;

@end
