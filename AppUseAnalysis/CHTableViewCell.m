//
//  CHTableViewCell.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHTableViewCell.h"


@implementation CHTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _frameLines = CHTableViewCellFrameLineBottom;
        _framelineColor = [UIColor lightGrayColor];
        _bgNormalColor = [UIColor clearColor];
        _bgSelectedColor = [UIColor colorWithHexString:@"0xf7f7f7"];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (selected && self.selectionStyle != UITableViewCellSelectionStyleNone) {
        self.backgroundColor = _bgSelectedColor;
    }else{
        self.backgroundColor = [UIColor clearColor];
    }
    [self setNeedsDisplay];

}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.backgroundColor = _bgSelectedColor;
    }else{
        self.backgroundColor = [UIColor clearColor];
    }
    [self setNeedsDisplay];
}

// 自绘边框
- (void)drawRect:(CGRect)rect
{
    @try {
        
        if(_frameLines == 0){
           return;
        }
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, _bgNormalColor.CGColor);
        CGContextFillRect(context, rect);
        
        CGContextSetLineWidth(context,0.5);
        
        //上边框
        if((self.frameLines & CHTableViewCellFrameLineTop) == CHTableViewCellFrameLineTop){
            if(self.topLineColor){
                CGContextSetStrokeColorWithColor(context, self.topLineColor.CGColor);
            }else{
                CGContextSetStrokeColorWithColor(context, self.framelineColor.CGColor);
            }
            CGPoint points[2];
            points[0]=CGPointMake(0,0);
            points[1]=CGPointMake(rect.size.width,0);
            
            CGContextStrokeLineSegments(context,points, 2);
        }
        
        //下边框
        if((self.frameLines & CHTableViewCellFrameLineBottom) == CHTableViewCellFrameLineBottom){
            if(self.bottomLineColor){
                CGContextSetStrokeColorWithColor(context, self.bottomLineColor.CGColor);
            }else{
                CGContextSetStrokeColorWithColor(context, self.framelineColor.CGColor);
            }
            CGPoint points[2];
            points[0]=CGPointMake(0,rect.size.height);
            points[1]=CGPointMake(rect.size.width,rect.size.height);
            CGContextStrokeLineSegments(context,points, 2);
        }
        
        //左边框
        if((self.frameLines & CHTableViewCellFrameLineLeft) == CHTableViewCellFrameLineLeft){
            if(self.leftLineColor){
                CGContextSetStrokeColorWithColor(context, self.leftLineColor.CGColor);
            }else{
                CGContextSetStrokeColorWithColor(context, self.framelineColor.CGColor);
            }
            CGPoint points[2];
            points[0]=CGPointMake(0,0);
            points[1]=CGPointMake(0,rect.size.height);
            CGContextStrokeLineSegments(context,points, 2);
        }
        
        //右边框
        if((self.frameLines & CHTableViewCellFrameLineRight) == CHTableViewCellFrameLineRight){
            if(self.rightLineColor){
                CGContextSetStrokeColorWithColor(context, self.rightLineColor.CGColor);
            }else{
                CGContextSetStrokeColorWithColor(context, self.framelineColor.CGColor);
            }
            CGPoint points[2];
            points[0]=CGPointMake(rect.size.width,0);
            points[1]=CGPointMake(rect.size.width,rect.size.height);
            CGContextStrokeLineSegments(context,points, 2);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"draw CHTableViewCell: %@",exception);
    }
    
}

@end
