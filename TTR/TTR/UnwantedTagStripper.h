//
//  UnwantedTagStipper.h
//  TTR
//
//  Created by Nikola Sobadjiev on 2/15/14.
//  Copyright (c) 2014 Nikola Sobadjiev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnwantedTagStripper : NSObject
{
    NSString* htmlString;
    NSArray* unwantedTags;
}

@property (nonatomic, strong) NSArray* unwantedTags;
@property (nonatomic, strong) NSString* htmlString;

+ (UnwantedTagStripper*)tagStripperWithHtmlString:(NSString*)html;
- (id)initWithHtmlString:(NSString*)html;

- (NSString*)strippedHtmlString;

@end
