//
//  TestableTTRArticleExtractor.h
//  TTR
//
//  Created by Nikola Sobadjiev on 1/25/14.
//  Copyright (c) 2014 Nikola Sobadjiev. All rights reserved.
//

#import "TTRArticleExtractor.h"

@interface TestableTTRArticleExtractor : TTRArticleExtractor

- (NSArray*)htmlLinesArray;
- (void)setTtrArray:(NSArray*)array;

@end
