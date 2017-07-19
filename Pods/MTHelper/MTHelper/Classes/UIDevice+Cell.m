//
//  UIDevice+Cell.m
//  SystemInfo
//
//  Created by adt on 13-12-2.
//  Copyright (c) 2013年 MasterCom. All rights reserved.
//

#import "UIDevice+Cell.h"

#import <SystemConfiguration/CaptiveNetwork.h>
#include <net/if.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "KeychinaHelper.h"

#include <ifaddrs.h> 
#include <arpa/inet.h>



struct CellInfo {
	int servingmnc;
	int network;
	int location;
	short cellid;
	short rnc;
	int station;
	short freq;
	short reserved;
	int rxlevel;
	int c1;
	int c2;
    int c3[6];
} cellInfo;

struct CTServerConnection {
    int a;
    int b;
    CFMachPortRef myport;
    int c;
    int d;
    int e;
    int f;
    int g;
    int h;
    int i;
};




struct CTResult
{
    int flag;
    int a;
};



extern NSString *CTSettingCopyMyPhoneNumber();

CFStringRef CTSIMSupportCopyMobileSubscriberIdentity(CFAllocatorRef allocator);
void CTIndicatorsGetSignalStrength(long int *raw, long int *graded, long int *bars);

extern NSString *CTSIMSupportCopyMobileSubscriberCountryCode();
extern NSString *CTSIMSupportCopyMobileSubscriberNetworkCode();
extern int CTGetSignalStrength();
extern int _CTServerConnectionGetSignalStrength();
extern id _CTServerConnectionCreate();



extern void _CTServerConnectionAddToRunLoop();

#ifdef __LP64__

void _CTServerConnectionRegisterForNotification(id, CFStringRef);
void _CTServerConnectionCellMonitorStart(id);
void _CTServerConnectionCellMonitorStop(id);
void _CTServerConnectionCellMonitorCopyCellInfo(id, void*, CFArrayRef*);
void _CTServerConnectionGetLocationAreaCode(id, int*);
void _CTServerConnectionGetCellID(id, int*);
void _CTServerConnectionGetRadioAccessTechnology(id,NSString**);
void _CTServerConnectionCellMonitorGetCellCount(id, int*);
void _CTServerConnectionCellMonitorGetCellInfo(id, int, int*, struct CellInfo*);

#else

void _CTServerConnectionRegisterForNotification(struct CTResult*, id, CFStringRef);
#define _CTServerConnectionRegisterForNotification(connection, notification) { struct CTResult res; _CTServerConnectionRegisterForNotification(&res, connection, notification); }

void _CTServerConnectionCellMonitorStart(struct CTResult*, id);
#define _CTServerConnectionCellMonitorStart(connection) { struct CTResult res; _CTServerConnectionCellMonitorStart(&res, connection); }

void _CTServerConnectionCellMonitorStop(struct CTResult*, id);
#define _CTServerConnectionCellMonitorStop(connection) { struct CTResult res; _CTServerConnectionCellMonitorStop(&res, connection); }

void _CTServerConnectionCellMonitorCopyCellInfo(struct CTResult*, id, void*, CFArrayRef*);
#define _CTServerConnectionCellMonitorCopyCellInfo(connection, tmp, cells) { struct CTResult res; _CTServerConnectionCellMonitorCopyCellInfo(&res, connection, tmp, cells); }

void _CTServerConnectionGetLocationAreaCode(struct CTResult*, id, int*);
#define _CTServerConnectionGetLocationAreaCode(connection, LAC) { struct CTResult res; _CTServerConnectionGetLocationAreaCode(&res, connection, LAC); }

void _CTServerConnectionGetCellID(struct CTResult*, id, int*);
#define _CTServerConnectionGetCellID(connection, CID) { struct CTResult res; _CTServerConnectionGetCellID(&res, connection, CID); }


void _CTServerConnectionGetRadioAccessTechnology(struct CTResult*, id,NSString**);
#define _CTServerConnectionGetRadioAccessTechnology(connection,networktype) { struct CTResult res; _CTServerConnectionGetRadioAccessTechnology(&res, connection, networktype); }

void _CTServerConnectionCellMonitorGetCellCount(struct CTResult*, id, int*);
#define _CTServerConnectionCellMonitorGetCellCount(connection,count) { struct CTResult res; _CTServerConnectionCellMonitorGetCellCount(&res, connection,count); }

void _CTServerConnectionCellMonitorGetCellInfo(struct CTResult*, id, int, int*, struct CellInfo*);
#define _CTServerConnectionCellMonitorGetCellInfo(connection,no,ts,cellinfo) { struct CTResult res; _CTServerConnectionCellMonitorGetCellInfo(&res, connection, no,ts,cellinfo); }

#endif


extern CFStringRef const kCTCellMonitorCellTypeServing;
extern CFStringRef const kCTCellMonitorCellId;
extern CFStringRef const kCTCellMonitorLAC;
extern CFStringRef const kCTCellMonitorUpdateNotification;

void callBack() {
	//do nothing
}



@implementation MTCellInfo
@end


static id _serverConnection;

@implementation UIDevice (Cell)

#pragma mark - wireless

- (id)getCTServerConnection{
    if(_serverConnection == nil){
#if TARGET_FOR_APPSTORE!=1
        _serverConnection = _CTServerConnectionCreate(NULL,NULL, NULL);
        _CTServerConnectionAddToRunLoop(_serverConnection,CFRunLoopGetMain(),kCFRunLoopCommonModes);
        _CTServerConnectionRegisterForNotification(_serverConnection, kCTCellMonitorUpdateNotification);
        _CTServerConnectionCellMonitorStart(_serverConnection);
#endif
    }
    return _serverConnection;
}

- (NSString *)networkType {
#if TARGET_IPHONE_SIMULATOR
	return @"";
#else
	
	NSString *networkType = @"";
#if TARGET_FOR_APPSTORE!=1
	id sc = _CTServerConnectionCreate(kCFAllocatorDefault, NULL, NULL);
	_CTServerConnectionGetRadioAccessTechnology(sc, &networkType);
	sc = nil;
#endif
	return networkType == nil ? @"" : networkType;
#endif
}


- (MTCellInfo*)currentCellInfo{
    
#if TARGET_IPHONE_SIMULATOR
    return nil;
#endif
    
    CFArrayRef cells = NULL;
#if TARGET_FOR_APPSTORE!=1
    id sc = _CTServerConnectionCreate(kCFAllocatorDefault, NULL, NULL);
    int tmp;
    //struct CTServerConnection *sc = (__bridge struct CTServerConnection *)[self getCTServerConnection];
    _CTServerConnectionCellMonitorCopyCellInfo(sc, (void*)&tmp, &cells);
    if (cells == NULL)
    {

        int lac = -1;
        _CTServerConnectionGetLocationAreaCode(sc, &lac);
        int cid = -1;
        _CTServerConnectionGetCellID(sc, &cid);
        
        long int raw = 0;
        long int graded = 0;
        long int bars = 0;
        
        CTIndicatorsGetSignalStrength(&raw, &graded, &bars);

        MTCellInfo *info = [[MTCellInfo alloc] init];
        info.rxlev = raw;
        info.lac = lac;
        info.cid = cid;
        sc = nil;
        
        return info;

    }
#endif
    MTCellInfo *info = [[MTCellInfo alloc] init];
    for (NSDictionary* cell in (__bridge NSArray*)cells)
    {
        if ([cell[@"kCTCellMonitorCellType"] isEqualToString:@"kCTCellMonitorCellTypeServing"]){
            for (NSString *key in cell) {
                if([key isEqualToString:@"kCTCellMonitorTAC"]){
                    info.lac = [cell[key] intValue];
                }else if([key isEqualToString:@"kCTCellMonitorLAC"]){
                    info.lac = [cell[key] intValue];
                }else if([key isEqualToString:@"kCTCellMonitorCellId"]){
                    info.cid = [cell[key] intValue];
                }else if([key isEqualToString:@"kCTCellMonitorPID"]){
                    info.pci = [cell[key] intValue];
                }else if([key isEqualToString:@"kCTCellMonitorBandInfo"]){
                    info.band = [cell[key] intValue];
                }else if([key isEqualToString:@"kCTCellMonitorRSRP"]){
                    info.rxlev = [cell[key] intValue];//字符串型？
                }else if([key isEqualToString:@"kCTCellMonitorRSCP"]){
                    info.rxlev = [cell[key] intValue];//字符串型？
                }else if([key isEqualToString:@"kCTCellMonitorSNR"]){
                    info.snr = [cell[key] intValue];
                }else if([key isEqualToString:@"kCTCellMonitorEcio"]){
                    info.snr = [cell[key] intValue];
                }else if([key isEqualToString:@"kCTCellMonitorECN0"]){
                    info.snr = [cell[key] intValue];
                }else if([key isEqualToString:@"kCTCellMonitorUARFCN"]){
                    info.arfcn = [cell[key] intValue];
                }else if([key isEqualToString:@"kCTCellMonitorARFCN"]){
                    info.arfcn = [cell[key] intValue];
                }
            }
        }

    }
    
    if(cells!=NULL)CFRelease(cells);
    return info;
}

- (NSInteger)signalStrength {
#if TARGET_IPHONE_SIMULATOR
	return -113;
#else
	int signalStrength = -113;
	@try {
#if TARGET_FOR_APPSTORE!=1
		signalStrength = CTGetSignalStrength(nil);
#endif
	}
	@catch (NSException *exception)
	{
		NSLog(@"%@", exception);
	}
	return signalStrength;
#endif
}

- (NSArray *)networkStatisc {
	struct ifaddrs *addrs;
	const struct ifaddrs *cursor;
	const struct if_data *networkStatisc;
    
	long rxWifi = 0;
	long txWifi = 0;
	long rxMobile = 0;
	long txMobile = 0;
	long rxTotal = 0;
	long txTotal = 0;
    
	NSString *name = nil; 
	if (getifaddrs(&addrs) == 0) {
		cursor = addrs;
		while (cursor != NULL) {
			//en0 is Wifi, pdp_ip0 is Mobile
			name = [NSString stringWithFormat:@"%s", cursor->ifa_name];
            
			if (cursor->ifa_addr->sa_family == AF_LINK) {
				if ([name hasPrefix:@"en"]) {
					networkStatisc = (const struct if_data *)cursor->ifa_data;
					txWifi += networkStatisc->ifi_obytes;
					rxWifi += networkStatisc->ifi_ibytes;
				}
                
				if ([name hasPrefix:@"pdp_ip"]) {
					networkStatisc = (const struct if_data *)cursor->ifa_data;
					txMobile += networkStatisc->ifi_obytes;
					rxMobile += networkStatisc->ifi_ibytes;
				}
                
				rxTotal = rxMobile + rxWifi;
				txTotal = txMobile + txWifi;
			}
            
			cursor = cursor->ifa_next;
		}
        
		freeifaddrs(addrs);
	}
    
	return @[@(rxTotal), @(rxWifi), @(rxMobile), @(txTotal), @(txWifi), @(txMobile)];
}

- (NSMutableArray *)neighbourCell {
#if TARGET_IPHONE_SIMULATOR
    return NULL;
#endif
	
    NSMutableArray * neighbourArr = [[NSMutableArray alloc] init];
#if TARGET_FOR_APPSTORE!=1
    int ts = 0;
    int count = 0;
    id sc = (_CTServerConnectionCreate(kCFAllocatorDefault, NULL, NULL));

    @try{
        _CTServerConnectionCellMonitorGetCellCount(sc, &count);
    	for (int i = 0; i < count; i++) {
            struct CellInfo ci;
            _CTServerConnectionCellMonitorGetCellInfo(sc, i, &ts, &ci);
            MTCellInfo *cell = [[MTCellInfo alloc] init];
            cell.lac = ci.location;
            cell.cid =(uint16_t)ci.cellid;
            cell.rxlev = ci.rxlevel;
            cell.arfcn = ci.freq;
            [neighbourArr addObject:cell];
        }
        sc = nil;
    }@catch(NSException *ex){
        
    }
#endif
    return neighbourArr;
}

#pragma mark - deivce

- (NSString *)udid {
	if ([[UIDevice currentDevice]respondsToSelector:@selector(identifierForVendor)]) {
		return [UIDevice currentDevice].identifierForVendor.UUIDString;
	} else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		SEL uniqueIdentifier = NSSelectorFromString(@"uniqueIdentifier");
		return [[UIDevice currentDevice] performSelector:uniqueIdentifier];
#pragma clang diagnostic pop
	}
}

- (NSString *)uuid {
    CFUUIDRef tempUUID = CFUUIDCreate(NULL);
	NSString *UUID = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, tempUUID);
	CFRelease(tempUUID);
	return UUID;
}
- (NSString *)token {
    
   NSString* token= [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    if (token==nil) {
        return @"";
    }
    return token;
}
- (NSString *)imei {
    /*
   	NSString *imei= [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    if (imei.length>0) {
        return imei;
    }*/
    NSString *imei;
	imei = [KeychinaHelper queryKeychainItemWithIdentifier:@"imei"];
	if (imei == nil) {
		imei = [NSString stringWithFormat:@"01275%010lu", (unsigned long)[[self uuid] hash]];
		[KeychinaHelper storeKeychainItem:imei WithIdentifier:@"imei"];
	} 
	return imei;
}

/** 
 *  UUID
 */
- (NSString *)imsi {
    NSString *imsi = [KeychinaHelper queryKeychainItemWithIdentifier:@"imsiA"];
	if (imsi == nil) {
        imsi = [NSString stringWithFormat:@"460%@A%09lu", [UIDevice currentDevice].mnc, (unsigned long)[[self uuid] hash]];
        [KeychinaHelper storeKeychainItem:imsi WithIdentifier:@"imsiA"];
	}
    NSLog(@"imsi = %@",imsi);

    return imsi;
}



- (NSString *)phoneNumber {
#if TARGET_IPHONE_SIMULATOR
	return @"13612283076";
#else
	NSString *phoneNumber = nil;
	@try {
#if TARGET_FOR_APPSTORE!=1
		phoneNumber = CTSettingCopyMyPhoneNumber(nil);
#endif
    }
	@catch (NSException *exception)
	{
		NSLog(@"%@", exception);
	}
	return phoneNumber == nil ? @"" : phoneNumber;
#endif
}

- (NSString *)mcc {
#if TARGET_IPHONE_SIMULATOR
	return @"460";
#else
	NSString *mcc = nil;
	@try {
#if TARGET_FOR_APPSTORE!=1
		mcc = CTSIMSupportCopyMobileSubscriberCountryCode(nil);
#endif
    }
	@catch (NSException *exception)
	{
		NSLog(@"%@", exception);
	}
	return mcc == nil ? @"460" : mcc;
#endif
}

- (NSString *)mnc {
#if TARGET_IPHONE_SIMULATOR
	return @"00";
#else
	NSString *mnc = nil;
	@try {
#if TARGET_FOR_APPSTORE!=1
        mnc = CTSIMSupportCopyMobileSubscriberNetworkCode(nil);
#endif
    }
	@catch (NSException *exception)
	{
		NSLog(@"%@", exception);
	}
    if(mnc == nil || [mnc length]==0){
        return @"00";
    }
    
	return mnc;
#endif
}

- (NSString *)platform {
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithUTF8String:machine];
	free(machine);
	return platform;
}

- (NSString *)platformName {
	NSString *platform = [self platform];
	if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";
	if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
	if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
	if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
	if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (GSM Rev A)";
	if ([platform isEqualToString:@"iPhone3,3"]) return @"Verizon iPhone 4";
	if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
	if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (GSM)";
	if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (GSM+CDMA)";
	if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (GSM)";
	if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (Global)";
	if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (GSM)";
	if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (Global)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    
	if ([platform isEqualToString:@"iPod1,1"]) return @"iPod Touch 1G";
	if ([platform isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G";
	if ([platform isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G";
	if ([platform isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G";
	if ([platform isEqualToString:@"iPod5,1"]) return @"iPod Touch 5G";
	if ([platform isEqualToString:@"iPad1,1"]) return @"iPad";
	if ([platform isEqualToString:@"iPad2,1"]) return @"iPad 2 (WiFi)";
	if ([platform isEqualToString:@"iPad2,2"]) return @"iPad 2 (GSM)";
	if ([platform isEqualToString:@"iPad2,3"]) return @"iPad 2 (CDMA)";
	if ([platform isEqualToString:@"iPad2,4"]) return @"iPad 2 (WiFi)";
	if ([platform isEqualToString:@"iPad2,5"]) return @"iPad Mini (WiFi)";
	if ([platform isEqualToString:@"iPad2,6"]) return @"iPad Mini (GSM)";
	if ([platform isEqualToString:@"iPad2,7"]) return @"iPad Mini (GSM+CDMA)";
	if ([platform isEqualToString:@"iPad3,1"]) return @"iPad 3 (WiFi)";
	if ([platform isEqualToString:@"iPad3,2"]) return @"iPad 3 (GSM+CDMA)";
	if ([platform isEqualToString:@"iPad3,3"]) return @"iPad 3 (GSM)";
	if ([platform isEqualToString:@"iPad3,4"]) return @"iPad 4 (WiFi)";
	if ([platform isEqualToString:@"iPad3,5"]) return @"iPad 4 (GSM)";
	if ([platform isEqualToString:@"iPad3,6"]) return @"iPad 4 (GSM+CDMA)";
	if ([platform isEqualToString:@"iPad4,1"]) return @"iPad Air (WiFi)";
	if ([platform isEqualToString:@"iPad4,2"]) return @"iPad Air (GSM)";
	if ([platform isEqualToString:@"iPad4,4"]) return @"iPad Mini Retina (WiFi)";
	if ([platform isEqualToString:@"iPad4,5"]) return @"iPad Mini Retina (GSM)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
	if ([platform isEqualToString:@"i386"]) return @"Simulator";
	if ([platform isEqualToString:@"x86_64"]) return @"Simulator";
 
	return platform;
}

+ (NSString *)appVersion {
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

- (NSString *)ipAddress {
	NSString *address = @"0.0.0.0";
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *temp_addr = NULL;
	int success = 0;
	// retrieve the current interfaces - returns 0 on success
	success = getifaddrs(&interfaces);
	if (success == 0) {
		// Loop through linked list of interfaces
		temp_addr = interfaces;
		while (temp_addr != NULL) {
			if (temp_addr->ifa_addr->sa_family == AF_INET) {
				// Check if interface is en0 which is the wifi connection on the iPhone
				if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
					// Get NSString from C String
					address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
				}
			}
			temp_addr = temp_addr->ifa_next;
		}
	}
	// Free memory
	freeifaddrs(interfaces);
	return address;
}

- (NSString *)macAddress {
	int mib[6];
	size_t len;
	char *buf;
	unsigned char *ptr;
	struct if_msghdr *ifm;
	struct sockaddr_dl *sdl;
    
	mib[0] = CTL_NET;
	mib[1] = AF_ROUTE;
	mib[2] = 0;
	mib[3] = AF_LINK;
	mib[4] = NET_RT_IFLIST;
    
	if ((mib[5] = if_nametoindex("en0")) == 0) {
		printf("Error: if_nametoindex error/n");
		return @"";
	}
    
	if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 1/n");
		return @"";
	}
    
	if ((buf = malloc(len)) == NULL) {
		printf("Could not allocate memory. error!/n");
		return @"";
	}
    
	if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        free(buf);
		printf("Error: sysctl, take 2");
		return @"";
	}
    
	ifm = (struct if_msghdr *)buf;
	sdl = (struct sockaddr_dl *)(ifm + 1);
	ptr = (unsigned char *)LLADDR(sdl);
	NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr + 1), *(ptr + 2), *(ptr + 3), *(ptr + 4), *(ptr + 5)];
	free(buf);
	return [outstring uppercaseString];
}

#pragma mark - traffic

- (long)totalRxBytes {
	return [[[self networkStatisc] objectAtIndex:0] longValue];
}

- (long)wifiRxBytes {
	return [[[self networkStatisc] objectAtIndex:1] longValue];
}

- (long)mobileRxBytes {
	return [[[self networkStatisc] objectAtIndex:2] longValue];
}

- (long)rxBytesWithUid:(NSInteger)uid {
	return 0;
}

- (long)totalTxBytes {
	return [[[self networkStatisc] objectAtIndex:3] longValue];
}

- (long)wifiTxBytes {
	return [[[self networkStatisc] objectAtIndex:4] longValue];
}

- (long)mobileTxBytes {
	return [[[self networkStatisc] objectAtIndex:5] longValue];
}


#pragma mark - wifi

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (NSDictionary *)currentWifiInfo {
	NSDictionary *wifiInfo = nil;
	NSArray *interfaces = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
	for (NSString *interface in interfaces) {
		wifiInfo = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)interface);
        
		break;
	}
    
	return wifiInfo;
}
#pragma clang diagnostic pop
@end
