//
//  BiruniFormatter.m
//  Biruni
//
//  Copyright (c) 2010 Sean Soper
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "BiruniFormatter.h"


@implementation BiruniFormatter

@synthesize kDateTagsRFC822, kDateTagsRFC3399, dateFormatter;

- (id) init {
  if (self = [super init]) {
    self.kDateTagsRFC822 = [[NSArray alloc] initWithObjects: @"pubDate", nil];
    self.kDateTagsRFC3399 = [[NSArray alloc] initWithObjects: @"dc:date", @"published", @"updated", nil];

    NSLocale *en_US_POSIX = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:en_US_POSIX];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [en_US_POSIX release];
  }

  return self;
}

//  Derived from work done by Michael Waterfall (2010) for MWFeedParser.
- (id) parseRFC822:(NSString *) strDate {
  NSDate *date = nil;
	NSString *RFC822String = [[NSString stringWithString: strDate] uppercaseString];

	if ([RFC822String rangeOfString:@","].location != NSNotFound) {
		if (!date) { // Sun, 19 May 2002 15:21:36 GMT
			[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zzz"]; 
			date = [dateFormatter dateFromString:RFC822String];
		}
		if (!date) { // Sun, 19 May 2002 15:21 GMT
			[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm zzz"]; 
			date = [dateFormatter dateFromString:RFC822String];
		}
		if (!date) { // Sun, 19 May 2002 15:21:36
			[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss"]; 
			date = [dateFormatter dateFromString:RFC822String];
		}
		if (!date) { // Sun, 19 May 2002 15:21
			[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm"]; 
			date = [dateFormatter dateFromString:RFC822String];
		}
	} else {
		if (!date) { // 19 May 2002 15:21:36 GMT
			[dateFormatter setDateFormat:@"d MMM yyyy HH:mm:ss zzz"]; 
			date = [dateFormatter dateFromString:RFC822String];
		}
		if (!date) { // 19 May 2002 15:21 GMT
			[dateFormatter setDateFormat:@"d MMM yyyy HH:mm zzz"]; 
			date = [dateFormatter dateFromString:RFC822String];
		}
		if (!date) { // 19 May 2002 15:21:36
			[dateFormatter setDateFormat:@"d MMM yyyy HH:mm:ss"]; 
			date = [dateFormatter dateFromString:RFC822String];
		}
		if (!date) { // 19 May 2002 15:21
			[dateFormatter setDateFormat:@"d MMM yyyy HH:mm"]; 
			date = [dateFormatter dateFromString:RFC822String];
		}
	}

	if (!date) NSLog(@"Could not parse RFC822 date: \"%@\" Possibly invalid format.", strDate);

	return date;
}

//  Derived from work done by Michael Waterfall (2010) for MWFeedParser.
- (id) parseRFC3399:(NSString *) strDate {
	NSDate *date = nil;
	NSString *RFC3339String = [[NSString stringWithString: strDate] uppercaseString];
	RFC3339String = [RFC3339String stringByReplacingOccurrencesOfString:@"Z" withString:@"-0000"];

	// Remove colon in timezone as iOS 4+ NSDateFormatter breaks. See https://devforums.apple.com/thread/45837
	if (RFC3339String.length > 20) {
		RFC3339String = [RFC3339String stringByReplacingOccurrencesOfString:@":" 
                                                             withString:@"" 
                                                                options:0
                                                                  range:NSMakeRange(20, RFC3339String.length-20)];
	}
	if (!date) { // 1996-12-19T16:39:57-0800
		[dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"]; 
		date = [dateFormatter dateFromString:RFC3339String];
	}
	if (!date) { // 1937-01-01T12:00:27.87+0020
		[dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZ"]; 
		date = [dateFormatter dateFromString:RFC3339String];
	}
	if (!date) { // 1937-01-01T12:00:27
		[dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"]; 
		date = [dateFormatter dateFromString:RFC3339String];
	}

	if (!date) NSLog(@"Could not parse RFC3339 date: \"%@\" Possibly invalid format.", strDate);

	return date;
}

- (NSUInteger) dateTag:(NSString *) tag {  
  NSMutableSet *matches;
  BOOL result;
  
  matches = [[NSMutableSet alloc] initWithArray: self.kDateTagsRFC822];
  [matches filterUsingPredicate:[NSPredicate predicateWithFormat:@"SELF MATCHES %@", tag]];
  result = (matches.count > 0);
  [matches release];
  
  if (result)
    return BiruniDateFormatRFC822;
  
  matches = [[NSMutableSet alloc] initWithArray: self.kDateTagsRFC3399];
  [matches filterUsingPredicate:[NSPredicate predicateWithFormat:@"SELF MATCHES %@", tag]];
  result = (matches.count > 0);
  [matches release];
  
  if (result)
    return BiruniDateFormatRFC3399;

  return BiruniDateFormatNil;
}

- (id) parseDate:(NSString *) strDate
            dateFormat:(NSUInteger) dateFormat {

  if (dateFormat == BiruniDateFormatRFC822) {
    return [self parseRFC822: strDate];
  } else {
    return [self parseRFC3399: strDate];
  }

  return nil;
}

- (void) dealloc {
  NSLog(@"and here?");
  [kDateTagsRFC822 release];
  [kDateTagsRFC3399 release];
  [dateFormatter release];

  [super dealloc];
}
@end
