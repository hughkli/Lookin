//
//  LKMethodTraceDataSource.m
//  Lookin
//
//  Created by Li Kai on 2019/5/24.
//  https://lookin.work
//

#import "LKMethodTraceDataSource.h"
#import "LKInspectableApp.h"
#import "LKAppsManager.h"
#import "LookinMethodTraceRecord.h"

@interface LKMethodTraceDataSource ()

@property(nonatomic, copy, readwrite) NSArray<NSString *> *allClassNames;
@property(nonatomic, copy, readwrite) NSArray<LookinMethodTraceRecord *> *records;

@property(nonatomic, strong, readwrite) NSArray<NSDictionary<NSString *, id> *> *menuData;

@end

@implementation LKMethodTraceDataSource

- (instancetype)init {
    if (self = [super init]) {
        self.records = [NSArray array];
        [[self syncData] subscribeNext:^(id  _Nullable x) {}];
    }
    return self;
}

- (RACSignal *)syncData {
    if (!InspectingApp) {
        return [RACSignal error:LookinErr_NoConnect];
    }
    if (self.allClassNames) {
        return [RACSignal return:nil];
    }
    @weakify(self);
    return [[[InspectingApp fetchClassesAndMethodTraceList] doNext:^(NSDictionary *dict) {
        @strongify(self);
        self.allClassNames = [dict[@"classes"] lookin_sortedArrayByStringLength];
        self.menuData = dict[@"activeList"];
        [self clearAllRecords];
        
    }] doError:^(NSError * _Nonnull error) {
        @strongify(self);
        self.menuData = nil;
    }];
}

- (RACSignal *)fetchSelectorNamesWithClass:(NSString *)className {
    return [[[LKAppsManager sharedInstance].inspectingApp fetchSelectorNamesWithClass:className hasArg:YES] map:^id _Nullable(NSArray<NSString *> *value) {
        return [[value lookin_nonredundantArray] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            // 字符串长度从短到长
            if (obj1.length > obj2.length) {
                return NSOrderedDescending;
            } else if (obj1.length == obj2.length) {
                return NSOrderedSame;
            } else {
                return NSOrderedAscending;
            }
        }];
    }];
}

- (RACSignal *)addWithClassName:(NSString *)className selName:(NSString *)selName {
    if (!className.length || !selName.length) {
        return [RACSignal error:LookinErr_Inner];
    }
    if ([selName isEqualToString:@"dealloc"]) {
        return [RACSignal error:LookinErrorMake(NSLocalizedString(@"Lookin doesn't support adding \"-(void)dealloc\" method.", nil), @"")];
    }
    @weakify(self);
    return [[[LKAppsManager sharedInstance].inspectingApp addMethodTraceWithClassName:className selName:selName] doNext:^(id  _Nullable x) {
        @strongify(self);
        self.menuData = x;
    }];
}

- (void)deleteWithClassName:(NSString *)className selName:(NSString *)selName {
    if (!className.length) {
        return;
    }
    @weakify(self);
    [[[LKAppsManager sharedInstance].inspectingApp deleteMethodTraceWithClassName:className selName:selName] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.menuData = x;
    }];
}

- (void)handleReceivingRecord:(LookinMethodTraceRecord *)record {
    if (record) {
        self.records = [self.records arrayByAddingObject:record];        
    }
}

- (void)clearAllRecords {
    self.records = [NSArray array];
}

- (void)dealloc {
    NSLog(@"LKMethodTraceDataSource dealloc");
}

@end
