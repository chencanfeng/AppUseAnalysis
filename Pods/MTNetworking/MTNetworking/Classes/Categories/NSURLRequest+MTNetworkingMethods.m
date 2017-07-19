//
//  NSURLRequest+CTNetworkingMethods.m
//  MTNetworking
//
//  Created by song mj on 16/8/23.
//  Copyright © 2016年 mastercom. All rights reserved.
//

#import "NSURLRequest+MTNetworkingMethods.h"
#import <objc/runtime.h>

static void *MTNetworkingRequestParams;

@implementation NSURLRequest (MTNetworkingMethods)

- (void)setRequestParams:(NSDictionary *)requestParams
{
    objc_setAssociatedObject(self, &MTNetworkingRequestParams, requestParams, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)requestParams
{
    return objc_getAssociatedObject(self, &MTNetworkingRequestParams);
}

@end
