//
//  MTUtils.h
//  MTNOP
//
//  Created by renwanqian on 14-4-16.
//  Copyright (c) 2014年 cn.mastercom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h> 


#define __BASE64( text )        [MTUtils base64StringFromText:text]
#define __TEXT( base64 )        [MTUtils textFromBase64String:base64]

@interface MTUtils : NSObject

@end

@interface NSString (size)
- (CGSize)sizeWithAttributeFont:(UIFont *)font;
- (CGSize)sizeWithAttributeFont:(UIFont *)font forWidth:(int)width;

@end


@interface UIImage (colorsize)

+ (UIImage *)imageWithColor:(UIColor *)color;
-(UIImage*)resize:(CGSize)size;
@end

@interface UIColor (html)
/**
 *  UIColor with html format
 *
 *  @param e.g. value 0xFFFF0000 for red.
 *
 *  @return color
 */
+ (UIColor *)colorWithHtmlFormat:(NSUInteger)value;
/**
 *  UIColor with hex string format
 *
 *  @param e.g. color 0xFFFF00 for red.
 *
 *  @return color
 */
+ (UIColor *)colorWithHexString:(NSString *)color;

+ (UIColor *)colorWithHexString:(NSString *)color alpha :(CGFloat)alpha;
/**
 *  hex string format of UIColor
 *
 *  @param color
 *
 *  @return e.g. color 0xFFFF00 for red.
 */
+ (NSString*)hexStringOfColor:(UIColor*)color;

 

@end

@interface UIView (grand)

- (void)setGradientBackground;

@end

@interface NSMutableDictionary (allowNil)

- (void)setObjectOrNil:(id)anObject forKey:(id <NSCopying> )aKey;

@end

@interface NSDate (MTUtils)
+ (NSString *)currentDateString;
+ (NSString *)currentDateStringWithMillis;
+ (NSString*)dayStringFromNow:(int)days;
+ (NSString*)monthStringFromNow:(int)months;

+ (NSString*)stringFromDate:(NSDate*)date dateFormat:(NSString *)dateFormat;
+ (NSString *)dateFormat2String:(NSDate*)date withFormat :(NSString*) format;

+ (NSDate*)dateFromString:(NSString*)dateString dateFormat:(NSString *)dateFormat;
+ (NSDate*)dateFromYMD:(int)year month:(int)month day:(int)day;
+ (NSDate *)jsDateFromBeginDate:(NSDate *)beginDate todays:(int)days;
+ (NSDate *)jsDateFromBeginDate:(NSDate *)beginDate tomonths:(int)months;

+ (long long)currentTimeMillis;



- (NSString *)dateStringWithFormat:(NSString *)format;



@end

@interface NSString (converter)

+(NSString*)fromInt:(int)value;
+(NSString*)fromFloat:(float)value;
+(NSString*)fromFloat:(float)value decimal:(int)decimal;
+(NSString*)fromNumber:(NSNumber*)value decimal:(int)decimal;
+(NSString*)fromObject:(id)value;
+(NSString*)fromObject:(id)value decimal:(int)decimal;

@end

/*
@interface NSObject (setValuesAndKeys)

-(void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues;

@end
 */



