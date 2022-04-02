//
//  LKMethodTraceDetailView.m
//  Lookin
//
//  Created by Li Kai on 2019/5/24.
//  https://lookin.work
//

#import "LKMethodTraceDetailView.h"
#import "LKMethodTraceDataSource.h"
#import "LKOutlineView.h"
#import "LKOutlineItem.h"
#import "LookinMethodTraceRecord.h"
#import "LKOutlineRowView.h"
#import "LKPreferenceManager.h"
#import "LKTableView.h"

@interface LKMethodTraceDetailRowView : LKOutlineRowView

@property(nonatomic, assign) BOOL needTopBorder;
@property(nonatomic, strong) CAShapeLayer *topBorderLayer;

@property(nonatomic, strong) LKLabel *timeLabel;

@end

@implementation LKMethodTraceDetailRowView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.timeLabel = [LKLabel new];
        self.timeLabel.textColor = [NSColor secondaryLabelColor];
        [self addSubview:self.timeLabel];
    }
    return self;
}

- (void)layout {
    [super layout];
    if (self.timeLabel.isVisible) {
        $(self.timeLabel).sizeToFit.right(8).verAlign;
        $(self.titleLabel).toMaxX(self.timeLabel.$x - 10);
    } else {
        $(self.titleLabel).toRight(5);
    }
    
    if (self.topBorderLayer && !self.topBorderLayer.hidden) {
        CGFloat x = [self convertPoint:self.imageView.frame.origin fromView:self.titleLabel.superview].x;
        $(self.topBorderLayer).x(x).toRight(0).height(1).y(0);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, 0, 0);
        CGPathAddLineToPoint(path, nil, self.$width, 0);
        self.topBorderLayer.path = path;
        CGPathRelease(path);
    }
}

- (void)setNeedTopBorder:(BOOL)needTopBorder {
    _needTopBorder = needTopBorder;
    if (needTopBorder) {
        if (!self.topBorderLayer) {
            self.topBorderLayer = [CAShapeLayer layer];
            [self.topBorderLayer setLineWidth:1];
            self.topBorderLayer.lineDashPattern = @[@3, @3];
            [self.topBorderLayer lookin_removeImplicitAnimations];
            [self.layer addSublayer:self.topBorderLayer];
            [self _updateBorderColor];
        }
        self.topBorderLayer.hidden = NO;
        [self setNeedsLayout:YES];
    } else {
        self.topBorderLayer.hidden = YES;
    }
}

- (void)viewDidChangeEffectiveAppearance {
    [super viewDidChangeEffectiveAppearance];
    if (self.topBorderLayer && !self.topBorderLayer.hidden) {
        [self _updateBorderColor];
    }
}

- (void)_updateBorderColor {
    [self.topBorderLayer setStrokeColor:self.isDarkMode ? LookinColorRGBAMake(255, 255, 255, .5).CGColor : LookinColorRGBAMake(0, 0, 0, .5).CGColor];
}

@end

@interface LKMethodTraceDetailItem : LKOutlineItem

@property(nonatomic, strong) LookinMethodTraceRecord *record;

@property(nonatomic, strong) LookinMethodTraceRecordStackItem *stackItem;

@property(nonatomic, copy) NSString *rawStackString;


@end

@implementation LKMethodTraceDetailItem

@end

@interface LKMethodTraceDetailView () <LKOutlineViewDelegate>

@property(nonatomic, strong) LKMethodTraceDataSource *dataSource;
@property(nonatomic, strong) LKOutlineView *outlineView;

@property(nonatomic, strong) LKLabel *emptyViewLabel;

@end

@implementation LKMethodTraceDetailView

- (instancetype)initWithDataSource:(LKMethodTraceDataSource *)dataSource {
    if (self = [self initWithFrame:NSZeroRect]) {
        self.dataSource = dataSource;
        
        self.backgroundColorName = @"MainWindowBackgroundColor";
        
        self.outlineView = [[LKOutlineView alloc] initWithRowViewClass:[LKMethodTraceDetailRowView class]];
        self.outlineView.tableView.canScrollHorizontally = NO;
        self.outlineView.delegate = self;
        [self addSubview:self.outlineView];
        
        self.emptyViewLabel = [LKLabel new];
        self.emptyViewLabel.font = NSFontMake(13);
        self.emptyViewLabel.textColor = [NSColor tertiaryLabelColor];
        self.emptyViewLabel.stringValue = NSLocalizedString(@"Call stacks will appear here when the methods you added are invoked.", nil);
        [self addSubview:self.emptyViewLabel];
        
        @weakify(self);
        [[RACSignal combineLatest:@[RACObserve(dataSource, records),
                                    RACObserve([LKPreferenceManager mainManager], callStackType)]]
         subscribeNext:^(RACTuple * _Nullable x) {
             @strongify(self);
             NSMutableArray<LKMethodTraceDetailItem *> *items = [NSMutableArray array];
             LookinPreferredCallStackType type = ((NSNumber *)x.second).integerValue;
             
             NSArray<LookinMethodTraceRecord *> *records = x.first;
             [records enumerateObjectsUsingBlock:^(LookinMethodTraceRecord * _Nonnull record, NSUInteger idx, BOOL * _Nonnull stop) {
                 LKMethodTraceDetailItem *item = [LKMethodTraceDetailItem new];
                 item.record = record;
                 item.stackItem = nil;
                 [items addObject:item];
                 
                 if (type == LookinPreferredCallStackTypeDefault) {
                     item.subItems = [record.briefFormattedCallStacks lookin_map:^id(NSUInteger idx, LookinMethodTraceRecordStackItem *value) {
                         LKMethodTraceDetailItem *stackItem = [LKMethodTraceDetailItem new];
                         stackItem.record = nil;
                         stackItem.stackItem = value;
                         return stackItem;
                     }];
                 
                 } else if (type == LookinPreferredCallStackTypeFormattedCompletely) {
                     item.subItems = [record.completeFormattedCallStacks lookin_map:^id(NSUInteger idx, LookinMethodTraceRecordStackItem *value) {
                         LKMethodTraceDetailItem *stackItem = [LKMethodTraceDetailItem new];
                         stackItem.record = nil;
                         stackItem.stackItem = value;
                         return stackItem;
                     }];
                     
                 } else {
                     NSAssert(type == LookinPreferredCallStackTypeRaw, @"");
                     item.subItems = [record.callStacks lookin_map:^id(NSUInteger idx, NSString *value) {
                         LKMethodTraceDetailItem *stackItem = [LKMethodTraceDetailItem new];
                         stackItem.record = nil;
                         stackItem.rawStackString = value;
                         return stackItem;
                     }];
                 }
             }];
             
             self.outlineView.items = items;
             
             self.emptyViewLabel.hidden = (items.count > 0);
         }];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.outlineView).fullFrame;
    $(self.emptyViewLabel).sizeToFit.centerAlign;
}

#pragma mark - LKOutlineViewDelegate

- (void)outlineView:(LKOutlineView *)view configureRowView:(LKMethodTraceDetailRowView *)rowView withItem:(LKMethodTraceDetailItem *)item {
    rowView.titleLabel.selectable = YES;
    rowView.titleLabel.textColor = [NSColor labelColor];
    rowView.imageView.alphaValue = 1;
    rowView.needTopBorder = NO;
    rowView.timeLabel.hidden = YES;
    
    if (item.record) {
        rowView.image = NSImageMake(@"icon_message");
        rowView.titleLabel.stringValue = item.record.combinedTitle;
        rowView.timeLabel.hidden = NO;
        rowView.timeLabel.stringValue = ({
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"HH:MM:ss.SSSS"];
            NSString *string = [formatter stringFromDate:item.record.date];
            string;
        });
        
    } else {
        if (item.stackItem) {
            rowView.titleLabel.stringValue = [NSString stringWithFormat:@"%@  %@", @(item.stackItem.idx), item.stackItem.detail];
            if (item.stackItem.isSystemItem) {
                rowView.image = NSImageMake(@"icon_stack_system");
                rowView.titleLabel.textColor = [NSColor secondaryLabelColor];
                rowView.imageView.alphaValue = .65;
                if (item.stackItem.isSystemSeriesEnding) {
                    rowView.needTopBorder = YES;
                }
            } else {
                rowView.image = NSImageMake(@"icon_stack_user");
            }
        } else {
            rowView.titleLabel.stringValue = item.rawStackString;
            rowView.image = nil;
        }
    }
    [rowView setNeedsLayout:YES];
}

@end
