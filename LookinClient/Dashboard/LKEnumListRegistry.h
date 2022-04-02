//
//  LKEnumListRegistry.h
//  Lookin
//
//  Created by Li Kai on 2018/11/21.
//  https://lookin.work
//

#import <Foundation/Foundation.h>

@interface LKEnumListRegistryKeyValueItem : NSObject

@property(nonatomic, copy) NSString *desc;
@property(nonatomic, assign) long value;
@property(nonatomic, assign) NSInteger availableOSVersion;

@end

@interface LKEnumListRegistry : NSObject

+ (instancetype)sharedInstance;

- (NSArray<LKEnumListRegistryKeyValueItem *> *)itemsForEnumName:(NSString *)enumName;

- (NSString *)descForEnumName:(NSString *)enumName value:(long)value;

@end
