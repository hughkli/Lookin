//
//  AppDelegate.m
//  Lookin
//
//  Created by Li Kai on 2018/8/4.
//  https://lookin.work
//

#import "AppDelegate.h"
#import "LKNavigationManager.h"
#import "LKConnectionManager.h"
#import "LKPreferenceManager.h"
#import "LKAppMenuManager.h"
#import "LKLaunchWindowController.h"
#import "LookinDocument.h"
#import "NSString+Score.h"
#import "LookinDashboardBlueprint.h"

@interface AppDelegate ()

@property(nonatomic, assign) BOOL launchedToOpenFile;

@end

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [[LKAppMenuManager sharedInstance] setup];
    
    if (@available(macOS 10.14, *)) {
        [RACObserve([LKPreferenceManager mainManager], appearanceType) subscribeNext:^(NSNumber *number) {
            LookinPreferredAppeanranceType type = [number integerValue];
            switch (type) {
                case LookinPreferredAppeanranceTypeDark:
                    NSApp.appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
                    break;
                case LookinPreferredAppeanranceTypeLight:
                    NSApp.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
                    break;
                default:
                    NSApp.appearance = nil;
                    break;
            }
        }];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self _extractServerFrameworkIfNeeded];
    
    [LKConnectionManager sharedInstance];
    if (!self.launchedToOpenFile) {
        [[LKNavigationManager sharedInstance] showLaunch];
    }
    
#ifdef DEBUG
    [self _runTests];
#endif
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    self.launchedToOpenFile = YES;
    NSError *error;
    BOOL isSuccessful = [[LKNavigationManager sharedInstance] showReaderWithFilePath:filename error:&error];    
    return isSuccessful;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // 清理打开 UIImageView 的图片时创建的临时文件
    NSArray<NSString *> *tempImageFilesToDelete = [LKHelper sharedInstance].tempImageFiles;
    if (tempImageFilesToDelete.count == 0) {
        return NSTerminateNow;
    }
    [tempImageFilesToDelete enumerateObjectsUsingBlock:^(NSString * _Nonnull path, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isSucc = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        if (!isSucc) {
            NSAssert(NO, @"");
        }
    }];
    return NSTerminateNow;
}

#pragma mark - LookinServer

- (void)_extractServerFrameworkIfNeeded {
    // /Users/hughkli/Library/Developer/Xcode/DerivedData/Lookin-aakuktsqhjnrovcimtdtpcbdyqqh/Build/Products/Debug/Lookin Experimental.app
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *frameworkDirPath = [bundlePath stringByAppendingPathComponent:@"/Contents/Resources/LookinServerFramework/"];
    NSString *unzippedFilePath = [frameworkDirPath stringByAppendingPathComponent:@"LookinServer.framework"];
    
    NSFileManager *mng = [NSFileManager defaultManager];
    BOOL alreadyZipped = [mng fileExistsAtPath:unzippedFilePath isDirectory:NULL];
    if (alreadyZipped) {
        return;
    }
    
    NSString *zipFilePath = [frameworkDirPath stringByAppendingPathComponent:@"LookinServer.zip"];
    if (![mng fileExistsAtPath:zipFilePath isDirectory:NULL]) {
        // error, zip 文件不存在
        return;
    }
    NSArray *arguments = [NSArray arrayWithObject:zipFilePath];
    NSTask *unzipTask = [[NSTask alloc] init];
    [unzipTask setLaunchPath:@"/usr/bin/unzip"];
    [unzipTask setCurrentDirectoryPath:frameworkDirPath];
    [unzipTask setArguments:arguments];
    [unzipTask launch];
}

#pragma mark - Test

/// 一些单元测试
- (void)_runTests {
    // 确保 LookinAttrGroupIdentifier 的 value 没有重复
    NSArray<LookinAttrGroupIdentifier> *allGroupIDs = [LookinDashboardBlueprint groupIDs];
    NSSet<LookinAttrGroupIdentifier> *allGroupIDs_unique = [NSSet setWithArray:allGroupIDs];
    if (allGroupIDs.count != allGroupIDs_unique.count) {
        NSAssert(NO, @"");
    }
    
    // 确保 LookinAttrSectionIdentifier 的 value 没有重复
    NSMutableArray<LookinAttrSectionIdentifier> *allSecIDs = [NSMutableArray array];
    [allGroupIDs enumerateObjectsUsingBlock:^(LookinAttrGroupIdentifier  _Nonnull groupID, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<LookinAttrSectionIdentifier> *secIDs = [LookinDashboardBlueprint sectionIDsForGroupID:groupID];
        [allSecIDs addObjectsFromArray:secIDs];
    }];
    NSSet<LookinAttrSectionIdentifier> *allSecIDs_unique = [NSSet setWithArray:allSecIDs];
    if (allSecIDs.count != allSecIDs_unique.count) {
        NSAssert(NO, @"");
    }
    
    // 确保 LookinAttrIdentifier 的 value 没有重复
    NSMutableArray<LookinAttrIdentifier> *allAttrIDs = [NSMutableArray array];
    [allSecIDs enumerateObjectsUsingBlock:^(LookinAttrSectionIdentifier  _Nonnull secID, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<LookinAttrIdentifier> *attrIDs = [LookinDashboardBlueprint attrIDsForSectionID:secID];
        [allAttrIDs addObjectsFromArray:attrIDs];
    }];
    NSSet<LookinAttrIdentifier> *allAttrIDs_unique = [NSSet setWithArray:allAttrIDs];
    if (allAttrIDs.count != allAttrIDs_unique.count) {
        NSAssert(NO, @"");
    }
}

@end
