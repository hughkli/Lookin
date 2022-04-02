//
//  LKDashboardAttributeEnumsView.m
//  Lookin
//
//  Created by Li Kai on 2019/2/21.
//  https://lookin.work
//

#import "LKDashboardAttributeEnumsView.h"
#import "LKEnumListRegistry.h"
#import "LKDashboardCardView.h"
#import "LKDashboardViewController.h"
#import "LKHierarchyDataSource.h"
#import "LookinHierarchyInfo.h"
#import "LookinAppInfo.h"
#import "LookinDashboardBlueprint.h"

@interface LKDashboardAttributeEnumsView ()

@property(nonatomic, strong) NSImageView *iconImageView;
@property(nonatomic, strong) LKLabel *textLabel;

@end

@implementation LKDashboardAttributeEnumsView {
    CGFloat _labelX;
    CGFloat _labelRight;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _labelX = 5;
        _labelRight = 20;
        
        
//        self.layer.borderWidth = 1;
//        self.layer.borderColor = DashboardCardControlBorderColor.CGColor;
        self.layer.cornerRadius = DashboardCardControlCornerRadius;
        
        self.textLabel = [LKLabel new];
        self.textLabel.textColor = [NSColor colorNamed:@"DashboardCardValueColor"];
        self.textLabel.maximumNumberOfLines = 0;
        self.textLabel.font = NSFontMake(12);

        [self addSubview:self.textLabel];
        
        self.iconImageView = [NSImageView new];
        self.iconImageView.image = NSImageMake(@"Icon_ArrowUpDown");
        [self addSubview:self.iconImageView];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.iconImageView).sizeToFit.verAlign.right(9);
    $(self.textLabel).x(_labelX).toRight(_labelRight).heightToFit.verAlign;
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat height = [self.textLabel sizeThatFits:NSMakeSize(limitedSize.width - _labelRight - _labelX, CGFLOAT_MAX)].height;
    limitedSize.height = height + 10;
    return limitedSize;
}

- (void)renderWithAttribute {
    NSInteger enumValue = [self.attribute.value integerValue];
    NSString *enumListName = [LookinDashboardBlueprint enumListNameWithAttrID:self.attribute.identifier];
    NSString *enumString = [[LKEnumListRegistry sharedInstance] descForEnumName:enumListName value:enumValue];
    self.textLabel.stringValue = enumString;
}

- (void)mouseDown:(NSEvent *)event {
    NSInteger currentOSVersion = self.dashboardViewController.currentDataSource.rawHierarchyInfo.appInfo.osMainVersion;
    
    NSMenu *menu = [NSMenu new];
    menu.autoenablesItems = NO;
    NSString *enumListName = [LookinDashboardBlueprint enumListNameWithAttrID:self.attribute.identifier];
    NSArray<LKEnumListRegistryKeyValueItem *> *rawItems = [[LKEnumListRegistry sharedInstance] itemsForEnumName:enumListName];
    [rawItems enumerateObjectsUsingBlock:^(LKEnumListRegistryKeyValueItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL validOSVersion = currentOSVersion >= obj.availableOSVersion;
        
        NSMenuItem *item = [NSMenuItem new];
        item.image = [[NSImage alloc] initWithSize:NSMakeSize(1, 22)];
        item.title = validOSVersion ? obj.desc : [NSString stringWithFormat:@"%@ (iOS %@)", obj.desc, @(obj.availableOSVersion)];
        item.representedObject = @(obj.value);
        item.enabled = [self canEdit] && validOSVersion;
        item.target = self;
        item.action = @selector(_handleMenuItem:);
        if (obj.value == [self.attribute.value longValue]) {
            item.state = NSControlStateValueOn;
        } else {
            item.state = NSControlStateValueOff;
        }
        [menu addItem:item];
    }];
    [NSMenu popUpContextMenu:menu withEvent:event forView:self];
}

- (void)setDashboardViewController:(LKDashboardViewController *)dashboardViewController {
    [super setDashboardViewController:dashboardViewController];
    self.backgroundColorName = @"DashboardCardValueBGColor";
}

#pragma mark - Private

- (void)_handleMenuItem:(NSMenuItem *)item {
    NSNumber *expectedValue = item.representedObject;
    if ([expectedValue isEqual:self.attribute.value]) {
        NSLog(@"修改没有变化，不做任何提交");
        return;
    }
    [[self.dashboardViewController modifyAttribute:self.attribute newValue:expectedValue] subscribeNext:^(id  _Nullable x) {
    }];
}

@end
