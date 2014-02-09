//
//  browserHistoryLoader.h
//  htmlReader
//
//  Created by Nikola Sobadjiev on 10/5/13.
//  Copyright (c) 2013 Nikola Sobadjiev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface browserHistoryLoader : NSObject
{
    WebHistory*     webHistoryProvider;
    NSArray*        webHistoryItems;
    NSCalendarDate* webHistoryDate;
}

+ (NSArray*)browseHistoryForDate:(NSCalendarDate*)date;
+ (NSArray*)browseHistoryForToday;

@property (nonatomic, readonly) NSArray* webHistoryItems;

- (id)initWithCalendarDate:(NSCalendarDate*)date;
- (id)init;

- (void)refreshBrowserHistory;

@end
