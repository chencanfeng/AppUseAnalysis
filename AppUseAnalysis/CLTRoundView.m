//
//  CLTRoundView.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/11.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//


#import "CLTRoundView.h"

#import "AppChartInfoViewController.h"

//把角度转换成PI的方式
#define degreesToRadians(x) (M_PI*(x)/180.0)


static CGFloat  lineWidth = 18.f;   // 线宽


static int  num = 12;   // 显示的个数



@interface CLTRoundView ()

@property (nonatomic,strong) CAShapeLayer *bottomShapeLayer; // 外圆的底层layer
@property (nonatomic,strong)CAShapeLayer *upperShapeLayer;  // 外圆的更新的layer
@property (nonatomic,strong)CAGradientLayer *gradientLayer;  // 外圆的颜色渐变layer


@property (nonatomic,assign)CGFloat startAngle;  // 开始的弧度
@property (nonatomic,assign)CGFloat endAngle;  // 结束的弧度
@property (nonatomic,assign)CGFloat radius; // 开始角度


@property (nonatomic,assign)CGFloat centerX;  // 中心点 x
@property (nonatomic,assign)CGFloat centerY;  // 中心点 y
@property (nonatomic,assign)CGPoint centers;  // 中心点

@property (nonatomic,strong)UILabel *progressView;  //  进度文字


@property (nonatomic,strong)CALayer *needleLayer;  //指针

@property(nonatomic) CGFloat currentRadian; //当前角度

@end

@implementation CLTRoundView


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self  drawLayers];
        
    }
    
    return self;
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        
        [self drawLayers];
        
    }
    return self;
}




- (void)drawRect:(CGRect)rect
{
    //指针
    CABasicAnimation *bas2= [CABasicAnimation animationWithKeyPath:@"transform"];
    bas2.duration=.5f;
    bas2.speed = 1.f;
    bas2.fromValue=[NSValue valueWithCATransform3D:CATransform3DMakeRotation(-M_PI_2, 0, 0, 1)];
    bas2.toValue=[NSValue valueWithCATransform3D:CATransform3DMakeRotation(self.currentRadian, 0, 0, 1)];
    [_needleLayer addAnimation:bas2 forKey:@"bas2"];
}


- (void)drawLayers
{
   self.backgroundColor = [UIColor clearColor];
    
    _startAngle = - M_PI;  // 启始角度
    _endAngle = 0;  // 结束角度
    
    _centerX = self.frame.size.width / 2;  // 控制圆盘的X轴坐标
    _centerY = self.frame.size.height - 4 ; // 控制圆盘的Y轴坐标
    _centers = CGPointMake(_centerX, _centerY);
    
    _radius = 120.f;  // 内圆的角度
    
    [self drawBottomLayer];  // 绘制底部灰色填充layer
    [self drawUpperLayer]; // 绘制底部进度显示 layer
    [self drawGradientLayer];  // 绘制颜色渐变 layer
    [_bottomShapeLayer addSublayer:_gradientLayer]; // 将进度渐变layer 添加到 底部layer 上
    [_gradientLayer setMask:_upperShapeLayer]; // 设置进度layer 颜色 渐变
    
    [self.layer addSublayer:_bottomShapeLayer];  // 添加到底层的layer 上
    
    int index = 0;
    self.currentRadian = M_PI/12 * index + (-M_PI_2);// 默认位置为12
    
    //用户体验时延
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64, 18)];
    label.center = CGPointMake(_centerX - 8, _centerY - 40);
    label.text = @"用户体验时延";
    label.textColor = [UIColor whiteColor]; //[UIColor colorWithRed:0.145 green:0.392 blue:0.525 alpha:1.00];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13.f];
    [label sizeToFit];
    [self addSubview:label];
    
    //秒数
    _progressView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 18)];
    _progressView.center = CGPointMake(_centerX,_centerY - 25);
    _progressView.font = [UIFont systemFontOfSize:12];
    _progressView.textAlignment = NSTextAlignmentCenter;
    _progressView.textColor = [UIColor whiteColor];
    _progressView.text = @"0s";
    [self addSubview:_progressView];

    
    // 指针
    CALayer *needleLayer = [CALayer layer];
    needleLayer.anchorPoint = CGPointMake(0.5, 1155/1300.f);
    needleLayer.position = _centers;
    needleLayer.bounds = CGRectMake(0, 0, 26, _radius);
    needleLayer.contents = (id)[UIImage imageNamed:@"zhizhen"].CGImage;
    [self.layer addSublayer:needleLayer];
    needleLayer.transform = CATransform3DMakeRotation(self.currentRadian, 0, 0, 1);
    _needleLayer = needleLayer;
    
    
}




#pragma mark - 底部刻度的layer
// 绘制底部的layer
- (CAShapeLayer *)drawBottomLayer
{

    _bottomShapeLayer = [[CAShapeLayer alloc] init];
    _bottomShapeLayer.frame = self.bounds;
    
    CGFloat perAngle = M_PI / (4*num);
    
    //我们需要计算出每段弧线的起始角度和结束角度
    for (int i = 0; i< 4*num + 1; i++) {
        
        CGFloat startAngel = (_startAngle + perAngle * i);
        CGFloat endAngel   = startAngel + perAngle/2;
        
        UIBezierPath *tickPath = [UIBezierPath bezierPathWithArcCenter:_centers radius:_radius startAngle:startAngel endAngle:endAngel clockwise:YES];
        CAShapeLayer *perLayer = [CAShapeLayer layer];
        
        if (i % 4 == 0) {
            
            CGPoint point      = [self calculateTextPositonWithArcCenter:_centers Radius:_radius - 12 Angle:fabs(endAngel)];
            
            UIView *pView = [[UIView alloc] initWithFrame:CGRectMake(point.x - 1, point.y + 2, 2, 2)];
            pView.backgroundColor = [UIColor whiteColor];
            pView.layer.cornerRadius = 1.f;
            pView.layer.masksToBounds = YES;
            [self addSubview:pView];
            
            point      = [self calculateTextPositonWithArcCenter:_centers Radius:_radius - 25 Angle:fabs(endAngel)];
            
            NSString *tickText = [NSString stringWithFormat:@"%ds",(int)(i * 0.25)];
            
            UILabel *text      = [[UILabel alloc] initWithFrame:CGRectMake(point.x - 12, point.y -7, 22, 14)];
            UIFont *font = [UIFont systemFontOfSize:12.f];
            text.text          = tickText;
            text.font          = font;
            text.textColor     = [UIColor whiteColor];
            text.textAlignment = NSTextAlignmentCenter;
            [self addSubview:text];
        }
        
        perLayer.strokeColor = [UIColor colorWithRed:0.894 green:0.894 blue:0.894 alpha:0.50].CGColor;
        perLayer.lineWidth   = lineWidth;
        
        perLayer.path = tickPath.CGPath;
        [_bottomShapeLayer addSublayer:perLayer];
    }
    
    return _bottomShapeLayer;
    
}


// 绘制进度的layer
- (CAShapeLayer *)drawUpperLayer
{
    _upperShapeLayer                 = [[CAShapeLayer alloc] init];
    _upperShapeLayer.frame           = self.bounds;
    
    CGFloat perAngle = M_PI / (4*num);
    
    //我们需要计算出每段弧线的起始角度和结束角度
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i< (4 * num) + 1; i++) {
        
        CGFloat startAngel = (_startAngle + perAngle * i);
        CGFloat endAngel   = startAngel + perAngle/2;
        
        UIBezierPath *tickPath = [UIBezierPath bezierPathWithArcCenter:_centers radius:_radius startAngle:startAngel endAngle:endAngel clockwise:YES];
        
        
        [path appendPath:tickPath];
        
    }
    _upperShapeLayer.lineWidth = lineWidth;
    _upperShapeLayer.path = path.CGPath;
    
    _upperShapeLayer.strokeStart = 0;
    _upperShapeLayer.strokeEnd =   0;
    
    _upperShapeLayer.strokeColor     = [UIColor redColor].CGColor;
    _upperShapeLayer.fillColor       = [UIColor clearColor].CGColor;

    return _upperShapeLayer;
}

//  绘制渐变色的layer
- (CAGradientLayer *)drawGradientLayer
{
    NSMutableArray *colors1 = [NSMutableArray arrayWithObjects:
                              (id)[UIColor colorWithRed:0.514 green:0.976 blue:0.522 alpha:1.00].CGColor,
                              (id)[UIColor colorWithRed:0.514 green:0.976 blue:0.522 alpha:1.00].CGColor,nil];
    NSMutableArray *colors2 = [NSMutableArray arrayWithObjects:
                              (id)[UIColor colorWithRed:0.996 green:0.745 blue:0.804 alpha:1.00].CGColor,
                              (id)[UIColor colorWithRed:0.996 green:0.745 blue:0.804 alpha:1.00].CGColor,nil];
    
    
    CGFloat length = _radius * cos((4 *5-1) * M_PI / (4*num)) ; //第五格前是绿色
    
    CAGradientLayer *layer1 = [CAGradientLayer layer];
    layer1.frame = CGRectMake(0, 0, self.bounds.size.width/2.f - length, self.bounds.size.height);
    layer1.startPoint = CGPointMake(0, 0);
    layer1.endPoint = CGPointMake(0, 0);
    [layer1 setColors:colors1];
    
    CAGradientLayer *layer2 = [CAGradientLayer layer];
    layer2.frame = CGRectMake(self.bounds.size.width/2.f - length, 0, self.bounds.size.width/2.f + length, self.bounds.size.height);
    layer2.startPoint = CGPointMake(1,0);
    layer2.endPoint = CGPointMake(1, 1);
    [layer2 setColors:colors2];

    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.frame = self.bounds;
    [_gradientLayer addSublayer:layer1];
    [_gradientLayer addSublayer:layer2];
    
    return _gradientLayer;
}

#pragma mark - 以半径计算Label和点相对中心点的位置
- (CGPoint)calculateTextPositonWithArcCenter:(CGPoint)center
                                      Radius:(CGFloat)raduis
                                       Angle:(CGFloat)angel
{
    CGFloat x = raduis * cosf(angel);
    CGFloat y = raduis * sinf(angel);
    
    return CGPointMake(center.x + x, center.y - y);
}



@synthesize ratio = _ratio;
- (double )ratio
{
    return _ratio;
}
- (void)setRatio:(double)ratio
{
    _ratio = ratio;
    
    if (ratio > num) {
        ratio = num;
    }else if (ratio < 0){
        ratio = 0;
    }
    
    self.progressView.text = [NSString stringWithFormat:@"%.2fs",ratio];
    
    [self performSelector:@selector(shapeChange) withObject:nil afterDelay:0];
}

- (void)shapeChange
{
    
    // 复原
    [CATransaction begin];
    [CATransaction setDisableActions:NO];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [CATransaction setAnimationDuration:0];
    _upperShapeLayer.strokeEnd = 0 ;
    [CATransaction commit];
    
    [CATransaction begin];
    [CATransaction setDisableActions:NO];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [CATransaction setAnimationDuration:.5f];
    _upperShapeLayer.strokeEnd = self.ratio/12.f;;
    [CATransaction commit];
    
    self.currentRadian = M_PI/12 * self.ratio + (-M_PI_2);
    [self setNeedsDisplay];
    // 指针动画
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _needleLayer.transform = CATransform3DMakeRotation(self.currentRadian, 0, 0, 1);
    [CATransaction commit];
    
    
}




@end
