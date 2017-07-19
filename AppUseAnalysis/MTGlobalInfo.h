//
//  MTGlobalInfo.h
//  MTNOP
//
//  Created by renwanqian on 14-4-16.
//  Copyright (c) 2014年 cn.mastercom. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface MTGlobalInfo : NSObject
/**
 *  Info-plist字典
 */
@property (strong,nonatomic) NSDictionary *appInfoDict;
/**
 *  公有bundle
 */
@property (strong,nonatomic) NSBundle *commBundle;
/**
 *  服务器地址
 */
@property (strong,nonatomic) NSString *SERVER_ADDRESS;
/**
 *  共享地址
 */
@property (strong,nonatomic) NSString *shareAddress;
/**
 *  版本更新地址
 */
@property (strong,nonatomic) NSString *updateAddress;

/**
 *  手机号
 */
@property (strong, nonatomic) NSString *phoneNumber;

/**
 *  用户名
 */
@property (strong, nonatomic) NSString *userName;

/**
 *  用户ID
 */
@property (strong, nonatomic) NSString *userID;

/**
 *  功能列表
 */
@property (strong, nonatomic) NSArray *funcArray;

/**
 *  地区列表
 */
@property (strong, nonatomic) NSArray *regionArray;
/**
 *  所有地区列表
 */
@property (strong, nonatomic) NSArray *allRegionArray;
/**
 *  是否离线模式
 */
@property (assign, nonatomic) BOOL isOffline;


+ (instancetype)sharedInstance;
- (void)putAttribute:(NSString*)key value:(id)value;
- (id)getAttribute:(NSString*)key;

/**
 *  根据区域 键和值 获取区域字典
 */
- (id)getRegionByValueAndKey:(id)value key:(NSString *)key;
@end
