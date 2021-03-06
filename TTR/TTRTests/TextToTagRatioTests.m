//
//  TextToTagRatioTests.m
//  TTR
//
//  Created by Nikola Sobadjiev on 1/21/14.
//  Copyright (c) 2014 Nikola Sobadjiev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestableTTRArticleExtractor.h"

@interface TextToTagRatioTests : XCTestCase
{
    TestableTTRArticleExtractor* ttrExtractor;
    NSString* htmlString;
}

@end

@implementation TextToTagRatioTests

- (void)setUp
{
    [super setUp];
    ttrExtractor = [TestableTTRArticleExtractor new];
    htmlString = nil;
}

- (void)tearDown
{
    ttrExtractor = nil;
    htmlString = nil;
    [super tearDown];
}

- (void)testTtrArrayReturnsNilIfNoHtmlIsProvided
{
    htmlString = nil;
    ttrExtractor.htmlString = htmlString;
    NSArray* ttrArray = [ttrExtractor ttrArray];
    XCTAssertNil(ttrArray, @"TTR extactor should return a nil ttrArray if no HTML is provided");
}

- (void)testTtrReturnsEmptyArrayIfEmptyHtmlIsProvided
{
    htmlString = @"";
    ttrExtractor.htmlString = htmlString;
    NSArray* ttrArray = [ttrExtractor ttrArray];
    XCTAssert((ttrArray.count == 1 && ttrArray != nil), @"TTR extactor should return an ttrArray with one object if no HTML is provided");
}

- (void)testTtrStripsUnwantedHtmlTags
{
    htmlString = @"<div id=\"slug_leaderboard_2\" style=\"display:none;display: block; text-align: center; border-top: 1px solid rgb(204, 204, 204); padding-top: 10px;\"><script type=\"text/javascript\">placeAd2(commercialNode, 'leaderboard_2', false, '');</script></div>";
    ttrExtractor.htmlString = htmlString;
    [ttrExtractor stripScriptTags];
    NSString* strippedHtml = ttrExtractor.htmlString;
    NSRange scriptStartRange = [strippedHtml rangeOfString:@"<script"];
    NSRange scriptEndRange = [strippedHtml rangeOfString:@"</script>"];
    NSRange remarkStartRange = [strippedHtml rangeOfString:@"<remark"];
    NSRange remarkEndRange = [strippedHtml rangeOfString:@"</remark>"];
    XCTAssertTrue((scriptStartRange.location == NSNotFound), @"There should be no opening script tags");
    XCTAssertTrue((scriptEndRange.location == NSNotFound), @"There should be no closing script tags");
    XCTAssertTrue((remarkStartRange.location == NSNotFound), @"There should be no opening remark tags");
    XCTAssertTrue((remarkEndRange.location == NSNotFound), @"There should be no closing remark tags");
}

- (void)testTtrReturnsSameStringIfNoUnwantedTags
{
    htmlString = @"<ul class=\"search-wrap\"><li data=\"none\" class=\"search\"><form name=\"headersearch\" action=\"http://www.washingtonpost.com/newssearch/search.html\"method=\"get\" onSubmit=\"try{s.sendDataToOmniture('Search Submit','event2',{'eVar38':jQuery(this).find('input[type=text]').val(),'eVar1':s.pageName});}catch(e){};return true;\"><!--input type=\"hidden\" value=\"null\" name=\"searchsection\" /--> <input class=\"restore text autocomplete\" type=\"text\" name=\"st\" value=\"\" /> <input type=\"submit\" class=\"global-search\" name=\"submit\" /> </form> </li> </ul>";
    ttrExtractor.htmlString = htmlString;
    [ttrExtractor stripScriptTags];
    NSString* strippedHtml = ttrExtractor.htmlString;
    XCTAssertEqualObjects(htmlString, strippedHtml, @"The HTML should remain the same after trimming if it does not contain unwanted tags");
}

- (void)testTtrReturnsEmptyStringIfOnlyUnwantedTags
{
    htmlString = @"<script type=\"text/cjs\" data-cjssrc=\"http://js.washingtonpost.com/wpost/js/combo?token=20140114143100&c=true&m=true&context=eidos&r=/search-autocomplete/global-header-autocomplete.js\"></script><remark>Hello</remark><script type=\"text/cjs\">fefeef</script>";
    ttrExtractor.htmlString = htmlString;
    [ttrExtractor stripScriptTags];
    NSString* strippedHtml = ttrExtractor.htmlString;
    XCTAssertEqualObjects(@"", strippedHtml, @"If the HTML contains only unwanted tags, stripping should return an empty string");
}

- (void)testTtrRemovesEmptyLines
{
    htmlString = @"\n\n<script type=\"text/cjs\" data-cjssrc=\"http://js.washingtonpost.com/wpost/js/combo?token=20140114143100&c=true&m=true&context=eidos&r=/search-autocomplete/global-header-autocomplete.js\">\n\n</script><remark>Hello</remark><script type=\"text/cjs\">fefeef</script>";
    ttrExtractor.htmlString = htmlString;
    [ttrExtractor stripScriptTags];
    NSString* strippedHtml = ttrExtractor.htmlString;
    NSRange emptyLineRange = [strippedHtml rangeOfString:@"\n\n"];
    XCTAssertEqual(emptyLineRange.location, NSNotFound, @"TTR should strip empty lines");
}

- (void)testTtrRemovesEmptyWhitespaces
{
    htmlString = @"<tag1 type=\"text/cjs\" data-cjssrc=\"http://js.washingtonpost.com/wpost/js/combo?token=20140114143100&c=true&m=true&context=eidos&r=/search-autocomplete/global-header-autocomplete.js\">       </tag1><tag2>Hello   </tag2><tag3 type=\"text/cjs\">fefeef</tag3>";
    ttrExtractor.htmlString = htmlString;
    [ttrExtractor stripScriptTags];
    NSString* strippedHtml = ttrExtractor.htmlString;
    XCTAssertEqualObjects(strippedHtml, 
                          @"<tag1 type=\"text/cjs\" data-cjssrc=\"http://js.washingtonpost.com/wpost/js/combo?token=20140114143100&c=true&m=true&context=eidos&r=/search-autocomplete/global-header-autocomplete.js\"></tag1><tag2>Hello</tag2><tag3 type=\"text/cjs\">fefeef</tag3>",
                          @"TTR should strip whitespaces");
}

- (void)testTtrRemovesEmptyLinesAtBegining
{
    htmlString = @"\n<script type=\"text/cjs\" data-cjssrc=\"http://js.washingtonpost.com/wpost/js/combo?token=20140114143100&c=true&m=true&context=eidos&r=/search-autocomplete/global-header-autocomplete.js\">\n\n</script><remark>Hello</remark><script type=\"text/cjs\">fefeef</script>";
    ttrExtractor.htmlString = htmlString;
    [ttrExtractor stripScriptTags];
    NSString* strippedHtml = ttrExtractor.htmlString;
    NSRange emptyLineRange = [strippedHtml rangeOfString:@"\n"];
    XCTAssert((emptyLineRange.location == NSNotFound || emptyLineRange.location != 0), @"TTR should strip empty lines at the begining of the file");
}

- (void)testTtrRemovesEmptyLinesAtTheEnd
{
    htmlString = @"<script type=\"text/cjs\" data-cjssrc=\"http://js.washingtonpost.com/wpost/js/combo?token=20140114143100&c=true&m=true&context=eidos&r=/search-autocomplete/global-header-autocomplete.js\"></script><remark>Hello</remark><script type=\"text/cjs\">fefeef</script>\n";
    ttrExtractor.htmlString = htmlString;
    [ttrExtractor stripScriptTags];
    NSString* strippedHtml = ttrExtractor.htmlString;
    NSRange emptyLineRange = [strippedHtml rangeOfString:@"\n"];
    XCTAssert((emptyLineRange.location == NSNotFound || emptyLineRange.location != 0), @"TTR should strip empty lines at the end of the file");
}

- (void)testTtrSeparatesHtmlIntoLines
{
    htmlString = @"<script type=\"text/cjs\" data-cjssrc=\"http://js.washingtonpost.com/wpost/js/combo?token=20140114143100&c=true&m=true&context=eidos&r=/search-autocomplete/global-header-autocomplete.js\">\n</script><remark>Hello</remark>\n<script type=\"text/cjs\">fefeef</script>";
    ttrExtractor.htmlString = htmlString;
    [ttrExtractor separateLines];
    NSArray* htmlLines = [ttrExtractor htmlLinesArray];
    
    XCTAssert((htmlLines.count == 3), @"HTML should have been separated into 3 lines");
    XCTAssertEqualObjects([htmlLines objectAtIndex:0], @"<script type=\"text/cjs\" data-cjssrc=\"http://js.washingtonpost.com/wpost/js/combo?token=20140114143100&c=true&m=true&context=eidos&r=/search-autocomplete/global-header-autocomplete.js\">", @"First HTML line does not match");
    XCTAssertEqualObjects([htmlLines objectAtIndex:1], @"</script><remark>Hello</remark>", @"Second HTML line does not match");
    XCTAssertEqualObjects([htmlLines objectAtIndex:2], @"<script type=\"text/cjs\">fefeef</script>", @"Third HTML line does not match");
}

- (void)testTtrSingleLine
{
    htmlString = @"<tag attr=\"hello\">12345</tag>678";
    ttrExtractor.htmlString = htmlString;
    [ttrExtractor separateLines];
    NSArray* ttrArray = [ttrExtractor tagToTextRatioArray];
    XCTAssert(ttrArray.count == 1, @"There should be only one line in the TTR array");
    NSNumber* ttr = (NSNumber*)[ttrArray objectAtIndex:0];
    XCTAssert([[ttrArray objectAtIndex:0] integerValue] == 4, @"The TTR should be 4, not %@", ttr);
}

- (void)testTtrSingleLineOnlyOneTag
{
    htmlString = @"<meta charset=\"utf-8\">";
    ttrExtractor.htmlString = htmlString;
    [ttrExtractor separateLines];
    NSArray* ttrArray = [ttrExtractor tagToTextRatioArray];
    XCTAssert(ttrArray.count == 1, @"There should be only one line in the TTR array");
    NSNumber* ttr = (NSNumber*)[ttrArray objectAtIndex:0];
    XCTAssert([[ttrArray objectAtIndex:0] integerValue] == 0, @"The TTR should be 0, not %@", ttr);
}

- (void)testTtrHandlesTwoLineTag
{
    htmlString = @"<multilinetag attr=\"value\"\notherattr=\"value2\">Hello</multilinetag>";
    ttrExtractor.htmlString = htmlString;
    [ttrExtractor separateLines];
    NSArray* ttrArray = [ttrExtractor tagToTextRatioArray];
    XCTAssert(ttrArray.count == 2, @"There should be only one line in the TTR array");
    NSNumber* ttr = (NSNumber*)[ttrArray objectAtIndex:0];
    XCTAssert([[ttrArray objectAtIndex:0] integerValue] == 0, @"The TTR should be 0, not %@", ttr);
}

- (void)testTtrHandlesThreeLineTag
{
    htmlString = @"<tag1 attr=3\nattr2=\"test\"\nattr=\"somevalue\"/>Pure Content</tag3>";
    NSString* extractedText = [TestableTTRArticleExtractor articleText:htmlString];
    XCTAssertEqualObjects(extractedText, @"Pure Content\n", @"(%@)TTR should be able to handle three line tags by ignoring all intermediate lines", extractedText);
}

- (void)testTtrHandlesMultipleLineTag
{
    htmlString = @"<article\n    data-entry-id=\"amXxV44\"\n    data-entry-thumbnail-url=\"http://d24w6bsrhbeh9d.cloudfront.net/photo/amXxV44_92x92.jpg\"\n    data-entry-url=\"http://9gag.com/gag/amXxV44\"\n    data-entry-votes=\"9910\"\n    data-entry-comments=\"153\"\n    id=\"jsid-entry-entity-amXxV44\"\n    class=\"badge-entry-container badge-entry-entity\">\n    <header>Content";
    NSString* extractedText = [TestableTTRArticleExtractor articleText:htmlString];
    XCTAssertEqualObjects(extractedText, @"\nContent\n", @"(%@)TTR should be able to handle multi-line tags by ignoring all intermediate lines", extractedText);
}

- (void)testTtrHandlesMultilineNestedTag
{
    htmlString = @"<h2 class=\"badge-item-title\">\n    <a class=\"badge-evt badge-track\"\n    data-evt=\"ref-post-from-list,hot,position-1\"\n    data-track=\"post,v,,,d,azbRr6z,l\"\n    href=\"/gag/azbRr6z\"\n    target=\"_blank\">\n    Haunted Graveyard            </a>\n    </h2>";
    NSString* extractedText = [TestableTTRArticleExtractor articleText:htmlString];
    XCTAssertEqualObjects(extractedText, @"\nHaunted Graveyard\n\n", @"(%@)TTR should be able to handle multi-line nested tags by ignoring all intermediate lines", extractedText);
}

- (void)testTtrIgnoresTagsFromPreviousLines
{
    htmlString = @"<multilinetag attr=\"value\"\notherattr=\"value2\">Hello</multilinetag>";
    ttrExtractor.htmlString = htmlString;
    [ttrExtractor separateLines];
    NSArray* ttrArray = [ttrExtractor tagToTextRatioArray];
    XCTAssert(ttrArray.count == 2, @"There should be only one line in the TTR array");
    NSNumber* ttr = (NSNumber*)[ttrArray objectAtIndex:0];
    XCTAssert([[ttrArray objectAtIndex:1] floatValue] == 2.5, @"The TTR should be 0, not %@", ttr);
}

- (void)testTtrNoTags
{
    htmlString = @"12345678";
    ttrExtractor.htmlString = htmlString;
    [ttrExtractor separateLines];
    NSArray* ttrArray = [ttrExtractor tagToTextRatioArray];
    XCTAssert(ttrArray.count == 1, @"There should be only one line in the TTR array");
    NSNumber* ttr = (NSNumber*)[ttrArray objectAtIndex:0];
    XCTAssert([[ttrArray objectAtIndex:0] integerValue] == 8, @"The TTR should be 8, not %@", ttr);
}

- (void)testTtrOnlyTags
{
    htmlString = @"<tag><tag2 attr=\"fwfe\"/><tag3></tag3>";
    ttrExtractor.htmlString = htmlString;
    [ttrExtractor separateLines];
    NSArray* ttrArray = [ttrExtractor tagToTextRatioArray];
    XCTAssert(ttrArray.count == 1, @"There should be only one line in the TTR array");
    NSNumber* ttr = (NSNumber*)[ttrArray objectAtIndex:0];
    XCTAssert([[ttrArray objectAtIndex:0] integerValue] == 0, @"The TTR should be 0, not %@", ttr);
}

- (void)testTtrSeveralLines
{
    htmlString = @"<tag attr=\"hello\">12345</tag>678\n</tag>\negeheh\n<tag3/>";
    ttrExtractor.htmlString = htmlString;
    [ttrExtractor separateLines];
    NSArray* ttrArray = [ttrExtractor tagToTextRatioArray];
    XCTAssert(ttrArray.count == 4, @"There should be only four lines in the TTR array");
    NSNumber* ttr = (NSNumber*)[ttrArray objectAtIndex:0];
    XCTAssert([[ttrArray objectAtIndex:0] integerValue] == 4, @"The TTR should be 4, not %@", ttr);
    XCTAssert([[ttrArray objectAtIndex:1] integerValue] == 0, @"The TTR should be 0, not %@", ttr);
    XCTAssert([[ttrArray objectAtIndex:2] integerValue] == 6, @"The TTR should be 6, not %@", ttr);
    XCTAssert([[ttrArray objectAtIndex:3] integerValue] == 0, @"The TTR should be 0, not %@", ttr);
}

- (void)testTtrSmooths
{
    htmlString = @"";
    ttrExtractor.htmlString = htmlString;
    NSArray* ttrArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],
                         [NSNumber numberWithInt:2],
                         [NSNumber numberWithInt:3],
                         [NSNumber numberWithInt:4],
                         [NSNumber numberWithInt:5],
                         [NSNumber numberWithInt:6],
                         [NSNumber numberWithInt:7],
                         [NSNumber numberWithInt:8],
                         [NSNumber numberWithInt:9],
                         [NSNumber numberWithInt:10],
                         [NSNumber numberWithInt:11],
                         nil];
    NSArray* expectedSmoothTtr = [NSArray arrayWithObjects:[NSNumber numberWithFloat:(float)6 / (float)5],
                                  [NSNumber numberWithFloat:2],
                                  [NSNumber numberWithFloat:3],
                                  [NSNumber numberWithFloat:4],
                                  [NSNumber numberWithFloat:5],
                                  [NSNumber numberWithFloat:6],
                                  [NSNumber numberWithFloat:7],
                                  [NSNumber numberWithFloat:8],
                                  [NSNumber numberWithFloat:9],
                                  [NSNumber numberWithFloat:(float)38 / (float)5],
                                  [NSNumber numberWithFloat:6],
                                  nil];
    [ttrExtractor setTtrArray:ttrArray];
    [ttrExtractor smoothTtrArray];
    NSArray* smoothTtrArray = [ttrExtractor ttrArray];
    XCTAssertEqualObjects(smoothTtrArray, expectedSmoothTtr, @"Smooth TTR array does not match the expected");
}

- (void)testTtrCalculatesTheCorrectStandartDeviation
{
    htmlString = @"";
    ttrExtractor.htmlString = htmlString;
    NSArray* ttrArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],
                         [NSNumber numberWithInt:2],
                         [NSNumber numberWithInt:3],
                         [NSNumber numberWithInt:4],
                         nil];
    NSNumber* expectedDeviation = [NSNumber numberWithFloat:sqrtf(15.0 / 2.0f)];
    [ttrExtractor setTtrArray:ttrArray];
    //[ttrExtractor smoothTtrArray];
    NSNumber* standardDeviation = [ttrExtractor standardDeviation];
    XCTAssertEqualObjects(standardDeviation, expectedDeviation, @"TTR should be able to calculate the correct standard deviation");
}

//- (void)testTtrAppliesThresholdClusteringProperly
//{
//    htmlString = @"Line 1\nLine 2\nLine 3\nLine 4\nLine 5\nLine 6\nLine 7\nLine 8\nLine 9\nLine 10";
//    ttrExtractor.htmlString = htmlString;
//    NSArray* ttrArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],
//                         [NSNumber numberWithInt:11],
//                         [NSNumber numberWithInt:15],
//                         [NSNumber numberWithInt:12],
//                         [NSNumber numberWithInt:13],
//                         [NSNumber numberWithInt:23],
//                         [NSNumber numberWithInt:1],
//                         [NSNumber numberWithInt:50],
//                         [NSNumber numberWithInt:1],
//                         [NSNumber numberWithInt:7],
//                         nil];
//    [ttrExtractor setTtrArray:ttrArray];
//    [ttrExtractor separateLines];
//    NSNumber* standardDeviation = [ttrExtractor standardDeviation];
//    NSArray* contentTtrValues = [ttrExtractor tagToTextRatioArray];
//    for (NSNumber* ttrValue in contentTtrValues)
//    {
//        XCTAssert([ttrValue compare:standardDeviation] == NSOrderedDescending, @"All content TTR values should be >= than the standard deviation");
//    }
//}

- (void)testTtrUnescapesEncodedHtmlCharacters
{
    htmlString = @"&amp;&#39;&euro;&#37;&#55;&lt;&nbsp;&#167;&#233;";
    NSString* extractedText = [TestableTTRArticleExtractor articleText:htmlString];
    NSString* expectedString = @"&'€%7< §é\n";
    XCTAssertTrue([extractedText localizedCompare:expectedString] == NSOrderedSame, @"TTR should unescape HTML encoded characters once extraction is complete");
}

- (void)testTtrRemovesAllTagsAfterExtractingText
{
    htmlString = @"<tag /> Text text text <b> bold text </b> <a href=\"www\"> here </a> More text";
    NSString* extractedText = [TestableTTRArticleExtractor articleText:htmlString];

    XCTAssertEqual([extractedText rangeOfString:@"<tag />"].location, NSNotFound, @"TTR should have removed the <tag /> from the string");
    XCTAssertEqual([extractedText rangeOfString:@"<b>"].location, NSNotFound, @"TTR should have removed the <b> from the string");
    XCTAssertEqual([extractedText rangeOfString:@"</b>"].location, NSNotFound, @"TTR should have removed the </b> from the string");
    XCTAssertEqual([extractedText rangeOfString:@"<a href=\"www\">"].location, NSNotFound, @"TTR should have removed the <a href=\"www\"> from the string");
    XCTAssertEqual([extractedText rangeOfString:@"</a>"].location, NSNotFound, @"TTR should have removed the </a> from the string");
}

@end
