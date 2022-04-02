//
//  LKInputSearchSuggestionWindowController.m
//  Lookin
//
//  Created by Li Kai on 2019/6/2.
//  https://lookin.work
//

#import "LKInputSearchSuggestionWindowController.h"
#import "LKInputSearchSuggestionsContentView.h"

@implementation LKInputSearchSuggestionWindowController

- (instancetype)init {
    LKInputSearchSuggestionsContentView *view = [LKInputSearchSuggestionsContentView new];
    
    NSPanel *suggestionPanel = [[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 400, 100) styleMask:NSWindowStyleMaskUtilityWindow backing:NSBackingStoreBuffered defer:YES];
    suggestionPanel.contentView = view;
    suggestionPanel.floatingPanel = YES;
    suggestionPanel.becomesKeyOnlyIfNeeded = YES;
    suggestionPanel.backgroundColor = [NSColor clearColor];
    
    if (self = [self initWithWindow:suggestionPanel]) {
        self.suggestionsView = view;
    }
    return self;
}

@end
