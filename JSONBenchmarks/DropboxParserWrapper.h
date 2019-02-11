//
//  DropboxParserWrapper.h
//  JSONBenchmarks
//
//  Created by Iaroslav Spirin on 1/28/19.
//  Copyright © 2019 Mountain Viewer. All rights reserved.
//

#ifndef DropboxParserWrapper_h
#define DropboxParserWrapper_h

#import <Foundation/Foundation.h>

#include "Structs.h"

@interface DropboxParserWrapper: NSObject

@property (strong, nonatomic) NSString *jsonString;

- (id)initWith:(NSString *)jsonString;
- (struct Car*)parse;
    
@end

@interface JSMNParser : NSObject

@property (strong, nonatomic) NSString *jsonString;

- (id)initWith:(NSString *)jsonString;
- (struct Car*)parseJSON;

@end

#endif /* DropboxParserWrapper_h */
