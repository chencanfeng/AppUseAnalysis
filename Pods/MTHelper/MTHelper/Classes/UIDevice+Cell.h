//
//  UIDevice+Cell.h
//  SystemInfo
//
//  Created by adt on 13-12-2.
//  Copyright (c) 2013年 MasterCom. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface MTCellInfo : NSObject
@property NSInteger lac;
@property NSInteger cid;
@property NSInteger band;
@property NSInteger arfcn;
@property NSInteger snr;
@property NSInteger pci;
@property NSInteger rxlev;
@property NSString* network;
@end

@interface UIDevice (Cell)

- (NSString *)udid;
- (NSString *)uuid;
- (NSString *)imei;
- (NSString *)token;
- (NSString *)imsi;
- (NSString *)phoneNumber;
- (NSString *)mcc;
- (NSString *)mnc;
- (NSString *)networkType;
- (MTCellInfo*)currentCellInfo;

- (NSInteger)signalStrength;

- (NSString *)platform;
- (NSString *)platformName;

- (long)totalRxBytes;
- (long)wifiRxBytes;
- (long)mobileRxBytes;
- (long)totalTxBytes;
- (long)wifiTxBytes;
- (long)mobileTxBytes;


- (NSMutableArray*)neighbourCell;
+ (NSString *)appVersion;
- (NSString *)ipAddress;
- (NSString *)macAddress;
- (NSDictionary *)currentWifiInfo;

@end
