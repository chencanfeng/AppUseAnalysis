//
//  MTRequestGenerator.h
//  MTNetworking
//
//  Created by song mj on 16/8/23.
//  Copyright © 2016年 mastercom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTNetworkingProtocol.h"

@interface MTRequestGenerator : NSObject

+ (instancetype)sharedInstance;

@property(nonatomic, assign) BOOL isMTZip;

- (NSURLRequest *)generateRequestWithUrl:(NSString *)fullUrl requestParams:(NSDictionary *)requestParams requestType:(MTAPIManagerRequestType) requestType isZip:(BOOL)isZip;

@end
