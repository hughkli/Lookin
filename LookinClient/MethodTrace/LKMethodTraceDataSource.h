//
//  LKMethodTraceDataSource.h
//  Lookin
//
//  Created by Li Kai on 2019/5/24.
//  https://lookin.work
//

#import <Foundation/Foundation.h>

@class LookinMethodTraceRecord;

@interface LKMethodTraceDataSource : NSObject

@property(nonatomic, copy, readonly) NSArray<NSString *> *allClassNames;

- (RACSignal *)syncData;

- (RACSignal *)fetchSelectorNamesWithClass:(NSString *)className;

- (RACSignal *)addWithClassName:(NSString *)className selName:(NSString *)selName;
- (void)deleteWithClassName:(NSString *)className selName:(NSString *)selName;

- (void)handleReceivingRecord:(LookinMethodTraceRecord *)record;

/**
 @[
 @{@"class": @"UIViewController", @"sels": @[@"init", @"viewDidAppear:"]},
 @{@"class": @"UIView", @"sels": @[@"init", @"layoutSubviews"]}
 ];
 */
@property(nonatomic, strong, readonly) NSArray<NSDictionary<NSString *, id> *> *menuData;

@property(nonatomic, copy, readonly) NSArray<LookinMethodTraceRecord *> *records;
- (void)clearAllRecords;

@end
