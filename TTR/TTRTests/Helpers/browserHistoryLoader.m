//
//  browserHistoryLoader.m
//  htmlReader
//
//  Created by Nikola Sobadjiev on 10/5/13.
//  Copyright (c) 2013 Nikola Sobadjiev. All rights reserved.
//

#import "browserHistoryLoader.h"

@interface browserHistoryLoader ()

- (void)initializeWithDate:(NSCalendarDate*)date;
- (void)initializeHistoryProvider;
- (NSArray*)urlsForWebHistory:(NSArray*)webHistory;
- (void)loadHistorypList;
- (void)processHistoryPlist:(NSDictionary*)historyPlist;
- (BOOL)isDateFromToday:(NSDate*)date;

@end

@implementation browserHistoryLoader

@synthesize webHistoryItems;

+ (NSArray*)browseHistoryForDate:(NSCalendarDate*)date
{
    browserHistoryLoader* browserHistory = [[browserHistoryLoader alloc] initWithCalendarDate:date];
    return browserHistory.webHistoryItems;
}

+ (NSArray*)browseHistoryForToday
{
    browserHistoryLoader* browserHistory = [[browserHistoryLoader alloc] init];
    return browserHistory.webHistoryItems;
}

- (id)initWithCalendarDate:(NSCalendarDate*)date
{
    self = [super init];
    if (self)
    {
        [self initializeWithDate:date];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initializeWithDate:[NSCalendarDate date]];    // for today
    }
    return self;
}

- (NSArray*)webHistoryItems
{
    return [self urlsForWebHistory:webHistoryItems];
}

- (void)refreshBrowserHistory
{
    if (webHistoryProvider == nil)
    {
        [self loadHistorypList];
    }
    else
    {
        webHistoryItems = [webHistoryProvider orderedItemsLastVisitedOnDay:webHistoryDate];
    }
}

- (void)initializeWithDate:(NSCalendarDate*)date
{
    webHistoryDate = date;
    [self initializeHistoryProvider];
    [self refreshBrowserHistory];
}

- (void)initializeHistoryProvider
{
    webHistoryProvider = [WebHistory optionalSharedHistory];
    if (webHistoryProvider == nil)
    {
        [self loadHistorypList];
    }
}

- (NSArray*)urlsForWebHistory:(NSArray*)webHistory
{
    NSMutableArray* urlsArray = [NSMutableArray arrayWithCapacity:webHistory.count];
    for (WebHistoryItem* webHistoryItem in webHistory)
    {
        NSString* url = [webHistoryItem URLString];
        [urlsArray addObject:url];
    }
    return [NSArray arrayWithArray:urlsArray];  // to make it immutable
}

- (void)loadHistorypList
{
    NSError *error;
    NSString* historyFileName = @"/Users/nikolasobadjiev/Library/Safari/History.plist";
    NSData* plistData = [NSData dataWithContentsOfFile:historyFileName];
    NSPropertyListFormat format;
    NSString* errorString = nil;
    NSDictionary* historyPlist = [NSPropertyListSerialization propertyListFromData:plistData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:&format
                                                           errorDescription:&errorString];

    if(!historyPlist)
    {
        NSLog(@"Error: %@",error);
        return;
    }
    else
    {
        [self processHistoryPlist:historyPlist];
    }
}

- (void)processHistoryPlist:(NSDictionary*)historyPlist
{
    NSArray* allHistoryEntries = [historyPlist objectForKey:@"WebHistoryDates"];
    NSMutableArray* webHistoryEntries = [NSMutableArray arrayWithCapacity:allHistoryEntries.count];
    for (NSDictionary* historyEntry in allHistoryEntries)
    {
        NSString* entryURL = [historyEntry objectForKey:@""];   // the URL seams to have an empty key in the plist
        NSString* entryDateStr = [historyEntry objectForKey:@"lastVisitedDate"];
        NSTimeInterval entryDateInterval = [entryDateStr floatValue];
        NSDate* visitDate = [NSDate dateWithTimeIntervalSinceReferenceDate:entryDateInterval];
        NSString* entryTitle = [historyEntry objectForKey:@"title"];
        
        if ([self isDateFromToday:visitDate] == NO)
        {
            // don't handle history that's not from today
            break;
        }
        
        WebHistoryItem* newWebItem = [[WebHistoryItem alloc] initWithURLString:entryURL
                                                                         title:entryTitle
                                                       lastVisitedTimeInterval:entryDateInterval];
        [webHistoryEntries addObject:newWebItem];
    }
    webHistoryItems = [NSArray arrayWithArray:webHistoryEntries];
}

- (BOOL)isDateFromToday:(NSDate *)_date
{
    if (_date == nil)
    {
        // don't allow events with no date to be added
        return NO;
    }
    
    // YES if the event happened today
    NSDate* date = [[NSDate alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:_date];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    return [today isEqualToDate:otherDate];
}

@end
