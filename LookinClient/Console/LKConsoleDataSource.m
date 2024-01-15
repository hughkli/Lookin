//
//  LKConsoleDataSource.m
//  Lookin
//
//  Created by Li Kai on 2019/6/1.
//  https://lookin.work
//

#import "LKConsoleDataSource.h"
#import "LKConsoleDataSourceRowItem.h"
#import "LKStaticHierarchyDataSource.h"
#import "LookinDisplayItem.h"
#import "LKAppsManager.h"
#import "LKPreferenceManager.h"

@interface LKConsoleDataSource ()

/**
 @{
     @"UIView": @{
         @"selector": @[@"layoutSubviews", ...],
         @"ivar": @[@"_name", ...]
     },
     @"UIViewController": @{
         @"selector": @[@"viewDidAppear:", ...],
         @"ivar": @[@"_didAppear", ...]
     },
     ...
 };
 */
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSArray<NSString *> *> *classesToSelsDict;
@property(nonatomic, strong, readwrite) LookinObject *currentObject;
@property(nonatomic, strong, readwrite) NSArray<LookinObject *> *selectedObjects;

@end

@implementation LKConsoleDataSource

- (instancetype)initWithHierarchyDataSource:(LKHierarchyDataSource *)hierarchyDataSource {
    if (self = [self init]) {
        self.classesToSelsDict = [NSMutableDictionary dictionary];
        
        LKConsoleDataSourceRowItem *item = [LKConsoleDataSourceRowItem new];
        item.type = LKConsoleDataSourceRowItemTypeInput;
        self.rowItems = @[item];
        
        RAC(self, selectedObjects) = [RACObserve(hierarchyDataSource, selectedItem)
                                      map:^id _Nullable(LookinDisplayItem *item) {
                                          if (!item) {
                                              return nil;
                                          }
                                          NSArray<LookinObject *> *objs = $(item.hostViewControllerObject, item.layerObject, item.viewObject).array;
                                          return objs;
                                      }];
    }
    return self;
}

- (RACSignal *)submit:(NSString *)text {
    return [self submitWithObj:self.currentObject text:text];
}

- (RACSignal *)submitWithObj:(LookinObject *)obj text:(NSString *)text {
    if (!self.currentObject) {
        return [RACSignal error:LookinErr_Inner];
    }
    if (!text.length) {
        return [RACSignal error:LookinErrorMake(NSLocalizedString(@"Content is empty.", nil), @"")];
    }
    if (![LKAppsManager sharedInstance].inspectingApp) {
        return [RACSignal error:LookinErr_NoConnect];
    }
    if ([text containsString:@":"]) {
        NSString *className = obj.rawClassName;
        NSString *address = obj.memoryAddress;
        NSString *errDesc = [NSString stringWithFormat:NSLocalizedString(@"You can click \"Pause\" button near the bottom-left corner in Xcode to pause your iOS app, and input in Xcode console like the contents below:\nexpr [((%@ *)%@) %@]", nil), className, address, text];
        return [RACSignal error:LookinErrorMake(NSLocalizedString(@"Lookin doesn't support invoking methods with arguments yet.", nil), errDesc)];
    }
    if ([text containsString:@"."]) {
        return [RACSignal error:LookinErrorMake(NSLocalizedString(@"Lookin doesn't support this syntax yet. Please input a method or property name.", nil), @"")];
    }
    @weakify(self);
    return [[[LKAppsManager sharedInstance].inspectingApp invokeMethodWithOid:obj.oid text:text] doNext:^(NSDictionary *dict) {
        NSString *returnDescription = dict[@"description"];
        LookinObject *returnObject = dict[@"object"];

        @strongify(self);
        NSMutableArray<LKConsoleDataSourceRowItem *> *rowItems = self.rowItems.mutableCopy;
        [rowItems insertObject:({
            LKConsoleDataSourceRowItem *item = [LKConsoleDataSourceRowItem new];
            item.type = LKConsoleDataSourceRowItemTypeSubmit;
            item.normalText = text;
            item.highlightText = [NSString stringWithFormat:@"<%@: %@>", obj.lk_simpleDemangledClassName, obj.memoryAddress];
            item;
        }) atIndex:(rowItems.count - 1)];
        if (returnDescription.length) {
            [rowItems insertObject:({
                LKConsoleDataSourceRowItem *item = [LKConsoleDataSourceRowItem new];
                item.type = LKConsoleDataSourceRowItemTypeReturn;
                item.normalText = returnDescription;
                item;
            }) atIndex:(rowItems.count - 1)];
        }
        if (returnObject) {
            NSString *message = [NSString stringWithFormat:@"<%@: %@> => %@", obj.lk_simpleDemangledClassName, obj.memoryAddress, text];
            [self _addRecentObject:returnObject message:message];
        }
        
        self.rowItems = rowItems;
    }];
}

- (RACSignal *)makeObjectAsCurrent:(LookinObject *)obj {
    NSString *className = obj.rawClassName;
    if (!className.length) {
        return [RACSignal error:LookinErr_Inner];
    }
    if (![LKAppsManager sharedInstance].inspectingApp) {
        return [RACSignal error:LookinErr_NoConnect];
    }
    if ([self.classesToSelsDict objectForKey:className]) {
        self.currentObject = obj;
        return [RACSignal return:nil];
    }
    
    @weakify(self);
    return [[[LKAppsManager sharedInstance].inspectingApp fetchSelectorNamesWithClass:obj.rawClassName hasArg:YES] doNext:^(NSArray<NSString *> *sels) {
        @strongify(self);
        self.classesToSelsDict[className] = sels;
        self.currentObject = obj;
    }];
}

- (NSArray<NSString *> *)currentObjectSelectorNameList {
    return self.classesToSelsDict[self.currentObject.rawClassName];
}

- (void)clearHistoryContents {
    LKConsoleDataSourceRowItem *item = [LKConsoleDataSourceRowItem new];
    item.type = LKConsoleDataSourceRowItemTypeInput;
    self.rowItems = @[item];
}

- (void)setSelectedObjects:(NSArray<LookinObject *> *)selectedObjects {
    _selectedObjects = selectedObjects.copy;
    [self _syncConsoleTargetIfNeeded];
}

- (void)setIsShowingConsole:(BOOL)isShowingConsole {
    _isShowingConsole = isShowingConsole;
    [self _syncConsoleTargetIfNeeded];
}

- (void)_syncConsoleTargetIfNeeded {
    if (self.isShowingConsole && self.selectedObjects.count) {
        if ([LKPreferenceManager mainManager].syncConsoleTarget || !self.currentObject) {
            [[self makeObjectAsCurrent:self.selectedObjects.lastObject] subscribeNext:^(id  _Nullable x) {
                
            } error:^(NSError * _Nullable error) {
                
            }];
        }
    }
}

- (void)_addRecentObject:(LookinObject *)object message:(NSString *)message {
    if (!object) {
        return;
    }
    NSUInteger sameObjIdx = [self.recentObjects indexOfObjectPassingTest:^BOOL(RACTwoTuple * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return ((LookinObject *)obj.first).oid == object.oid;
    }];
    if (sameObjIdx != NSNotFound) {
        [self.recentObjects removeObjectAtIndex:sameObjIdx];
    }
    
    NSUInteger maxCount = 5;
    if (!self.recentObjects) {
        _recentObjects = [NSMutableArray arrayWithCapacity:maxCount];
    }
    
    RACTwoTuple *newTuple = [RACTwoTuple tupleWithObjectsFromArray:@[object, message]];
    [self.recentObjects insertObject:newTuple atIndex:0];
    
    if (self.recentObjects.count > maxCount) {
        [self.recentObjects removeLastObject];
    }
}

@end
