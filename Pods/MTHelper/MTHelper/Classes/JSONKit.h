//
//  JSONKit.h
//  NetRecord_BJ
//
//  Created by adt on 13-12-11.
//  Copyright (c) 2013年 MasterCom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JSONString)

- (NSString *)JSONString;

@end

@interface NSString (JSONObject)

- (id)objectFromJSONString;
- (NSString *)urlEncode;
- (NSString *)urlDecode;

@end

@interface NSData (JSONObject)

- (id)objectFromJSONData;

@end
