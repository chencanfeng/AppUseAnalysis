//
//  CHLineChartView.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHLineChartView.h"
#import "CHInfoView.h"


@interface LineChartDataItem ()

@property (readwrite) float x; // should be within the x range
@property (readwrite) float y; // should be within the y range
@property (readwrite) NSString *xLabel; // label to be shown on the x axis
@property (readwrite) NSString *dataLabel; // label to be shown directly at the data item

- (id)initWithhX:(float)x y:(float)y xLabel:(NSString *)xLabel dataLabel:(NSString *)dataLabel;

@end

@implementation LineChartDataItem



- (id)initWithhX:(float)x y:(float)y xLabel:(NSString *)xLabel dataLabel:(NSString *)dataLabel {
    if((self = [super init])) {
        self.x = x;
        self.y = y;
        self.xLabel = xLabel;
        self.dataLabel = dataLabel;
    }
    return self;
}

+ (LineChartDataItem *)dataItemWithX:(float)x y:(float)y xLabel:(NSString *)xLabel dataLabel:(NSString *)dataLabel {
    
    return [[LineChartDataItem alloc] initWithhX:x y:y xLabel:xLabel dataLabel:dataLabel];
    
}

@end



@implementation LineChartData

@end



@interface CHLineChartView () {
    
}

@property CHLegendView *legendView;
@property CHInfoView   *infoView;
@property UIView     *currentPosView;
@property UILabel    *xAxisLabel;



@end




@implementation CHLineChartView
{
    NSMutableArray* columnChartArr;
    CGPoint currentPos;
    CGFloat errerHeight;
}
@synthesize data=_data;
@synthesize X_AXIS_SPACE,PADDING,TOPEXTRAPADDING;

- (id)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        

        columnChartArr=[[NSMutableArray alloc] init];
        self.currentPosView = [[UIView alloc] init];
        self.currentPosView.backgroundColor = [UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:1.0];
        self.currentPosView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.currentPosView.alpha = 0.0;
        [self addSubview:self.currentPosView];
        
        self.legendView = [[CHLegendView alloc] init];
        self.legendView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.legendView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.legendView];
        self.legendView.delegate = self;
        
        self.xAxisLabel = [[UILabel alloc] init];
        self.xAxisLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.xAxisLabel.font = [UIFont boldSystemFontOfSize:10];
        self.xAxisLabel.textColor = [UIColor grayColor];
        self.xAxisLabel.textAlignment = NSTextAlignmentCenter;
        self.xAxisLabel.alpha = 0.0;
        self.xAxisLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.xAxisLabel];
        
        self.backgroundColor = [UIColor whiteColor];
        self.scaleFont = [UIFont systemFontOfSize:8.0];
        
        self.autoresizesSubviews = YES;
        self.contentMode = UIViewContentModeRedraw;
        
        self.drawsDataPoints = YES;
        self.drawsDataLines  = YES;
        self.showXLabel=YES;
        
        self.X_AXIS_SPACE = 15;
        self.PADDING = 10;
        self.TOPEXTRAPADDING=20;
        
        self.showLegend = YES;
        self.enableTouch = NO;
        
        self.ySteps = [[NSArray alloc] init];
        
        
        self.xAxisHorizontalMaxValue = 8 ;
    }
    return self;
}


- (void)setData:(NSArray *)data {
    
    LineChartData * lineData = data[0];
    if (lineData.itemCount >= self.xAxisHorizontalMaxValue) {
        errerHeight = 20;
    }
    else {
        errerHeight = 0;
    }
    
    NSUInteger count = self.ySteps.count-1;
    if(count<=0){
        count = 5;
    }
    
    if (self.yMin==0&&self.dataMin!=0 && self.yMax!=self.dataMin) {
        float step=  fabsf(self.dataMin/(self.yMax- self.dataMin));
        
        CGFloat everyStep=(self.yMax-self.yMin)/count;
        if (step>=10&&everyStep>10) {
            everyStep=[self roundStep:(self.yMax-self.dataMin)/count jump:YES];
            self.yMin=floor(self.dataMin/everyStep)*everyStep;
        }
    }
    
    self.ySteps = [self makeYSteps:count yMax:self.yMax yMin:self.yMin];
    
    
    if(data != _data) {
        NSMutableArray *titles = [NSMutableArray arrayWithCapacity:[data count]];
        NSMutableDictionary *colors = [NSMutableDictionary dictionaryWithCapacity:[data count]];
        NSMutableDictionary *chartTypes = [NSMutableDictionary dictionaryWithCapacity:[data count]];
        for(LineChartData *dat in data) {
            [titles addObject:dat.title];
            [colors setObject:dat.color forKey:dat.title];
            if (dat.chartType==Line) {
                [chartTypes setObject:@"Line" forKey:dat.title];
            }
            else if (dat.chartType==Column){
                [chartTypes setObject:@"Column" forKey:dat.title];
            }
            else if (dat.chartType==Bessel){
                [chartTypes setObject:@"Bessel" forKey:dat.title];
            }
            else{
                dat.chartType=Column;
            }
            if (dat.chartType==Column) {
                [columnChartArr addObject:dat];
            }
        }
        self.legendView.titles = titles;
        self.legendView.colors = colors;
        self.legendView.chartTypes = chartTypes;
        self.legendView.xTitle=self.xTitle;
        
        _data = data;
        
        if(self.showLegend){
            
            [self.legendView sizeToFit];
        }
    }
}

#pragma mark 绘图
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    @try {

        
        
        if (self.title) {
            
            UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, CGRectGetWidth(self.frame), 20)];
            titleLab.text = self.title;
            titleLab.font = [UIFont systemFontOfSize:13];
            titleLab.textColor = [UIColor colorWithRed:0.541 green:0.537 blue:0.631 alpha:1.00];    
            titleLab.textAlignment = NSTextAlignmentCenter;
            [self addSubview:titleLab];
        }
        
        
        CGContextRef c = UIGraphicsGetCurrentContext();
        
        CGFloat availableHeight = self.bounds.size.height -  PADDING -TOPEXTRAPADDING - X_AXIS_SPACE - errerHeight -self.legendView.frame.size.height;
        
        CGFloat availableWidth = self.bounds.size.width - 2 * PADDING - self.yAxisLabelsWidth - 15;
        CGFloat xStart = PADDING + self.yAxisLabelsWidth;
        CGFloat yStart = PADDING + TOPEXTRAPADDING;
        
        static CGFloat dashedPattern[] = {4,2};
        
        // draw scale and horizontal lines
        CGFloat heightPerStep = self.ySteps == nil || [self.ySteps count] <= 1 ? availableHeight : (availableHeight / ([self.ySteps count] - 1));
        
        
        //y轴标注
        NSUInteger i = 0;
        CGContextSaveGState(c);
        CGContextSetLineWidth(c, 1.0);
        NSUInteger yCnt = [self.ySteps count];
        CGFloat h = [self.scaleFont lineHeight];
        
        NSMutableParagraphStyle* paraStyle = [[NSMutableParagraphStyle alloc] init];
        [paraStyle setAlignment:NSTextAlignmentRight];
        [paraStyle setLineBreakMode:NSLineBreakByWordWrapping];
        NSDictionary* dictitleFont = [NSDictionary dictionaryWithObjectsAndKeys:self.scaleFont, NSFontAttributeName, paraStyle,NSParagraphStyleAttributeName, [UIColor grayColor], NSForegroundColorAttributeName,nil];
        
        NSString * yLabel;
        BOOL isPureInt = YES;
        for (id step in _ySteps) {
            NSString* stepStr = [NSString stringWithFormat:@"%@",step];
            isPureInt = isPureInt && [self isPureInt:stepStr];
        }
        
        CGFloat miny,maxy;
        
        for(NSString *step in self.ySteps) {
            
            [[UIColor grayColor] set];
            if(isPureInt)
            {
                yLabel=[NSString stringWithFormat:@"%d",(int)[step integerValue]];
                
            }
            else
            {
                yLabel=[NSString stringWithFormat:@"%.2f",[step floatValue]];
            }
            
            CGFloat y = yStart + heightPerStep * (yCnt - 1 - i);
            
              //记录y最小值，最大值 为画X轴门限做准备
            if (i == 0) {
                miny = y;
            }
            if (i == self.ySteps.count -1) {
                maxy = y;
            }
            // y轴数值
            CGRect titleFrame = CGRectMake(PADDING, y - h / 2, self.yAxisLabelsWidth - 3, h);
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
                [yLabel drawInRect:titleFrame withAttributes:dictitleFont];
            }else{
                NSAttributedString *att_title = [[NSAttributedString alloc] initWithString:yLabel attributes:dictitleFont];
                [att_title drawInRect:titleFrame];
                
            }
            
            [[UIColor colorWithWhite:0.9 alpha:1.0] set];
            
            // 画虚线
            CGContextSetLineDash(c, 0, dashedPattern, 2);
            CGContextMoveToPoint(c, xStart, round(y) + 0.5);
            CGContextAddLineToPoint(c, self.bounds.size.width - PADDING, round(y) + 0.5);
            CGContextStrokePath(c);
            
            i++;
        }

        CGContextRestoreGState(c);
        
        
        
        
        CGFloat yRangeLen = self.ySteps==nil || [self.ySteps count] <= 1 ? 1: [[self.ySteps objectAtIndex:self.ySteps.count-1] floatValue] - self.yMin;
        
        // 添加横坐标标注
        if (self.showXLabel) {
            CGFloat xPos =  xStart;
            CGFloat yPos =  yStart;
            
            LineChartDataItem *closest = nil;
            float minDist = FLT_MAX;
            float minDistY = FLT_MAX;
            CGPoint closestPos = CGPointZero;
            
            NSMutableParagraphStyle* paraStyle2 = [[NSMutableParagraphStyle alloc] init];
            [paraStyle2 setAlignment:NSTextAlignmentLeft];
            [paraStyle2 setLineBreakMode:NSLineBreakByWordWrapping];
            NSDictionary * dicscaleFont = [NSDictionary dictionaryWithObjectsAndKeys:self.scaleFont, NSFontAttributeName, paraStyle2,NSParagraphStyleAttributeName, [UIColor grayColor], NSForegroundColorAttributeName,nil];
            
            
           
            
            
            for(LineChartData *data in self.data) {
                float xRangeLen = data.xMax - data.xMin;
                LineChartDataItem *datItem = data.getData(0);
                
                NSInteger i=0;
                while (i<data.itemCount) {
                    
                    LineChartDataItem * datItem = data.getData(i);
                    closest = datItem;
                    CGFloat xVal = round((xRangeLen == 0 ? 0.5 : ((datItem.x - data.xMin) / xRangeLen)) * availableWidth);
                    
                    CGFloat yVal = round((1.0 - (datItem.y - self.yMin) / yRangeLen) * availableHeight);
                    
                    float dist = fabsf((float)(xVal - xPos));
                    float distY = fabsf((float)(yVal - yPos));
                    
                    if(dist < minDist || (dist == minDist && distY < minDistY)) {
                        minDist = dist;
                        minDistY = distY;
                        closest = datItem;
                        closestPos = CGPointMake(xStart + xVal, yStart + yVal);
                    }
                    
                    
                    if(closest.xLabel != nil) {
                        self.xAxisLabel.text = closest.xLabel;
                        [self.xAxisLabel sizeToFit];
                        [[UIColor grayColor] set];
                        
                        CGRect r = self.xAxisLabel.frame;
                        
                        CGRect titleFrame = CGRectMake(xStart + xVal-r.size.width/2  ,self.bounds.size.height-self.legendView.frame.size.height-PADDING - errerHeight, r.size.width, r.size.height);
                        
                        
                        //横坐标竖排--begin-add
                        if (data.itemCount>=self.xAxisHorizontalMaxValue && self.xAxisHorizontalMaxValue!=0) {
                            
                            titleFrame = CGRectMake(xStart + xVal-r.size.height/2 ,  self.bounds.size.height-self.legendView.frame.size.height-PADDING -errerHeight, r.size.width, r.size.height);
                            
                            float tempwidth=titleFrame.size.width;
                            float tempheigth=titleFrame.size.height;
                            
                            CGRect r = self.legendView.frame;
                            if(titleFrame.origin.y + titleFrame.size.width >= r.origin.y+ PADDING+12) {
                                CGRect temptitleFrame =CGRectMake(titleFrame.origin.x,titleFrame.origin.y,tempheigth*2.2f ,tempwidth);
                                titleFrame=temptitleFrame;
                            }else {
                                CGRect temptitleFrame =CGRectMake(titleFrame.origin.x,titleFrame.origin.y,tempheigth* 0.9f,tempwidth + 5);
                                titleFrame=temptitleFrame;
                            }
                            
                        }
                        //--end-add
                        
                        if((_intervalTime != 0 && i%_intervalTime == _intervalTime - 1) || _intervalTime == 0) {
                            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
                                [closest.xLabel drawInRect:titleFrame withAttributes:dicscaleFont];
                            }else{
                                NSAttributedString *att_title = [[NSAttributedString alloc] initWithString:closest.xLabel attributes:dicscaleFont];
                                [att_title drawInRect:titleFrame];
                                
                            }
                        }
                        
                        
                        //控制横坐标过长间隔显示
                        if (self.bounds.size.width>data.itemCount*titleFrame.size.width || _intervalTime != 0) {
                            i=i+1;
                        }
                        else
                        {
                            CGFloat per=data.itemCount*titleFrame.size.width/self.bounds.size.width;
                            
                            i=i+ceilf(per);
                        }
                    }
                }
            }
            
        }
        
        //若横坐标竖排，调整self.legendView的位置
        if([self.data count]>0){
            LineChartData *data = [self.data objectAtIndex:0];
            if (data.itemCount>=self.xAxisHorizontalMaxValue && self.xAxisHorizontalMaxValue!=0) {
                CGRect r = self.legendView.frame;
                r.origin.y = r.origin.y+ PADDING+12;
                
                if(self.showLegend){
                    self.legendView.frame = r;
                }else{
                    self.legendView.frame = CGRectMake(0, 0, 0, 0);
                }
            }
        }
        //画点、线、柱子
        for(int lineIndex=0;lineIndex < self.data.count;lineIndex++){
            LineChartData *data = [self.data objectAtIndex:lineIndex];
            //准备各个显示点的位置
            NSMutableArray *pointsArr = [[NSMutableArray alloc] init];
            for(int i=0;i<data.itemCount;i++){
                LineChartDataItem *datItem = data.getData(i);
                float xRangeLen = data.xMax - data.xMin;
                CGFloat xVal = xStart + round((xRangeLen == 0 ? 0.5 : ((datItem.x - data.xMin) / xRangeLen)) * availableWidth);
                
                CGFloat yVal = 0;
                yVal = yStart + round(yRangeLen==0 ? 0 : ((1.0 - (datItem.y - self.yMin) / yRangeLen) * availableHeight));
                [pointsArr addObject:[NSValue valueWithCGPoint:CGPointMake(xVal, yVal)]];
            }
            //对于贝塞尔曲线，首先算出各点最近的控制点与当前点的位置增量
            NSMutableArray *deltaArray = nil;
            if(1){
                deltaArray = [[NSMutableArray alloc] init];
                if (pointsArr.count < 3) {
                }
                else{
                    for(int i=0;i<pointsArr.count;i++){
                        NSValue *ptValue = [pointsArr objectAtIndex:i];
                        CGFloat deltax = 0;
                        CGFloat deltay = 0;
                        if(i==0){
                            NSValue *ptNextValue = [pointsArr objectAtIndex:i+1];
                            deltax = ([ptNextValue CGPointValue].x - [ptValue CGPointValue].x)/5;
                            deltay = ([ptNextValue CGPointValue].y - [ptValue CGPointValue].y)/5;
                        }else if(i==pointsArr.count-1){
                            NSValue *ptPrevValue = [pointsArr objectAtIndex:i-1];
                            deltax = ([ptValue CGPointValue].x - [ptPrevValue CGPointValue].x)/5;
                            deltay = ([ptValue CGPointValue].y - [ptPrevValue CGPointValue].y)/5;
                        }else{
                            NSValue *ptNextValue = [pointsArr objectAtIndex:i+1];
                            NSValue *ptPrevValue = [pointsArr objectAtIndex:i-1];
                            deltax = ([ptNextValue CGPointValue].x - [ptPrevValue CGPointValue].x)/5;
                            deltay = ([ptNextValue CGPointValue].y - [ptPrevValue CGPointValue].y)/5;
                        }
                        
                        [deltaArray addObject:[NSValue valueWithCGPoint:CGPointMake(deltax, deltay)]];
                    }
                }
            }
            
            if (self.drawsDataLines) {
                
                //开始画
                if(data.itemCount >= 2) {
                    if (data.chartType==Line || data.chartType==Bessel) {
                        

                        //创建你贝塞尔路径
                        NSUInteger starti;
                        BOOL isSetStarti = NO;
                        
                        NSMutableArray * layers = [[NSMutableArray alloc] init];
                        NSMutableArray * paths = [[NSMutableArray alloc] init];
                        int layerIndex = 0 ;//第几条线
                        for(NSUInteger i = 0; i < data.itemCount; ++i) {
                            
                            //数据中间有隔断，一条折线分成多条
                            NSValue *ptValue = [pointsArr objectAtIndex:i];
                            CGFloat x = [ptValue CGPointValue].x;
                            CGFloat y = [ptValue CGPointValue].y;
                            CGFloat value = data.getData(i).y;
                            if (value < 0) {
                                if (isSetStarti) { //已经开始画了 中断
                                    isSetStarti = NO;
                                    layerIndex ++;
                                }
                                else continue;
                            }
                            else {//
                                
                                if (!isSetStarti) { //开始画一条新的线
                                    isSetStarti = YES;
                                    CAShapeLayer *layer = [CAShapeLayer layer];
                                    layer.fillColor = [UIColor clearColor].CGColor;
                                    layer.lineWidth =  1.0f;
                                    layer.lineCap = kCALineCapRound;
                                    layer.lineJoin = kCALineJoinRound;
                                    layer.strokeColor = [data.color CGColor];
                                    [self.layer addSublayer:layer];
                                    
                                    UIBezierPath * path = [UIBezierPath bezierPath];
                                    [path moveToPoint:CGPointMake(x, y)];
                                    [layers addObject:layer];
                                    [paths addObject:path];
                                    
                                }
                                else{
                                    UIBezierPath * path = paths[layerIndex];
                                    [path addLineToPoint:CGPointMake(x, y)];
                                }
                                
                                
                                
                                
                            }
                            //特殊数据画垂直虚线
                            if(i == _specialRow && [_specialData count] >0) {
                                
                                // 画虚线
                                CGContextSetLineDash(c, 0, dashedPattern, 2);
                                CGContextMoveToPoint(c, x, y);
                                CGContextAddLineToPoint(c, x, availableHeight+yStart);
                                CGContextSetStrokeColorWithColor(c,[data.color CGColor]);
                                CGContextStrokePath(c);
                                
                                //画label
                                NSString *str = [_specialData[1] stringValue];
                                CGRect  lastyStrR = CGRectMake(x -4 , y - 14, 30, 10);
                                NSMutableParagraphStyle* paraStyle2 = [[NSMutableParagraphStyle alloc] init];
                                [paraStyle2 setAlignment:NSTextAlignmentLeft];
                                [paraStyle2 setLineBreakMode:NSLineBreakByWordWrapping];
                                NSDictionary* dicscaleFont = [NSDictionary dictionaryWithObjectsAndKeys:self.scaleFont, NSFontAttributeName, paraStyle2,NSParagraphStyleAttributeName, data.color, NSForegroundColorAttributeName,nil];
                                if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
                                    [str drawInRect:lastyStrR withAttributes:dicscaleFont];
                                }else{
                                    NSAttributedString *att_title = [[NSAttributedString alloc] initWithString:str attributes:dicscaleFont];
                                    [att_title drawInRect:lastyStrR];
                                }
                                
                            }
                            
                        }
                        
                        
                        for(int i = 0 ; i< [layers count];i++)
                        {
                            CAShapeLayer *layer = layers[i];
                            UIBezierPath *path = paths[i];
                            layer.path = path.CGPath;
                            layer.strokeEnd = 1;
                        }
                        
                        if(_specialData == nil) {
                            for(int i = 0 ; i< [layers count];i++)
                            {
                                CAShapeLayer *layer = layers[i];
                                //创建Animation
                                CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
                                animation.fromValue = @(0.0);
                                animation.toValue = @(1.0);
                                layer.autoreverses = NO;
                                animation.duration = 2.0;
                                [layer addAnimation:animation forKey:nil];
                            }
                        }
                        
                        //渐变图层
                        if(self.showGradientLayer) {
                            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
                            gradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
                            gradientLayer.colors = @[(__bridge id)data.color.CGColor,(__bridge id)[UIColor colorWithWhite:1 alpha:0.1].CGColor];
                            
                            gradientLayer.locations=@[@0.0,@0.8];
                            gradientLayer.startPoint = CGPointMake(0,0);
                            gradientLayer.endPoint = CGPointMake(0,1);
                            
                            UIBezierPath *gradientPath = [[UIBezierPath alloc] init];
                            [gradientPath moveToPoint:CGPointMake([pointsArr[0] CGPointValue].x, yStart + heightPerStep * (yCnt - 1))];
                            
                            for (int i = 0; i < pointsArr.count; i ++) {
                                [gradientPath addLineToPoint:[pointsArr[i] CGPointValue]];
                            }
                            
                            CGPoint endPoint = [[pointsArr lastObject] CGPointValue];
                            endPoint = CGPointMake(endPoint.x, yStart + heightPerStep * (yCnt - 1));
                            [gradientPath addLineToPoint:endPoint];
                            CAShapeLayer *arc = [CAShapeLayer layer];
                            arc.path = gradientPath.CGPath;
                            gradientLayer.mask = arc;
                            [self.layer addSublayer:gradientLayer]; 
                        }
                        
 
                    }
                    else if(data.chartType==Column){
                        //柱状图
                        CGFloat columnWidth=[self getColumnWidth:data];
                        
                        for(NSUInteger i = 0; i < data.itemCount; ++i) {
                            
                            //创建layer
                            CAShapeLayer *layer = [CAShapeLayer layer];
                            layer.fillColor = [UIColor clearColor].CGColor;
                            layer.lineWidth =  columnWidth;
                            layer.lineCap = kCALineCapButt;
                            layer.strokeColor = [data.color CGColor];
                            [self.layer insertSublayer:layer atIndex:0];
                            
                            //创建你贝塞尔路径
                            UIBezierPath * path = [UIBezierPath bezierPath];
                            
                            //CGMutablePathRef path = CGPathCreateMutable();
                            NSValue *ptValue = [pointsArr objectAtIndex:i];
                            //2016-06-21 hqf 这里柱状图与下面文字有偏差，调整了下(去掉-columnWidth)
                            CGFloat x = [ptValue CGPointValue].x+columnWidth*lineIndex;//-columnWidth;
                            CGFloat y = [ptValue CGPointValue].y;
                            
                            [path moveToPoint:CGPointMake(x, availableHeight+yStart)];
                            [path addLineToPoint:CGPointMake(x, y)];
                            
                            //关联layer和贝塞尔路径
                            layer.path = path.CGPath;
                            [path closePath];
                            //创建Animation
                            CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
                            animation.fromValue = @(0.0);
                            animation.toValue = @(1.0);
                            layer.autoreverses = NO;
                            animation.duration = 1.0;
                            
                            //设置layer的animation
                            [layer addAnimation:animation forKey:nil];
                            layer.strokeEnd = 1;
                            
                        }
                    }
                }
            }
            
            // 画线中的小圆圈
            if (self.drawsDataPoints&&(data.chartType==Line || data.chartType==Bessel)) {
                
                // 取出最低的y值
                CGFloat minY = 0;
                for (int i = 0; i < pointsArr.count; i++) {
                    NSValue * ptValue = [pointsArr objectAtIndex:i];
                    CGFloat tempY = [ptValue CGPointValue].y;
                    if (tempY > minY) {
                        minY = tempY;
                    }
                }
                
                for(NSUInteger i = 0; i < data.itemCount; ++i) {
                    
                    if (data.getData(i).y < 0) continue;
                    if((_intervalTime != 0 && i%_intervalTime == _intervalTime -1) || _intervalTime == 0) {
                        
                        NSValue *ptValue = [pointsArr objectAtIndex:i];
                        CGFloat x = [ptValue CGPointValue].x;
                        CGFloat y = [ptValue CGPointValue].y;
                        
                        
                        CGFloat diameter = self.drawsDataPointsDiameter;
                        if (diameter == 0) {
                            diameter = 4.0;//默认值
                        }
                        
                        CAShapeLayer * layer = [CAShapeLayer layer];
                        layer.frame = CGRectMake(0, 0, diameter, diameter);
                        layer.position = CGPointMake(x, minY);
                        if (self.drawsDataPointsType == 1 ) {
                            layer.fillColor = [data.color CGColor];
                        }
                        else {
                            layer.fillColor = [UIColor whiteColor].CGColor;
                        }
                        
                        
                        layer.lineWidth = 1.0f;
                        
                        layer.strokeColor = [data.color CGColor];
                        UIBezierPath * circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, diameter, diameter)];
                        
                        layer.path = circlePath.CGPath;
                        
                        [self.layer addSublayer:layer];
                        
                        
                        if(_specialData == nil) {
                            //基础动画
                            CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
                            //位移大小
                            CGFloat distance = (minY - y) * -1;
                            animation.toValue = @(distance);
                            
                            animation.duration = 0.5;
                            animation.autoreverses = NO;
                            animation.repeatCount = 0;
                            animation.fillMode = kCAFillModeForwards;
                            animation.removedOnCompletion = NO;
                            
                            //添加动画
                            [layer addAnimation:animation forKey:nil];
                        }else {
                            layer.position = CGPointMake(x, y);
                        } 
                        
                    }
                }
            }
            
            
            
            
            
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"图：%@",exception);
    }
    @finally {
        
    }
}

#pragma mark - 布局
- (void)showLegend:(BOOL)show animated:(BOOL)animated {
    self.showLegend = !show;
    
    if(! animated) {
        self.legendView.alpha = show ? 1.0 : 0.0;
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.legendView.alpha = show ? 1.0 : 0.0;
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self relocateSubViews];
}

- (void)relocateSubViews{
    
    CGRect r = self.legendView.frame;
    r.origin.x = 0;
    r.origin.y = self.bounds.size.height-(([self.data count]+1)/2*12 +12+ PADDING);
    r.size = CGSizeMake(self.bounds.size.width, ([self.data count]+1)/2*12 + 12+ PADDING);
    if(self.showLegend){
        self.legendView.frame = r;
    }else{
        self.legendView.frame = CGRectMake(0, 0, 0, 0);
    }
    
    self.currentPosView.frame = CGRectMake(currentPos.x, PADDING + TOPEXTRAPADDING, 1 / self.contentScaleFactor, self.bounds.size.height -   PADDING - TOPEXTRAPADDING - X_AXIS_SPACE-self.legendView.frame.size.height);
    
    [self.xAxisLabel sizeToFit];
    r.origin.x = currentPos.x;
    r.origin.y = self.bounds.size.height-self.legendView.frame.size.height-PADDING - TOPEXTRAPADDING;
    self.xAxisLabel.frame = r;
    
    [self.infoView sizeToFit];
    r = self.infoView.frame;
    r.origin.x = currentPos.x - self.infoView.frame.size.width/2;
    r.origin.y = currentPos.y - self.infoView.frame.size.height;
    self.infoView.frame = r;
    
    [self.infoView setNeedsLayout];
    [self.infoView setNeedsDisplay];
    [self.legendView setNeedsDisplay];
    
    [self bringSubviewToFront:self.legendView];
    
}





#pragma mark - InfoView
- (void)showIndicatorForTouch:(UITouch *)touch {
    if(! self.infoView) {
        self.infoView = [[CHInfoView alloc] init];
        [self addSubview:self.infoView];
    }
    
    CGPoint pos = [touch locationInView:self];
    CGFloat xStart = PADDING + self.yAxisLabelsWidth;
    CGFloat yStart = PADDING + TOPEXTRAPADDING;
    CGFloat yRangeLen = (self.yMax - self.yMin)==0?1:self.yMax - self.yMin;
    CGFloat xPos = pos.x - xStart;
    CGFloat yPos = pos.y - yStart;
    CGFloat availableWidth = self.bounds.size.width - 2 * PADDING - self.yAxisLabelsWidth - 15;
    CGFloat availableHeight = self.bounds.size.height -  PADDING -TOPEXTRAPADDING - X_AXIS_SPACE-self.legendView.frame.size.height;//self.bounds.size.height  - X_AXIS_SPACE  - 2-([self.data count]+1)/2*12;
    
    LineChartDataItem *closest = nil;
    float minDist = FLT_MAX;
    float minDistY = FLT_MAX;
    CGPoint closestPos = CGPointZero;
    
    for(LineChartData *data in self.data) {
        float xRangeLen = data.xMax - data.xMin;
        for(NSUInteger i = 0; i < data.itemCount; ++i) {
            LineChartDataItem *datItem = data.getData(i);
            CGFloat xVal = round((xRangeLen == 0 ? 0.5 : ((datItem.x - data.xMin) / xRangeLen)) * availableWidth)-10;
            CGFloat yVal = round((1.0 - (datItem.y - self.yMin) / yRangeLen) * availableHeight);
            
            float dist = fabsf((float)(xVal - xPos));
            float distY = fabsf((float)(yVal - yPos));
            
            
            if(dist < minDist || (dist == minDist && distY < minDistY)) {
                minDist = dist;
                minDistY = distY;
                closest = datItem;
                closestPos = CGPointMake(xStart + xVal, yStart + yVal);
                
                currentPos = closestPos;
            }
        }
    }
    
    self.infoView.infoLabel.text =[NSString stringWithFormat:@"%.2f",[closest.dataLabel floatValue]];
    
    
    [UIView animateWithDuration:0.1 animations:^{
        self.infoView.alpha = 1.0;
        self.currentPosView.alpha = 1.0;
        if (!self.showXLabel) {
            self.xAxisLabel.alpha = 1.0;
        }
        
        [self relocateSubViews];
        
    }];
}



- (void)hideIndicator {
    [UIView animateWithDuration:0.1 animations:^{
        self.infoView.alpha = 0.0;
        self.currentPosView.alpha = 0.0;
        self.xAxisLabel.alpha = 0.0;
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.enableTouch){
        [self showIndicatorForTouch:[touches anyObject]];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.enableTouch){
        [self showIndicatorForTouch:[touches anyObject]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self hideIndicator];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self hideIndicator];
}



#pragma mark Helper methods

- (CGFloat)yAxisLabelsWidth {
    float width=20.0f;
    NSString *label ;
    
    BOOL isPureInt = YES;
    for (id step in _ySteps) {
        NSString* stepStr = [NSString stringWithFormat:@"%@",step];
        isPureInt = isPureInt && [self isPureInt:stepStr];
    }
    
    for (id obj in  self.ySteps) {
        
        if(!isPureInt){
            label=[NSString stringWithFormat:@"%.2f",[obj floatValue]];
        }
        else{
            label=[NSString stringWithFormat:@"%ld",(long)[obj integerValue]];
        }
        
        CGSize labelSize = [label sizeWithAttributeFont:self.scaleFont];
        // CGSize labelSize = [label sizeWithFont:self.scaleFont];
        if (labelSize.width>width) {
            width=labelSize.width;
        }
    }
    return width + 3;
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    if([scan scanInt:&val] && [scan isAtEnd]){
        return YES;
    }
    float fval;
    if([scan scanFloat:&fval] && [scan isAtEnd] && fval==0){
        return YES;
    }
    return NO;
}

//判断是否为浮点形：

- (BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

-(CGFloat) getColumnWidth :(LineChartData *)data{
    
    NSUInteger columnChartCount=[columnChartArr count];
    CGFloat availableWidth = self.bounds.size.width - 2 * PADDING - self.yAxisLabelsWidth - 15;
    
    float xRangeLen = data.xMax - data.xMin;
    if(columnChartCount*xRangeLen*14<=availableWidth)
    {
        return 12.0f;
    }
    else{
        return (availableWidth-columnChartCount*xRangeLen*2)/(columnChartCount*xRangeLen);
    }
    return 0.0f;
}

#pragma mark 单个步进值
-(CGFloat)roundStep:(CGFloat)everyStep jump:(BOOL)jump{
    
    
    int digit = 0;
    if (everyStep>10) {
        while(digit<4 && everyStep>10){
            everyStep /= 10;
            digit ++;
        }
    }else{
        while(digit>-4 && everyStep<1){
            everyStep *= 10;
            digit --;
        }
    }
    if(jump){
        if(everyStep==1){
            everyStep = 1;
        }else if(everyStep>1 && everyStep<=2){
            everyStep = 2;
        }else if(everyStep>2 && everyStep<=5){
            everyStep = 5;
        }else if(everyStep>5 && everyStep<=10){
            everyStep = 10;
        }
    }else{
        everyStep = ceil(everyStep);
    }
    everyStep *= pow(10,digit);
    
    return everyStep;
}

#pragma mark 一组步进值
-(NSArray*) makeYSteps:(NSUInteger)count yMax:(CGFloat)yMax yMin:(CGFloat)yMin
{
    if(count==0){
        count=5;
    }
    NSMutableArray * newSteps=[[NSMutableArray alloc] init];
    [newSteps addObject:@(yMin)];
    CGFloat everyStep = [self roundStep:(yMax-yMin)/count jump:NO];
    
    if (everyStep>0) {
        
        for (NSInteger i=0; i<count; i++) {
            if (everyStep>10) {
                NSUInteger stepLen=[NSString stringWithFormat:@"%d",(int)everyStep].length;//位数
                NSInteger step= (NSInteger)(yMin/powf(10, stepLen-1)*powf(10, stepLen-1))+everyStep*(i+1);
                
                if ([newSteps containsObject:@(step)]) {
                    continue;
                }
                [newSteps addObject:@(step)];
            }
            else
            {
                
                NSString* step=[NSString stringWithFormat:@"%.2f", yMin+everyStep*(i+1)];
                if ([newSteps containsObject:step]) {
                    continue;
                }
                [newSteps addObject:step];
            }
        }
        
        
        
    }
    if (newSteps.count==1&&everyStep>10) {
        [newSteps addObject:@([[newSteps objectAtIndex:0] integerValue]+1)];
    }
    else  if(newSteps.count==1&&everyStep<=10)
    {
        [newSteps addObject:@([[newSteps objectAtIndex:0] floatValue]+1)];
    }
    return newSteps;
}





@end
