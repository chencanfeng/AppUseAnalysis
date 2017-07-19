//
//  JSONKit.m
//  NetRecord_BJ
//
//  Created by adt on 13-12-11.
//  Copyright (c) 2013年 MasterCom. All rights reserved.
//

#import "JSONKit.h"

@implementation NSObject (JSONString)

- (NSString *)JSONString {
	if ([NSJSONSerialization isValidJSONObject:self]) {
		return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self options:0 error:NULL]
		                             encoding:NSUTF8StringEncoding];
	}
	return nil;
}

- (NSData *)JSONData {
	if ([NSJSONSerialization isValidJSONObject:self]) {
		return [NSJSONSerialization dataWithJSONObject:self options:0 error:NULL];
	}
	return nil;
}

@end

@implementation NSString (JSONObject)

- (id)objectFromJSONString {
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (NSString *)urlEncode {
	return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
	                                                                             (__bridge CFStringRef)self, NULL,
	                                                                             (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
}

-(NSString *)urlDecode{
    return (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                 (__bridge CFStringRef)self,  CFSTR("") ,
                                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

@end
#pragma #pragma clang diagnostic pop


@implementation NSData (JSONObject)

- (id)objectFromJSONData {
	return [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingMutableContainers error:NULL];
}

@end
