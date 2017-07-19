//
//  MTApiProxy.h
//  MTNetworking
//
//  Created by song mj on 16/8/23.
//  Copyright © 2016年 mastercom. All rights reserved.
//



#import "AFNetworking.h"
#import "MTApiProxy.h"
#import "SVProgressHUD.h"
#import "JSONKit.h"
#import "GZIP.h"
#import "MTNetworkingHelper.h"



@interface MTApiProxy ()

@property (nonatomic, strong) NSMutableDictionary *dispatchTable;

//AFNetworking stuff
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation MTApiProxy
#pragma mark - getters and setters
- (NSMutableDictionary *)dispatchTable
{
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

- (AFHTTPSessionManager *)sessionManager
{
    if (_sessionManager == nil) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.securityPolicy.allowInvalidCertificates = YES;
        _sessionManager.securityPolicy.validatesDomainName = NO;
        
        /*
        [_sessionManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        _sessionManager.requestSerializer.timeoutInterval = 60.f;
        [_sessionManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        */
        
        BOOL useHttps = [[[NSBundle mainBundle].infoDictionary objectForKey:@"USEHTTPS"] boolValue];
        if(useHttps) {
            AFSecurityPolicy *securityPplicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
            securityPplicy.allowInvalidCertificates = YES;
            NSSet * setset = [AFSecurityPolicy certificatesInBundle:[NSBundle mainBundle]];
            [securityPplicy setPinnedCertificates:setset];
            
            [_sessionManager setSecurityPolicy:securityPplicy];
        }
    }
    return _sessionManager;
}
- (AFSecurityPolicy *)securityPolicy {
    return nil;
}
#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static MTApiProxy *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MTApiProxy alloc] init];
    });
    return sharedInstance;
}

#pragma mark - public methods


- (void)cancelRequestWithRequestID:(NSNumber *)requestID
{
    NSURLSessionDataTask *requestOperation = self.dispatchTable[requestID];
    [requestOperation cancel];
    [self.dispatchTable removeObjectForKey:requestID];
}

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList
{
    for (NSNumber *requestId in requestIDList) {
        [self cancelRequestWithRequestID:requestId];
    }
}


/** 这个函数存在的意义在于，如果将来要把AFNetworking换掉，只要修改这个函数的实现即可。 */
- (NSNumber *)callApiWithRequest:(NSURLRequest *)request loadingHint:(NSString*)loadingHint doneHint:(NSString *)doneHint success:(AXCallback)success fail:(AXCallback)fail
{
    
    NSLog(@"\n==================================\n\nRequest Start: \n\n %@\n\n==================================", request.URL);
    
    // 跑到这里的block的时候，就已经是主线程了。
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        NSNumber *requestID = @([dataTask taskIdentifier]);
        [self.dispatchTable removeObjectForKey:requestID];
 
        if (error) {
            if(loadingHint) {
                [SVProgressHUD showErrorWithStatus:@"无网络连接或连接超时"];
            }
            
            fail?fail(responseObject):nil;
#if DEBUG
            NSLog(@"Error: %@", error);
#endif
        } else {
            NSData *result = [[((NSData*)responseObject) copy] gunzippedData];
            if(nil == result) {
                result = [((NSData*)responseObject) copy];
            }
            NSLog(@"\n==================================\n\nResponse End(原始数据）: \n\n %@\n\n==================================", result);
            //此处漏掉了一个过程：如果返回数据只是纯粹的DATA时，直接转发出去的逻辑（我们项目中基本上没有出现过）
            // success(result)
            
            
            
            if(success != nil) {
                id jsonObject = [result objectFromJSONData];
                if (jsonObject == nil) {
                    jsonObject = [[MTNetworkingHelper dataDecode:result] objectFromJSONString];
                }
                
                 NSLog(@"\n==================================\n\nResponse End(解析后的JSON数据）: \n\n %@\n\n==================================", jsonObject);
               
                
                NSString *res = [jsonObject objectForKey:@"result"];
                
                if(1 == [[jsonObject objectForKey:@"success"] intValue]) {
                    if(doneHint) {
                        [SVProgressHUD showSuccessWithStatus:doneHint];
                    } else {
                        if(loadingHint) {
                            [SVProgressHUD dismiss];
                        }
                    }
                    
                } else {
                    NSString *retCode = [jsonObject objectForKey:@"success"];
                    NSString *retInfo = [NSString stringWithFormat:@"%@:%@",retCode,res];
                    if(doneHint) {
                        [SVProgressHUD showErrorWithStatus:retInfo];
                    } else {
                        if(loadingHint) {
                            [SVProgressHUD dismiss];
                        }
                    }
                }
                
                
                success(jsonObject);
            }
            
        }
    }];
    
    NSNumber *requestId = @([dataTask taskIdentifier]);
    
    self.dispatchTable[requestId] = dataTask;
    [dataTask resume];
    
    return requestId;
}

// 该方法专门用于上传文件
- (NSNumber *) callUploadApiWithRequest:(NSURLRequest *)request success:(AXCallback)success fail:(AXCallback)fail uploadProgress:(AXCallUploadback)uploadHandle {
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    BOOL useHttps = [[[NSBundle mainBundle].infoDictionary objectForKey:@"USEHTTPS"] boolValue];
    if(useHttps) {
        AFSecurityPolicy *securityPplicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        securityPplicy.allowInvalidCertificates = YES;
        NSSet * setset = [AFSecurityPolicy certificatesInBundle:[NSBundle mainBundle]];
        [securityPplicy setPinnedCertificates:setset];
        
        [manager setSecurityPolicy:securityPplicy];
    }
    
    NSURLSessionUploadTask *dataTask;
    
    dataTask = [manager
                uploadTaskWithStreamedRequest:request
                progress:^(NSProgress * _Nonnull uploadProgress) {
                    // This is not called back on the main queue.
                    // You are responsible for dispatching to the main queue for UI updates
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //Update the progress view
                        //[UIProgressView setProgress:uploadProgress.fractionCompleted];
#if DEBUG
                        NSLog(@"uploaded progress:%f",uploadProgress.fractionCompleted);
#endif
                        uploadHandle ? uploadHandle(uploadProgress.fractionCompleted):nil;
                        
                    });
                }
                completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                    
                    NSNumber *requestID = @([dataTask taskIdentifier]);
                    [self.dispatchTable removeObjectForKey:requestID];
                    
                    
                   
                    
                    if (error) {
                        
                        fail?fail(responseObject):nil;
#if DEBUG
                        NSLog(@"Error: %@", error);
#endif
                        
                    } else {
                        // 检查http response是否成立。
                        NSData *result = [[((NSData*)responseObject) copy] gunzippedData];
                        if(nil == result) {
                            result = [((NSData*)responseObject) copy];
                        }
                        
                        //此处漏掉了一个过程：如果返回数据只是纯粹的DATA时，直接转发出去的逻辑（我们项目中基本上没有出现过）
                        // success(result)
                        
                        if(success != nil) {
                            id jsonObject = [result objectFromJSONData];
                            if (jsonObject == nil) {
                                jsonObject = [[MTNetworkingHelper dataDecode:result] objectFromJSONString];
                            }
                            
                            NSLog(@"%@",jsonObject);
                            success(jsonObject);
                        }

                    }
                }];
    
    [dataTask resume];
    
    
    
    NSNumber *requestId = @([dataTask taskIdentifier]);
    
    self.dispatchTable[requestId] = dataTask;
    [dataTask resume];
    
    return requestId;
}

@end
