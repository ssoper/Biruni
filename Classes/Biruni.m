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
@synthesize currentPath, results, currentData, currentText, formatter, process, targetDepth;


#pragma mark -
#pragma mark Private

- (id) initWithArray:(NSArray *) _tagsToParse
            andBlock:(void(^)(NSArray *)) block {
  if (self = [super init]) {
    self.tagsToParse = _tagsToParse;
    self.afterParse = block;
    self.results = [[NSMutableArray alloc] init];
    self.formatter = [[BiruniFormatter alloc] init];
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
  NSArray *_tags = [NSArray arrayWithArray: tmpTags];
  [tmpTags release];

  return _tags;
}


#pragma mark -
#pragma mark Public class methods

+ (void) parseData:(NSData *) data
              tags:(NSString *) tags
             block:(void(^)(NSArray *)) block {
  [[[Biruni alloc] initWithData: data
                       andArray: [self parseTags: tags]
                       andBlock: block]
   autorelease];
}

+ (void) parseURL:(NSString *) url
             tags:(NSString *) tags
            block:(void(^)(NSArray *)) block {
  [[[Biruni alloc] initWithUrl: [NSURL URLWithString: url]
                      andArray: [self parseTags: tags]
                      andBlock: block]
   autorelease];
}


#pragma mark -
#pragma mark NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
  self.currentPath = [[NSMutableArray alloc] init];
  self.currentData = [[NSMutableDictionary alloc] init];
  self.process = NO;
  self.targetDepth = 0;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {

  [self.currentPath addObject: qualifiedName];

  // We've found a matching tag so this must be our target depth
  if (self.targetDepth == 0 && [self tagMatch: qualifiedName])
    self.targetDepth = self.currentPath.count;

  // Wrong depth
  if (self.targetDepth != self.currentPath.count)
    return;

  // Tag doesn't match
  if (![self tagMatch: qualifiedName])
    return;

  self.currentText = [[NSMutableString alloc] init];
  self.process = YES;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  if (self.process) {
    [self.currentText appendString: string];
  }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  if (!self.process && (self.currentPath.count == (self.targetDepth - 1))) {
    [self.results addObject: [NSMutableDictionary dictionaryWithDictionary: currentData]];
    [currentData release];
    currentData = [[NSMutableDictionary alloc] init];
  }

  if (self.process) {
    id finalObj = nil;
    NSString *key = (NSString *)[self.currentPath lastObject];
    NSUInteger dateFormat = [self.formatter dateTag: qName];

    if (dateFormat != BiruniDateFormatNil)
      finalObj = [self.formatter parseDate: currentText dateFormat: dateFormat];

    if (!finalObj)
      finalObj = [NSString stringWithString: currentText];

    if ([self.currentData objectForKey: key] != nil) {
      // Multiple values exist for this tag
      NSMutableArray *tmpValues;

      if ([[self.currentData objectForKey: key] isKindOfClass: [NSArray class]]) {
        // We already have this object as an NSArray and simply need to append this value
        tmpValues = [[NSMutableArray alloc] initWithArray: [self.currentData objectForKey: key]];
      } else {
        // Just a single NSString exists for this tag
        tmpValues = [[NSMutableArray alloc] initWithObjects: [self.currentData objectForKey: key], nil];
      }

      [tmpValues addObject: finalObj];
      [self.currentData setObject: [NSArray arrayWithArray: tmpValues] forKey: key];
      [tmpValues release];
    } else {
      [self.currentData setObject: finalObj forKey: (NSString *)[self.currentPath lastObject]];
    }

    [currentText release];
  }

  [self.currentPath removeLastObject];
  self.process = NO;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
  [currentData release];
  [currentPath release];

  NSArray *final = [NSArray arrayWithArray: self.results];
  [results release];
  [parser release];

  self.afterParse(final);
}

- (void) dealloc {
  [tagsToParse release];
  [afterParse release];
  [formatter release];

  [super dealloc];
}

@end
