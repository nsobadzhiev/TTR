//
//  TextToTagRatioCalculator.m
//  TTR
//
//  Created by Nikola Sobadjiev on 2/15/14.
//  Copyright (c) 2014 Nikola Sobadjiev. All rights reserved.
//

#import "TextToTagRatioCalculator.h"
#import "RegexFactory.h"

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
    for (NSString* line in htmlStringLines)
    {
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

@end
