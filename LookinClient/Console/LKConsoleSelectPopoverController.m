//
//  LKConsoleSelectPopoverController.m
//  Lookin
//
//  Created by Li Kai on 2019/6/19.
//  https://lookin.work
//

#import "LKConsoleSelectPopoverController.h"
#import "LKConsoleDataSource.h"
#import "LKConsoleSelectPopoverItemControl.h"
#import "LKImageTextView.h"
#import "LookinObject.h"
#import "LKPreferenceManager.h"

@interface LKConsoleSelectPopoverController ()

@property(nonatomic, strong) LKConsoleDataSource *dataSource;

@property(nonatomic, strong) LKImageTextView *historyTitleView;
@property(nonatomic, copy) NSArray<LKConsoleSelectPopoverItemControl *> *historyControls;
@property(nonatomic, copy) NSArray<LKConsoleSelectPopoverItemControl *> *highlightControls;
@property(nonatomic, strong) LKImageTextView *highlightTitleView;
@property(nonatomic, strong) NSButton *toggleButton;
@property(nonatomic, strong) CALayer *sepLayer;

@end

@implementation LKConsoleSelectPopoverController {
    NSEdgeInsets _insets;
    CGFloat _titleMarginTop;
    CGFloat _itemControlMarginTop;
    CGFloat _toggleButtonMarginTop;
}

- (instancetype)initWithDataSource:(LKConsoleDataSource *)dataSource {
    if (self = [self initWithContainerView:nil]) {
        self.dataSource = dataSource;
        _insets = NSEdgeInsetsMake(8, 12, 8, 12);
        _titleMarginTop = 16;
        _itemControlMarginTop = 5;
        _toggleButtonMarginTop = 22;
    }
    return self;
}

- (NSView *)makeContainerView {
    LKBaseView *view = [LKBaseView new];
    
    self.historyTitleView = [LKImageTextView new];
    self.historyTitleView.imageMargins = HorizontalMarginsMake(0, 5);
    self.historyTitleView.imageView.image = NSImageMake(@"console_history");
    self.historyTitleView.label.stringValue = NSLocalizedString(@"Objects returned recently in console", nil);
    [view addSubview:self.historyTitleView];
    
    self.highlightTitleView = [LKImageTextView new];
    self.highlightTitleView.imageMargins = HorizontalMarginsMake(0, 5);
    self.highlightTitleView.imageView.image = NSImageMake(@"icon_cursor");
    self.highlightTitleView.label.stringValue = NSLocalizedString(@"Objects highlighted in hierarchy panel", nil);
    [view addSubview:self.highlightTitleView];
    
    self.historyControls = [NSArray array];
    self.highlightControls = [NSArray array];
    
    self.toggleButton = [NSButton new];
    [self.toggleButton setButtonType:NSButtonTypeSwitch];
    self.toggleButton.title = NSLocalizedString(@"Automatically make highlighted view in hierarchy panel as console target", nil);
    self.toggleButton.font = NSFontMake(12);
    self.toggleButton.target = self;
    self.toggleButton.action = @selector(_handleToggleSyncButton);
    [view addSubview:self.toggleButton];
    
    RAC(self.toggleButton, state) = [RACObserve([LKPreferenceManager mainManager], syncConsoleTarget) map:^id _Nullable(NSNumber *value) {
        BOOL shouldChecked = value.boolValue;
        if (shouldChecked) {
            return @(NSControlStateValueOn);
        } else {
            return @(NSControlStateValueOff);
        }
    }];
    
    @weakify(self);
    view.didChangeAppearanceBlock = ^(LKBaseView *view, BOOL isDarkMode) {
        @strongify(self);
        if (isDarkMode) {
            self.sepLayer.backgroundColor = [NSColor colorWithWhite:1 alpha:.2].CGColor;
        } else {
            self.sepLayer.backgroundColor = [NSColor colorWithWhite:0 alpha:.12].CGColor; 
        }
    };
    self.sepLayer = [CALayer layer];
    [self.sepLayer lookin_removeImplicitAnimations];
    [view.layer addSublayer:self.sepLayer];
    
    return view;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    
    __block CGFloat y = _insets.top;
    
    if (self.historyTitleView.isVisible) {
        $(self.historyTitleView).sizeToFit.x(_insets.left).y(y);
        y = self.historyTitleView.$maxY;
    }
    [self.historyControls enumerateObjectsUsingBlock:^(LKConsoleSelectPopoverItemControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        $(obj).x(self->_insets.left).toRight(self->_insets.right).heightToFit.y(y + self->_itemControlMarginTop);
        y = obj.$maxY;
    }];
    if (self.highlightTitleView.isVisible) {
        if (self.historyTitleView.isVisible) {
            y += _titleMarginTop;
        }
        $(self.highlightTitleView).sizeToFit.x(_insets.left).y(y);
        y = self.highlightTitleView.$maxY;
    }
    [self.highlightControls enumerateObjectsUsingBlock:^(LKConsoleSelectPopoverItemControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        $(obj).x(self->_insets.left).toRight(self->_insets.right).heightToFit.y(y + self->_itemControlMarginTop);
        y = obj.$maxY;
    }];
    
    $(self.toggleButton).x(_insets.left).toRight(_insets.right).y(y + _toggleButtonMarginTop).height([self.toggleButton sizeThatFits:NSSizeMax].height + 2);
    $(self.sepLayer).x(_insets.left).toRight(_insets.right).height(1).y(self.toggleButton.$y - 7);
}

- (CGFloat)bestHeight {
    __block CGFloat height = _insets.top + _insets.bottom;
    if (self.historyTitleView.isVisible) {
        height += [self.historyTitleView sizeThatFits:NSSizeMax].height;
    }
    if (self.highlightTitleView.isVisible) {
        height += [self.highlightTitleView sizeThatFits:NSSizeMax].height;
        
        if (self.historyTitleView.isVisible) {
            height += _titleMarginTop;
        }
    }
    [[self.historyControls arrayByAddingObjectsFromArray:self.highlightControls] enumerateObjectsUsingBlock:^(LKConsoleSelectPopoverItemControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        height += [obj sizeThatFits:NSSizeMax].height + self->_itemControlMarginTop;
    }];
    
    height += [self.toggleButton sizeThatFits:NSSizeMax].height + _toggleButtonMarginTop;
    return height;
}

- (void)reRender {
    if (self.dataSource.recentObjects.count == 0) {
        self.historyControls = [self.historyControls lookin_resizeWithCount:1 add:^LKConsoleSelectPopoverItemControl *(NSUInteger idx) {
            LKConsoleSelectPopoverItemControl *control = [LKConsoleSelectPopoverItemControl new];
            [control addTarget:self clickAction:@selector(_handleControl:)];
            [self.view addSubview:control];
            return control;
            
        } remove:^(NSUInteger idx, LKConsoleSelectPopoverItemControl *control) {
            [control removeFromSuperview];
            
        } doNext:^(NSUInteger idx, LKConsoleSelectPopoverItemControl *control) {
            control.title = NSLocalizedString(@"No object was returned yet", nil);
            control.isChecked = NO;
            control.representedObject = nil;
        }];
    } else {
        self.historyControls = [self.historyControls lookin_resizeWithCount:self.dataSource.recentObjects.count add:^LKConsoleSelectPopoverItemControl *(NSUInteger idx) {
            LKConsoleSelectPopoverItemControl *control = [LKConsoleSelectPopoverItemControl new];
            [control addTarget:self clickAction:@selector(_handleControl:)];
            [self.view addSubview:control];
            return control;
            
        } remove:^(NSUInteger idx, LKConsoleSelectPopoverItemControl *control) {
            [control removeFromSuperview];
            
        } doNext:^(NSUInteger idx, LKConsoleSelectPopoverItemControl *control) {
            RACTwoTuple *tuple = self.dataSource.recentObjects[idx];
            LookinObject *targetObject = tuple.first;
            control.title = [NSString stringWithFormat:@"<%@: %@>", targetObject.shortSelfClassName, targetObject.memoryAddress];
            control.subtitle = tuple.second;
            control.isChecked = (self.dataSource.currentObject.oid == targetObject.oid);
            control.representedObject = targetObject;
        }];
    }
    
    self.highlightTitleView.hidden = (self.dataSource.selectedObjects.count == 0);
    self.highlightControls = [self.highlightControls lookin_resizeWithCount:self.dataSource.selectedObjects.count add:^LKConsoleSelectPopoverItemControl *(NSUInteger idx) {
        LKConsoleSelectPopoverItemControl *control = [LKConsoleSelectPopoverItemControl new];
        [control addTarget:self clickAction:@selector(_handleControl:)];
        [self.view addSubview:control];
        return control;
        
    } remove:^(NSUInteger idx, LKConsoleSelectPopoverItemControl *control) {
        [control removeFromSuperview];
        
    } doNext:^(NSUInteger idx, LKConsoleSelectPopoverItemControl *control) {
        LookinObject *targetObject = self.dataSource.selectedObjects[idx];
        control.title = [NSString stringWithFormat:@"<%@: %@>", targetObject.shortSelfClassName, targetObject.memoryAddress];
        control.isChecked = (self.dataSource.currentObject.oid == targetObject.oid);
        control.representedObject = targetObject;
    }];
    
    [self.view setNeedsLayout:YES];
}

- (void)_handleControl:(LKConsoleSelectPopoverItemControl *)control {
    LookinObject *obj = control.representedObject;
    if (!obj) {
        return;
    }
    @weakify(self);
    [[self.dataSource makeObjectAsCurrent:obj] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (obj.oid != self.dataSource.selectedObjects.lastObject.oid) {
            [LKPreferenceManager mainManager].syncConsoleTarget = NO;
        }
        if (self.needClose) {
            self.needClose();
        }

    } error:^(NSError * _Nullable error) {
        if (self.needShowError) {
            self.needShowError(LookinErr_NoConnect);
        }
    }];
}

- (void)_handleToggleSyncButton {
    LKPreferenceManager *mng = [LKPreferenceManager mainManager];
    mng.syncConsoleTarget = !mng.syncConsoleTarget;
    if (mng.syncConsoleTarget) {
        @weakify(self);
        [[self.dataSource makeObjectAsCurrent:self.dataSource.selectedObjects.lastObject] subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self reRender];
        }];
    }
}

@end
