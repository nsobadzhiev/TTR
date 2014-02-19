//
//  TTRArticleExtractor.h
//  TTR
//
//  Created by Nikola Sobadjiev on 1/21/14.
//  Copyright (c) 2014 Nikola Sobadjiev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnwantedTagStripper.h"
#import "TextToTagRatioCalculator.h"
#import "TextToTagRatioSmoother.h"

@interface TTRArticleExtractor : NSObject
{
    UnwantedTagStripper* unwantedTagStripper;
    TextToTagRatioCalculator* ttrCalculator;
    TextToTagRatioSmoother* ttrSmoother;
    NSArray* htmlLines;
    NSArray* tagToTextRatioArray;
}

@property (strong) NSString* htmlString;
@property (strong, readonly) NSArray* tagToTextRatioArray;

- (NSArray*)ttrArray;
- (void)stripScriptTags;
- (void)separateLines;
- (void)smoothTtrArray;
- (NSNumber*)standardDeviation;
- (NSArray*)contentLines;
- (void)removeTagsFromString:(NSMutableString*)string;

+ (NSString*)articleText:(NSString*)html;

@end
