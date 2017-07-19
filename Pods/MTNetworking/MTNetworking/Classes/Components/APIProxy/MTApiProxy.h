//
//  MTApiProxy.h
//  MTNetworking
//
//  Created by song mj on 16/8/23.
//  Copyright © 2016年 mastercom. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "MTURLResponse.h"
#import "MTNetworkingProtocol.h"



@interface MTApiProxy : NSObject

+ (instancetype)sharedInstance;

- (NSNumber *)callApiWithRequest:(NSURLRequest *)request loadingHint:(NSString*)loadingHint doneHint:(NSString *)doneHint success:(AXCallback)success fail:(AXCallback)fail;

// 该方法专门用于上传文件
- (NSNumber *) callUploadApiWithRequest:(NSURLRequest *)request success:(AXCallback)success fail:(AXCallback)fail uploadProgress:(AXCallUploadback)uploadHandle;

- (void)cancelRequestWithRequestID:(NSNumber *)requestID;
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;

@end
