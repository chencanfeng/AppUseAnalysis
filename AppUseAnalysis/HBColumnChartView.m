//
//  HBColumnChartView.m
//  柱形图
//
//  Created by MasterCom on 2017/5/15.
//  Copyright © 2017年 MasterCom. All rights reserved.
//

#import "HBColumnChartView.h"


@implementation HBColumnChartView


- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        _paddingH = 10;
        _drawDuration = 1;
        _yLabelW = 20;
        _xLabelH = 20;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];

    // 几列
    NSUInteger col = [_xTitleDatas count];
    // 几行
    NSUInteger row = [_yTitleDatas count];
    
    //y轴标签宽度
    CGFloat yLabelW = _yLabelW;
    //x轴标签高度
    CGFloat xLabelH = _xLabelH;
    
    //渐变条宽度占比(这个由传入数据决定)
    CGFloat colummWScale =  (rect.size.width - 2 * yLabelW)/(_xMaxScaleValues);
    
    //渐变条高度
    CGFloat colummH =  (rect.size.height - _paddingH *(row - 1) - xLabelH)/row;

    //x轴标签的X坐标
    CGFloat xLabelX = rect.size.width/(col + 1);

    //x轴标签的宽度
    CGFloat xLabelW = rect.size.width/(col + 1);
    
    //x轴标签的高度
    CGFloat xLabelY = rect.size.height - xLabelH;
    
    //绘制x轴
    UIView *xlineView = [[UIView alloc]initWithFrame:CGRectMake(yLabelW, rect.size.height - xLabelH, rect.size.width - yLabelW, 1)];
    xlineView.backgroundColor = [UIColor colorWithRed:0.886 green:0.894 blue:0.898 alpha:1.00];
    [self addSubview:xlineView];
    
    //绘制y轴
    UIView *ylineView = [[UIView alloc]initWithFrame:CGRectMake(yLabelW, 0, 1, rect.size.height - xLabelH)];
    ylineView.backgroundColor = [UIColor colorWithRed:0.886 green:0.894 blue:0.898 alpha:1.00];
    [self addSubview:ylineView];
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    static CGFloat dashedPattern[] = {4,2};
    //绘制X/Y轴标签,渐变线,辅助虚线
    for (int colIndex = 0; colIndex < col; colIndex ++)
    {
        //x轴label
        UILabel *xLabel = [[UILabel alloc]initWithFrame:CGRectMake(xLabelX + xLabelX * colIndex, xLabelY, xLabelW, xLabelH)];
        xLabel.text = [NSString stringWithFormat:@"%@",_xTitleDatas[colIndex]];
        xLabel.textColor = [UIColor lightGrayColor];
        xLabel.textAlignment = NSTextAlignmentCenter;
        xLabel.font = [UIFont systemFontOfSize:8];
        [self addSubview:xLabel];
        
        
        // 绘制虚线
//        UIView *xuxianView = [[UIView alloc]initWithFrame:CGRectMake(xLabel.center.x, 0, 1, rect.size.height - xLabelH)];
//        [self addSubview:xuxianView];
//        [self drawDashLine:xuxianView lineLength:4 lineSpacing:2 lineColor:[UIColor colorWithRed:0.886 green:0.894 blue:0.898 alpha:1.00]];
        
        // 画虚线
        
        CGContextSetLineDash(c, 0, dashedPattern, 2);
        CGContextMoveToPoint(c, xLabel.center.x, 0);
        CGContextAddLineToPoint(c, xLabel.center.x, rect.size.height - xLabelH);
        CGContextSetStrokeColorWithColor(c,[UIColor colorWithRed:0.886 green:0.894 blue:0.898 alpha:1.00].CGColor);
        CGContextStrokePath(c);
        
        

        for (int rowIndex = 0; rowIndex < row; rowIndex ++)
        {
            //y轴label
            UILabel *yLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (colummH + _paddingH) * rowIndex, yLabelW, colummH)];
            yLabel.text = [NSString stringWithFormat:@"%@",_yTitleDatas[rowIndex]];
            yLabel.textColor = [UIColor lightGrayColor];
            yLabel.textAlignment = NSTextAlignmentCenter;
            yLabel.font = [UIFont systemFontOfSize:10];
            [self addSubview:yLabel];
            
           //走一次就行了
            if (colIndex == 0)
            {
                //绘制柱形图
                CAShapeLayer *shapeLayer= [CAShapeLayer layer];
                shapeLayer.fillColor = [UIColor clearColor].CGColor;
                shapeLayer.lineWidth= colummH;
                UIColor *color = [UIColor colorWithHexString:_colorDatas[rowIndex][0]];
                shapeLayer.strokeColor = color.CGColor;
                
                UIBezierPath*circlePath = [UIBezierPath bezierPath];
                [circlePath moveToPoint:CGPointMake(yLabelW,(colummH + _paddingH) * rowIndex + colummH/2)];
                
                //宽度另行设置
                [circlePath addLineToPoint:CGPointMake(yLabelW + [_titleValues[rowIndex] intValue] * colummWScale,(colummH + _paddingH) * rowIndex + colummH/2)];
                
                shapeLayer.path = circlePath.CGPath;
//                [self.layer addSublayer:shapeLayer];
                //渐变图层
                CAGradientLayer *gradientLayer = [CAGradientLayer layer];
                gradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
                gradientLayer.colors = @[(__bridge id)color.CGColor,(__bridge id)[UIColor colorWithWhite:1 alpha:0.1].CGColor];
                
                gradientLayer.locations=@[@0.0];
                gradientLayer.startPoint = CGPointMake(0,0);
                gradientLayer.endPoint = CGPointMake(1,0.5);
                
                UIBezierPath *gradientPath = [[UIBezierPath alloc] init];
                [gradientPath moveToPoint:CGPointMake(yLabelW,(colummH + _paddingH) * rowIndex + colummH/2)];
                
                [gradientPath addLineToPoint:CGPointMake(yLabelW + [_titleValues[rowIndex] intValue] * colummWScale,(colummH + _paddingH) * rowIndex + colummH/2)];
                
                
//                CAShapeLayer *arc = [CAShapeLayer layer];
//                arc.path = gradientPath.CGPath;
                gradientLayer.mask = shapeLayer;
                [self.layer addSublayer:gradientLayer];
                

                //提交动画
                CABasicAnimation*pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
                pathAnimation.duration = _drawDuration;
                pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                pathAnimation.fromValue = @0.0f;
                pathAnimation.toValue = @(1);
                [shapeLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
 
                //绘制标题说明
                if([_titleDatas count] > 0 && [_titleDatas count] > rowIndex)
                {
                    UILabel *columnTitleLabel = [[UILabel alloc]init];
                    [self addSubview:columnTitleLabel];
                    columnTitleLabel.font = [UIFont systemFontOfSize:12.0];
                    columnTitleLabel.text = _titleDatas[rowIndex];
                    
                    
                    CGSize size = [columnTitleLabel.text sizeWithFont:columnTitleLabel.font constrainedToSize:CGSizeMake(rect.size.width - 2 * yLabelW, colummH)];
                    
                    //因判断渐变线是否足够显示label, 否则移到渐变线后面显示
                    CGFloat columnTitleLabelW = size.width;
                    
                    columnTitleLabel.textAlignment = NSTextAlignmentLeft;
                    
                    if(([_titleValues[rowIndex] intValue] * colummWScale) + 2 >= columnTitleLabelW)
                    {
                        //NSLog(@"%@够宽",_titleDatas[rowIndex]);
                        columnTitleLabel.frame = CGRectMake(yLabelW + 2, yLabel.frame.origin.y, ([_titleValues[rowIndex] intValue] * colummWScale), colummH);
                        columnTitleLabel.textColor = [UIColor whiteColor];
                    }
                    else
                    {
                        //NSLog(@"%@已坠毁",_titleDatas[rowIndex]);
                        columnTitleLabel.frame = CGRectMake(yLabelW + 2 , yLabel.frame.origin.y, columnTitleLabelW, colummH);
                        
                        columnTitleLabel.textColor = [UIColor darkGrayColor];
                    }
                }
            }
        }
    }
}



/**
 绘制虚线
 @param lineView 需要绘制成虚线的view
 @param lineLength  虚线的宽度
 @param lineSpacing 虚线的间距
 @param lineColor 虚线的颜色
 */
- (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];

    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame), CGRectGetHeight(lineView.frame) / 2)];

    
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    
    //  设置虚线宽度
    //[shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    [shapeLayer setLineWidth:1.0];

    [shapeLayer setLineJoin:kCALineJoinRound];
    
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, CGRectGetMinY(lineView.frame));
    CGPathAddLineToPoint(path, NULL, 0, CGRectGetMaxY(lineView.frame));
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
}

@end
