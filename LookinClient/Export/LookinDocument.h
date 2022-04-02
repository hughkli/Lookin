//
//  LookinDocument.h
//  Lookin
//
//  Created by Li Kai on 2019/6/26.
//  https://lookin.work
//

#import <Cocoa/Cocoa.h>

@class LookinHierarchyFile;

@interface LookinDocument : NSDocument

@property(nonatomic, strong) LookinHierarchyFile *hierarchyFile;

@end
