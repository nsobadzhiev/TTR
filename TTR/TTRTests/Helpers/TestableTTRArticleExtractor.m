//
//  TestableTTRArticleExtractor.m
//  TTR
//
//  Created by Nikola Sobadjiev on 1/25/14.
//  Copyright (c) 2014 Nikola Sobadjiev. All rights reserved.
//

#import "TestableTTRArticleExtractor.h"

@implementation TestableTTRArticleExtractor

- (NSArray*)htmlLinesArray
{
    return htmlLines;
}

- (void)setTtrArray:(NSArray*)array
{
    tagToTextRatioArray = array;
}

@end
