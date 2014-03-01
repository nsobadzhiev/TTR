//
//  TagsStripper.m
//  TTR
//
//  Created by Nikola Sobadjiev on 3/1/14.
//  Copyright (c) 2014 Nikola Sobadjiev. All rights reserved.
//

#import "TagsStripper.h"
#import "RegexFactory.h"

@implementation TagsStripper

- (NSString*)strippedHtmlString
{
    NSMutableString* mutableHtml = [NSMutableString stringWithString:self.htmlString];
    [RegexFactory removeMatchesForPattern:@"(^((?!(<|>)).)*>|<((?!<).)*?(>|$))"
                                 inString:mutableHtml];
    return [NSString stringWithString:mutableHtml];
}

@end
