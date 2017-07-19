//
//  UIImage+Bundle.m
//  NetRecord_Comm
//
//  Created by renwanqian on 14-3-25.
//  Copyright (c) 2014年 cn.mastercom. All rights reserved.
//

#import "UIImage+Bundle.h"

@implementation UIImage (UIImage_Bundle)

+ (UIImage *)imageNamed:(NSString *)name bundle:(NSBundle *)bundle{
    if(bundle == nil){
        return [UIImage imageNamed:name];
    }

    NSString* extensiton = [name pathExtension];
    if (extensiton) {
        name = [name stringByDeletingPathExtension];
    }else{
        extensiton = @"png";
    }
    NSString *imagePath = [bundle pathForResource:[name stringByAppendingString:@"@2x"] ofType:extensiton];
    if(imagePath == nil){
        imagePath = [bundle pathForResource:name ofType:@"png"];
        if(imagePath == nil){
            return [UIImage imageNamed:name];
        }

    }
    
    return [[UIImage alloc]initWithContentsOfFile:imagePath];
}

+ (UIImage *)imageNamed:(NSString *)name bundleName:(NSString *)bundleName{
    NSBundle *bundle = nil;
    if(bundleName){
        NSURL *url = [[NSBundle mainBundle] URLForResource:bundleName withExtension:@"bundle"];
        if(url){
            bundle = [NSBundle bundleWithURL:url];
        }
    }
    
    
    return [self imageNamed:name bundle:bundle];
}

@end

