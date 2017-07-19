//
//  CLTLineView.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/11.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CLTLineView.h"

#import "AppChartInfoViewController.h"

@interface CLTLineView ()

@property (nonatomic,assign)CGFloat bounceX;  // 原点 x
@property (nonatomic,assign)CGFloat bounceY;  // 原点 y




@property (nonatomic, strong) CAShapeLayer *lineChartLayer;

/** 渐变背景视图 */
@property (nonatomic, strong) UIView *gradientBackgroundView;
/** 渐变图层 */
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
/** 颜色数组 */
@property (nonatomic, strong) NSMutableArray *gradientLayerColors;


@end

@implementation CLTLineView


- (void)drawRect:(CGRect)rect {
    // Drawing code
}




- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _bounceX = 30.f;
        _bounceY = 20.f;
        _datasX = @[@"9",@"10",@"11",@"12",@"13",@"14",@"15"];
        _datasY = @[@"12",@"20",@"90",@"76",@"12",@"12",@"56"];
        
//        [self createTitleLabel];
        
        [self createLabelX];
        [self createLabelY];
        [self dravLine];
    }
    return self;
}

- (void)createTitleLabel {
    //用户小时活跃趋势
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64, 18)];
    label.center = CGPointMake(self.bounds.size.width/2.f, 20.f);
    label.text = @"用户小时活跃趋势";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12.f];
    [label sizeToFit];
    [self addSubview:label];
    
}

#pragma mark 创建x轴的数据
- (void)createLabelX{
    CGFloat  num = [_datasX count];
    for (NSInteger i = 0; i < num; i++) {
        UILabel * xLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.frame.size.width - 2*_bounceX)/num * i + 2*_bounceX, self.frame.size.height - _bounceY + _bounceY*0.5 , (self.frame.size.width - 2*_bounceX)/num, _bounceY/2)];
        xLabel.tag = 1000 + i;
        xLabel.text = [NSString stringWithFormat:@"%@",_datasX[i]];
        xLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:xLabel];
    }
    
}
#pragma mark 创建y轴数据
- (void)createLabelY{
    CGFloat yStep = 5;
    for (NSInteger i = 0; i <= yStep; i++) {
        //yLabel
        UILabel * yLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (self.frame.size.height - 2 * _bounceY)/yStep *i + _bounceY, _bounceX*0.8, _bounceY/2.0)];
        yLabel.tag = 2000 + i;
        yLabel.text = [NSString stringWithFormat:@"%.0f",(yStep - i)*20];
        yLabel.font = [UIFont systemFontOfSize:10];
        yLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:yLabel];
        
        //*******画出坐标轴********
        CAShapeLayer * dashLayer = [CAShapeLayer layer];
        UIBezierPath * path = [[UIBezierPath alloc]init];
        
        [path moveToPoint:CGPointMake( _bounceX, yLabel.center.y)];
        [path addLineToPoint:CGPointMake(self.frame.size.width - _bounceX,yLabel.center.y)];
    
        dashLayer.path = path.CGPath;
        dashLayer.lineCap = kCALineCapButt;
        dashLayer.strokeColor = [UIColor colorWithRed:0.886 green:0.894 blue:0.898 alpha:1.00].CGColor;
        dashLayer.fillColor = [[UIColor clearColor] CGColor];
        dashLayer.lineWidth = 1.0;
        
        if(i < yStep) {
           dashLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:3],[NSNumber numberWithInt:5], nil];
        }
        
        [self.layer addSublayer:dashLayer];
    }
}


#pragma mark 画折线图
- (void)dravLine{
    
    
    UIBezierPath * path = [[UIBezierPath alloc]init];
    path.lineWidth = 1.0;
    
    
    
    //创建折现点标记
    for (NSInteger i = 0; i< [_datasY count]; i++) {
        
        UILabel * label1 = (UILabel*)[self viewWithTag:1000 + i];
        CGFloat  arc = [_datasY[i] floatValue];
        if(i == 0) {
            [path moveToPoint:CGPointMake( label1.frame.origin.x , (self.frame.size.height - _bounceY*2 )*(100 - arc) /100.f  + _bounceX+ _bounceY/4.f)];
        }else {
           [path addLineToPoint:CGPointMake(label1.frame.origin.x,  (self.frame.size.height - _bounceY*2 )*(100 - arc) /100.f + _bounceX + _bounceY/4.f)];
        }
        
    }

    
    self.lineChartLayer = [CAShapeLayer layer];
    self.lineChartLayer.path = path.CGPath;
    self.lineChartLayer.strokeColor = [UIColor colorWithRed:0.349 green:0.714 blue:0.976 alpha:1.00].CGColor;
    self.lineChartLayer.fillColor = [[UIColor clearColor] CGColor];
    self.lineChartLayer.lineWidth = 1;
    self.lineChartLayer.lineCap = kCALineCapRound;
    self.lineChartLayer.lineJoin = kCALineJoinRound;
    
    [self.layer addSublayer:self.lineChartLayer];//直接添加导视图上
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1;
    pathAnimation.repeatCount = 1;
    pathAnimation.removedOnCompletion = YES;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    // 设置动画代理，动画结束时添加一个标签，显示折线终点的信息
    pathAnimation.delegate = self;
    [self.lineChartLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
}

#pragma mark 点击重新绘制折线和背景
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    
    AppChartInfoViewController *vc = [[AppChartInfoViewController alloc] init];
    vc.navTitle = @"用户活跃量分析";
    vc.funcName = @"用户活跃量分析";
    vc.model = @[
                 @{@"title":@"趋势分析",
                   @"url":@"/gdmt/analysis/UserActivityOfTime.mt",
                   @"urlParams":@{@"granularity":@"天",@"beginTime":@"",@"endTime":@""},
                   @"drillMore":@"NO"},
                 @{@"title":@"地市分析",
                   @"url":@"/gdmt/analysis/UserActivityOfCity.mt",
                   @"urlParams":@{@"granularity":@"天",@"beginTime":@"",@"endTime":@""},
                   @"drillMore":@"YES"}
                 ];
    
    [[self viewController].navigationController pushViewController:vc animated:YES];
    
    
    
    
    
}

- (UIViewController*) viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}





@end
