//
//  NSString+Score.m
//
//  Created by Nicholas Bruning on 5/12/11.
//  Copyright (c) 2011 Involved Pty Ltd. All rights reserved.
//

//score reference: http://jsfiddle.net/JrLVD/

#import "NSString+Score.h"

@implementation NSString (Score)

- (CGFloat) scoreAgainst:(NSString *)otherString{
    return [self scoreAgainst:otherString fuzziness:nil];
}

- (CGFloat) scoreAgainst:(NSString *)otherString fuzziness:(NSNumber *)fuzziness{
    return [self scoreAgainst:otherString fuzziness:fuzziness options:NSStringScoreOptionNone];
}

- (CGFloat) scoreAgainst:(NSString *)anotherString fuzziness:(NSNumber *)fuzziness options:(NSStringScoreOption)options {
    NSCharacterSet *invalidCharacterSet = [self invalidCharacterSet];
    NSString *string = [self decomposedStringWithInvalidCharacterSet:invalidCharacterSet];
    return [self scoreAgainst:anotherString fuzziness:fuzziness options:options invalidCharacterSet:invalidCharacterSet decomposedString:string];
}

- (NSCharacterSet *)invalidCharacterSet {
    NSMutableCharacterSet *workingInvalidCharacterSet = [NSCharacterSet lowercaseLetterCharacterSet].mutableCopy;
    [workingInvalidCharacterSet formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
    [workingInvalidCharacterSet addCharactersInString:@" "];
    NSCharacterSet *invalidCharacterSet = [workingInvalidCharacterSet invertedSet];
    return invalidCharacterSet;
}

- (NSString *)decomposedStringWithInvalidCharacterSet:(NSCharacterSet *)invalidCharacterSet {
    NSString *string = [[[self decomposedStringWithCanonicalMapping] componentsSeparatedByCharactersInSet:invalidCharacterSet] componentsJoinedByString:@""];
    return string;
}

- (CGFloat) scoreAgainst:(NSString *)anotherString fuzziness:(NSNumber *)fuzziness options:(NSStringScoreOption)options
     invalidCharacterSet:(NSCharacterSet *)invalidCharacterSet decomposedString:(NSString *)string {
    NSString *otherString = [[[anotherString decomposedStringWithCanonicalMapping] componentsSeparatedByCharactersInSet:invalidCharacterSet] componentsJoinedByString:@""];
    
    // If the string is equal to the abbreviation, perfect match.
    if([string isEqualToString:otherString]) return (CGFloat) 1.0f;
    
    //if it's not a perfect match and is empty return 0
    if([otherString length] == 0) return (CGFloat) 0.0f;
    
    CGFloat totalCharacterScore = 0;
    NSUInteger otherStringLength = [otherString length];
    NSUInteger stringLength = [string length];
    BOOL startOfStringBonus = NO;
    CGFloat otherStringScore;
    CGFloat fuzzies = 1;
    CGFloat finalScore;

    NSString *otherUpper = [otherString uppercaseString];
    NSString *otherLower = [otherString lowercaseString];

    CGFloat fuzzinessFloat = fuzziness.floatValue;

    unichar space = [@" " characterAtIndex:0];

    // Walk through abbreviation and add up scores.
    for(uint index = 0; index < otherStringLength; index++){
        CGFloat characterScore = 0.1;
        NSInteger indexInString = NSNotFound;
        NSRange rangeChrLowercase;
        NSRange rangeChrUppercase;

        NSRange r  =NSMakeRange(index, 1);

        unichar chr = [otherString characterAtIndex:index];

        NSString *upperChr = [otherUpper substringWithRange:r];
        NSString *lowerChr = [otherLower substringWithRange:r];

        //make these next few lines leverage NSNotfound, methinks.
        rangeChrLowercase = [string rangeOfString:lowerChr];
        rangeChrUppercase = [string rangeOfString:upperChr];
        
        if(rangeChrLowercase.location == NSNotFound && rangeChrUppercase.location == NSNotFound){
            if(fuzziness != nil){
                fuzzies += 1 - fuzzinessFloat;
            } else {
                return 0; // this is an error!
            }
            
        } else if (rangeChrLowercase.location != NSNotFound && rangeChrUppercase.location != NSNotFound){
            indexInString = MIN(rangeChrLowercase.location, rangeChrUppercase.location);
            
        } else if(rangeChrLowercase.location != NSNotFound || rangeChrUppercase.location != NSNotFound){
            indexInString = rangeChrLowercase.location != NSNotFound ? rangeChrLowercase.location : rangeChrUppercase.location;
            
        } else {
            indexInString = MIN(rangeChrLowercase.location, rangeChrUppercase.location);
            
        }
        
        // Set base score for matching chr
        
        // Same case bonus.
        if(indexInString != NSNotFound && [string characterAtIndex:indexInString] == chr){
            characterScore += 0.1;
        }
        
        // Consecutive letter & start-of-string bonus
        if(indexInString == 0){
            // Increase the score when matching first character of the remainder of the string
            characterScore += 0.6;
            if(index == 0){
                // If match is the first character of the string
                // & the first character of abbreviation, add a
                // start-of-string match bonus.
                startOfStringBonus = YES;
            }
        } else if(indexInString != NSNotFound) {
            // Acronym Bonus
            // Weighing Logic: Typing the first character of an acronym is as if you
            // preceded it with two perfect character matches.

            if([string characterAtIndex:indexInString - 1] == space) {
                characterScore += 0.8;
            }
        }
        
        // Left trim the already matched part of the string
        // (forces sequential matching).
        if(indexInString != NSNotFound){
            string = [string substringFromIndex:indexInString + 1];
        }
        
        totalCharacterScore += characterScore;
    }
    
    if(NSStringScoreOptionFavorSmallerWords == (options & NSStringScoreOptionFavorSmallerWords)){
        // Weigh smaller words higher
        return totalCharacterScore / stringLength;
    } 
    
    otherStringScore = totalCharacterScore / otherStringLength;
    
    if(NSStringScoreOptionReducedLongStringPenalty == (options & NSStringScoreOptionReducedLongStringPenalty)){
        // Reduce the penalty for longer words
        CGFloat percentageOfMatchedString = otherStringLength / stringLength;
        CGFloat wordScore = otherStringScore * percentageOfMatchedString;
        finalScore = (wordScore + otherStringScore) / 2;
        
    } else {
        finalScore = ((otherStringScore * ((CGFloat)(otherStringLength) / (CGFloat)(stringLength))) + otherStringScore) / 2;
    }
    
    finalScore = finalScore / fuzzies;
    
    if(startOfStringBonus && finalScore + 0.15 < 1){
        finalScore += 0.15;
    }
    
    return finalScore;
}

@end
