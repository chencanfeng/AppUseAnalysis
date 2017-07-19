//
//  CLTBarView.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/11.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CLTBarView.h"

#import "GDUseAnalyzeController.h"

@interface CLTBarView ()

//@property (nonatomic , strong) CAShapeLayer * shapeLayer;

@property (nonatomic,assign)CGFloat bounceX;  // 原点 x
@property (nonatomic,assign)CGFloat bounceY;  // 原点 y

@property (nonatomic, strong) NSMutableArray *colorSource;

@property (nonatomic, assign) NSUInteger paddingH;

@end

@implementation CLTBarView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.





- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        
        self.backgroundColor = [UIColor clearColor];
        _paddingH = 15;
        
        
        
        _bounceX = 20.f;
        _bounceY = 20.f;
        
//        _datasY = @[@"135",@"120",@"110",@"82",@"78",@"70",@"56",@"50",@"40",@"30"];
        
        _colorSource = [@[
                          [UIColor colorWithRed:0.949 green:0.400 blue:0.584 alpha:1.00],
                          [UIColor colorWithRed:0.961 green:0.529 blue:0.522 alpha:1.00],
                          [UIColor colorWithRed:0.969 green:0.706 blue:0.431 alpha:1.00],
                          [UIColor colorWithRed:0.965 green:0.847 blue:0.518 alpha:1.00],
                          [UIColor colorWithRed:0.373 green:0.898 blue:0.875 alpha:1.00],
                          [UIColor colorWithRed:0.353 green:0.784 blue:0.694 alpha:1.00],
                          [UIColor colorWithRed:0.361 green:0.753 blue:0.988 alpha:1.00],
                          [UIColor colorWithRed:0.502 green:0.776 blue:0.976 alpha:1.00],
                          [UIColor colorWithRed:0.302 green:0.725 blue:0.843 alpha:1.00],
                          [UIColor colorWithRed:0.655 green:0.510 blue:0.808 alpha:1.00]
                          ] mutableCopy];
        
        
        
        
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    // 几列
    NSUInteger col = [_xTitleDatas count];
    // 几行
    NSUInteger row = [_yTitleDatas count];
    
    //y轴标签宽度
    CGFloat yLabelW = 20;
    //x轴标签高度
    CGFloat xLabelH = 20;
    
    //渐变条宽度占比(这个由传入数据决定)
    CGFloat colummWScale =  (rect.size.width - 2 * yLabelW)/(_xMaxScaleValues);
    
    //渐变条高度
    CGFloat colummH =  (rect.size.height - _paddingH *(row - 1) - xLabelH)/row;
    
    if (self.title) {
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, CGRectGetWidth(self.frame), 20)];
        titleLab.text = self.title;
        titleLab.font = [UIFont systemFontOfSize:13];
        titleLab.textColor = [UIColor colorWithRed:0.541 green:0.537 blue:0.631 alpha:1.00];
        titleLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLab];
    }
    
    
    //x轴坐标、垂直虚线
    for (NSInteger i = 0; i < col; i++) {
        CGFloat perWidth =  (self.frame.size.width - 2*_bounceX)/col;
        UILabel * xLabel = [[UILabel alloc]initWithFrame:CGRectMake(perWidth * i +_bounceX - 8, self.frame.size.height - _bounceY + _bounceY*0.5 , perWidth, _bounceY/2)];
        xLabel.tag = 1000 + i;
        xLabel.text = [NSString stringWithFormat:@"%@",_xTitleDatas[i]];
        xLabel.font = [UIFont systemFontOfSize:10];
        xLabel.textAlignment = NSTextAlignmentLeft;
        if(i > 0) {
            
            [self addSubview:xLabel];
            
        }
        
        //*******画出坐标轴********
        CAShapeLayer * dashLayer = [CAShapeLayer layer];
        UIBezierPath * path = [[UIBezierPath alloc]init];
        
        [path moveToPoint:CGPointMake( perWidth * i +_bounceX, _bounceY)];
        [path addLineToPoint:CGPointMake(perWidth * i +_bounceX,self.frame.size.height - _bounceY)];
        
        dashLayer.path = path.CGPath;
        dashLayer.lineCap = kCALineCapButt;
        dashLayer.strokeColor = [UIColor colorWithRed:0.886 green:0.894 blue:0.898 alpha:1.00].CGColor;
        dashLayer.fillColor = [[UIColor clearColor] CGColor];
        dashLayer.lineWidth = 1.0;
        
        if(i > 0) {
            dashLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:3],[NSNumber numberWithInt:5], nil];
        }
        
        [self.layer addSublayer:dashLayer];
        
        
    }
    
    
    
    //y轴 、 水平实线
    for (NSInteger i = 0; i < row; i++) {
        //yLabel
        CGFloat perHeight = (self.frame.size.height - 2 * _bounceY)/row;
        UILabel * yLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, perHeight *i + _bounceY, _bounceX*0.8, _bounceY/2.0)];
        yLabel.tag = 2000 + i;
        yLabel.text = [NSString stringWithFormat:@"%@",_yTitleDatas[i]];
        yLabel.font = [UIFont systemFontOfSize:10];
        yLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:yLabel];
        
        
        if(i == row -1) {
            //*******画出坐标轴********
            CAShapeLayer * dashLayer = [CAShapeLayer layer];
            UIBezierPath * path = [[UIBezierPath alloc]init];
            
            [path moveToPoint:CGPointMake( _bounceX, self.frame.size.height - _bounceY)];
            [path addLineToPoint:CGPointMake(self.frame.size.width - _bounceX,self.frame.size.height - _bounceY)];
            
            dashLayer.path = path.CGPath;
            dashLayer.lineCap = kCALineCapButt;
            dashLayer.strokeColor = [UIColor colorWithRed:0.886 green:0.894 blue:0.898 alpha:1.00].CGColor;
            dashLayer.fillColor = [[UIColor clearColor] CGColor];
            dashLayer.lineWidth = 1.0;
            
            [self.layer addSublayer:dashLayer];
            
        }
        
        //*******画出柱子********
        CAShapeLayer *shapeLayer= [CAShapeLayer layer];
        shapeLayer.fillColor= [UIColor clearColor].CGColor;
        shapeLayer.lineWidth= _bounceY/2.f;
        UIColor *color = _colorSource[i];
        shapeLayer.strokeColor= color.CGColor;
        
        UIBezierPath*circlePath = [UIBezierPath bezierPath];
        [circlePath moveToPoint:CGPointMake(_bounceX,yLabel.center.y)];
        [circlePath addLineToPoint:CGPointMake((self.frame.size.width - _bounceX)/_xMaxScaleValues * [_titleValues[i] doubleValue] - _bounceX,yLabel.center.y)];
        
        shapeLayer.path= circlePath.CGPath;
        [self.layer addSublayer:shapeLayer];
        
        CABasicAnimation*pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration=1.0f;
        pathAnimation.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAnimation.fromValue=@0.0f;
        pathAnimation.toValue=@(1);
        [shapeLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
        
        
    }
    
}



@end
