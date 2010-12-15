//
//  Biruni.m
//  Biruni
//
//  Created by Sean Soper on 12/15/10.
//

#import "Biruni.h"


@interface Biruni ()
@property (nonatomic, retain) NSXMLParser *parser;
@property (nonatomic, retain) NSMutableArray *currentPath, *results, *parsed;
@property (nonatomic, retain) NSMutableDictionary *currentData;
@property (nonatomic, retain) NSMutableString *currentText;
@property (nonatomic, assign) BOOL process;
- (void) initWithUrl:(NSURL *) _url
            andArray:(NSArray *) _tagsToParse
            andBlock:(void(^)(NSArray *)) block;
@end


@implementation Biruni

@synthesize url, tagsToParse, afterParse;
@synthesize parser, currentPath, results, currentData, currentText, process, parsed;

- (void) initWithUrl:(NSURL *) _url
            andArray:(NSArray *) _tagsToParse
            andBlock:(void(^)(NSArray *)) block {
  if (self = [super init]) {
    self.url = _url;
    self.tagsToParse = _tagsToParse;
    self.afterParse = block;

    self.results = [[NSMutableArray alloc] init];
    self.parser = [[NSXMLParser alloc] initWithContentsOfURL: self.url];
    self.parser.delegate = self;
    [self.parser setShouldProcessNamespaces: YES];
    [self.parser parse];
  }
}

+ (void) parseWithFeedURL:(NSString *) url
                  andTags:(NSArray *) tags
                 andBlock:(void(^)(NSArray *)) block {
  NSURL *_url = [NSURL URLWithString: url];
  [[Biruni alloc] initWithUrl: _url andArray: tags andBlock: block];
}


#pragma mark -
#pragma mark NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
  self.currentPath = [[NSMutableArray alloc] init];
  self.currentData = [[NSMutableDictionary alloc] init];
  self.parsed = [[NSMutableArray alloc] init];
  self.process = NO;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
  [self.currentPath addObject: qualifiedName];

  NSMutableSet *matches = [[NSMutableSet alloc] initWithArray: self.tagsToParse];
  [matches filterUsingPredicate:[NSPredicate predicateWithFormat:@"SELF MATCHES %@", qualifiedName]];

  // Not a tag selected for parsing
  if (matches.count == 0) {
    [matches release];
    return;
  }

  [matches release];
  matches = [[NSMutableSet alloc] initWithArray: self.parsed];
  [matches filterUsingPredicate: [NSPredicate predicateWithFormat:@"SELF MATCHES %@", qualifiedName]];

  // Matches an already parsed tag which means we've moved onto the next set of results
  if (matches.count > 0) {
    [self.results addObject: [NSDictionary dictionaryWithDictionary: currentData]];
    [currentData release];
    currentData = [[NSMutableDictionary alloc] init];
    [parsed release];
    self.parsed = [[NSMutableArray alloc] init];
  }

  [matches release];
  [self.parsed addObject: qualifiedName];
  self.currentText = [[NSMutableString alloc] init];
  self.process = YES;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  if (self.process) {
    [self.currentText appendString: string];
  }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  if (self.process) {
    NSString *finalText = [NSString stringWithString: currentText];
    [self.currentData setObject: finalText forKey: (NSString *)[self.currentPath lastObject]];
    [currentText release];
  }

  [self.currentPath removeLastObject];
  self.process = NO;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
  NSArray *final = [NSArray arrayWithArray: results];
  [results release];

  self.afterParse(final);
}

@end
