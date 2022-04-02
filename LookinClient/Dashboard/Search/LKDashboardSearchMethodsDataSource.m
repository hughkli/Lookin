//
//  LKDashboardSearchMethodsDataSource.m
//  Lookin
//
//  Created by Li Kai on 2019/9/6.
//  https://lookin.work
//

#import "LKDashboardSearchMethodsDataSource.h"
#import "LKAppsManager.h"

@interface LKDashboardSearchMethodsDataSource ()

/**
 @{
 @"UIView": @[@"layoutSubviews", @"addSubview:", ...],
 @"UIViewController": @[@"viewDidAppear:", ...],
 ...
 };
 */
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSArray<NSString *> *> *classesToSelsDict;

@end

@implementation LKDashboardSearchMethodsDataSource

- (instancetype)init {
    if (self = [super init]) {
        self.classesToSelsDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (RACSignal *)fetchNonArgMethodsListWithClass:(NSString *)className {
    if (!className.length) {
        return [RACSignal error:LookinErr_Inner];
    }
    if (![LKAppsManager sharedInstance].inspectingApp) {
        return [RACSignal error:LookinErr_NoConnect];
    }
    if ([self.classesToSelsDict objectForKey:className]) {
        return [RACSignal return:self.classesToSelsDict[className]];
    }
    
    @weakify(self);
    return [[[LKAppsManager sharedInstance].inspectingApp fetchSelectorNamesWithClass:className hasArg:NO] doNext:^(NSArray<NSString *> *sels) {
        @strongify(self);
        self.classesToSelsDict[className] = sels;
    }];
}

- (void)clearAllCache {
    [self.classesToSelsDict removeAllObjects];
}

@end
