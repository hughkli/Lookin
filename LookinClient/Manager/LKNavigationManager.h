//
//  LKNavigationManager.h
//  Lookin
//
//  Created by Li Kai on 2018/11/3.
//  https://lookin.work
//

#import <Foundation/Foundation.h>

@class LKLaunchWindowController, LKStaticWindowController, LKDynamicWindowController, LKWindowController, LKReadWindowController, LookinHierarchyInfo, LookinHierarchyFile;

@interface LKNavigationManager : NSObject <NSWindowDelegate>

+ (instancetype)sharedInstance;

- (void)showLaunch;

- (void)closeLaunch;

- (void)showStaticWorkspace;

- (void)showPreference;

- (void)showAbout;

- (BOOL)showReaderWithFilePath:(NSString *)filePath error:(NSError **)error;
- (void)showReaderWithHierarchyFile:(LookinHierarchyFile *)file title:(NSString *)title;

@property(nonatomic, strong, readonly) LKLaunchWindowController *launchWindowController;
@property(nonatomic, strong, readonly) LKStaticWindowController *staticWindowController;
@property(nonatomic, strong) NSMutableArray<LKReadWindowController *> *readWindowControllers;

- (LKWindowController *)currentKeyWindowController;

@property(nonatomic, assign) CGFloat windowTitleBarHeight;

@end
