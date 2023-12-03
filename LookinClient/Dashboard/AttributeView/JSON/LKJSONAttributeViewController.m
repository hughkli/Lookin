//
//  LKJSONAttributeViewController.m
//  LookinClient
//
//  Created by likai.123 on 2023/12/4.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "LKJSONAttributeViewController.h"
#import "LKJSONAttributeItem.h"
#import "LKTableView.h"

@interface LKJSONAttributeViewController ()

@property(nonatomic, strong) NSMutableArray<LKJSONAttributeItem *> *rootItems;
@property(nonatomic, strong) LKTableView *tableView;

@end

@implementation LKJSONAttributeViewController


- (void)renderWithJSON:(NSString *)json {
    //    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    //    NSError *error;
    //    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    //    if (error) {
    //        NSLog(@"转换失败: %@", error);
    //        NSAssert(NO, @"");
    //        return;
    //    }
    //    self.textView.string = json;
    
    //    self.textView.string = self.initialText;
    //    self.textView.editable = self.canEdit;
}

@end
