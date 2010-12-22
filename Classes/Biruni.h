//
//  Biruni.h
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

#import <Foundation/Foundation.h>

@class BiruniFormatter;

@interface Biruni : NSObject <NSXMLParserDelegate> {
  NSArray *tagsToParse;
  void (^afterParse)(NSArray *);

@private
  NSMutableArray *currentPath, *results;
  NSMutableDictionary *currentData;
  NSMutableString *currentText;
  BiruniFormatter *formatter;
  BOOL process;
  NSUInteger targetDepth;
}

@property (nonatomic, retain) NSArray *tagsToParse;
@property (copy) void (^afterParse)(NSArray *);

@property (nonatomic, retain) NSMutableArray *currentPath, *results;
@property (nonatomic, retain) NSMutableDictionary *currentData;
@property (nonatomic, retain) NSMutableString *currentText;
@property (nonatomic, retain) BiruniFormatter *formatter;
@property (nonatomic, assign) BOOL process;
@property (nonatomic, assign) NSUInteger targetDepth;

+ (void) parseData:(NSData *) data
              tags:(NSString *) tags
             block:(void(^)(NSArray *)) block;

+ (void) parseURL:(NSString *) url
             tags:(NSString *) tags
            block:(void(^)(NSArray *)) block;
@end