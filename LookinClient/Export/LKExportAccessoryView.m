//
//  LKExportAccessoryView.m
//  Lookin
//
//  Created by Li Kai on 2019/5/13.
//  https://lookin.work
//

#import "LKExportAccessoryView.h"
#import "LKPreferenceManager.h"

@interface LKExportAccessoryView ()

@property(nonatomic, assign, readwrite) CGFloat selectedCompression;

@property(nonatomic, strong) LKLabel *compressionLabel;

@property(nonatomic, strong) NSPopUpButton *compressionButton;

@property(nonatomic, strong) LKLabel *sizeLabel;

@property(nonatomic, copy) NSArray<NSNumber *> *compressionArray;

@end

@implementation LKExportAccessoryView {
    CGFloat _insetTop;
    CGFloat _insetBottom;
    CGFloat _buttonWidth;
    CGFloat _sizeLabelTop;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _insetTop = 20;
        _insetBottom = 10;
        _buttonWidth = 150;
        _sizeLabelTop = 5;
        
        self.compressionArray = @[@(.1), @(.3), @(.5), @(.75), @(1)];
        
        self.compressionLabel = [LKLabel new];
        self.compressionLabel.stringValue = NSLocalizedString(@"Image Quality:", nil);
        self.compressionLabel.font = NSFontMake(15);
        self.compressionLabel.alignment = NSTextAlignmentRight;
        [self addSubview:self.compressionLabel];
        
        self.compressionButton = [NSPopUpButton new];
        self.compressionButton.font = NSFontMake(14);
        self.compressionButton.target = self;
        self.compressionButton.action = @selector(_handleCompressionButton);
        [self.compressionButton addItemsWithTitles:[self.compressionArray lookin_map:^id(NSUInteger idx, NSNumber *value) {
            return [NSString stringWithFormat:@"%@%%", @(value.doubleValue * 100)];
        }]];
        [self addSubview:self.compressionButton];
        
        self.sizeLabel = [LKLabel new];
        self.sizeLabel.font = NSFontMake(13);
        self.sizeLabel.stringValue = NSLocalizedString(@"File Size", nil);
        self.sizeLabel.alignment = NSTextAlignmentRight;
        [self addSubview:self.sizeLabel];
        
        @weakify(self);
        [[RACObserve([LKPreferenceManager mainManager], preferredExportCompression) distinctUntilChanged] subscribeNext:^(NSNumber *num) {
            @strongify(self);
            NSUInteger shouldSelectIdx = [self.compressionArray indexOfObjectPassingTest:^BOOL(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CGFloat diff = ABS(num.doubleValue - obj.doubleValue);
                return (diff < 0.05);
            }];
            
            if (self.compressionButton.indexOfSelectedItem != shouldSelectIdx) {
                [self.compressionButton selectItemAtIndex:shouldSelectIdx];
            }
        }];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.compressionLabel).sizeToFit.y(_insetTop).x(0);
    $(self.compressionButton).width(_buttonWidth).heightToFit.x(self.compressionLabel.$maxX).midY(self.compressionLabel.$midY);

    $(self.sizeLabel).fullWidth.heightToFit.y(self.compressionButton.$maxY + _sizeLabelTop);
}

- (void)_handleCompressionButton {
    CGFloat compression = [self.compressionArray[self.compressionButton.indexOfSelectedItem] doubleValue];
    [LKPreferenceManager mainManager].preferredExportCompression = compression;
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    limitedSize.width = [self.compressionLabel sizeThatFits:NSSizeMax].width + _buttonWidth;
    limitedSize.height = _insetTop + [self.compressionLabel sizeThatFits:NSSizeMax].height + _sizeLabelTop + [self.sizeLabel sizeThatFits:NSSizeMax].height + _insetBottom;
    return limitedSize;
}

- (void)setDataSize:(NSUInteger)dataSize {
    _dataSize = dataSize;
    self.sizeLabel.stringValue = [NSString stringWithFormat:NSLocalizedString(@"File Size: %.2f M", nil), dataSize / 1000.0 / 1000.0];
}

@end
