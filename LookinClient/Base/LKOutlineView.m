//
//  LKOutlineView.m
//  Lookin
//
//  Created by Li Kai on 2019/5/28.
//  https://lookin.work
//

#import "LKOutlineView.h"
#import "LKTableView.h"
#import "LKOutlineItem.h"
#import "LKOutlineRowView.h"

@interface LKOutlineView () <LKTableViewDelegate, LKTableViewDataSource>

@property(nonatomic, copy, readwrite) NSArray<LKOutlineItem *> *displayingItems;
@property(nonatomic, assign) Class rowViewClass;

@end

@implementation LKOutlineView

- (instancetype)initWithRowViewClass:(Class)aClass {
    if (self = [super initWithFrame:NSZeroRect]) {
        _itemHeight = 24;
        
        self.rowViewClass = aClass;
        NSAssert([aClass isSubclassOfClass:[LKOutlineRowView class]], @"");
        
        self.displayingItems = [NSArray array];
        
        _tableView = [LKTableView new];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.adjustsSelectionAutomatically = NO;
        [self addSubview:self.tableView];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    return [self initWithRowViewClass:[LKOutlineRowView class]];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    return [self initWithRowViewClass:[LKOutlineRowView class]];
}

- (void)layout {
    [super layout];
    $(self.tableView).fullFrame;
}

- (void)setItems:(NSArray<LKOutlineItem *> *)items {
    _items = items.copy;
    [self _updateDisplayingItems];
}

#pragma mark - LKTableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.displayingItems.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return self.itemHeight;
}

- (LKOutlineRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    LKOutlineItem *item = [self.displayingItems lookin_safeObjectAtIndex:row];
    if (!item) {
        return [self.rowViewClass new];
    }
    
    LKOutlineRowView *view = (LKOutlineRowView *)[tableView makeViewWithIdentifier:@"cell" owner:self];
    if (!view) {
        view = [self.rowViewClass new];
        view.identifier = @"cell";
    }
    view.disclosureButton.tag = row;
    view.disclosureButton.target = self;
    view.disclosureButton.action = @selector(_handleDisclosureButton:);
    
    if (item.status == LKOutlineItemStatusNotExpandable) {
        view.status = LKOutlineRowViewStatusNotExpandable;
    } else if (item.status == LKOutlineItemStatusExpanded) {
        view.status = LKOutlineRowViewStatusExpanded;
    } else {
        view.status = LKOutlineRowViewStatusCollapsed;
    }
    
    view.indentLevel = item.indentation;
    view.titleLabel.stringValue = item.titleText;
    view.image = item.image;
    
    if ([self.delegate respondsToSelector:@selector(outlineView:configureRowView:withItem:)]) {
        [self.delegate outlineView:self configureRowView:view withItem:item];
    }
    
    [view setNeedsLayout:YES];
    
    return view;
}

#pragma mark - Event Handler

- (void)_handleDisclosureButton:(NSButton *)button {
    NSInteger row = button.tag;
    LKOutlineItem *item = [self.displayingItems lookin_safeObjectAtIndex:row];
    if (!item || item.status == LKOutlineItemStatusNotExpandable) {
        return;
    }
    if (item.status == LKOutlineItemStatusExpanded) {
        item.status = LKOutlineItemStatusCollapsed;
    } else {
        item.status = LKOutlineItemStatusExpanded;
    }
    [self _updateDisplayingItems];
}

#pragma mark - Others

- (void)_updateDisplayingItems {
    self.displayingItems = [LKOutlineItem flatItemsFromRootItems:self.items];
    [self.tableView reloadData];
}

@end
