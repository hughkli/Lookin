//
//  LKHelper.m
//  Lookin
//
//  Created by Li Kai on 2018/8/4.
//  https://lookin.work
//

#import "LKHelper.h"
#import "NSString+Score.h"

const CGFloat HierarchyMinWidth = 200;
const CGFloat MeasureViewWidth = 240;
const CGFloat DashboardViewWidth = 260;
const CGFloat DashboardHorInset = 10;
const CGFloat DashboardAttrItemHorInterspace = 10;
const CGFloat DashboardAttrItemVerInterspace = 9;
const CGFloat DashboardCardControlCornerRadius = 4;
const CGFloat DashboardSectionMarginTop = 10;
const CGFloat DashboardCardCornerRadius = 6;
const CGFloat DashboardSearchCardInset = 6;
const CGFloat ConsoleInsetLeft = 10;
const CGFloat ConsoleInsetRight = 26;
const CGFloat ZoomSliderMaxValue = 2.8;

@implementation LKHelper

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LKHelper *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

+ (NSFont *)italicFontOfSize:(CGFloat)fontSize {
    NSFontDescriptor *fontDescriptor = [NSFontMake(fontSize).fontDescriptor fontDescriptorWithSymbolicTraits:NSFontDescriptorTraitItalic];
    NSFont *font = [NSFont fontWithDescriptor:fontDescriptor size:fontSize];
    return font;
}

+ (NSString *)lookinReadableVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *string = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return string ? : @"";
}

+ (void)openLookinWebsiteWithPath:(NSString *)path {
    NSString *version = [[self lookinReadableVersion] stringByReplacingOccurrencesOfString:@"." withString:@"d"];
    NSString *urlString = [NSString stringWithFormat:@"https://lookin.work/%@?v=%@", path, version];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
}

+ (void)openLookinOfficialWebsite {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://lookin.work"]];
}

+ (void)openCustomConfigWebsite {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://lookin.work/faq/config-file/"]];
}

+ (BOOL)isEnglish {
    static dispatch_once_t onceToken;
    static BOOL isEnglish = YES;
    dispatch_once(&onceToken,^{
        NSArray *languages = [NSLocale preferredLanguages];
        NSString *language = [languages objectAtIndex:0];
        isEnglish = ![language hasPrefix:@"zh"];
    });
    return isEnglish;
}

+ (NSColor *)accentColor {
    return [NSColor controlAccentColor];
}

+ (NSArray<NSString *> *)bestMatchesInCandidates:(NSArray<NSString *> *)candidates input:(NSString *)input maxResultsCount:(NSUInteger)maxResultsCount {
    // {"string":"abc", "score":@(0.75)}
    NSMutableArray<NSDictionary *> *topResults = [NSMutableArray arrayWithCapacity:maxResultsCount];
    __block CGFloat lowestScore = 1;
    
    input = [input lowercaseString];
    [candidates enumerateObjectsUsingBlock:^(NSString * _Nonnull candidate, NSUInteger idx, BOOL * _Nonnull stop) {
        if (lowestScore >= 1 && topResults.count >= maxResultsCount) {
            *stop = YES;
            return;
        }
        
        NSString *candidate_lowercase = [candidate lowercaseString];
        CGFloat score;
        if ([candidate_lowercase containsString:input]) {
            score = 1;
        } else {
            score = [input scoreAgainst:candidate_lowercase fuzziness:@(.5) options:NSStringScoreOptionNone];
        }
        
        if (topResults.count < maxResultsCount) {
            [topResults addObject:@{@"string": candidate, @"score":@(score)}];
            
            if (score < lowestScore) {
                lowestScore = score;
            }
            return;
        }
        
        if (score > lowestScore) {
            NSUInteger idxToDelete = [self _indexOfSmallestNumberInArray:[topResults lookin_map:^id(NSUInteger idx, NSDictionary *value) {
                return value[@"score"];
            }]];
            [topResults removeObjectAtIndex:idxToDelete];
            [topResults addObject:@{@"string": candidate, @"score":@(score)}];
            lowestScore = [self _smallestNumberInArray:[topResults lookin_map:^id(NSUInteger idx, NSDictionary *value) {
                return value[@"score"];
            }]];
        }
    }];
    
    [topResults sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        CGFloat score1 = ((NSNumber *)obj1[@"score"]).doubleValue;
        CGFloat score2 = ((NSNumber *)obj2[@"score"]).doubleValue;
        if (score1 > score2) {
            return NSOrderedAscending;
        } else if (score1 < score2) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    NSArray<NSString *> *resultStrings = [topResults lookin_map:^id(NSUInteger idx, NSDictionary *value) {
        return value[@"string"];
    }];
    return resultStrings;
}

+ (NSUInteger)_indexOfSmallestNumberInArray:(NSArray<NSNumber *> *)array {
    if (array.count == 0) {
        NSAssert(NO, @"_indexOfSmallestNumberInArray");
        return NSNotFound;
    }
    __block NSUInteger index = NSNotFound;
    __block CGFloat smallestNumber = CGFLOAT_MAX;
    [array enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.doubleValue < smallestNumber) {
            smallestNumber = obj.doubleValue;
            index = idx;
        }
    }];
    return index;
}

+ (CGFloat)_smallestNumberInArray:(NSArray<NSNumber *> *)array {
    if (!array.count) {
        NSAssert(NO, @"_smallestNumberInArray");
        return 0;
    }
    __block CGFloat smallestNumber = CGFLOAT_MAX;
    [array enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.doubleValue < smallestNumber) {
            smallestNumber = obj.doubleValue;
        }
    }];
    return smallestNumber;
}

+ (NSScrollView *)scrollableTextView {
    return [NSTextView scrollableTextView];
}

+ (BOOL)validateFrame:(CGRect)frame {
    return !CGRectIsNull(frame) && !CGRectIsInfinite(frame) && ![self cgRectIsNaN:frame] && ![self cgRectIsInf:frame] && ![self cgRectIsUnreasonable:frame];
}

+ (BOOL)cgRectIsNaN:(CGRect)rect {
    return isnan(rect.origin.x) || isnan(rect.origin.y) || isnan(rect.size.width) || isnan(rect.size.height);
}

+ (BOOL)cgRectIsInf:(CGRect)rect {
    return isinf(rect.origin.x) || isinf(rect.origin.y) || isinf(rect.size.width) || isinf(rect.size.height);
}

+ (BOOL)cgRectIsUnreasonable:(CGRect)rect {
    return ABS(rect.origin.x) > 100000 || ABS(rect.origin.y) > 100000 || rect.size.width < 0 || rect.size.height < 0 || rect.size.width > 100000 || rect.size.height > 100000;
}
@end
