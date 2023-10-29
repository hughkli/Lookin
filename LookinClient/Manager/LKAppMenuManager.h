//
//  LKAppMenuManager.h
//  Lookin
//
//  Created by Li Kai on 2019/3/20.
//  https://lookin.work
//

#import <Foundation/Foundation.h>

@class LKAppMenuManager, LKWindowController;

@protocol LKAppMenuManagerDelegate <NSObject>

@optional

- (void)appMenuManagerDidSelectReload;
- (void)appMenuManagerDidSelectDimension;
- (void)appMenuManagerDidSelectZoomIn;
- (void)appMenuManagerDidSelectZoomOut;
- (void)appMenuManagerDidSelectDecreaseInterspace;
- (void)appMenuManagerDidSelectIncreaseInterspace;
- (void)appMenuManagerDidSelectExpansionIndex:(NSUInteger)index;
- (void)appMenuManagerDidSelectFilter;

- (void)appMenuManagerDidSelectExport;
- (void)appMenuManagerDidSelectOpenInNewWindow;

@end

@interface LKAppMenuManager : NSObject <NSMenuDelegate>

+ (instancetype)sharedInstance;

- (void)setup;

@end
