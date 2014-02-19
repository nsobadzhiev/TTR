//
//  RegexFactory.h
//  TTR
//
//  Created by Nikola Sobadjiev on 2/15/14.
//  Copyright (c) 2014 Nikola Sobadjiev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegexFactory : NSObject
{
    
}

+ (NSRegularExpression*)regexForPattern:(NSString*)pattern;
+ (NSArray*)matchesForPattern:(NSString*)pattern
                     inString:(NSString*)string;
+ (void)removeMatchesForPattern:(NSString*)pattern
                       inString:(NSString*)string;

@end
