//
//  LKInputSearchSuggestionWindowController.h
//  Lookin
//
//  Created by Li Kai on 2019/6/2.
//  https://lookin.work
//

#import "LKWindowController.h"

@class LKInputSearchSuggestionsContentView;

@interface LKInputSearchSuggestionWindowController : LKWindowController

@property(nonatomic, strong) LKInputSearchSuggestionsContentView *suggestionsView;

@end
