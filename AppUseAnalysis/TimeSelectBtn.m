//
//  TimeSelectBtn.m
//  GDWWNOP
//
//  Created by MasterCom on 2017/5/23.
//  Copyright © 2017年 cn.mastercom. All rights reserved.
//

#import "TimeSelectBtn.h"

@implementation TimeSelectBtn

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//- (CGRect)backgroundRectForBounds:(CGRect)bounds;
//- (CGRect)contentRectForBounds:(CGRect)bounds;

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGRect titleRect = contentRect;
    titleRect.origin.x = titleRect.size.height *0.5;
    titleRect.size.width -= (titleRect.size.height *1.5);
    return titleRect;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGRect imageRect = contentRect;
    imageRect.origin.x += (imageRect.size.width - imageRect.size.height);
    imageRect.origin.y += imageRect.size.height *1/4;
    imageRect.size.width = imageRect.size.height *0.5;
    imageRect.size.height = imageRect.size.height *0.5;
    return imageRect;
}

@end
