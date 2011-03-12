//
//  Biruni.h
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

#import <Foundation/Foundation.h>

@class BiruniFormatter;

typedef void (^ResultsBlock)(NSArray *);
typedef void (^ResultBlock)(NSDictionary *);
typedef void (^ErrorBlock)(NSError *);

@interface Biruni : NSObject <NSXMLParserDelegate> {
  NSArray *tagsToParse;
  NSString *container;
  ResultsBlock afterParse;
  ResultBlock onResult;
  ErrorBlock onError;
  
@private
  NSMutableArray *currentPath, *results;
  NSMutableDictionary *currentDict;
  NSMutableData *currentData, *responseData;
  BiruniFormatter *formatter;
  BOOL process;
  NSUInteger targetDepth;
  NSXMLParser *parser;
  NSDictionary *currentAttributes;
  NSURLConnection *urlConnection;
  NSUInteger responseHttpCode;
}

@property (nonatomic, retain) NSArray *tagsToParse;
@property (nonatomic, copy) NSString *container;
@property (nonatomic, copy) ResultsBlock afterParse;

@property (nonatomic, assign) BOOL process;
@property (nonatomic, assign) NSUInteger targetDepth;
@property (nonatomic, retain) NSXMLParser *parser;

+ (id) parseData:(NSData *) data
            tags:(NSString *) tags
           block:(ResultsBlock) block;

+ (id) parseURL:(NSString *) url
           tags:(NSString *) tags
          block:(ResultsBlock) block;

+ (id) parseData:(NSData *) data
            tags:(NSString *) tags
       container:(NSString *) _container
           block:(ResultsBlock) block;

+ (id) parseURL:(NSString *) url
           tags:(NSString *) tags
       container:(NSString *) _container
          block:(ResultsBlock) block;
@end
