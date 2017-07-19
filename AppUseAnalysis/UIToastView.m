//
//  UIToastView.m
//  MTNOS_SH
//
//  Created by c0ming on 13-6-5.
//  Copyright (c) 2013年 c0ming. All rights reserved.
//

#import "UIToastView.h"

#import <QuartzCore/QuartzCore.h>

@implementation UIToastView

//- (id)initWithFrame:(CGRect)frame
//{
//    return [self initWithTitle:@""];
//}

#define PADDING  10.0
#define MIN_WIDTH  72.0
#define MAX_WIDTH  250.0
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height > 568.0f)
- (id)initWithTitle:(NSString *)title {
    
    CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:15]];
    int width = size.width + PADDING * 2;
    if (width > MAX_WIDTH) {
        width = MAX_WIDTH;
    } else if (width < MIN_WIDTH) {
        width = MIN_WIDTH;
    }
    int height = size.height + PADDING * 2;
    
    int y = ([UIScreen mainScreen].bounds.size.height-64)*2/3;//IS_IPHONE_5 ? 480 : 392;
    int x = ([[UIScreen mainScreen] bounds].size.width - width) / 2;
    
    self = [super initWithFrame:CGRectMake(x, y, width, height)];
    if (self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.layer.cornerRadius = 5.0;
            self.layer.borderWidth = 1.0;
            self.layer.borderColor = [UIColor darkGrayColor].CGColor;
            self.clipsToBounds = YES;
            
            [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.9]];
            [self setTextColor:[UIColor whiteColor]];
            [self setText:title];
            [self setFont:[UIFont systemFontOfSize:15]];
            [self setTextAlignment:NSTextAlignmentCenter];
        });
    }
    return self;
}

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        
        [UIView animateWithDuration:1.2 animations:^{
            self.alpha = 0.9;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.8 animations:^{
                self.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
        }];
    });
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
