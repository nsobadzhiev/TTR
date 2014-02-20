//
//  TextToTagRatioCalculator.m
//  TTR
//
//  Created by Nikola Sobadjiev on 2/15/14.
//  Copyright (c) 2014 Nikola Sobadjiev. All rights reserved.
//

#import "TextToTagRatioCalculator.h"
#import "RegexFactory.h"

@interface TextToTagRatioCalculator ()

- (BOOL)hasUnfinishedTag:(NSString*)line;
- (BOOL)hasClosingBracket:(NSString*)line;

@end

@implementation TextToTagRatioCalculator

- (id)initWithHtmlString:(NSString*)html
{
    self = [super init];
    if (self)
    {
        htmlString = html;
        htmlStringLines = nil;
    }
    return self;
}

+ (TextToTagRatioCalculator*)ttrCalculatorWithString:(NSString*)html
{
    return [[TextToTagRatioCalculator alloc] initWithHtmlString:html];
}

- (NSArray*)textToTagRatioArray
{
    htmlStringLines = [htmlString componentsSeparatedByString:@"\n"];
    return [self calculateTtrArray];
}

- (NSArray*)calculateTtrArray
{
    NSMutableArray* ttrArray = [NSMutableArray arrayWithCapacity:htmlStringLines.count];
    BOOL hasCarryOver = NO;     // hasCarryOver is YES if there is an unfinished tag from a previous line
                                // that has to be taken into account for the next one
    for (NSString* line in htmlStringLines)
    {
        if (hasCarryOver == YES)
        {
            if ([self hasClosingBracket:line] == NO)
            {
                [ttrArray addObject:[NSNumber numberWithUnsignedInteger:0]];
                continue;
            }
            else
            {
                hasCarryOver = NO;
            }
        }
        if ([self hasUnfinishedTag:line])
        {
            hasCarryOver = YES;
        }
        [ttrArray addObject:[self ttrForLine:line]];
    }
    return [NSArray arrayWithArray:ttrArray];
}

- (NSNumber*)ttrForLine:(NSString*)line
{
    NSArray* tagsArray = [RegexFactory matchesForPattern:@"(^((?!(<|>)).)*>|<((?!<).)*?(>|$))"
                                                inString:line];
    NSUInteger nonTagCharCount = line.length - [self regexMatchesLength:tagsArray];
    NSUInteger tagsCount = tagsArray.count;
    if (tagsCount != 0)
    {
        return [NSNumber numberWithFloat:(float)nonTagCharCount / (float)tagsCount];
    }
    else
    {
        return [NSNumber numberWithLong:nonTagCharCount];
    }
}

- (NSUInteger)regexMatchesLength:(NSArray*)regexMatches
{
    NSUInteger matchesLength = 0;
    for (NSTextCheckingResult* result in regexMatches)
    {
        matchesLength += result.range.length;
    }
    return matchesLength;
}

- (BOOL)hasUnfinishedTag:(NSString*)line
{
    NSArray* unfinishedTagsArray = [RegexFactory matchesForPattern:@"<((?!>).)*$"
                                                          inString:line];
    return (unfinishedTagsArray.count > 0);
}

- (BOOL)hasClosingBracket:(NSString*)line
{
    NSArray* noClosingBracketsArray = [RegexFactory matchesForPattern:@">"
                                                             inString:line];
    return (noClosingBracketsArray.count > 0);
}

@end
