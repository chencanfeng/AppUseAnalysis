//
//  MTAPICallManager.h
//  MTNetworking_rebuild
//
//  Created by song mj on 16/10/30.
//  Copyright © 2016年 mastercom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTNetworkingProtocol.h"

@interface MTAPICenterCallManager : NSObject



/**
 单例方法，使用场景：在ViewController中发送一个网络请求后，当退出这个ViewController后，不希望该网络请求被中断

 @return 返回单例
 */
+ (instancetype)sharedInstance;

/**
 非单例方法：使用场景：在ViewController中发送一个网络请求后，当退出这个ViewController后，希望该网络请求被中断
 注意：当使用该方法调请求时，请确保其为一个控制器的成员变量，否则，刚发些网络请求，实例就被销毁了

 @return 实例
 */
+ (instancetype)instance;

- (void) callAPIWithMethodName:(NSString *)methodName params:(NSDictionary *)params  handleBlock:(AXCallback)handleBlock ;


- (void) callAPIWithMethodName:(NSString *)methodName params:(NSDictionary *)params  loadingHint:(NSString*)loadingHint doneHint:(NSString *)doneHint handleBlock:(AXCallback)handleBlock ;


- (void) callAPIWithMethodName:(NSString *)methodName params:(NSDictionary *)params loadingHint:(NSString*)loadingHint doneHint:(NSString *)doneHint requestType:(MTAPIManagerRequestType) requestType handleBlock:(AXCallback)handleBlock ;


- (void) callAPIWithMethodName:(NSString *)methodName params:(NSDictionary *)params requestType:(MTAPIManagerRequestType) requestType handleBlock:(AXCallback)handleBlock ;





//////////////////////////////////////////////////////////////////////////////////////////////
/**
 上传文件API

 @param methodName      方法名称，比如"/uploadImg.php"
 @param params   API中的参数
 @param fileURLs 需要上传的文件信息列表
 @param handleBlock 成功返回的回调方法
 @param failedBlock 失败返回的回调方法
 @param handler  文件上传的进度处理方法，通用用于实时更新与进度相符的进度条
 */
- (void)uploadWithMethodName:(NSString *)methodName params:(NSDictionary *)params fileURLs:(NSArray *)fileURLs  handleBlock:(AXCallback)handleBlock  progressHandler:(AXCallUploadback)handler;








/////////////////////////////带失败Block的访方法//////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void) callAPIWithMethodName:(NSString *)methodName params:(NSDictionary *)params  successBlock:(AXCallback)successBlock failedBlock:(AXCallback)failedBlock;


- (void) callAPIWithMethodName:(NSString *)methodName params:(NSDictionary *)params  loadingHint:(NSString*)loadingHint doneHint:(NSString *)doneHint successBlock:(AXCallback)successBlock failedBlock:(AXCallback)failedBlock;


- (void) callAPIWithMethodName:(NSString *)methodName params:(NSDictionary *)params loadingHint:(NSString*)loadingHint doneHint:(NSString *)doneHint requestType:(MTAPIManagerRequestType) requestType successBlock:(AXCallback)successBlock failedBlock:(AXCallback)failedBlock;


- (void) callAPIWithMethodName:(NSString *)methodName params:(NSDictionary *)params requestType:(MTAPIManagerRequestType) requestType successBlock:(AXCallback)successBlock failedBlock:(AXCallback)failedBlock;



- (void)uploadWithMethodName:(NSString *)methodName params:(NSDictionary *)params fileURLs:(NSArray *)fileURLs  successBlock:(AXCallback)successBlock failedBlock:(AXCallback)failedBlock progressHandler:(AXCallUploadback)handler;



//////////////////////////////////////////////////////////////////////////////////////////////
- (void)callAPIWithHost:(NSString *)host methodName:(NSString *)methodName params:(NSDictionary *)params loadingHint:(NSString*)loadingHint doneHint:(NSString *)doneHint requestType:(MTAPIManagerRequestType) requestType successBlock:(AXCallback)successBlock failedBlock:(AXCallback)failedBlock isZip:(BOOL)isZip;


/**
 上传文件API
 
 @param host       提供API的服务器地址，比如http://xxx.xxx.xxx.xxx 或者 http:www.somecom.cn
 @param methodName      方法名称，比如"/uploadImg.php"
 @param params   API中的参数
 @param fileURLs 需要上传的文件信息列表
 @param successBlock 成功返回的回调方法
 @param failedBlock 失败返回的回调方法
 @param handler  文件上传的进度处理方法，通用用于实时更新与进度相符的进度条
 */
- (void)uploadWithHost:(NSString *)host methodName:(NSString *)methodName params:(NSDictionary *)params fileURLs:(NSArray *)fileURLs successBlock:(AXCallback)successBlock failedBlock:(AXCallback)failedBlock progressHandler:(AXCallUploadback)handler isZip:(BOOL)isZip;



/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

/**
 取消所有的的网络请求，该方法应该在包括“集约方式”进行网络请求的UIController的dealloc方法中进行显式调用
 */
- (void) cancelAllRequests;


/**
 取消指定的网络请求。在“成功和失败”返回的回调方法中应记得显式地调用[self removeRequestIdWithRequestID:response.requestId]以取消当前的网络请求！

 @param requestID <#requestID description#>
 */
- (void) cancelRequestWithRequestId:(NSInteger)requestID;

@end
