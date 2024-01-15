//
//  LKJSONAttributeContentView.m
//  LookinClient
//
//  Created by likai.123 on 2023/12/10.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "LKJSONAttributeContentView.h"
#import "LKJSONAttributeItem.h"
#import "LKTableView.h"
#import "LKOutlineRowView.h"
#import "LKTableRowView.h"

@interface LKJSONAttributeContentRowView : LKOutlineRowView

@end

@implementation LKJSONAttributeContentRowView

+ (CGFloat)insetLeft {
    return 0;
}

@end

@interface LKJSONAttributeContentView () <LKTableViewDelegate, LKTableViewDataSource>

@property(nonatomic, assign) BOOL useBigFont;

@property(nonatomic, strong) NSArray<LKJSONAttributeItem *> *rootItems;
@property(nonatomic, strong) NSMutableArray<LKJSONAttributeItem *> *flatItems;

@property(nonatomic, strong) LKTableView *tableView;

@property(nonatomic, assign) CGFloat rowHeight;

@end

@implementation LKJSONAttributeContentView


- (instancetype)initWithBigFont:(BOOL)bigFont {
    if (self = [super initWithFrame:NSZeroRect]) {
        self.tableView = [LKTableView new];
        self.tableView.drawsBackground = NO;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.adjustsSelectionAutomatically = NO;
        self.tableView.adjustsHoverAutomatically = NO;
        self.tableView.automaticallyAdjustsContentInsets = NO;
        if (bigFont) {
            self.tableView.contentInsets = NSEdgeInsetsMake(5, 0, 5, 0);
            self.rowHeight = 25;
        } else {
            self.tableView.contentInsets = NSEdgeInsetsMake(0, 0, 0, 0);
            self.rowHeight = 20;
        }
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.tableView).fullFrame;
}

- (void)renderWithJSON:(NSString *)json {
    [self buildModel:json];
    [self render];
}

- (void)buildModel:(NSString *)json {
    self.rootItems = nil;
    
    if (!json) {
        return;
    }
    
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (error) {
        NSLog(@"转换失败: %@", error);
        NSAssert(NO, @"");
        return;
    }
    if (![array isKindOfClass:[NSArray class]]) {
        return;
    }
    self.rootItems = [self createItemsFromArray:array];
}

- (NSArray<LKJSONAttributeItem *> *)createItemsFromArray:(NSArray *)rawArray {
    if (![rawArray isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSMutableArray *resultArray = [NSMutableArray array];
    
    [rawArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![dict isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSString *title = dict[@"title"];
        NSString *desc = dict[@"desc"];
        NSArray *details = dict[@"details"];
        
        LKJSONAttributeItem *item = [LKJSONAttributeItem new];
        item.titleText = title;
        item.desc = desc;
        item.expanded = YES;
        item.subItems = [self createItemsFromArray:details];
        
        [resultArray addObject:item];
    }];
    
    return resultArray;
}

- (void)render {
    self.flatItems = [NSMutableArray array];
    [self.rootItems enumerateObjectsUsingBlock:^(LKJSONAttributeItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.flatItems addObjectsFromArray:[obj flatItems]];
    }];
    
    [self.tableView reloadData];
}

#pragma mark - LKTableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSInteger count = self.flatItems.count;
    return count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return self.rowHeight;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    LKJSONAttributeItem *item = [self.flatItems lookin_safeObjectAtIndex:row];
    if (!item) {
        return [LKTableBlankRowView new];
    }
    
    LKJSONAttributeContentRowView *view = (LKJSONAttributeContentRowView *)[tableView makeViewWithIdentifier:@"myView" owner:self];
    if (!view) {
        view = [[LKJSONAttributeContentRowView alloc] initWithCompactUI:YES];
        view.titleLabel.textColor = [NSColor secondaryLabelColor];
        if (self.useBigFont) {
            view.titleLabel.font = [NSFont monospacedDigitSystemFontOfSize:14 weight:NSFontWeightRegular];
            view.subtitleLabel.font = [NSFont monospacedDigitSystemFontOfSize:14 weight:NSFontWeightRegular];
        } else {
            view.titleLabel.font = [NSFont monospacedDigitSystemFontOfSize:12 weight:NSFontWeightRegular];
            view.subtitleLabel.font = [NSFont monospacedDigitSystemFontOfSize:12 weight:NSFontWeightRegular];
        }
        
        view.titleLabel.selectable = YES;
        view.subtitleLabel.textColor = [NSColor labelColor];
        view.subtitleLabel.selectable = YES;
        view.disclosureButton.target = self;
        view.disclosureButton.action = @selector(handleExpand:);
        view.identifier = @"myView";
    }
    view.titleLabel.stringValue = item.titleText;
    if (item.desc) {
        view.subtitleLabel.stringValue = item.desc;
    } else {
        view.subtitleLabel.stringValue = @"";
    }
    view.disclosureButton.tag = row;
    view.indentLevel = item.indentation;
    if (item.subItems.count > 0) {
        if (item.expanded) {
            view.status = LKOutlineRowViewStatusExpanded;
        } else {
            view.status = LKOutlineRowViewStatusCollapsed;
        }
    } else {
        view.status = LKOutlineRowViewStatusNotExpandable;
    }
    [view setNeedsLayout:YES];
    return view;
}

- (void)handleExpand:(NSButton *)button {
    NSUInteger row = button.tag;
    LKJSONAttributeItem *item = [self.flatItems lookin_safeObjectAtIndex:row];
    if (!item) {
        return;
    }
    item.expanded = !item.expanded;
    [self render];
    
    if (self.didReloadData) {
        self.didReloadData();
    }
}

- (CGFloat)queryContentHeight {
    NSInteger count = self.flatItems.count;
    return count * self.rowHeight;
}

@end
