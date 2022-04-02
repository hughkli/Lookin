//
//  LKInputSearchSuggestionsContentView.m
//  Lookin
//
//  Created by Li Kai on 2019/6/3.
//  https://lookin.work
//

#import "LKInputSearchSuggestionsContentView.h"
#import "LKInputSearchSuggestionsRowView.h"
#import "LKInputSearchSuggestionItem.h"

static CGFloat const kInputSearchSuggestionsItemViewHeight = 28;

@interface LKInputSearchSuggestionsContentView () <NSTableViewDelegate, NSTableViewDataSource>

@property(nonatomic, strong) LKVisualEffectView *backgroundEffectView;

@end

@implementation LKInputSearchSuggestionsContentView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.layer.cornerRadius = 4;
        
        self.backgroundEffectView = [LKVisualEffectView new];
        self.backgroundEffectView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
        self.backgroundEffectView.state = NSVisualEffectStateActive;
        [self addSubview:self.backgroundEffectView];
        
        _tableView = [[NSTableView alloc] init];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.wantsLayer = YES;
        self.tableView.headerView = nil;
//        self.tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
//        self.tableView.focusRingType = NSFocusRingTypeNone;
        self.tableView.intercellSpacing = NSMakeSize(0, 0);
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"column"];
        column.editable = NO;
        [self.tableView addTableColumn:column];
        [self addSubview:self.tableView];
        
        @weakify(self);
        [RACObserve(self, items) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self.tableView reloadData];
        }];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.backgroundEffectView, self.tableView).fullFrame;
}

- (LKInputSearchSuggestionItem *)currentSelectedItem {
    NSInteger selectedRow = self.tableView.selectedRow;
    return [self.items lookin_safeObjectAtIndex:selectedRow];
}

- (NSSize)bestSize {
    LKInputSearchSuggestionsRowView *rowView = [self lookin_getBindObjectForKey:@"calculatingRowView"];
    if (!rowView) {
        rowView = [LKInputSearchSuggestionsRowView new];
        [self lookin_bindObject:rowView forKey:@"calculatingRowView"];
    }
    CGFloat width = [self.items lookin_reduceCGFloat:^CGFloat(CGFloat accumulator, NSUInteger idx, LKInputSearchSuggestionItem *obj) {
        rowView.imageView.image = obj.image;
        rowView.titleLabel.stringValue = obj.text;
        return MAX(rowView.bestWidth, accumulator);
    } initialAccumlator:0];
    
    CGFloat height = kInputSearchSuggestionsItemViewHeight * self.items.count;
    return NSMakeSize(width, height);
}

#pragma mark - Table View

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.items.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return kInputSearchSuggestionsItemViewHeight;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    LKInputSearchSuggestionItem *item = [self.items lookin_safeObjectAtIndex:row];
    if (!item) {
        return [LKInputSearchSuggestionsRowView new];
    }
    LKInputSearchSuggestionsRowView *view = (LKInputSearchSuggestionsRowView *)[tableView makeViewWithIdentifier:@"cell" owner:self];
    if (!view) {
        view = [LKInputSearchSuggestionsRowView new];
        view.identifier = @"cell";
    }
    view.titleLabel.stringValue = item.text;
    view.imageView.image = item.image;
    [view setNeedsLayout:YES];
    return view;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return nil;
}

@end
