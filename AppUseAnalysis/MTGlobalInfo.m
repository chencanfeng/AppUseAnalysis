//
//  MTGlobalInfo.m
//  MTNOP
//
//  Created by renwanqian on 14-4-16.
//  Copyright (c) 2014年 cn.mastercom. All rights reserved.
//


#import "MTGlobalInfo.h"

@interface MTGlobalInfo(){
    NSMutableDictionary *_attrDict;
}
@end

@implementation MTGlobalInfo

- (id)init {
	self = [super init];
	if (self) {
		_attrDict = [NSMutableDictionary dictionaryWithCapacity:100];
	}
	return self;
}

+ (instancetype)sharedInstance {
	static MTGlobalInfo *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    sharedInstance = [[MTGlobalInfo alloc] init];
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        sharedInstance.appInfoDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath]; 
        NSString *address = (NSString *)[sharedInstance.appInfoDict objectForKey:@"ServerAddress"];
        sharedInstance.SERVER_ADDRESS = address ? address : @"221.130.39.185:8090";
 
        NSError *error;
        NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"Area" ofType:@"json"];
        if (dataPath) {
            NSArray *regionArray = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath] options:kNilOptions error:&error];
            sharedInstance.allRegionArray = regionArray;
        }
	});
    
    return sharedInstance;
}

- (NSString *)shareAddress {
    return [_SERVER_ADDRESS stringByAppendingString:@"/download.html"];
}

- (NSString *)updateAddress{
    NSString *address = (NSString *)[_appInfoDict objectForKey:@"PlistAddress"];
    if (address == nil) {
        return [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=http://%@/UpdateFiles/%@.plist",
     _SERVER_ADDRESS, [_appInfoDict valueForKey:@"CFBundleIdentifier"]];
    } else {
        return [@"itms-services://?action=download-manifest&url=" stringByAppendingString:address];
    }
}

- (void)putAttribute:(NSString*)key value:(id)value{
    if (value == nil) {
        value = [NSNull null];
    }
    [_attrDict setObject:value forKey:key];
}

- (id)getAttribute:(NSString*)key {
    return [_attrDict valueForKey:key];
}

/**
 *  根据一对键值对，获取地区的的字典
 */
- (id)getRegionByValueAndKey:(id)value key:(NSString *)key{
    for (NSDictionary *item in _allRegionArray) {
        id value2 = [item valueForKey:key];
        if ([value2 isKindOfClass:[NSString class]]) {
            if ([(NSString *)value isEqualToString:value2]) {
                return item;
            }
        } else if ([value2 isKindOfClass:[NSNumber class]] && [value integerValue]==[value2 integerValue]) {
            return item;
        }
    }
    return nil;
}
@end
