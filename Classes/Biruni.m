//
//  Biruni.m
//  Biruni
//
//  Copyright (c) 2011 Sean Soper
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

static const NSUInteger kBiruniTimeout         = 30;
static const NSUInteger kBiruniHttpNotFound    = 404;
static const NSUInteger kBiruniHttpBadResponse = 500;

static NSString* kBiruniUserAgent   = @"Biruni RSS parser";
//static NSString* kBiruniErrorDomain = @"BiruniError";

@implementation Biruni

@synthesize tagsToParse, container, onComplete;
@synthesize process, targetDepth, parser;

@synthesize usesUrl, onResult, onError;

#pragma mark -
#pragma mark Private

- (id) initWithArray:(NSArray *) _tagsToParse
        andContainer:(NSString *) _container
            andBlock:(void(^)(NSArray *)) block {
  if (self = [super init]) {
    self.tagsToParse = _tagsToParse;
    [_tagsToParse release];

    self.container = _container;
    self.onComplete = block;
  }

  return self;
}

- (void) initParser:(NSData *) data {
  NSXMLParser *_parser = [[NSXMLParser alloc] initWithData: data];
  self.parser = _parser;
  [_parser release];

  NSLog(@"[Biruni] Parsing %u bytes", [data length]);

  self.parser.delegate = self;
  [self.parser setShouldProcessNamespaces: YES];
  [self.parser parse];
}

- (id) initWithData:(NSData *) _data
           andArray:(NSArray *) _tagsToParse
       andContainer:(NSString *) _container
           andBlock:(void(^)(NSArray *)) block {
  if (self = [self initWithArray: _tagsToParse andContainer: _container andBlock: block]) {
    [self initParser: _data];
  }

  return self;
}

- (id) initWithUrl:(NSURL *) _url
          andArray:(NSArray *) _tagsToParse
      andContainer:(NSString *) _container
          andBlock:(void(^)(NSArray *)) block {
  if (self = [self initWithArray: _tagsToParse andContainer: _container andBlock: block]) {
    NSLog(@"[Biruni] Parsing %@", _url);

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:_url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:kBiruniTimeout];
    [request setValue:kBiruniUserAgent forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:@"GET"];

    urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
  }

  return self;
}

- (BOOL) currentPathMatch {
  // Get tags with paths
  NSIndexSet *tagsWithPaths = [self.tagsToParse indexesOfObjectsPassingTest: ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    return ([(NSString *)obj rangeOfString: @"/"].length > 0);
  }];

  if (tagsWithPaths.count == 0)
    return NO;

  __block BOOL match = NO;
  NSString *tokenizedPath = [currentPath componentsJoinedByString: @"/"];

  // Of the tags with paths, find the one that matches the suffix of the current path
  [tagsWithPaths enumerateIndexesUsingBlock: ^(NSUInteger idx, BOOL *stop) {
    NSString *suffix = (NSString *)[self.tagsToParse objectAtIndex: idx];
    *stop = match = [tokenizedPath hasSuffix: suffix];
  }];

  return match;
}

- (BOOL) currentTagMatch {
  NSMutableSet *matches = [[NSMutableSet alloc] initWithArray: self.tagsToParse];
  [matches filterUsingPredicate:[NSPredicate predicateWithFormat:@"SELF MATCHES %@", [currentPath lastObject]]];

  BOOL result = (matches.count > 0);
  [matches release];

  return result;
}

- (BOOL) inContainer {
  NSMutableSet *matches = [[NSMutableSet alloc] initWithArray: currentPath];
  [matches filterUsingPredicate:[NSPredicate predicateWithFormat:@"SELF MATCHES %@", self.container]];
  
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
#pragma mark Public methods

+ (id) parserWithData:(NSData *) data
                 tags:(NSString *) firstTag, ... {
  return [[Biruni alloc] initWithData: data tags: firstTag, __VA_ARGS__];
}

- (id) initWithData:(NSData *) data
               tags:(NSString *) firstTag, ... {

  // Extract tags
  NSMutableArray *tmpTags = [[NSMutableArray alloc] init];
  va_list args;
  va_start(args, firstTag);
  for (NSString *arg = firstTag; arg != nil; arg = va_arg(args, NSString*)) {
    [tmpTags addObject: arg];
  }
  va_end(args);

  if (self = [super init]) {
    self.tagsToParse = [[NSArray alloc] initWithArray: tmpTags];
    self.usesUrl = NO;

    NSXMLParser *_parser = [[NSXMLParser alloc] initWithData: data];
    self.parser = _parser;
    [_parser release];

    NSLog(@"[Biruni] Parsing %u bytes", [data length]);
  }

  [tmpTags release];

  return self;
}

- (void) start {
  if (self.usesUrl) {
    // Parse that url yo
  } else {
    self.parser.delegate = self;
    [self.parser setShouldProcessNamespaces: YES];
    [self.parser parse];
  }
}

#pragma mark -
#pragma mark Public class methods

+ (id) parseData:(NSData *) data
            tags:(NSString *) tags
       container:(NSString *) _container
           block:(void(^)(NSArray *)) block {
  return [[[Biruni alloc] initWithData: data
                             andArray: [self parseTags: tags]
                         andContainer: _container
                              andBlock: block] autorelease];

}

+ (id) parseURL:(NSString *) url
           tags:(NSString *) tags
      container:(NSString *) _container
          block:(void(^)(NSArray *)) block {
  return [[[Biruni alloc] initWithUrl: [NSURL URLWithString: url]
                            andArray: [self parseTags: tags]
                        andContainer: _container
                             andBlock: block] autorelease];
}

+ (id) parseData:(NSData *) data
            tags:(NSString *) tags
           block:(void(^)(NSArray *)) block {
  return [Biruni parseData: data tags: tags container: nil block:block];
}

+ (id) parseURL:(NSString *) url
           tags:(NSString *) tags
          block:(void(^)(NSArray *)) block {
  return [Biruni parseURL: url tags:tags container: nil block: block];
}


#pragma mark -
#pragma mark NSURLConnectionDelegate

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
  return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
  [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
  responseData = [[NSMutableData alloc] init];

  NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
  responseHttpCode = httpResponse.statusCode;
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
  [responseData appendData:data];
}

- (NSCachedURLResponse*)connection:(NSURLConnection*)connection
                 willCacheResponse:(NSCachedURLResponse*)cachedResponse {
  return nil;
}

-(void) connectionDidFinishLoading:(NSURLConnection*)connection {
  NSData *data;

  if ((responseHttpCode == kBiruniHttpNotFound) ||
      (responseHttpCode == kBiruniHttpBadResponse)) {
    // TODO: Add an add'l block argument for errors
    NSLog(@"There was an error retrieving the data");
  } else {
    data = [NSData dataWithData: responseData];
    [self initParser: data];
  }

  [responseData release];
  [urlConnection release];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
  // TODO: Add an add'l block argument for errors
  [responseData release];
  [urlConnection release];
}


#pragma mark -
#pragma mark NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
  NSMutableArray *_currentPath = [[NSMutableArray alloc] init];
  currentPath = [_currentPath retain];
  [_currentPath release];

  NSMutableDictionary *_currentDict = [[NSMutableDictionary alloc] init];
  currentDict = [_currentDict retain];
  [_currentDict release];

  NSMutableArray *_results = [[NSMutableArray alloc] init];
  results = [_results retain];
  [_results release];  

  currentAttributes = nil;

  BiruniFormatter *_formatter = [[BiruniFormatter alloc] init];
  formatter = [_formatter retain];
  [_formatter release];

  self.process = NO;
  self.targetDepth = 0;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {

  [currentPath addObject: qualifiedName];

  // Items to parse must be under a specific container
  if (self.container) {

    // We've not yet found our target depth
    if (self.targetDepth == 0) {

      // Still not deep enough to find our container
      if (![self inContainer])
        return;

      // We've found a matching tag in the appropriate container
      if ([self currentTagMatch])
        self.targetDepth = currentPath.count;
    }
  }

  // We've found a matching tag so this must be our target depth
  if (self.targetDepth == 0 && [self currentTagMatch])
    self.targetDepth = currentPath.count;

  // Tag matches but wrong depth
  if ([self currentTagMatch] && self.targetDepth < currentPath.count)
    return;

  // Tag doesn't match
  if (![self currentTagMatch] && ![self currentPathMatch])
    return;

  NSMutableData *_currentData = [[NSMutableData alloc] init];
  currentData = [_currentData retain];
  [_currentData release];

  currentAttributes = [attributeDict retain];

  self.process = YES;
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {

  if (!self.process)
    return;

  [currentData appendData: CDATABlock];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  if (self.process) {
    [currentData appendData: [string dataUsingEncoding: NSUTF8StringEncoding]];
  }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  NSMutableDictionary *_currentDict;

  if (!self.process && (currentPath.count == (self.targetDepth - 1))) {
    [results addObject: [NSMutableDictionary dictionaryWithDictionary: currentDict]];
    [currentDict release];
    _currentDict = [[NSMutableDictionary alloc] init];
    currentDict = [_currentDict retain];
    [_currentDict release];
  }

  if (self.process) {
    id finalObj = nil;
    NSString *key = (NSString *)[currentPath lastObject];
    NSUInteger dateFormat = [formatter dateTag: qName];
    NSString *tmpStr = [[NSString alloc] initWithData: currentData encoding: NSUTF8StringEncoding];

    if (dateFormat != BiruniDateFormatNil)
      finalObj = [formatter parseDate: tmpStr dateFormat: dateFormat];

    if (!finalObj) {
      if (tmpStr.length == 0 && [currentAttributes count] > 0) {
        // An empty element with tag attributes
        finalObj = [currentAttributes copy];
      } else {
        // A normal element with data
        finalObj = [NSString stringWithString: tmpStr];
      }
    }

    if ([currentDict objectForKey: key] != nil) {
      // Multiple values exist for this tag
      NSMutableArray *tmpValues;

      if ([[currentDict objectForKey: key] isKindOfClass: [NSArray class]]) {
        // We already have this object as an NSArray and simply need to append this value
        tmpValues = [[NSMutableArray alloc] initWithArray: [currentDict objectForKey: key]];
      } else {
        // Just a single NSString exists for this tag
        tmpValues = [[NSMutableArray alloc] initWithObjects: [currentDict objectForKey: key], nil];
      }

      [tmpValues addObject: finalObj];
      [currentDict setObject: [NSArray arrayWithArray: tmpValues] forKey: key];
      [tmpValues release];
    } else {
      [currentDict setObject: finalObj forKey: (NSString *)[currentPath lastObject]];
    }

    [tmpStr release];
    [currentAttributes release];
    [currentData release];
  }

  [currentPath removeLastObject];
  self.process = NO;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
  [formatter release];
  [currentDict release];
  [currentPath release];

  NSArray *final = [NSArray arrayWithArray: results];
  [results release];

  self.onComplete(final);
}

- (void) dealloc {
  [tagsToParse release];
  [container release];
  [onComplete release];
  [parser release];

  [super dealloc];
}

- (NSString *) description {
  return [NSString stringWithFormat: @"%@ tags=%@ container=%@", [super description], [self.tagsToParse description], [self.container description]];
}

@end
