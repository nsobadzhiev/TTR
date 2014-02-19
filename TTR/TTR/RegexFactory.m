//
//  RegexFactory.m
//  TTR
//
//  Created by Nikola Sobadjiev on 2/15/14.
//  Copyright (c) 2014 Nikola Sobadjiev. All rights reserved.
//

#import "RegexFactory.h"

@implementation RegexFactory

+ (NSRegularExpression*)regexForPattern:(NSString*)pattern
{
    NSError* regexError = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                                                             error:&regexError];
    if (regexError)
    {
        NSLog(@"Regex creation failed with error: %@", [regexError description]);
        return nil;
    }
    return regex;
}

+ (NSArray*)matchesForPattern:(NSString*)pattern
                     inString:(NSString*)string
{
    NSRegularExpression* regex = [self regexForPattern:pattern];
    NSArray* matches = [regex matchesInString:string
                                      options:NSMatchingWithoutAnchoringBounds
                                        range:NSMakeRange(0, string.length)];
    return matches;
}

+ (void)removeMatchesForPattern:(NSString*)pattern
                       inString:(NSMutableString*)string
{
    NSRegularExpression* regex = [self regexForPattern:pattern];
    [regex replaceMatchesInString:string
                          options:NSMatchingWithoutAnchoringBounds
                            range:NSMakeRange(0, string.length)
                     withTemplate:@""];
}

@end
