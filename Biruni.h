//
//  Biruni.h
//  Biruni
//
//  Created by Sean Soper on 12/15/10.
//

#import <Foundation/Foundation.h>


@interface Biruni : NSObject <NSXMLParserDelegate> {
  NSArray *tagsToParse;
  void (^afterParse)(NSArray *);
}

@property (nonatomic, retain) NSArray *tagsToParse;
@property (copy) void (^afterParse)(NSArray *);

+ (void) parseData:(NSData *) data
              tags:(NSString *) tags
             block:(void(^)(NSArray *)) block;

+ (void) parseURL:(NSString *) url
             tags:(NSString *) tags
            block:(void(^)(NSArray *)) block;
@end
