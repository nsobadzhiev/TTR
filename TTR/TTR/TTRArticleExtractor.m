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

- (NSString*)removeTagsFromString:(NSMutableString*)string
{
    ttrTagStripper = [TagsStripper new];
    ttrTagStripper.htmlString = string;
    return [ttrTagStripper strippedHtmlString];
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
    NSString* strippedArticle = [extractor removeTagsFromString:articleString];
    return [strippedArticle gtm_stringByUnescapingFromHTML];
}

@end
