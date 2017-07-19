//
//  KeychinaHelper.m
//  URLS
//
//  Created by adt on 14-1-22.
//  Copyright (c) 2014年 MasterCom. All rights reserved.
//

#import "KeychinaHelper.h"

#import <Security/Security.h>

@implementation KeychinaHelper

+ (NSMutableDictionary *)newKeychainQuery:(NSString *)identifier {
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:
	        (__bridge_transfer  id)kSecClassGenericPassword, (__bridge id)kSecClass,
	        identifier, (__bridge id)kSecAttrAccount,
	        identifier, (__bridge id)kSecAttrService,
	        (__bridge id)kSecAttrAccessibleAlways, (__bridge id)kSecAttrAccessible,
	        nil];
}

+ (id)queryKeychainItemWithIdentifier:(NSString *)identifier {
	id keychainItem = nil;
    
	NSMutableDictionary *keychainQuery = [self newKeychainQuery:identifier];
	[keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	[keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
	CFDataRef data = NULL;
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&data);
	if (status == errSecSuccess) {
		keychainItem = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge id)data];
	}
	return keychainItem;
}

+ (void)storeKeychainItem:(id)keychainItem WithIdentifier:(NSString *)identifier {
	NSMutableDictionary *keychainQuery = [self newKeychainQuery:identifier];
	SecItemDelete((__bridge CFDictionaryRef)(keychainQuery));
	[keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:keychainItem] forKey:(__bridge id)(kSecValueData)];
    
	OSStatus status = SecItemAdd((__bridge CFDictionaryRef)(keychainQuery), NULL);
	if (status != errSecSuccess) {
		NSLog(@"OSStatus >>> %@", @(status));
	}
}

@end
