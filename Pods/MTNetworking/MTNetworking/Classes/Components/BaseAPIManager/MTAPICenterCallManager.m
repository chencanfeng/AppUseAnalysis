//
//  MTAPICallManager.m
//  MTNetworking_rebuild
//
//  Created by song mj on 16/10/30.
//  Copyright © 2016年 mastercom. All rights reserved.
//

#import "MTAPICenterCallManager.h"
#import "MTApiProxy.h"
#import "MTRequestGenerator.h"
#import "SVProgressHUD.h"

@interface MTAPICenterCallManager ()

@property (nonatomic, strong) NSMutableArray *requestIdList;

@end

@implementation MTAPICenterCallManager

#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static MTAPICenterCallManager *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MTAPICenterCallManager alloc] init];
        sharedInstance.requestIdList = [[NSMutableArray alloc]init];
    });
    return sharedInstance;
}

+ (instancetype)instance {
    return [[self alloc]init];
}

- (void) dealloc {
#if DEBUG
    NSLog(@"dealloc ...");
#endif
    [self cancelAllRequests];
    self.requestIdList = nil;
}

#pragma mark - public methods

- (void) callAPIWithMethodName:(NSString *)methodName params:(NSDictionary *)params  handleBlock:(AXCallback)handleBlock {
    
    [self callAPIWithHost:nil methodName:methodName params:params loadingHint:nil doneHint:nil requestType:MTAPIManagerRequestTypePost successBlock:handleBlock failedBlock:nil isZip:NO];
}


- (void) callAPIWithMethodName:(NSString *)methodName params:(NSDictionary *)params  loadingHint:(NSString*)loadingHint doneHint:(NSString *)doneHint handleBlock:(AXCallback)handleBlock {
   
    [self callAPIWithHost:nil methodName:methodName params:params loadingHint:loadingHint doneHint:doneHint requestType:MTAPIManagerRequestTypePost successBlock:handleBlock failedBlock:nil isZip:NO];
    
}


- (void) callAPIWithMethodName:(NSString *)methodName params:(NSDictionary *)params loadingHint:(NSString*)loadingHint doneHint:(NSString *)doneHint requestType:(MTAPIManagerRequestType) requestType handleBlock:(AXCallback)handleBlock
{
    [self callAPIWithHost:nil methodName:methodName params:params loadingHint:loadingHint doneHint:doneHint requestType:requestType successBlock:handleBlock failedBlock:nil isZip:NO];
    
}


- (void) callAPIWithMethodName:(NSString *)methodName params:(NSDictionary *)params requestType:(MTAPIManagerRequestType) requestType handleBlock:(AXCallback)handleBlock
{
     [self callAPIWithHost:nil methodName:methodName params:params loadingHint:nil doneHint:nil requestType:requestType successBlock:handleBlock failedBlock:nil isZip:NO];
    
}



#pragma mark - 带失败回调Block的方法

- (void) callAPIWithMethodName:(NSString *)methodName params:(NSDictionary *)params  successBlock:(AXCallback)successBlock failedBlock:(AXCallback)failedBlock
{
    [self callAPIWithHost:nil methodName:methodName params:params loadingHint:nil doneHint:nil requestType:MTAPIManagerRequestTypePost successBlock:successBlock failedBlock:failedBlock isZip:NO];
    
}


- (void) callAPIWithMethodName:(NSString *)methodName params:(NSDictionary *)params  loadingHint:(NSString*)loadingHint doneHint:(NSString *)doneHint successBlock:(AXCallback)successBlock failedBlock:(AXCallback)failedBlock
{
    [self callAPIWithHost:nil methodName:methodName params:params loadingHint:loadingHint doneHint:doneHint requestType:MTAPIManagerRequestTypePost successBlock:successBlock failedBlock:failedBlock isZip:NO];
    
}


- (void) callAPIWithMethodName:(NSString *)methodName params:(NSDictionary *)params loadingHint:(NSString*)loadingHint doneHint:(NSString *)doneHint requestType:(MTAPIManagerRequestType) requestType successBlock:(AXCallback)successBlock failedBlock:(AXCallback)failedBlock
{
    [self callAPIWithHost:nil methodName:methodName params:params loadingHint:loadingHint doneHint:doneHint requestType:requestType successBlock:successBlock failedBlock:failedBlock isZip:NO];
    
}


- (void) callAPIWithMethodName:(NSString *)methodName params:(NSDictionary *)params requestType:(MTAPIManagerRequestType) requestType successBlock:(AXCallback)successBlock failedBlock:(AXCallback)failedBlock
{
    [self callAPIWithHost:nil methodName:methodName params:params loadingHint:nil doneHint:nil requestType:requestType successBlock:successBlock failedBlock:failedBlock isZip:NO];
    
}

- (void)uploadWithMethodName:(NSString *)methodName params:(NSDictionary *)params fileURLs:(NSArray *)fileURLs  successBlock:(AXCallback)successBlock failedBlock:(AXCallback)failedBlock progressHandler:(AXCallUploadback)handler
{
    
    [self uploadWithHost:nil methodName:methodName params:params fileURLs:fileURLs successBlock:successBlock failedBlock:failedBlock progressHandler:handler isZip:NO];
    
}

////////////////////////////////////////////////////////////////////////////

- (void)callAPIWithHost:(NSString *)host methodName:(NSString *)methodName params:(NSDictionary *)params loadingHint:(NSString*)loadingHint doneHint:(NSString *)doneHint requestType:(MTAPIManagerRequestType) requestType successBlock:(AXCallback)successBlock failedBlock:(AXCallback)failedBlock isZip:(BOOL)isZip{
    
    if(loadingHint) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showWithStatus:loadingHint];
    }
    NSParameterAssert(host || methodName);
    
    NSString *fullUrl;
    if([methodName hasPrefix:@"http://"] ||
       [methodName hasPrefix:@"https://"]|| [methodName hasPrefix:@"www."]) {
        fullUrl = methodName;
    } else {
        if(nil == host) {
            host = [self defaultServerHost];
        }
        BOOL useHttps = [[[NSBundle mainBundle].infoDictionary objectForKey:@"USEHTTPS"] boolValue];
        
        if(methodName) {
            if(useHttps) {
                fullUrl = [NSString stringWithFormat:@"https://%@/%@", host, methodName];
            } else {
                fullUrl = [NSString stringWithFormat:@"http://%@%@", host, methodName];
            }
        } else {
            if(useHttps) {
                fullUrl = [NSString stringWithFormat:@"https://%@", host];
            } else {
                fullUrl = [NSString stringWithFormat:@"https://%@", host];
            }
        }
    }
    
    
    
    NSURLRequest *request = [[MTRequestGenerator sharedInstance] generateRequestWithUrl:fullUrl requestParams:params requestType:requestType  isZip:isZip];
    
    NSInteger requestId = [[[MTApiProxy sharedInstance]callApiWithRequest:request loadingHint:loadingHint doneHint:doneHint success:successBlock fail:failedBlock]integerValue];
    [self.requestIdList addObject:@(requestId)];
    
}



- (void)uploadWithHost:(NSString *)host methodName:(NSString *)methodName params:(NSDictionary *)params fileURLs:(NSArray *)fileURLs successBlock:(AXCallback)successBlock failedBlock:(AXCallback)failedBlock progressHandler:(AXCallUploadback)handler isZip:(BOOL)isZip
{
    
    NSParameterAssert(host || methodName);
    
    NSString *fullUrl;
    
    if([methodName hasPrefix:@"http://"]
       || [methodName hasPrefix:@"https://"] || [methodName hasPrefix:@"www."]) {
        fullUrl = methodName;
    } else {
        if(nil == host) {
            host = [self defaultServerHost];
        }
        BOOL useHttps = [[[NSBundle mainBundle].infoDictionary objectForKey:@"USEHTTPS"] boolValue];
        
        if(methodName) {
            if(useHttps) {
                fullUrl = [NSString stringWithFormat:@"https://%@/%@", host, methodName];
            } else {
                fullUrl = [NSString stringWithFormat:@"http://%@/%@", host, methodName];
            }
        } else {
            if(useHttps) {
                fullUrl = [NSString stringWithFormat:@"https://%@", host];
            } else {
                fullUrl = [NSString stringWithFormat:@"https://%@", host];
            }
        }
    }
    
    //发起网络请求之前，先取消
    
    NSURLRequest *request = [[MTRequestGenerator sharedInstance] generateRequestWithUrl:fullUrl requestParams:params requestType:MTAPIManagerRequestTypeUploadFiles isZip:isZip];
    
    NSInteger requestId = [[[MTApiProxy sharedInstance]callUploadApiWithRequest:request success:successBlock fail:failedBlock uploadProgress:handler]integerValue];
    
    [self.requestIdList addObject:@(requestId)];
    
}



- (void) cancelAllRequests {
    [[MTApiProxy sharedInstance] cancelRequestWithRequestIDList:self.requestIdList];
    [self.requestIdList removeAllObjects];
}
- (void) cancelRequestWithRequestId:(NSInteger)requestID {
    [self removeRequestIdWithRequestID:requestID];
    [[MTApiProxy sharedInstance]cancelRequestWithRequestID:@(requestID)];
}







#pragma mark - privated methods

- (void)removeRequestIdWithRequestID:(NSInteger)requestId {
    NSNumber *requestIDToRemove = nil;
    for (NSNumber *storedRequestId in self.requestIdList) {
        if ([storedRequestId integerValue] == requestId) {
            requestIDToRemove = storedRequestId;
            break;
        }
    }
    if (requestIDToRemove) {
        [self.requestIdList removeObject:requestIDToRemove];
    }
}


- (NSString *)defaultServerHost {
    
    NSString *testHost = [[NSUserDefaults standardUserDefaults]objectForKey:@"MTTestHost"];
    if(testHost && [testHost isKindOfClass:[NSString class]]) {
        testHost = [testHost stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(testHost.length > 0) {
            return testHost;
        }
    }
    
    NSDictionary* appInfoDict = [NSBundle mainBundle].infoDictionary;
    NSString *address = (NSString *)[appInfoDict objectForKey:@"ServerAddress"];
    address = address ? address : @"221.130.39.185:8090";
    return address;
}
@end
