//
//  LKExportManager.h
//  Lookin
//
//  Created by Li Kai on 2019/5/12.
//  https://lookin.work
//

#import <Foundation/Foundation.h>

@class LookinHierarchyInfo, LookinDisplayItem;

@interface LKExportManager : NSObject

+ (instancetype)sharedInstance;

- (NSData *)dataFromHierarchyInfo:(LookinHierarchyInfo *)info imageCompression:(CGFloat)compression fileName:(NSString **)fileName;

+ (void)exportScreenshotWithDisplayItem:(LookinDisplayItem *)displayItem;

@end
