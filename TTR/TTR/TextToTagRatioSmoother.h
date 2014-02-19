//
//  TextToTagRatioSmoother.h
//  TTR
//
//  Created by Nikola Sobadjiev on 2/15/14.
//  Copyright (c) 2014 Nikola Sobadjiev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextToTagRatioSmoother : NSObject
{
    NSArray* ttrArray;
}

- (id)initWithTTRArray:(NSArray*)_ttrArray;
+ (TextToTagRatioSmoother*)ttrSmootherWithArray:(NSArray*)ttrArray;

- (NSArray*)smoothTtrArray;

@end
