//
//  LKTableView.m
//  Lookin
//
//  Created by Li Kai on 2019/4/20.
//  https://lookin.work
//

#import "LKTableView.h"
#import "LKTableRowView.h"

@interface LKTableView () <NSTableViewDelegate, NSTableViewDataSource>

@property(nonatomic, assign) CGFloat tableViewWidth;

/// -1 表示不存在
@property(nonatomic, assign) NSInteger hoveredRow;
@property(nonatomic, assign) NSInteger selectedRow;

@end

@implementation LKTableView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.adjustsSelectionAutomatically = YES;
        self.adjustsHoverAutomatically = YES;
        
        _selectedRow = -1;
        _hoveredRow = -1;
        
        self.backgroundColor = [NSColor clearColor];
        self.drawsBackground = NO;
        self.hasVerticalScroller = YES;
        self.autohidesScrollers = YES;
        
        _tableView = [[NSTableView alloc] init];
        if (@available(macOS 11.0, *)) {
            self.tableView.style = NSTableViewStylePlain;
        }
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.wantsLayer = YES;
        self.tableView.backgroundColor = [NSColor clearColor];
        self.tableView.headerView = nil;
        self.tableView.focusRingType = NSFocusRingTypeNone;
        self.tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
        self.tableView.intercellSpacing = NSMakeSize(0, 0);
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"column"];
        column.editable = NO;
        [self.tableView addTableColumn:column];
        self.contentView.documentView = self.tableView;
        self.tableView.target = self;
        self.tableView.action = @selector(_handleTableViewDefaultAction);
        self.tableView.doubleAction = @selector(_handleDoubleClickTableView);
        
        @weakify(self);
        [[[[self.tableView rac_signalForSelector:@selector(reloadData)] filter:^BOOL(RACTuple * _Nullable value) {
            @strongify(self);
            return self.canScrollHorizontally;
        }] throttle:.5] subscribeNext:^(RACTuple * _Nullable x) {
            NSInteger rows = [self.tableView numberOfRows];
            CGFloat maxWidth = 0;
            while (rows--) {
                NSTableRowView *view = [self.tableView rowViewAtRow:rows makeIfNecessary:YES];
                if (!view) {
                    continue;
                }
                if ([view isKindOfClass:[LKTableRowView class]]) {
                    CGFloat width = ((LKTableRowView *)view).contentWidth;
                    maxWidth = MAX(maxWidth, width);
                } else {
                    //                    NSAssert(NO, @"");
                }
            }
            self.tableViewWidth = maxWidth;
            [self setNeedsLayout:YES];
        }];
        
        self.canScrollHorizontally = YES;
    }
    return self;
}

- (void)layout {
    [super layout];
    if (self.canScrollHorizontally) {
        $(self.tableView).width(self.tableViewWidth);
    } else {
        $(self.tableView).fullWidth;
    }
}

- (void)reloadData {
    self.selectedRow = -1;
    [self.tableView reloadData];
}

- (void)scrollRowToVisible:(NSInteger)row {
    [self.tableView scrollRowToVisible:row];
}

- (LKTableRowView *)makeViewWithIdentifier:(NSString *)identifier owner:(id)owner {
    return [self.tableView makeViewWithIdentifier:identifier owner:self];
}

- (void)setCanScrollHorizontally:(BOOL)canScrollHorizontally {
    _canScrollHorizontally = canScrollHorizontally;
    self.hasHorizontalScroller = canScrollHorizontally;
}

#pragma mark - Table View

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if ([self.delegate respondsToSelector:@selector(numberOfRowsInTableView:)]) {
        return [self.dataSource numberOfRowsInTableView:tableView];
    }
    return 0;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if ([self.delegate respondsToSelector:@selector(tableView:heightOfRow:)]) {
        return [self.delegate tableView:tableView heightOfRow:row];
    }
    return 0;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    if ([self.delegate respondsToSelector:@selector(tableView:rowViewForRow:)]) {
        NSTableRowView *rowView = [self.delegate tableView:tableView rowViewForRow:row];
        if ([rowView isKindOfClass:[LKTableRowView class]]) {
            ((LKTableRowView *)rowView).isHovered = (self.hoveredRow == row);
            if (self.adjustsSelectionAutomatically) {
                ((LKTableRowView *)rowView).isSelected = (self.selectedRow == row);
            }
        }
        return rowView;
    }
    return nil;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return nil;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    if ([self.delegate respondsToSelector:@selector(tableView:shouldSelectRow:)]) {
        return [self.delegate tableView:tableView shouldSelectRow:row];
    }
    return YES;
}

- (void)tableViewSelectionIsChanging:(NSNotification *)notification {
    NSInteger selectedRow = [self.tableView selectedRow];
    if (selectedRow < 0) {
        return;
    }
    self.selectedRow = selectedRow;
    
    if (!self.adjustsSelectionAutomatically) {
        if ([self.delegate respondsToSelector:@selector(tableView:didSelectRow:)]) {
            [self.delegate tableView:self didSelectRow:selectedRow];
        }
    }
    
    // 为什么加这一句呢？因为我们实际上不想依赖于 NSTableView 内建的 selectedRow 系统。想象这么一个场景：我们通过点击 NSTableView 把 selectedRow 变成了 10，然后通过点击 preview 选中了 row 20，但 NSTableView 仍然以为我们当前选中的是 10，于是当我们再次点击 NSTableView 的 row 10 时会发现 tableViewSelectionIsChanging: 不会被调用，因为 NSTableView 不认为 selectedRow 变化了。
    [self.tableView deselectRow:selectedRow];
}

#pragma mark - Event Handler

// tableViewSelectionIsChanging 会在 mouseDown 时被调用，而这个 _handleTableViewDefaultAction 会在 mouseUp 时被调用，有点晚
- (void)_handleTableViewDefaultAction {
    NSInteger clickedRow = self.tableView.clickedRow;
    if (clickedRow < 0 && [self.delegate respondsToSelector:@selector(tableViewDidClickBlankArea:)]) {
        [self.delegate tableViewDidClickBlankArea:self];
    }
}

- (void)_handleDoubleClickTableView {
    NSInteger clickedRow = self.tableView.clickedRow;
    if ([self.delegate respondsToSelector:@selector(tableView:didDoubleClickAtRow:)]) {
        [self.delegate tableView:self didDoubleClickAtRow:clickedRow];
    }
}

- (void)mouseMoved:(NSEvent *)event {
    [super mouseMoved:event];
    if (!self.adjustsHoverAutomatically) {
        return;
    }
    [self _updateHoveredRowWithMouseEvent:event];
}

// 当鼠标离开了某一个 row 进入另一个 row 时，rowView 的 mouseExited: 里的 [super mouseExited:] 这一句会调用到这里的这个方法
- (void)mouseExited:(NSEvent *)event {
    [super mouseExited:event];
    if (!self.adjustsHoverAutomatically) {
        return;
    }
    NSPoint rawPoint = [event locationInWindow];
    NSPoint point = [self.tableView convertPoint:rawPoint fromView:nil];
    NSInteger row = [self.tableView rowAtPoint:point];
    self.hoveredRow = row;
}

- (void)_updateHoveredRowWithMouseEvent:(NSEvent *)event {
    NSPoint rawPoint = [event locationInWindow];
    NSPoint point = [self.tableView convertPoint:rawPoint fromView:nil];
    NSInteger row = [self.tableView rowAtPoint:point];
    self.hoveredRow = row;
}

#pragma mark - Others

- (void)setHoveredRow:(NSInteger)hoveredRow {
    if (_hoveredRow == hoveredRow) {
        return;
    }
    NSInteger prevHoveredRow = _hoveredRow;
    _hoveredRow = hoveredRow;
    
    if (prevHoveredRow >= 0 && prevHoveredRow < self.tableView.numberOfRows) {
        NSTableRowView *rowView = [self.tableView rowViewAtRow:prevHoveredRow makeIfNecessary:NO];
        if ([rowView isKindOfClass:[LKTableRowView class]]) {
            ((LKTableRowView *)rowView).isHovered = NO;
        }
    }
    
    if (hoveredRow >= 0 && hoveredRow < self.tableView.numberOfRows) {
        BOOL canHover = YES;
        if ([self.delegate respondsToSelector:@selector(tableView:shouldSelectRow:)]) {
            canHover = [self.delegate tableView:self.tableView shouldSelectRow:hoveredRow];
        }
        if (canHover) {
            NSTableRowView *rowView = [self.tableView rowViewAtRow:hoveredRow makeIfNecessary:NO];
            if ([rowView isKindOfClass:[LKTableRowView class]]) {
                ((LKTableRowView *)rowView).isHovered = YES;
            }
        }
    }
    if ([self.delegate respondsToSelector:@selector(tableView:didHoverAtRow:)]) {
        [self.delegate tableView:self didHoverAtRow:hoveredRow];
    }
}

- (void)setSelectedRow:(NSInteger)selectedRow {
    if (!self.adjustsSelectionAutomatically) {
        return;
    }
    if (_selectedRow == selectedRow) {
        return;
    }
    NSInteger prevSelectedRow = _selectedRow;
    _selectedRow = selectedRow;
    
    if (prevSelectedRow >= 0 && prevSelectedRow < self.tableView.numberOfRows) {
        NSTableRowView *rowView = [self.tableView rowViewAtRow:prevSelectedRow makeIfNecessary:NO];
        if ([rowView isKindOfClass:[LKTableRowView class]]) {
            ((LKTableRowView *)rowView).isSelected = NO;
        }
    }
    
    if (selectedRow >= 0 && selectedRow < self.tableView.numberOfRows) {
        NSTableRowView *rowView = [self.tableView rowViewAtRow:selectedRow makeIfNecessary:NO];
        if ([rowView isKindOfClass:[LKTableRowView class]]) {
            ((LKTableRowView *)rowView).isSelected = YES;
        }
        if ([self.delegate respondsToSelector:@selector(tableView:didSelectRow:)]) {
            [self.delegate tableView:self didSelectRow:selectedRow];
        }
    }
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    [self.trackingAreas enumerateObjectsUsingBlock:^(NSTrackingArea * _Nonnull oldArea, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeTrackingArea:oldArea];
    }];
    
    NSTrackingArea *newArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSEventTypeMouseExited|NSTrackingMouseMoved|NSTrackingActiveInKeyWindow|NSTrackingInVisibleRect owner:self userInfo:nil];
    [self addTrackingArea:newArea];
}

@end
