//
//  Biruni.m
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

#import "Biruni.h"
#import "BiruniFormatter.h"


@implementation Biruni

@synthesize tagsToParse, afterParse;
@synthesize process, targetDepth;


#pragma mark -
#pragma mark Private

- (id) initWithArray:(NSArray *) _tagsToParse
            andBlock:(void(^)(NSArray *)) block {
  if (self = [super init]) {
    self.tagsToParse = _tagsToParse;
    [_tagsToParse release];

    self.afterParse = block;
  }

  return self;
}

- (id) initWithData:(NSData *) _data
           andArray:(NSArray *) _tagsToParse
           andBlock:(void(^)(NSArray *)) block {
  if (self = [self initWithArray: _tagsToParse andBlock: block]) {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData: _data];
    parser.delegate = self;
    [parser setShouldProcessNamespaces: YES];
    [parser parse];
  }

  return self;
}

- (id) initWithUrl:(NSURL *) _url
          andArray:(NSArray *) _tagsToParse
          andBlock:(void(^)(NSArray *)) block {
  if (self = [self initWithArray: _tagsToParse andBlock: block]) {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL: _url];
    parser.delegate = self;
    [parser setShouldProcessNamespaces: YES];
    [parser parse];
  }

  return self;
}

- (BOOL) tagMatch:(NSString *) tag {
  NSMutableSet *matches = [[NSMutableSet alloc] initWithArray: self.tagsToParse];
  [matches filterUsingPredicate:[NSPredicate predicateWithFormat:@"SELF MATCHES %@", tag]];

  BOOL result = (matches.count > 0);
  [matches release];

  return result;
}

+ (NSArray *) parseTags:(NSString *) tags {
  NSMutableArray *tmpTags = [[NSMutableArray alloc] init];
  for (NSString *tag in [tags componentsSeparatedByString: @","]) {
    NSString *trimmedTag = [tag stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [tmpTags addObject: trimmedTag];
  }

  NSArray *finalTags = [[NSArray alloc] initWithArray: tmpTags];
  [tmpTags release];

  return finalTags;
}


#pragma mark -
#pragma mark Public class methods

+ (id) parseData:(NSData *) data
            tags:(NSString *) tags
           block:(void(^)(NSArray *)) block {
  return [[Biruni alloc] initWithData: data
                             andArray: [self parseTags: tags]
                             andBlock: block];

}

+ (id) parseURL:(NSString *) url
           tags:(NSString *) tags
          block:(void(^)(NSArray *)) block {
  return [[Biruni alloc] initWithUrl: [NSURL URLWithString: url]
                            andArray: [self parseTags: tags]
                            andBlock: block];
}


#pragma mark -
#pragma mark NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
  NSMutableArray *_currentPath = [[NSMutableArray alloc] init];
  currentPath = [_currentPath retain];
  [_currentPath release];

  NSMutableDictionary *_currentData = [[NSMutableDictionary alloc] init];
  currentData = [_currentData retain];
  [_currentData release];

  NSMutableArray *_results = [[NSMutableArray alloc] init];
  results = [_results retain];
  [_results release];  

  BiruniFormatter *_formatter = [[BiruniFormatter alloc] init];
  formatter = [_formatter retain];
  [_formatter release];

  self.process = NO;
  self.targetDepth = 0;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {

  [currentPath addObject: qualifiedName];

  // We've found a matching tag so this must be our target depth
  if (self.targetDepth == 0 && [self tagMatch: qualifiedName])
    self.targetDepth = currentPath.count;

  // Wrong depth
  if (self.targetDepth != currentPath.count)
    return;

  // Tag doesn't match
  if (![self tagMatch: qualifiedName])
    return;

  NSMutableString *_currentText = [[NSMutableString alloc] init];
  currentText = [_currentText retain];
  [_currentText release];

  self.process = YES;
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {

  if (!self.process)
    return;

  NSString *buffer = nil;

  @try {
    buffer = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    if (!buffer)
      buffer = [[NSString alloc] initWithData:CDATABlock encoding:NSISOLatin1StringEncoding];
    if (buffer)
      [currentText appendString:buffer];
  } @catch (NSException * e) {
    // Do nothing
  } @finally {
    if (buffer)
      [buffer release];
  }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  if (self.process) {
    [currentText appendString: string];
  }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  NSMutableDictionary *_currentData;

  if (!self.process && (currentPath.count == (self.targetDepth - 1))) {
    [results addObject: [NSMutableDictionary dictionaryWithDictionary: currentData]];
    [currentData release];
    _currentData = [[NSMutableDictionary alloc] init];
    currentData = [_currentData retain];
    [_currentData release];
  }

  if (self.process) {
    id finalObj = nil;
    NSString *key = (NSString *)[currentPath lastObject];
    NSUInteger dateFormat = [formatter dateTag: qName];

    if (dateFormat != BiruniDateFormatNil)
      finalObj = [formatter parseDate: currentText dateFormat: dateFormat];

    if (!finalObj)
      finalObj = [NSString stringWithString: currentText];

    if ([currentData objectForKey: key] != nil) {
      // Multiple values exist for this tag
      NSMutableArray *tmpValues;

      if ([[currentData objectForKey: key] isKindOfClass: [NSArray class]]) {
        // We already have this object as an NSArray and simply need to append this value
        tmpValues = [[NSMutableArray alloc] initWithArray: [currentData objectForKey: key]];
      } else {
        // Just a single NSString exists for this tag
        tmpValues = [[NSMutableArray alloc] initWithObjects: [currentData objectForKey: key], nil];
      }

      [tmpValues addObject: finalObj];
      [currentData setObject: [NSArray arrayWithArray: tmpValues] forKey: key];
      [tmpValues release];
    } else {
      [currentData setObject: finalObj forKey: (NSString *)[currentPath lastObject]];
    }

    [currentText release];
  }

  [currentPath removeLastObject];
  self.process = NO;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
  [currentData release];
  [currentPath release];

  NSArray *final = [NSArray arrayWithArray: results];
  [results release];
  [parser release];

  self.afterParse(final);
}

- (void) dealloc {
  [formatter release];
  [tagsToParse release];
  [afterParse release];

  [super dealloc];
}

@end
