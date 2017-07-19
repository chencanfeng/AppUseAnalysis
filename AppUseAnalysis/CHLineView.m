//
//  CHLineView.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/16.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHLineView.h"

#import "AppChartInfoViewController.h"



@interface CHLineView ()
@property (nonatomic, strong)NSArray * legendColorArray;

@end

@implementation CHLineView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _showLegend = YES;
        _showGradientLayer = YES;
        _legendColorArray = [NSArray arrayWithObjects:
                             [UIColor colorWithRed:36.0f/255.0f green:173.0f/255.0f blue:222.0f/255.0f alpha:1],
                             [UIColor colorWithRed:186.0f/255.0f green:117.0f/255.0f blue:220.0f/255.0f alpha:1],
                             [UIColor colorWithRed:138.0f/255.0f green:189.0f/255.0f blue:0.0f/255.0f alpha:1],
                             [UIColor colorWithRed:255.0f/255.0f green:174.0f/255.0f blue:24.0f/255.0f alpha:1],
                             [UIColor colorWithRed:240.0f/255.0f green:49.0f/255.0f blue:49.0f/255.0f alpha:1],
                             [UIColor colorWithRed:211.0f/255.0f green:233.0f/255.0f blue:146.0f/255.0f alpha:1],
                             [UIColor colorWithRed:255.0f/255.0f green:227.0f/255.0f blue:160.0f/255.0f alpha:1],
                             [UIColor colorWithRed:255.0f/255.0f green:175.0f/255.0f blue:175.0f/255.0f alpha:1],
                             [UIColor colorWithRed:168.0f/255.0f green:223.0f/255.0f blue:244.0f/255.0f alpha:1],
                             [UIColor colorWithRed:221.0f/255.0f green:188.0f/255.0f blue:238.0f/255.0f alpha:1],
                             [UIColor colorWithRed:167.0f/255.0f green:25.0f/255.0f blue:75.0f/255.0f alpha:1],
                             [UIColor colorWithRed:237.0f/255.0f green:54.0f/255.0f blue:40.0f/255.0f alpha:1],
                             [UIColor colorWithRed:255.0f/255.0f green:148.0f/255.0f blue:0.0f/255.0f alpha:1],
                             [UIColor colorWithRed:255.0f/255.0f green:204.0f/255.0f blue:1.0f/255.0f alpha:1],
                             [UIColor colorWithRed:255.0f/255.0f green:254.0f/255.0f blue:52.0f/255.0f alpha:1],
                             [UIColor colorWithRed:55.0f/255.0f green:166.0f/255.0f blue:90.0f/255.0f alpha:1],
                             [UIColor colorWithRed:161.0f/255.0f green:192.0f/255.0f blue:77.0f/255.0f alpha:1],
                             [UIColor colorWithRed:30.0f/255.0f green:206.0f/255.0f blue:206.0f/255.0f alpha:1],
                             [UIColor colorWithRed:58.0f/255.0f green:130.0f/255.0f blue:201.0f/255.0f alpha:1],
                             [UIColor colorWithRed:87.0f/255.0f green:101.0f/255.0f blue:174.0f/255.0f alpha:1],
                             [UIColor colorWithRed:45.0f/255.0f green:75.0f/255.0f blue:230.0f/255.0f alpha:1],
                             [UIColor colorWithRed:62.0f/255.0f green:1.0f/255.0f blue:164.0f/255.0f alpha:1],
                             [UIColor redColor],[UIColor orangeColor],[UIColor yellowColor],[UIColor greenColor],
                             [UIColor purpleColor],[UIColor blueColor],[UIColor cyanColor],[UIColor magentaColor],
                             [UIColor yellowColor],[UIColor greenColor],[UIColor purpleColor],[UIColor blueColor],nil];
    }
    return self;
}

-(void)createLineChartViewWithFrame:(CGRect)frame type:(ChartType)type{
    CHLineChartView *chartView = [[CHLineChartView alloc] initWithFrame:frame];
    [self addSubview:chartView];
    NSMutableArray *alldata = [[NSMutableArray alloc] initWithCapacity:5];
    int xcount = (int)[_result count];
    
    NSMutableArray * localColumns = [[NSMutableArray alloc]initWithArray:_columns];
    //获得日期字段索引
    NSUInteger dateindex = 0;
    BOOL isSameHour = NO;
    
    NSMutableArray  *orderedResult = [[NSMutableArray alloc] initWithArray:_result];
    if((type==Line || type==Bessel) && [_result count]>1){//曲线图对日期进行排序
        NSString *date1str = [_result[0] objectForKey:localColumns[dateindex]];
        NSString *date2str = [_result[1] objectForKey:localColumns[dateindex]];
        NSDate *date1;
        NSDate *date2;
        if(date1str && date2str) {
            if(date1str.length >= 19 && date2str.length >= 19) {
                if([[date1str substringFromIndex:11] isEqualToString:[date2str substringFromIndex:11]]) {
                    isSameHour = YES;
                    date1 =[NSDate dateFromString:[date1str substringToIndex:10] dateFormat:@"yyyy-MM-dd"];
                    date2 =[NSDate dateFromString:[date2str substringToIndex:10] dateFormat:@"yyyy-MM-dd"];
                }else {
                    date1 =[NSDate dateFromString:[date1str substringToIndex:19] dateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    date2 =[NSDate dateFromString:[date2str substringToIndex:19] dateFormat:@"yyyy-MM-dd HH:mm:ss"];
                }
            }else if(date1str.length >= 10 && date2str.length >= 10) {
                date1 =[NSDate dateFromString:[date1str substringToIndex:10] dateFormat:@"yyyy-MM-dd"];
                date2 =[NSDate dateFromString:[date2str substringToIndex:10] dateFormat:@"yyyy-MM-dd"];
                
            }
            if([date1 compare:date2]==1){//倒转顺序
                orderedResult = [[NSMutableArray alloc] initWithCapacity:[_result count]];
                for(int i=(int)[_result count]-1;i>=0;i--){
                    [(NSMutableArray*)orderedResult addObject:_result[i]];
                }
            }
        }
    }
    
    NSArray *colorArray = _legendColorArray;
    
    int linecount = 0;
    int  xLabelIndex = 0;
    for(int i=0;i<[localColumns count];i++){
        if (i==xLabelIndex) {
            continue;
        }
        linecount++;
        LineChartData *d1 = [LineChartData new];
        
        d1.chartType = type;
        d1.xMin = 0;
        d1.xMax =xcount;
        d1.title = localColumns[i];
        d1.color = colorArray[(linecount-1)%[colorArray count]];
        d1.itemCount = xcount;
        //每个d1对应一列,保存这列所有数据,d1也就对应了折线图的某一条线
        d1.getData = ^(NSUInteger item) {
            float x = item+1;
            
            id value = [orderedResult[item] objectForKey:localColumns[i]];
            if(value == nil || (NSNull*)value==[NSNull null]){
                value = [NSNumber numberWithInt:0];
            }
            float y = [value floatValue];
            NSString *label1;
            if (type==Line || type==Bessel) {
                
                NSString *datestr = [orderedResult[item] objectForKey:localColumns[dateindex]];
                if([self isIncludeChineseInString:datestr]) {
                    label1 = datestr;
                }else {
                    if (datestr.length >= 16) {
                        if(isSameHour) {
                            datestr = [datestr substringToIndex:10];
                            datestr = [datestr substringFromIndex:5];
                            label1 = [NSString stringWithFormat:@"%@",datestr];
                        }else {
                            datestr = [datestr substringToIndex:16];
                            datestr = [datestr substringFromIndex:11];
                            label1 = [NSString stringWithFormat:@"%@",datestr];
                        }
                    }else if(datestr.length >= 10) {
                        datestr = [datestr substringToIndex:10];
                        datestr = [datestr substringFromIndex:5];
                        label1 = [NSString stringWithFormat:@"%@",datestr];
                    }else {
                        label1= [orderedResult[item] objectForKey:localColumns[xLabelIndex]];
                    }
                }
                
                
            }
            else{
            
                label1= [orderedResult[item] objectForKey:localColumns[xLabelIndex]];
            }
            if ([label1 isKindOfClass: [NSNull class]]) {
                label1=@"-";
            }
            NSString *label2 = [NSString stringWithFormat:@"%f", y];
            return [LineChartDataItem dataItemWithX:x y:y xLabel:label1 dataLabel:label2];
        };
        
        [alldata addObject:d1];
    }
    float ymax = 0;
    float ymin=100000000000.0;
    int dataIndex = -1;
    for(int i=0;i<[localColumns count];i++){
        if(i==dateindex){
            continue;
        }
        dataIndex++;
        for(int j=0;j<[_result count];j++){
            id value = [_result[j] objectForKey:localColumns[i]];
            if(value == nil || (NSNull*)value==[NSNull null]){
                value = [NSNumber numberWithInt:0];
            }
            float y = [value floatValue];
            if(y>ymax){
                ymax = y;
            }
            if (y<ymin) {
                ymin = y;
            }
        }
    }
    chartView.yMin = 0;
    if (type == Line) {
        chartView.yMin = ymin;
    }
    chartView.dataMin= ymin;
    chartView.yMax = ymax;
    chartView.enableTouch = NO;
    chartView.xTitle = localColumns[xLabelIndex];
    if((type==Line || type==Bessel) && [_result count]>1) {
        chartView.xAxisHorizontalMaxValue=0;
    }else {
        chartView.xAxisHorizontalMaxValue=3;
    }
    NSMutableArray *steps=[[NSMutableArray alloc] init];
    float step=  (chartView.yMax-chartView.yMin)/5;
    for (int i=0; i<6; i++) {
        [steps addObject: [NSString stringWithFormat:@"%f",i*step]];
    }
    chartView.ySteps =[NSArray arrayWithArray:steps];
    
    chartView.specialData = _specailData;
    chartView.specialRow = _specialRow;
    chartView.showLegend = _showLegend;
    chartView.intervalTime = _intervalTime;
    chartView.title = _title;
    chartView.xAxisHorizontalMaxValue = 7;
    chartView.showGradientLayer = _showGradientLayer;
    chartView.data = alldata;
    
}

- (BOOL)isIncludeChineseInString:(NSString*)str {
    for (int i=0; i<str.length; i++) {
        unichar ch = [str characterAtIndex:i];
        if (0x4e00 < ch  && ch < 0x9fff) {
            return true;
        }
    }
    return false;
}


@end
