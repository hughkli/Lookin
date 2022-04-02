//
//  LKMethodTraceMenuItemView.m
//  Lookin
//
//  Created by Li Kai on 2019/5/24.
//  https://lookin.work
//

#import "LKMethodTraceMenuItemView.h"

@interface LKMethodTraceMenuItemView ()

@property(nonatomic, strong) NSImageView *imageView;
@property(nonatomic, strong) LKLabel *label;
@property(nonatomic, strong) NSButton *deleteButton;

@end

@implementation LKMethodTraceMenuItemView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.imageView = [NSImageView new];
        [self addSubview:self.imageView];
        
        self.label = [LKLabel new];
        self.label.font = [NSFont systemFontOfSize:12];
        self.label.maximumNumberOfLines = 1;
        self.label.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:self.label];
        
        self.deleteButton = [NSButton new];
        self.deleteButton.bezelStyle = NSBezelStyleRoundRect;
        self.deleteButton.bordered = NO;
        self.deleteButton.image = NSImageMake(@"icon_delete");
        self.deleteButton.target = self;
        self.deleteButton.action = @selector(_handleDelete);
        self.deleteButton.hidden = YES;
        [self addSubview:self.deleteButton];
        
        @weakify(self);
        RAC(self.label, stringValue) = [[[RACSignal combineLatest:@[RACObserve(self, representedAsClass),
                                                                    RACObserve(self, representedClassName),
                                                                    RACObserve(self, representedSelName)]]
                                         map:^id _Nullable(RACTuple * _Nullable value) {
                                             return ((NSNumber *)value.first).boolValue ? value.second : value.third;
                                         }] doNext:^(id  _Nullable x) {
                                             @strongify(self);
                                             [self setNeedsLayout:YES];
                                         }];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.imageView).sizeToFit.verAlign.x(self.representedAsClass ? 10 : 30);
    if (!self.deleteButton.hidden) {
        $(self.deleteButton).sizeToFit.verAlign.right(10);
        $(self.label).x(self.imageView.$maxX + 3).toMaxX(self.deleteButton.$x - 10).heightToFit.verAlign;
    } else {
        $(self.label).x(self.imageView.$maxX + 3).toRight(3).heightToFit.verAlign;
    }
}

- (void)setRepresentedAsClass:(BOOL)representedAsClass {
    _representedAsClass = representedAsClass;
    self.imageView.image = representedAsClass ? NSImageMake(@"icon_class"): NSImageMake(@"icon_method");
    [self setNeedsLayout:YES];
}

- (void)mouseEntered:(NSEvent *)event {
    [super mouseEntered:event];
    self.deleteButton.hidden = NO;
    [self setNeedsLayout:YES];
}

- (void)mouseExited:(NSEvent *)event {
    [super mouseExited:event];
    self.deleteButton.hidden = YES;
    [self setNeedsLayout:YES];
}

- (void)_handleDelete {
    if ([self.delegate respondsToSelector:@selector(methodTraceMenuItemViewDidClickDelete:)]) {
        [self.delegate methodTraceMenuItemViewDidClickDelete:self];
    }
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    [self.trackingAreas enumerateObjectsUsingBlock:^(NSTrackingArea * _Nonnull oldArea, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeTrackingArea:oldArea];
    }];
    
    NSTrackingArea *newArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSEventTypeMouseExited|NSEventTypeMouseEntered|NSTrackingActiveInKeyWindow|NSTrackingInVisibleRect owner:self userInfo:nil];
    [self addTrackingArea:newArea];
}

@end
