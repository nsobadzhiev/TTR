//
//  TTRArticleExtractor.m
//  TTR
//
//  Created by Nikola Sobadjiev on 1/21/14.
//  Copyright (c) 2014 Nikola Sobadjiev. All rights reserved.
//

#import "TTRArticleExtractor.h"
#import "GTMNSString+HTML.h"

@interface TTRArticleExtractor ()

- (NSRegularExpression*)regexWithPattern:(NSString*)pattern;
- (NSRegularExpression*)scriptsRegex;
- (NSRegularExpression*)remarksRegex;
- (NSRegularExpression*)stylesRegex;
- (NSRegularExpression*)whitespaceRegex;
- (NSRegularExpression*)emptyLinesRegex;
- (NSRegularExpression*)tagsRegex;

- (NSArray*)resultFromRegex:(NSRegularExpression*)regex
                   onString:(NSString*)string;
- (void)removeMatchesInArray:(NSArray*)matches;

- (NSArray*)calculateTtrArray;
- (NSUInteger)regexMatchesLength:(NSArray*)regexMatches;
- (NSNumber*)ttrForLine:(NSString*)line;

- (NSNumber*)smoothedValueForIndex:(NSInteger)index;
- (void)addTtrElementAtIndex:(NSInteger)index
                     toArray:(NSMutableArray*)array;

@end

@implementation TTRArticleExtractor

@synthesize htmlString;
@synthesize tagToTextRatioArray;

- (NSArray*)tagToTextRatioArray
{
    if (self.htmlString == nil)
    {
        return nil;
    }
    if (tagToTextRatioArray == nil)
    {
        ttrCalculator = [[TextToTagRatioCalculator alloc] initWithHtmlString:self.htmlString];
        tagToTextRatioArray = [ttrCalculator textToTagRatioArray];
    }
    return tagToTextRatioArray;
    
}

- (NSArray*)ttrArray
{
    return self.tagToTextRatioArray;
}

- (void)stripScriptTags
{
    unwantedTagStripper = [[UnwantedTagStripper alloc] initWithHtmlString:self.htmlString];
    self.htmlString = [unwantedTagStripper strippedHtmlString];
}

- (void)separateLines
{
    htmlLines = [self.htmlString componentsSeparatedByString:@"\n"];
}

- (void)smoothTtrArray
{
    ttrSmoother = [[TextToTagRatioSmoother alloc] initWithTTRArray:tagToTextRatioArray];
    tagToTextRatioArray = [ttrSmoother smoothTtrArray];
}

- (NSNumber*)standardDeviation
{
    float squareSum = 0;
    for (NSNumber* element in self.tagToTextRatioArray)
    {
        squareSum += powf([element floatValue], 2.0f);
    }
    float denominator = (float) self.tagToTextRatioArray.count;
    return [NSNumber numberWithFloat:sqrtf(squareSum / denominator)];
}

- (NSArray*)contentLines
{
    NSNumber* standardDeviation = [self standardDeviation];
    NSMutableArray* contentsArray = [NSMutableArray arrayWithCapacity:self.tagToTextRatioArray.count];
    for (int i = 0; i < self.tagToTextRatioArray.count; i++)
    {
        NSNumber* ttrNumber = [self.tagToTextRatioArray objectAtIndex:i];
        NSString* lineText = [htmlLines objectAtIndex:i];
        if ([ttrNumber compare:standardDeviation] != NSOrderedAscending)
        {
            [contentsArray addObject:lineText];
        }
    }
    return [NSArray arrayWithArray:contentsArray];
}

- (void)removeTagsFromString:(NSMutableString*)string;
{
    NSRegularExpression* tagsRegex = [self tagsRegex];
    [tagsRegex replaceMatchesInString:string
                              options:NSMatchingWithoutAnchoringBounds
                                range:NSMakeRange(0, string.length) 
                         withTemplate:@""];
}

+ (NSString*)articleText:(NSString*)html
{
    TTRArticleExtractor* extractor = [TTRArticleExtractor new];
    extractor.htmlString = html;
    [extractor stripScriptTags];
    [extractor separateLines];
    [extractor tagToTextRatioArray];
    [extractor smoothTtrArray];
    
    NSMutableString* articleString = [NSMutableString new];
    NSArray* contentLines = [extractor contentLines];
    for (NSString* line in contentLines)
    {
        [articleString appendString:line];
        [articleString appendString:@"\n"];
    }
    [extractor removeTagsFromString:articleString];
    return [articleString gtm_stringByUnescapingFromHTML];
}

#pragma mark -- PrivateMethods

- (NSRegularExpression*)regexWithPattern:(NSString*)pattern
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

- (NSRegularExpression*)scriptsRegex
{
    return [self regexWithPattern:@"<script((?!</script>).)*</script>"];
}

- (NSRegularExpression*)remarksRegex
{
    return [self regexWithPattern:@"<remark((?!</remark>).)*</remark>"];
}

- (NSRegularExpression*)stylesRegex
{
    return [self regexWithPattern:@"<style((?!</style>).)*</style>"];
}

- (NSRegularExpression*)whitespaceRegex
{
    return [self regexWithPattern:@"[\040\t]{2,}"];
}

- (NSRegularExpression*)emptyLinesRegex
{
    return [self regexWithPattern:@"^(\n)+|\n\n|(\n)+$"];
}

- (NSRegularExpression*)tagsRegex
{
    return [self regexWithPattern:@"(^((?!(<|>)).)*>|<((?!<).)*?(>|$))"];
}

- (NSArray*)resultFromRegex:(NSRegularExpression*)regex
                   onString:(NSString*)string
{
    NSArray* matches = [regex matchesInString:string
                                      options:NSMatchingWithoutAnchoringBounds
                                        range:NSMakeRange(0, string.length)];
    return matches;
}

- (void)removeMatchesInArray:(NSArray*)matches
{
    if (![self.htmlString isMemberOfClass:[NSMutableString class]])
    {
        self.htmlString = [NSMutableString stringWithString:self.htmlString];
    }
    NSUInteger numRemovedCharacters = 0;
    for (NSTextCheckingResult* match in matches)
    {
        NSRange deletionRange = match.range;
        deletionRange.location -= numRemovedCharacters;
        numRemovedCharacters += deletionRange.length;
        [(NSMutableString*)self.htmlString deleteCharactersInRange:deletionRange];
    }
}

- (NSArray*)calculateTtrArray
{
    NSMutableArray* ttrArray = [NSMutableArray arrayWithCapacity:htmlLines.count];
    for (NSString* line in htmlLines)
    {
        [ttrArray addObject:[self ttrForLine:line]];
    }
    return [NSArray arrayWithArray:ttrArray];
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

- (NSNumber*)ttrForLine:(NSString*)line
{
    NSArray* tagsArray = [self resultFromRegex:[self tagsRegex]
                                      onString:line];
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

- (NSNumber*)smoothedValueForIndex:(NSInteger)index
{
    float sum = 0.0f;
    for (long i = index - 2; i <= index + 2; i++)
    {
        if (i >= 0 && i < self.tagToTextRatioArray.count)
        {
            sum += [(NSNumber*)[self.tagToTextRatioArray objectAtIndex:i] floatValue];
        }
    }
    float denominator = 2 * 2 + 1;
    return [NSNumber numberWithFloat:sum/denominator];
}

- (void)addTtrElementAtIndex:(NSInteger)index
                     toArray:(NSMutableArray*)array
{
    if (index >= 0 && index < self.tagToTextRatioArray.count)
    {
        [array addObject:[self.tagToTextRatioArray objectAtIndex:index]];
    }
}

@end
