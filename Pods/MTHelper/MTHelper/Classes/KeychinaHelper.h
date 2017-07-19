//
//  KeychinaHelper.h
//  URLS
//
//  Created by adt on 14-1-22.
//  Copyright (c) 2014年 MasterCom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychinaHelper : NSObject

+ (id)queryKeychainItemWithIdentifier:(NSString *)identifier;
+ (void)storeKeychainItem:(id)keychainItem WithIdentifier:(NSString *)identifier;

@end
