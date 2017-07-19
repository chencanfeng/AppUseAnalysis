//
//  MTRequestGenerator.m
//  MTNetworking
//
//  Created by song mj on 16/8/23.
//  Copyright © 2016年 mastercom. All rights reserved.
//

#import "MTRequestGenerator.h"
#import "AFNetworking.h"
#import "NSURLRequest+MTNetworkingMethods.h"
#import "MTNetworking.h"
#import "MTNetworkingHelper.h"
#import "GZIP.h"
#import "UIDevice+Cell.h"

@interface MTRequestGenerator ()

@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;

@end

NSString *kUploadFileList = @"kUploadFileList";

@implementation MTRequestGenerator
- (instancetype) init {
    if(self = [super init]) {
        NSDictionary *appInfoDic = [NSBundle mainBundle].infoDictionary;
        /*
        id isZipFromPlist = [appInfoDic objectForKey:@"ZIP"];
        if(isZipFromPlist) {
            if(YES == [isZipFromPlist boolValue])
                _isZip = YES;
            
        } else {
            _isZip = NO;
            
        }
       */
        id isMTZipFromPlist = [appInfoDic objectForKey:@"MTZIP"];
        if(isMTZipFromPlist) {
            if(YES == [isMTZipFromPlist boolValue])
                _isMTZip = YES;
            
        } else {
            _isMTZip = NO;
            
        }
    }
    return self;
}

#pragma mark - public methods
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static MTRequestGenerator *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MTRequestGenerator alloc] init];
    });
    return sharedInstance;
}



////////////////////////////////////////////////////////////////////////////////////////////////

- (NSURLRequest *)generateRequestWithUrl:(NSString *)fullUrl requestParams:(NSDictionary *)requestParams requestType:(MTAPIManagerRequestType) requestType isZip:(BOOL)isZip
{
    
    //1.由业务方对原有的请求参数增加属性
    requestParams = [self reformParams:requestParams];
    
    NSString *requestTypeStr;
    
    switch (requestType) {
        case MTAPIManagerRequestTypeGet:
            requestTypeStr = @"GET";
            break;
        case MTAPIManagerRequestTypePost:
            requestTypeStr = @"POST";
            break;
        case MTAPIManagerRequestTypePut:
            requestTypeStr = @"PUT";
            break;
        case MTAPIManagerRequestTypeDelete:
            requestTypeStr = @"DELETE";
            break;
            
        case MTAPIManagerRequestTypeUploadFiles:
            requestTypeStr = @"POST";
            break;
            
        default:
            requestTypeStr = @"POST";
            break;
    }
    
    NSMutableURLRequest *request;
    
    if(MTAPIManagerRequestTypeUploadFiles == requestType) {// 如果是上传的话，需要做特殊处理
        ///////////////
        //获取需要上传的文件信息列表
        NSMutableArray* fileUrls = [requestParams objectForKey:kUploadFileList];
        
        NSAssert(fileUrls, @"上传文件缺少‘上传文件列表信息'");
        
        request = [self.httpRequestSerializer multipartFormRequestWithMethod:@"POST" URLString:fullUrl parameters:requestParams constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            for (id file in fileUrls) {
                if ([file isKindOfClass:[NSURL class]]) {
                    [formData appendPartWithFileURL:file name:[[(NSURL*)file path] lastPathComponent] error:NULL];
                } else if ([file isKindOfClass:[NSDictionary class]]) {
                    
                    NSDictionary* dic=(NSDictionary*)file;
                    NSData* data=[dic valueForKey:@"data"];
                    NSString* name=[dic valueForKey:@"name"];
                    NSString* fileName=[dic valueForKey:@"fileName"];
                    NSString* mimeType=[dic valueForKey:@"mimeType"];
                    [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType];
                    
                }
            }
            
        } error:nil];
        ///////////////
        
    } else {
        request = [self.httpRequestSerializer requestWithMethod:requestTypeStr URLString:fullUrl parameters:requestParams error:NULL];
    }
    
    
    
    [self reformRequest:request params:requestParams requestType:requestType isZip:isZip];
 
    request.requestParams = requestParams;
    return request;
}



#pragma mark - private methods
- (NSDictionary *) reformParams:(NSDictionary *)params {
    
    NSDictionary *retParams;
    
    NSMutableDictionary *requestParams = nil;
    if (params == nil) {
        requestParams = [[NSMutableDictionary alloc] init];
    } else {
        requestParams = [params mutableCopy];
    }
    
    // 添加额外参数
    if (![requestParams.allKeys containsObject:@"imei"]) {
        [requestParams setObject:[UIDevice currentDevice].imei forKey:@"imei"];
    }
    
    if (![requestParams.allKeys containsObject:@"imsi"]) {
        [requestParams setObject:[UIDevice currentDevice].imsi forKey:@"imsi"];
    }
    
    if (![requestParams.allKeys containsObject:@"submittime"]) {
        [requestParams setObject:[[MTNetworkingHelper currentDateString] urlEncode_ForNetworking] forKey:@"submittime"];//提交时间
    }
    
    if (![requestParams.allKeys containsObject:@"model"]) {
        [requestParams setObject:[UIDevice currentDevice].platformName forKey:@"model"];//手机型号
    }
    
    if (![requestParams.allKeys containsObject:@"workType"]) {
        [requestParams setObject:[UIDevice currentDevice].networkType forKey:@"workType"];//网络类型
    }
    
    if (![requestParams.allKeys containsObject:@"osversion"]) {
        [requestParams setObject:[UIDevice currentDevice].systemVersion forKey:@"osversion"];//手机系统
    }
    
    if (![requestParams.allKeys containsObject:@"osname"]) {
        [requestParams setObject:[UIDevice currentDevice].systemName forKey:@"osname"];//手机系统类型
    }
    
    /*
    if (![requestParams.allKeys containsObject:@"version"]) {
        [requestParams setObject:[UIDevice currentDevice].version forKey:@"version"];//软件版本
    }*/
    
    if (![requestParams.allKeys containsObject:@"token"]) {
        [requestParams setObject:[UIDevice currentDevice].token forKey:@"token"];//token
    }
    
    retParams = [requestParams copy];
    return retParams;
}

// 设置的信息从原框架代码中复制过来的
- (void) reformRequest:(NSMutableURLRequest *) request params:(NSDictionary *) params requestType:(MTAPIManagerRequestType)type isZip:(BOOL)isZip{
    
    if (!request)
        return;
    
    NSString *url = request.URL.absoluteString;
    NSArray *urlArray = [url componentsSeparatedByString:@"?"];
    
    NSMutableString *paramsStr = nil;
    if ((params != nil && [params count] > 0) || [urlArray count]>1) {
        NSMutableString *tempStr = [NSMutableString string];
        if([urlArray count]>1){
            [tempStr appendString:urlArray[1]];
            if([urlArray[1] length]>0 && ![urlArray[1] hasSuffix:@"&"]){
                [tempStr appendString:@"&"];
            }
        }
        NSArray *keys = [params allKeys];
        for (int i = 0; i < [keys count]; i++) {
            NSString* key = [keys objectAtIndex:i];
            NSString* value = [NSString stringWithFormat:@"%@",[params valueForKey:key]];
            [tempStr appendString:[NSString stringWithFormat:@"%@=%@&", key, value]];
        }
        
        paramsStr = [NSMutableString stringWithString:[tempStr substringToIndex:[tempStr length] - 1]];
    }
    
    
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"utf-8" forHTTPHeaderField:@"Accept-Language"];
    
    
    if (isZip) {
        [request setHTTPBody:[[paramsStr dataUsingEncoding:NSUTF8StringEncoding] gzippedData]];
    }
    else if(_isMTZip)
    {
        NSData* paramsStrData = [paramsStr dataUsingEncoding:NSUTF8StringEncoding];
        NSData* data= [MTNetworkingHelper dataEncode:paramsStrData];
        
        //不知道什么原因，注释掉下面这一行，否则无法上传文件
        if(type != MTAPIManagerRequestTypeUploadFiles) {
            [request setValue:@"application/mtzip" forHTTPHeaderField:@"Content-Type"];
        }
        
        
        [request setHTTPBody:[data gzippedData]];
    }else {
        [request setHTTPBody:[paramsStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
}

#pragma mark - getters and setters
- (AFHTTPRequestSerializer *)httpRequestSerializer
{
    if (_httpRequestSerializer == nil) {
        _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        _httpRequestSerializer.timeoutInterval = 20;
        _httpRequestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    return _httpRequestSerializer;
}
@end
