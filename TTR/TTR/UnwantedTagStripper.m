//
//  UnwantedTagStipper.m
//  TTR
//
//  Created by Nikola Sobadjiev on 2/15/14.
//  Copyright (c) 2014 Nikola Sobadjiev. All rights reserved.
//

#import "UnwantedTagStripper.h"
#import "RegexFactory.h"

@interface UnwantedTagStripper ()

- (NSArray*)defaultUnwantedTags;
- (NSString*)patternForUnwantedTag:(NSString*)tag;
- (NSArray*)unwantedPatterns;

@end

@implementation UnwantedTagStripper

@synthesize unwantedTags;
@synthesize htmlString;

+ (UnwantedTagStripper*)tagStripperWithHtmlString:(NSString*)html
{
    return [[UnwantedTagStripper alloc] initWithHtmlString:html];
}

- (id)initWithHtmlString:(NSString*)html
{
    self = [super init];
    if (self)
    {
        self.htmlString = html;
        self.unwantedTags = [self defaultUnwantedTags];
    }
    return self;
}

- (NSString*)strippedHtmlString
{
    NSMutableString* mutableHtml = [NSMutableString stringWithString:self.htmlString];
    for (NSString* unwantedTag in [self unwantedPatterns])
    {
        [RegexFactory removeMatchesForPattern:unwantedTag
                                     inString:mutableHtml];
    }
    return [NSString stringWithString:mutableHtml];
}

#pragma mark PrivateMethods

- (NSArray*)defaultUnwantedTags
{
    return [NSArray arrayWithObjects:@"script", @"remark", @"style", nil];
}

- (NSString*)patternForUnwantedTag:(NSString*)tag
{
    return [NSString stringWithFormat:@"<%@((?!</%@>).)*</%@>", tag, tag, tag];
}

- (NSArray*)unwantedPatterns
{
    NSString* whitespacePattern = @"[\040\t]{2,}";
    NSString* emptyLinePattern = @"^(\n)+|\n\n|(\n)+$";
    NSMutableArray* unwantedPatterns = [NSMutableArray arrayWithObjects:whitespacePattern, emptyLinePattern, nil];
    for (NSString* unwantedTag in [self unwantedTags])
    {
        [unwantedPatterns addObject:[self patternForUnwantedTag:unwantedTag]];
    }
    return unwantedPatterns;
}

@end
