//
//  LKInputSearchSuggestionsContentView.h
//  Lookin
//
//  Created by Li Kai on 2019/6/3.
//  https://lookin.work
//

#import "LKBaseView.h"

@class LKInputSearchSuggestionItem;

@interface LKInputSearchSuggestionsContentView : LKBaseView

@property(nonatomic, copy) NSArray<LKInputSearchSuggestionItem *> *items;

@property(nonatomic, strong, readonly) NSTableView *tableView;

- (LKInputSearchSuggestionItem *)currentSelectedItem;

- (NSSize)bestSize;

@end
