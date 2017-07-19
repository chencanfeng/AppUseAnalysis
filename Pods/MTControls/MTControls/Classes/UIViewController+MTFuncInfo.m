//
//  UIViewController(MTFuncInfo).m
//  MTControls
//
//  Created by song mj on 16/9/27.
//  Copyright © 2016年 mastercom. All rights reserved.
//

#import "UIViewController+MTFuncInfo.h"
#import <objc/runtime.h>

static NSString* const kFuncItemInfo = @"kFuncItemInfo";

@implementation UIViewController (MTFuncInfo)


- (void) setFucItemInfo:(NSDictionary *)funcItemInfo {
     objc_setAssociatedObject(self, (__bridge const void *)(kFuncItemInfo), funcItemInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *) funcItemInfo{
    return (NSDictionary*) objc_getAssociatedObject(self, (__bridge const void *)(kFuncItemInfo));
}

@end
