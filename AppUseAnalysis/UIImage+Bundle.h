//
//  UIImage+Bundle.h
//  NetRecord_Comm
//
//  Created by renwanqian on 14-3-25.
//  Copyright (c) 2014年 cn.mastercom. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (UIImage_Bundle)
+ (UIImage *)imageNamed:(NSString *)name bundle:(NSBundle *)bundle;
+ (UIImage *)imageNamed:(NSString *)name bundleName:(NSString *)bundleName;
@end


@interface UIImage (fixOrientation)

- (UIImage *)fixOrientation;

@end



@implementation UIImage (fixOrientation)

- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end

@interface UIImage(thumbNail)

-(UIImage*)getThumbnailScaleWithSize:(CGSize)size;

@end

@implementation UIImage (thumbNail)

//获取和传入size相同宽高比的缩略图
-(UIImage *)getThumbnailScaleWithSize:(CGSize)size{
    CGSize imgSize = self.size;
    CGFloat width = imgSize.height* size.width /size.height;
    if (width < imgSize.width) {
        size = CGSizeMake(width, imgSize.height);
    }else{
        size = CGSizeMake(imgSize.width, imgSize.width* size.height/ size.width);
    }
    
    UIGraphicsBeginImageContext(size);
    
    [self drawInRect:CGRectMake((size.width-imgSize.width)/2.0, (size.height- imgSize.height)/2.0, imgSize.width, imgSize.height)];
    
    UIImage* thumb = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return thumb;
}

@end

