//
//  LKNavigationManager.m
//  Lookin
//
//  Created by Li Kai on 2018/11/3.
//  https://lookin.work
//

#import "LKNavigationManager.h"
#import "LKLaunchWindowController.h"
#import "LKStaticWindowController.h"
#import "LKPreferenceWindowController.h"
#import "LKStaticViewController.h"
#import "LKPreviewController.h"
#import "LKPreviewController.h"
#import "LKAppsManager.h"
#import "LookinHierarchyFile.h"
#import "LKReadWindowController.h"
#import "LKMethodTraceWindowController.h"
#import "LKConsoleViewController.h"
#import "LKPreferenceManager.h"
#import "LKAboutWindowController.h"

@interface LKNavigationManager ()

@property(nonatomic, strong) LKPreferenceWindowController *preferenceWindowController;
@property(nonatomic, strong) LKAboutWindowController *aboutWindowController;

@end

@implementation LKNavigationManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LKNavigationManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (void)showLaunch {
    _launchWindowController = [[LKLaunchWindowController alloc] init];
    [self.launchWindowController showWindow:self];
}

- (void)showStaticWorkspace {
    if (!self.staticWindowController) {
        _staticWindowController = [[LKStaticWindowController alloc] init];
        self.staticWindowController.window.delegate = self;
    }
    [self.staticWindowController showWindow:self];
}

- (void)closeLaunch {
    [self.launchWindowController close];
    _launchWindowController = nil;
}

- (void)showPreference {
    if (!self.preferenceWindowController) {
        self.preferenceWindowController = [LKPreferenceWindowController new];
        self.preferenceWindowController.window.delegate = self;
    }
    [self.preferenceWindowController showWindow:self];
}

- (void)showAbout {
    if (!self.aboutWindowController) {
        _aboutWindowController = [[LKAboutWindowController alloc] init];
        self.aboutWindowController.window.delegate = self;
    }
    [self.aboutWindowController showWindow:self];
}

- (void)showMethodTrace {
    if (!self.methodTraceWindowController) {
        if (![LKAppsManager sharedInstance].inspectingApp) {
            NSWindow *window = self.staticWindowController.window;
            AlertErrorText(NSLocalizedString(@"Can not use Method Trace at this time.", nil), NSLocalizedString(@"Lost connection with the iOS app.", nil), window);
            return;
        }
        
        _methodTraceWindowController = [LKMethodTraceWindowController new];
        self.methodTraceWindowController.window.delegate = self;
    }
    [self.methodTraceWindowController showWindow:self];
}

- (LKWindowController *)currentKeyWindowController {
    NSWindow *keyWindow = [NSApplication sharedApplication].keyWindow;
    if ([keyWindow.windowController isKindOfClass:[LKWindowController class]]) {
        return keyWindow.windowController;
    }
    return nil;
}

- (BOOL)showReaderWithFilePath:(NSString *)filePath error:(NSError **)error {
    NSData *data = [NSData dataWithContentsOfFile:filePath options:0 error:error];
    if (!data) {
        return NO;
    }
    
    id dataObj = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSObject class] fromData:data error:error];
    if (!dataObj) {
        // 比如拖了一个 pdf 格式的文件进来就会走到这里
        if (error) {
            *error = [NSError errorWithDomain:LookinErrorDomain code:LookinErrCode_UnsupportedFileType userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed to open the document.", nil), NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"The file type is not supported.", nil)}];
        }
        return NO;
    }
    
    NSError *verifyError = [LookinHierarchyFile verifyHierarchyFile:dataObj];
    if (verifyError) {
        // 有问题，无法打开
        if (error) {
            *error = verifyError;
        }
        return NO;
    }
    
    // 文件校验无误
    NSString *title = [[NSFileManager defaultManager] displayNameAtPath:filePath];
    [self showReaderWithHierarchyFile:dataObj title:title];
    return YES;
}

- (void)showReaderWithHierarchyFile:(LookinHierarchyFile *)file title:(NSString *)title {
    LKReadWindowController *wc = [[LKReadWindowController alloc] initWithFile:file];
    wc.window.title = title ? : @"";
    wc.window.delegate = self;
    [wc showWindow:self];
    
    if (!self.readWindowControllers) {
        self.readWindowControllers = [NSMutableArray array];
    }
    [self.readWindowControllers addObject:wc];
}

#pragma mark - <NSWindowDelegate>


/**
 staticWindowController 关闭时不要直接释放，因为点击 methodTrace 窗口的“连接已断开” tips 需要唤起 static 窗口来切换 App
 */
- (void)windowWillClose:(NSNotification *)notification {
    NSWindow *closingWindow = notification.object;
    
    if (closingWindow == self.preferenceWindowController.window) {
        _preferenceWindowController = nil;
        
    } else if (closingWindow == self.staticWindowController.window) {
        [closingWindow saveFrameUsingName:LKWindowSizeName_Static];
        
    } else if (closingWindow == self.methodTraceWindowController.window) {
        [closingWindow saveFrameUsingName:LKWindowSizeName_Methods];
        _methodTraceWindowController = nil;
        
    } else if (closingWindow == self.aboutWindowController.window) {
        self.aboutWindowController = nil;
        
    } else {
        LKReadWindowController *wc = [self.readWindowControllers lookin_firstFiltered:^BOOL(LKReadWindowController *obj) {
            return obj.window == closingWindow;
        }];
        [self.readWindowControllers removeObject:wc];
    }
}

@end
