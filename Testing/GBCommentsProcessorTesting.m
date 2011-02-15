//
//  GBCommentsProcessorTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 14.2.11.
//  Copyright (C) 2011 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBStore.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessor (PrivateAPI)
- (BOOL)findCommentBlockInLines:(NSArray *)lines blockRange:(NSRange *)range shortRange:(NSRange *)shortRange;
@end

#pragma mark -

@interface GBCommentsProcessorTesting : GBObjectsAssertor

- (OCMockObject *)settingsProviderRepeatFirst:(BOOL)repeat;
- (void)assertFindCommentWithString:(NSString *)string matchesBlockRange:(NSRange)b shortRange:(NSRange)s;

@end

#pragma mark -

@implementation GBCommentsProcessorTesting

#pragma mark Descriptions testing

//- (void)testProcessCommentWithContextStore_description_shouldRegisterSingleComponent {
//	// setup
//	GBStore *store = [GBTestObjectsRegistry store];
//	GBCommentsProcessor *processor1 = [GBCommentsProcessor processorWithSettingsProvider:[self settingsProviderRepeatFirst:YES]];
//	GBCommentsProcessor *processor2 = [GBCommentsProcessor processorWithSettingsProvider:[self settingsProviderRepeatFirst:NO]];
//	GBComment *comment1 = [GBComment commentWithStringValue:@"Some text\n\nAnother paragraph"];
//	GBComment *comment2 = [GBComment commentWithStringValue:@"Some text\n\nAnother paragraph"];
//	// execute
//	[processor1 processComment:comment1 withContext:nil store:store];
//	[processor2 processComment:comment2 withContext:nil store:store];
//	// verify
//	[self assertComment:comment1 matchesShortDesc:@"Some text" longDesc:@"Some text\n\nAnother paragraph", nil];
//	[self assertComment:comment2 matchesShortDesc:@"Some text" longDesc:@"Another paragraph", nil];
//}

#pragma mark Private methods testing

- (void)testFindCommentBlockInLinesBlockRangeShortRange_shouldDetectSingleComponent {
	[self assertFindCommentWithString:@"line" matchesBlockRange:NSMakeRange(0, 1) shortRange:NSMakeRange(0, 1)];
	[self assertFindCommentWithString:@"line1\nline2" matchesBlockRange:NSMakeRange(0, 2) shortRange:NSMakeRange(0, 2)];
	[self assertFindCommentWithString:@"para1\n\npara" matchesBlockRange:NSMakeRange(0, 3) shortRange:NSMakeRange(0, 1)];
	[self assertFindCommentWithString:@"para1\n\npara2\n\npara3" matchesBlockRange:NSMakeRange(0, 5) shortRange:NSMakeRange(0, 1)];
}

- (void)testFindCommentBlockInLinesBlockRangeShortRange_shouldDetectSingleComponentUpToDirective {
	[self assertFindCommentWithString:@"line\n@warning desc" matchesBlockRange:NSMakeRange(0, 1) shortRange:NSMakeRange(0, 1)];
	[self assertFindCommentWithString:@"line\n\n@warning desc" matchesBlockRange:NSMakeRange(0, 2) shortRange:NSMakeRange(0, 1)];
	[self assertFindCommentWithString:@"para1\n\npara2\n@warning desc" matchesBlockRange:NSMakeRange(0, 3) shortRange:NSMakeRange(0, 1)];
	[self assertFindCommentWithString:@"para1\n\npara2\n\n@warning desc" matchesBlockRange:NSMakeRange(0, 4) shortRange:NSMakeRange(0, 1)];
}

- (void)testFindCommentBlockInLinesBlockRangeShortRange_shouldDetectDirectiveComponentUpToEndOfLines {
	[self assertFindCommentWithString:@"@warning desc" matchesBlockRange:NSMakeRange(0, 1) shortRange:NSMakeRange(0, 1)];
	[self assertFindCommentWithString:@"@warning line1\nline2" matchesBlockRange:NSMakeRange(0, 2) shortRange:NSMakeRange(0, 2)];
	[self assertFindCommentWithString:@"@warning para1\n\npara2" matchesBlockRange:NSMakeRange(0, 3) shortRange:NSMakeRange(0, 1)];
}

- (void)testFindCommentBlockInLinesBlockRangeShortRange_shouldDetectDirectiveComponentUpToNextDirective {
	[self assertFindCommentWithString:@"@warning desc\n@warning next" matchesBlockRange:NSMakeRange(0, 1) shortRange:NSMakeRange(0, 1)];
	[self assertFindCommentWithString:@"@warning desc\n\n@warning next" matchesBlockRange:NSMakeRange(0, 2) shortRange:NSMakeRange(0, 1)];
	[self assertFindCommentWithString:@"@warning line1\nline2\n@warning next" matchesBlockRange:NSMakeRange(0, 2) shortRange:NSMakeRange(0, 2)];
	[self assertFindCommentWithString:@"@warning line1\nline2\n\n@warning next" matchesBlockRange:NSMakeRange(0, 3) shortRange:NSMakeRange(0, 2)];
	[self assertFindCommentWithString:@"@warning para1\n\npara2\n@warning next" matchesBlockRange:NSMakeRange(0, 3) shortRange:NSMakeRange(0, 1)];
	[self assertFindCommentWithString:@"@warning para1\n\npara2\n\n@warning next" matchesBlockRange:NSMakeRange(0, 4) shortRange:NSMakeRange(0, 1)];
}

- (void)testFindCommentBlockInLinesBlockRangeShortRange_shouldStopAtAnyDirective {
	NSRange blockRange = NSMakeRange(0, 1);
	NSRange shortRange = NSMakeRange(0, 1);
	[self assertFindCommentWithString:@"line\n@warning desc" matchesBlockRange:blockRange shortRange:shortRange];
	[self assertFindCommentWithString:@"line\n@bug desc" matchesBlockRange:blockRange shortRange:shortRange];
	[self assertFindCommentWithString:@"line\n@param name desc" matchesBlockRange:blockRange shortRange:shortRange];
	[self assertFindCommentWithString:@"line\n@return desc" matchesBlockRange:blockRange shortRange:shortRange];
	[self assertFindCommentWithString:@"line\n@returns desc" matchesBlockRange:blockRange shortRange:shortRange];
	[self assertFindCommentWithString:@"line\n@exception name desc" matchesBlockRange:blockRange shortRange:shortRange];
	[self assertFindCommentWithString:@"line\n@see desc" matchesBlockRange:blockRange shortRange:shortRange];
	[self assertFindCommentWithString:@"line\n@sa desc" matchesBlockRange:blockRange shortRange:shortRange];
}

#pragma Creation & assertion methods

- (OCMockObject *)settingsProviderRepeatFirst:(BOOL)repeat {
	OCMockObject *result = [GBTestObjectsRegistry mockSettingsProvider];
	[[[result stub] andReturnValue:[NSNumber numberWithBool:repeat]] repeatFirstParagraphForMemberDescription];
	return result;
}

- (void)assertFindCommentWithString:(NSString *)string matchesBlockRange:(NSRange)b shortRange:(NSRange)s {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSRange blockRange = NSMakeRange(0, 0);
	NSRange shortRange = NSMakeRange(0, 0);
	[processor findCommentBlockInLines:[string arrayOfLines] blockRange:&blockRange shortRange:&shortRange];
	// verify
	assertThatInteger(blockRange.location, equalToInteger(b.location));
	assertThatInteger(blockRange.length, equalToInteger(b.length));
	assertThatInteger(shortRange.location, equalToInteger(s.location));
	assertThatInteger(shortRange.length, equalToInteger(s.length));
}

@end
