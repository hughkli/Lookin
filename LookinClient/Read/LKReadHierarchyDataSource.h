//
//  LKReadHierarchyDataSource.h
//  Lookin
//
//  Created by Li Kai on 2019/5/12.
//  https://lookin.work
//

#import "LKHierarchyDataSource.h"

@class LookinHierarchyFile, LKPreferenceManager;

@interface LKReadHierarchyDataSource : LKHierarchyDataSource

- (instancetype)initWithFile:(LookinHierarchyFile *)file preferenceManager:(LKPreferenceManager *)manager;

@end
