//
//  ArrowDirectionView.m
//  UICommon
//
//  Created by jianke on 14-12-17.
//  Copyright (c) 2014年 YN. All rights reserved.
//

#import "ArrowDirectionView.h"
#define ARROW_HEIGHT 6.0
#define  PADDING   3.0
@implementation ArrowDirectionView
-(id) init
{
    self=[super init];
    if (self) {
        self.arrowDirection=ArrowDirectionUp;
        
        self.backgroundColor = [UIColor clearColor];
        
        _contentBgColor=[UIColor whiteColor];
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(PADDING, PADDING, self.frame.size.width - PADDING*2, self.frame.size.height-PADDING*2-ARROW_HEIGHT)];
        _contentView.translatesAutoresizingMaskIntoConstraints=NO;
        [self addSubview:_contentView];

    }
    return self;
}
-(id) initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        self.arrowDirection=ArrowDirectionUp;
        _contentBgColor=[UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(PADDING, PADDING, self.frame.size.width - PADDING*2, frame.size.height-PADDING*2-ARROW_HEIGHT)];
        
        _contentView.translatesAutoresizingMaskIntoConstraints=NO;
        [self addSubview:_contentView];
    }
 
    return self;
    
}

- (UIView *)contentView {
    return _contentView;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if ( _arrowDirection==0) {
         _arrowDirection=ArrowDirectionUp;
    }
    if (_contentView==nil) {
       
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(PADDING, PADDING, rect.size.width - PADDING*2, rect.size.height-PADDING*2-ARROW_HEIGHT)];
        _contentView.backgroundColor = _contentBgColor;
        _contentView.translatesAutoresizingMaskIntoConstraints=NO;
        [self addSubview:_contentView];
        
    }
    CGFloat top=PADDING;
     CGFloat bottom=PADDING;
     CGFloat left=PADDING;
     CGFloat right=PADDING;
    switch (_arrowDirection) {
        case ArrowDirectionUp:
            top=PADDING+ARROW_HEIGHT;
            [self drawUp];
            break;
        case ArrowDirectionBottom:
            bottom=PADDING+ARROW_HEIGHT;
            [self drawBottom];
            break;
        case ArrowDirectionRight:
            right=PADDING+ARROW_HEIGHT;
            [self drawRight];
            break;
        case ArrowDirectionLeft:
            [self drawLeft];
              left=PADDING+ARROW_HEIGHT;
            break;
        default:
            break;
    }
    
    if (self.constraints) {
        [self removeConstraints:self.constraints];
    }
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[_contentView]-%f-|",left,right ]options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[_contentView]-%f-|",top,bottom ] options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentView)]];
    
    
    self.layer.shadowColor = [[UIColor colorWithRed:36.0f/255.0f green:173.0f/255.0f blue:222.0f/255.0f alpha:1] CGColor];
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}
/**
 *  箭头朝上
 */
-(void) drawUp
{ 
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.0);
    [[_contentBgColor colorWithAlphaComponent:1.0] setFill];
    
    CGFloat radius = 6.0;
    
    CGRect frame = self.bounds;
    
    if (self.arrowPosition<=12) {
        self.arrowPosition=CGRectGetMidX(frame);
    }
    
    CGFloat minx = CGRectGetMinX(frame);
    CGFloat arrowX = self.arrowPosition;
    CGFloat maxx = CGRectGetMaxX(frame);
    CGFloat miny = CGRectGetMinY(frame)+ARROW_HEIGHT;
    CGFloat maxy = CGRectGetMaxY(frame);
    
    CGContextMoveToPoint(context, arrowX, miny);
    CGContextAddLineToPoint(context,arrowX+ARROW_HEIGHT, miny - ARROW_HEIGHT);
    CGContextAddLineToPoint(context,arrowX +2* ARROW_HEIGHT, miny);
    
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, minx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, minx, radius);
    CGContextAddArcToPoint(context, minx, miny, arrowX, miny, radius);
    
    
    CGContextClosePath(context);
    
    CGContextFillPath(context);
    
  
 
}
/**
 *  箭头朝下
 */
-(void) drawBottom
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.0);
    [[ _contentBgColor colorWithAlphaComponent:1.0] setFill];
    
    CGFloat radius = 6.0;
    
    CGRect frame = self.bounds;
    if (self.arrowPosition<=12) {
        self.arrowPosition=CGRectGetMidX(frame);
    }
    
    CGFloat minx = CGRectGetMinX(frame);
    
    CGFloat arrowX = self.arrowPosition;
    CGFloat maxx = CGRectGetMaxX(frame);
    CGFloat miny = CGRectGetMinY(frame);
    CGFloat maxy = CGRectGetMaxY(frame) - ARROW_HEIGHT;
    
    CGContextMoveToPoint(context, arrowX +2* ARROW_HEIGHT, maxy);
    CGContextAddLineToPoint(context,arrowX+ARROW_HEIGHT, maxy + ARROW_HEIGHT);
    CGContextAddLineToPoint(context,arrowX, maxy);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, arrowX+ARROW_HEIGHT, maxy, radius);
    
    
    CGContextClosePath(context);
    
    CGContextFillPath(context);
}
/**
 *  箭头朝右
 */
-(void) drawRight
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.0);
    [[ _contentBgColor colorWithAlphaComponent:1.0] setFill];
    
    CGFloat radius = 6.0;
    
    CGRect frame = self.bounds;
    if (self.arrowPosition<=12) {
        self.arrowPosition=CGRectGetMidY(frame);
    }
    CGFloat minx = CGRectGetMinX(frame);
    CGFloat maxx = CGRectGetMaxX(frame)-ARROW_HEIGHT;
    CGFloat miny = CGRectGetMinY(frame);
    CGFloat arrowY = self.arrowPosition;
    CGFloat maxy = CGRectGetMaxY(frame) - ARROW_HEIGHT;
    CGContextMoveToPoint(context, maxx, arrowY);
    CGContextAddLineToPoint(context,maxx+ARROW_HEIGHT, arrowY+ARROW_HEIGHT);
    CGContextAddLineToPoint(context,maxx, arrowY+2*ARROW_HEIGHT);
    
    CGContextAddArcToPoint(context, maxx, maxy, minx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, minx, radius);
    CGContextAddArcToPoint(context, minx, miny, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, arrowY+ARROW_HEIGHT, radius);
    CGContextClosePath(context);
    
    CGContextFillPath(context);
    
}
/**
 *  箭头朝左
 */
-(void) drawLeft
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.0);
    [[ _contentBgColor colorWithAlphaComponent:1.0] setFill];
    
    CGFloat radius = 6.0;
    
    CGRect frame = self.bounds;
    if (self.arrowPosition<=12) {
        self.arrowPosition=CGRectGetMidY(frame);
    }
    CGFloat minx = CGRectGetMinX(frame)+ARROW_HEIGHT;
    CGFloat maxx = CGRectGetMaxX(frame);
    CGFloat miny = CGRectGetMinY(frame);
    CGFloat arrowY = self.arrowPosition;
    CGFloat maxy = CGRectGetMaxY(frame);
    CGContextMoveToPoint(context, minx, arrowY+2*ARROW_HEIGHT);
    CGContextAddLineToPoint(context,minx-ARROW_HEIGHT, arrowY+ARROW_HEIGHT);
    CGContextAddLineToPoint(context,minx, arrowY);
    
    CGContextAddArcToPoint(context, minx, miny, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, minx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, arrowY+ARROW_HEIGHT, radius);
    CGContextClosePath(context);
    
    CGContextFillPath(context);
    
}
@end
