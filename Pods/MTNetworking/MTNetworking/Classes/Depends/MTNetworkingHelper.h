//
//  MTNetworkingHelper.h
//  MTNetworking
//
//  Created by song mj on 16/8/26.
//  Copyright © 2016年 mastercom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTNetworkingHelper : NSObject

//+ (instancetype)sharedManager;

+ (NSString *)currentDateString;
+ (NSString *)dataDecode:(NSData *)data;
+ (NSData *)dataEncode:(NSData *)data;

@end

@interface NSString (MTNetHelper)

- (NSString *)urlEncode_ForNetworking;
-(NSString *)urlDecode_ForNetworking;

@end
