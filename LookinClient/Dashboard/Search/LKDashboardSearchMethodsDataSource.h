//
//  LKDashboardSearchMethodsDataSource.h
//  Lookin
//
//  Created by Li Kai on 2019/9/6.
//  https://lookin.work
//

#import <Foundation/Foundation.h>

@interface LKDashboardSearchMethodsDataSource : NSObject

- (RACSignal *)fetchNonArgMethodsListWithClass:(NSString *)className;

- (void)clearAllCache;

@end
