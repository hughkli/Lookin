//
//  DanceScriptManager.m
//  LookinClient
//
//  Created by likai.123 on 2023/12/18.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "DanceScriptManager.h"
@import AppCenter;
@import AppCenterAnalytics;

@implementation DanceScriptManager

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static DanceScriptManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

- (void)handleText:(NSString *)json {
    if (!json) {
        AlertError(LookinErr_Inner, CurrentKeyWindow);
        return;
    }
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (error) {
        NSString *msg = [NSString stringWithFormat:@"Failed to parse: %@", json];
        AlertErrorText(@"Failed", msg, CurrentKeyWindow);
        NSAssert(NO, @"");
        return;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        NSString *msg = [NSString stringWithFormat:@"Unexpected format: %@", json];
        AlertErrorText(@"Failed", msg, CurrentKeyWindow);
        return;
    }
    NSString *type = dict[@"type"];
    NSString *method = dict[@"method"];
    NSString *path = dict[@"build_path"];
    if (!type || !method || !path) {
        NSString *msg = [NSString stringWithFormat:@"Unexpected format: %@", json];
        AlertErrorText(@"Failed", msg, CurrentKeyWindow);
        return;
    }
    [self executeWithType:type method:method path:path];
}

// 把 sh 脚本从 App Content 里 Copy 出来（不确定有没有必要）
- (NSString *)copyScriptFromAppToDisk {
    NSString *newScriptPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Lookin_DanceJump.sh"];
    //    NSString *desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) firstObject];
    //    NSString *newScriptPath = [desktopPath stringByAppendingPathComponent:@"Lookin_DanceJump.sh"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:newScriptPath]) {
        return newScriptPath;
    }
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *scriptPath = [[mainBundle URLForResource:@"DanceScript" withExtension:@"sh"] relativePath];
    if (!scriptPath || ![[NSFileManager defaultManager] fileExistsAtPath:scriptPath]) {
        NSString *text = [NSString stringWithFormat: @"Cannot find script: %@", scriptPath];
        AlertErrorText(@"Failed", text, CurrentKeyWindow);
        return nil;
    }
    BOOL succ = [[NSFileManager defaultManager] copyItemAtPath:scriptPath toPath:newScriptPath error:nil];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithShort:0755] forKey:NSFilePosixPermissions];
    [[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:newScriptPath error:nil];
    if (!succ) {
        AlertErrorText(@"Failed", @"Copy script error", CurrentKeyWindow);
        return nil;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:newScriptPath]) {
        AlertErrorText(@"Failed", @"Copy script weird error", CurrentKeyWindow);
        return nil;
    }
    return newScriptPath;
}

/*
 
 对应 lookin_source 的类型是这个 json 结构
 {"type":"DanceUIApp.ContentView","method":"body.get","build_path":"\/Users\/bytedance\/Library\/Developer\/Xcode\/DerivedData\/DanceUIApp-ayaxbucdgzeouqefaavnvvhsjpvj\/Build\/Products\/Debug-iphonesimulator\/DanceUIApp.app\/DanceUIApp"}
 
 传参的顺序是 sh viewdebug.sh build_path type method
 */
- (void)executeWithType:(NSString *)type method:(NSString *)method path:(NSString *)buildPath {
    NSString *scriptPath = [self copyScriptFromAppToDisk];
    // 创建 NSTask 对象
    NSTask *task = [[NSTask alloc] init];
    
    // 设置要执行的命令
    [task setLaunchPath:@"/bin/bash"];
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@ %@ %@ %@", scriptPath, buildPath, type, method],
                          nil];
    [task setArguments:arguments];
    
    // 创建管道用于获取输出
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    // 开始任务
    [task launch];
    
    // 从管道中读取输出
    NSFileHandle *file = [pipe fileHandleForReading];
    NSData *data = [file readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // 输出脚本执行结果
    NSLog(@"脚本执行输出：%@", output);
    
    [MSACAnalytics trackEvent:@"DanceJump"];
}

@end
