//
//  LKDashboardAttributeRelationView.m
//  Lookin
//
//  Created by Li Kai on 2019/6/14.
//  https://lookin.work
//

#import "LKDashboardAttributeRelationView.h"
#import "Lookin-Swift.h"

@implementation LKDashboardAttributeRelationView

- (NSArray<NSString *> *)stringListWithAttribute:(LookinAttribute *)attribute {
    NSArray<NSString *> *cache = [attribute lookin_getBindObjectForKey:@"cachedDemangled"];
    if (cache) {
        return cache;
    }
    NSArray<NSString *> *result = attribute.value;
    NSArray<NSString *> *demangled = [result lookin_map:^id(NSUInteger idx, NSString *raw) {
        return [self demangle:raw];
    }];
    [attribute lookin_bindObject:demangled forKey:@"cachedDemangled"];
    return demangled;
}

- (NSString *)demangle:(NSString *)rawText {
    {
        // 先看看是不是 (AAA : BBB *)
        NSString *regexPattern = @"\\(\\s*(\\w+)\\s*:\\s*(\\w+)\\s*\\*\\s*\\)";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern options:0 error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:rawText options:0 range:NSMakeRange(0, rawText.length)];
        
        if (match) {
            assert(match.numberOfRanges == 3);
            NSRange range1 = [match rangeAtIndex:1];
            NSRange range2 = [match rangeAtIndex:2];
            NSString *substring1 = [rawText substringWithRange:range1];
            NSString *substring2 = [rawText substringWithRange:range2];
            NSString *demangled1 = [LKSwiftDemangler simpleParseWithInput:substring1];
            NSString *demangled2 = [LKSwiftDemangler simpleParseWithInput:substring2];
            
            NSString *newText = [rawText stringByReplacingCharactersInRange:range1 withString:demangled1];
            newText = [newText stringByReplacingOccurrencesOfString:substring2 withString:demangled2];
            return newText;
        }
    }
    
    {
        // 再看看是不是 (AAA *)
        NSString *regexPattern = @"\\(\\s*(\\w+)\\s*\\*\\s*\\)";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern options:0 error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:rawText options:0 range:NSMakeRange(0, rawText.length)];
        
        if (match) {
            NSRange range = [match rangeAtIndex:1];
            NSString *rawClassName = [rawText substringWithRange:range];
            NSString *demangledText = [LKSwiftDemangler simpleParseWithInput:rawClassName];
            NSString *newText = [rawText stringByReplacingCharactersInRange:range withString:demangledText];
            return newText;
        }
    }
    
    return rawText;
}

@end
