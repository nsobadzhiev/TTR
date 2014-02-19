//
//  TextToTagRatioSmoother.m
//  TTR
//
//  Created by Nikola Sobadjiev on 2/15/14.
//  Copyright (c) 2014 Nikola Sobadjiev. All rights reserved.
//

#import "TextToTagRatioSmoother.h"

static const float radius = 2;

@implementation TextToTagRatioSmoother

- (id)initWithTTRArray:(NSArray*)_ttrArray
{
    self = [super init];
    if (self)
    {
        ttrArray = _ttrArray;
    }
    return self;
}

+ (TextToTagRatioSmoother*)ttrSmootherWithArray:(NSArray*)ttrArray
{
    return [[TextToTagRatioSmoother alloc] initWithTTRArray:ttrArray];
}

- (NSArray*)smoothTtrArray
{
    NSMutableArray* smoothArray = [NSMutableArray arrayWithCapacity:ttrArray.count];
    for (int i = 0; i < ttrArray.count; i++)
    {
        NSNumber* smoothValue = [self smoothedValueForIndex:i];
        [smoothArray addObject:smoothValue];
    }
    return [NSArray arrayWithArray:smoothArray];
}

- (NSNumber*)smoothedValueForIndex:(NSInteger)index
{
    float sum = 0.0f;
    for (long i = index - radius; i <= index + radius; i++)
    {
        if (i >= 0 && i < ttrArray.count)
        {
            sum += [(NSNumber*)[ttrArray objectAtIndex:i] floatValue];
        }
    }
    float denominator = radius * radius + 1;
    return [NSNumber numberWithFloat:sum/denominator];
}

@end
