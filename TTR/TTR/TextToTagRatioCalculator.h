//
//  TextToTagRatioCalculator.h
//  TTR
//
//  Created by Nikola Sobadjiev on 2/15/14.
//  Copyright (c) 2014 Nikola Sobadjiev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextToTagRatioCalculator : NSObject
{
    NSArray* htmlStringLines;
    NSString* htmlString;
}

- (id)initWithHtmlString:(NSString*)html;
+ (TextToTagRatioCalculator*)ttrCalculatorWithString:(NSString*)html;

- (NSArray*)textToTagRatioArray;

@end
