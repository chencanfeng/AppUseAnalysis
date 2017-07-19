//
//  MTUtils.m
//  MTNOP
//
//  Created by renwanqian on 14-4-16.
//  Copyright (c) 2014年 cn.mastercom. All rights reserved.
//




#import <QuartzCore/QuartzCore.h>
#include <math.h>
#include <sys/time.h>
#import <objc/runtime.h>



//空字符串
#define     LocalStr_None           @""

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation MTUtils




@end
@implementation NSString (size)
- (CGSize) sizeWithAttributeFont:(UIFont *)font{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        return [self sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]];
    }else{
        return [self sizeWithFont:font forWidth:MAXFLOAT lineBreakMode:NSLineBreakByCharWrapping];
    }
}

- (CGSize)sizeWithAttributeFont:(UIFont *)font forWidth:(int)width{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        return [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:@{NSFontAttributeName: font} context:nil].size;
    }else{
        return [self sizeWithFont:font constrainedToSize:CGSizeMake(width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        
    }
}

@end
@implementation  UIImage (colorsize)

+ (UIImage *)imageWithColor:(UIColor *)color {
	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
	UIGraphicsBeginImageContext(rect.size);
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
    
	return image;
}

-(UIImage*)resize:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

@end

@implementation UIColor (html)

+ (UIColor *)colorWithHtmlFormat:(NSUInteger)value {
	NSUInteger alpha = value >> 24;
	NSUInteger red = (value >> 16) & 0xFF;
	NSUInteger green = (value >> 8) & 0xFF;
	NSUInteger blue = value & 0xFF;
    
	return [UIColor colorWithRed:(red / 255.0) green:(green / 255.0) blue:(blue / 255.0) alpha:(alpha / 255.0)];
}

+ (UIColor *)colorWithHexString:(NSString *)color{
    if(color == nil){
        return nil;
    }
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    
    // String should be 6 or more characters
    if ([cString length] < 6) {
        return nil;
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

+ (UIColor *)colorWithHexString:(NSString *)color alpha :(CGFloat)alpha
{
    if(color == nil){
        return nil;
    }
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    
    // String should be 6 or more characters
    if ([cString length] < 6) {
        return nil;
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
     return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:alpha];
}
+ (NSString*)hexStringOfColor:(UIColor*)color{
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [NSString stringWithFormat:@"#%02x%02x%02x",(int)(r*255.0f),(int)(g*255.0f),(int)(b*255.0f)];
}

@end

@implementation UIView (gradient)

- (void)setGradientBackground {
	CAGradientLayer *shadowLayer = [[CAGradientLayer alloc] init];
	shadowLayer.startPoint = CGPointMake(0.0, 0.0);
	shadowLayer.endPoint = CGPointMake(1.0, 0.0);
	shadowLayer.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
	shadowLayer.colors = [NSArray arrayWithObjects:
	                      (id)[[UIColor colorWithHtmlFormat:0xff0f303C] CGColor],
	                      (id)[[UIColor colorWithHtmlFormat:0xff015f79] CGColor],
	                      (id)[[UIColor colorWithHtmlFormat:0xff0f303C] CGColor],
	                      nil];
	[self.layer insertSublayer:shadowLayer atIndex:0];
}

@end

@implementation NSMutableDictionary (allowNil)

- (void)setObjectOrNil:(id)anObject forKey:(id <NSCopying> )aKey {
	if (anObject == nil) {
		[self setObject:@"" forKey:aKey];
	} else {
		[self setObject:anObject forKey:aKey];
	}
}

@end

@implementation NSDate (MTUtils)

+ (NSString *)currentDateString {
    char fmt[32];
    struct timeval tv;
    struct tm *tm;
    
    gettimeofday(&tv, NULL);
    tm = localtime(&tv.tv_sec);
    
    strftime(fmt, sizeof(fmt), "%Y-%m-%d %H:%M:%S", tm);
    
    return [NSString stringWithUTF8String:fmt];
}

+ (NSString *)currentDateStringWithMillis {
    char fmt[32], buf[32];
    struct timeval tv;
    struct tm *tm;
    
    gettimeofday(&tv, NULL);
    tm = localtime(&tv.tv_sec);
    
    strftime(fmt, sizeof(fmt), "%Y-%m-%d %H:%M:%S.%%03u", tm);
    snprintf(buf, sizeof(buf), fmt, tv.tv_usec / 1000);
    
    return [NSString stringWithUTF8String:buf];
}

+(NSString*)dayStringFromNow:(int)days{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:24*3600*days];
    return [NSDate stringFromDate:date dateFormat:@"yyyy-MM-dd"];
}

+(NSString*)monthStringFromNow:(int)months{
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:24*3600*30];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:-1];
    [comps setDay:0];
    NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:now  options:0];
    return [NSDate stringFromDate:date dateFormat:@"yyyy-MM"];
}


+(NSString*) stringFromDate:(NSDate*)date dateFormat:(NSString *)dateFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:dateFormat];
    return [formatter stringFromDate:date];
}


+(NSString*) dateFormat2String:(NSDate*)date withFormat: (NSString*) format
{
    NSDateFormatter * dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *dateStr=[dateFormatter stringFromDate:date];
    return  dateStr;
}

+(NSDate*) dateFromString:(NSString*)dateString dateFormat:(NSString *)dateFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:dateFormat];
    return [formatter dateFromString:dateString];
}

+(NSDate*) dateFromYMD:(int)year month:(int)month day:(int)day{
    NSString *str = [NSString stringWithFormat:@"%04d-%02d-%02d",year,month,day];
    return [NSDate dateFromString:str dateFormat:@"yyyy-MM-dd"];
}



+ (NSDate *)jsDateFromBeginDate:(NSDate *)beginDate todays:(int)days
{
    NSDate *dateTemp = [[NSDate alloc]init];
    NSTimeInterval interval = 24*60*60*days;
    dateTemp = [dateTemp initWithTimeInterval:interval sinceDate:beginDate];
    
    return dateTemp;
}

+ (NSDate *)jsDateFromBeginDate:(NSDate *)beginDate tomonths:(int)months
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:months];
    [comps setDay:0];
    return [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:beginDate  options:0];
}


+ (long long)currentTimeMillis {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec * 1000LL + tv.tv_usec / 1000;
}

- (NSString *)dateStringWithFormat:(NSString *)format {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:format];
    
    return [formatter stringFromDate:self];
}

@end

@implementation NSString (converter)
+(NSString*)fromInt:(int)value{
    return [NSString stringWithFormat:@"%d",value];
}
+(NSString*)fromFloat:(float)value{

    return [NSString stringWithFormat:@"%.2f",value];
}
+(NSString*)fromFloat:(float)value decimal:(int)decimal{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:decimal];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfDown];
    return [formatter stringFromNumber:[NSNumber numberWithFloat:value]];
}

+(NSString*)fromNumber:(NSNumber*)value decimal:(int)decimal{
    if ([self IsEmpty :value]) {
        return nil;
    }
   
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:decimal];
    //因为setRoundingMode方法显示不了小数点前的0，改成了numberStyle方法
//    [formatter setRoundingMode:NSNumberFormatterRoundHalfDown];
    formatter.numberStyle=kCFNumberFormatterRoundFloor;
    
    if ([value doubleValue]<1.0&&[value doubleValue]>-1) {
        return [NSString stringWithFormat:@"%@", [formatter stringFromNumber:value]];
    }
    return [formatter stringFromNumber:value];
}
+ (BOOL) IsEmpty:(id )thing
{
    return thing == nil
    || ([thing isEqual:[NSNull null]]) //JS addition for coredata
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}
+(NSString*)fromObject:(id)value{
    return [self fromObject:value decimal:2];
}
+(NSString*)fromObject:(id)value decimal:(int)decimal{
    if(value == nil || value == [NSNull null]){
        return nil;
    }
    if([value isKindOfClass:NSString.class]){
        return (NSString *)value;
    }else if([value isKindOfClass:NSNumber.class]){
        NSNumber *number = (NSNumber*)value;
        float intv = number.intValue;
        float floatv = number.floatValue;
        if(intv == floatv){
            return [self fromInt:number.intValue];
        }else{
            return [self fromNumber:number decimal:decimal];
        }
    }else{
        return [NSString stringWithFormat:@"%@",value];
    }
}

@end

