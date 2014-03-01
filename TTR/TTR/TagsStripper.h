//
//  TagsStripper.h
//  TTR
//
//  Created by Nikola Sobadjiev on 3/1/14.
//  Copyright (c) 2014 Nikola Sobadjiev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagsStripper : NSObject
{
    
}

@property (nonatomic, strong) NSString* htmlString;

- (NSString*)strippedHtmlString;

@end
