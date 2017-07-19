//
//  MTManagerProtocol.h
//  MTNetworking
//
//  Created by song mj on 16/8/23.
//  Copyright © 2016年 mastercom. All rights reserved.
//

//#import "MTURLResponse.h"

#ifndef MTManagerProtocol_h
#define MTManagerProtocol_h


typedef void(^AXCallback)(NSDictionary *_Nullable response);
typedef void(^AXCallUploadback) (double fractionCompleted);

@class MTAPIBaseManager;

// 在调用成功之后的params字典里面，用这个key可以取出requestID
static  NSString * _Nonnull  const kMTAPIBaseManagerRequestID = @"kMTAPIBaseManagerRequestID";

extern NSString *kUploadFileList;

typedef NS_ENUM (NSUInteger, MTAPIManagerRequestType){
    MTAPIManagerRequestTypeGet,
    MTAPIManagerRequestTypePost,
    MTAPIManagerRequestTypePut,
    MTAPIManagerRequestTypeDelete,
    MTAPIManagerRequestTypeUploadFiles,
};


#endif /* MTManagerProtocol_h */
