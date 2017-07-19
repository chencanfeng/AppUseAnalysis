//
//  MTNet_KeychinaHelper.h
//  MTNetworking
//
//  Created by song mj on 16/8/26.
//  Copyright © 2016年 mastercom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTNet_KeychinaHelper : NSObject

+ (id)queryKeychainItemWithIdentifier:(NSString *)identifier;
+ (void)storeKeychainItem:(id)keychainItem WithIdentifier:(NSString *)identifier;

@end
