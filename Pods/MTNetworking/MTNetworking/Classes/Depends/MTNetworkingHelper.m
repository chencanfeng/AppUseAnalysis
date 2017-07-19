//
//  MTNetworkingHelper.m
//  MTNetworking
//
//  Created by song mj on 16/8/26.
//  Copyright © 2016年 mastercom. All rights reserved.
//

#import "MTNetworkingHelper.h"
#include <sys/time.h>
#import <zlib.h>

@implementation MTNetworkingHelper


+ (NSString *)currentDateString {
    char fmt[32];
    struct timeval tv;
    struct tm *tm;
    
    gettimeofday(&tv, NULL);
    tm = localtime(&tv.tv_sec);
    
    strftime(fmt, sizeof(fmt), "%Y-%m-%d %H:%M:%S", tm);
    
    return [NSString stringWithUTF8String:fmt];
}

+ (NSString *)dataDecode:(NSData *)data {
    if (data == nil) {
        return nil;
    }
    
    Byte *byte = (Byte *)[data bytes];
    for (int i = 0; i < [data length]; i++) {
        *byte = *byte - 8;
        byte++;
    }
    
    return [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
}
+ (NSData *)dataEncode:(NSData *)data {
    if (data == nil) {
        return nil;
    }
    
    Byte *byte = (Byte *)[data bytes];
    for (int i = 0; i < [data length]; i++) {
        *(byte+i) = *(byte+i) + 8;
    }
    return [NSData dataWithBytes:byte length:[data length]];
    
    //    return [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
}
@end


@implementation  NSString (MTNetHelper)
- (NSString *)urlEncode_ForNetworking {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)self, NULL,
                                                                                 (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
#pragma clang diagnostic pop
}


    
    

-(NSString *)urlDecode_ForNetworking {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                 (__bridge CFStringRef)self,  CFSTR("") ,
                                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

#pragma clang diagnostic pop

@end


