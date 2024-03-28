//
//  LKWarningManager.m
//  LookinClient
//
//  Created by LikaiMacStudioWork on 2024/3/28.
//  Copyright © 2024 hughkli. All rights reserved.
//

#import "LKWarningManager.h"
#import "LKWarningItem.h"

@interface LKWarningManager ()

@property(nonatomic, assign) BOOL mainWorkspaceHasAppeard;
@property(nonatomic, strong) LKWarningItem *item;

@end

@implementation LKWarningManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LKWarningManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (void)handleReceiveServerInfo:(NSDictionary *)info {
    LKWarningItem *item = [LKWarningItem parseDict:info];
    if (!item) {
        NSAssert(NO, @"");
        return;
    }
    self.item = item;
}

- (void)notifyMainWorkspaceDidAppear {
    self.mainWorkspaceHasAppeard = YES;
}

- (void)showWarningIfNeeded {
    if (!self.mainWorkspaceHasAppeard) {
        return;
    }
    if (!self.item) {
        return;
    }
    NSArray<NSString *> *displayedIDList = [[NSUserDefaults standardUserDefaults] arrayForKey:@"DisplayedWarnIDList"];
    if ([displayedIDList isKindOfClass:[NSArray class]] && [displayedIDList containsObject:self.item.itemID]) {
        return;
    }
    // show
    NSMutableArray *newDisplayedIDList = [NSMutableArray array];
    if (displayedIDList) {
        [newDisplayedIDList addObjectsFromArray:displayedIDList];
    }
    [newDisplayedIDList addObject:self.item.itemID];
    [[NSUserDefaults standardUserDefaults] setObject:[newDisplayedIDList copy] forKey:@"DisplayedWarnIDList"];
}

@end
