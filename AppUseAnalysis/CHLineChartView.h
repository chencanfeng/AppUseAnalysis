//
//  CHLineChartView.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHLegendView.h"

@class LineChartDataItem;

typedef LineChartDataItem *(^LineChartDataGetter)(NSUInteger item);


#pragma mark 某个点的信息
@interface LineChartDataItem : NSObject
/** 第几个点*/
@property (readonly) float x; // should be within the x range
/** 点的值*/
@property (readonly) float y; // should be within the y range
/** x轴标注的描述文字*/
@property (readonly) NSString *xLabel; // label to be shown on the x axis
/** 点的值字符串*/
@property (readonly) NSString *dataLabel; // label to be shown directly at the data item


+ (LineChartDataItem *)dataItemWithX:(float)x y:(float)y xLabel:(NSString *)xLabel dataLabel:(NSString *)dataLabel;

@end

typedef NS_ENUM(NSInteger,ChartType){
    Line=1,
    Column=2,
    Bessel=3
};

#pragma mark 某条线的信息
@interface LineChartData : NSObject
/** 折线的颜色*/
@property (strong) UIColor *color;
/** 折线的标题*/
@property (copy) NSString *title;
/** 折线上点的个数*/
@property NSUInteger itemCount;
/** x轴的范围的开始值*/
@property float xMin;
/** x轴的范围的结束值*/
@property float xMax;
/** 折线的样式*/
@property (nonatomic) ChartType chartType;
/** block  获取某个点*/
@property (copy) LineChartDataGetter getData;

@end


#pragma mark 折线图





@interface CHLineChartView : UIView

@property (nonatomic, strong) NSArray *data; // Array of `LineChartData` objects, one for each line.



@property float dataMin;
@property float yMin;
@property float yMax;
@property (strong) NSArray *ySteps; // Array of step names (NSString). At each step, a scale line is shown.
@property NSUInteger xStepsCount; // number of steps in x. At each x step, a vertical scale line is shown. if x < 2, nothing is done

@property int X_AXIS_SPACE;
@property int PADDING;
@property int TOPEXTRAPADDING;

@property (strong) UIFont *scaleFont; // Font in which scale markings are drawn. Defaults to [UIFont systemFontOfSize:10].

@property (copy) NSString *xTitle;



@property (nonatomic ,assign) BOOL showGradientLayer; //是否显示渐变图层
@property BOOL showLegend;//图例是否显示
@property BOOL enableTouch;//是否支持触摸显示数据
@property BOOL showXLabel;//X坐标是否显示
@property BOOL drawsDataPoints; // Switch to turn off circles on data points. On by default.
@property BOOL drawsDataLines; // Switch to turn off lines connecting data points. On by default.


@property (nonatomic,assign) NSInteger drawsDataPointsDiameter;//画点的直径
@property (nonatomic,assign) NSInteger drawsDataPointsType;//0:圆圈  1:实心圆
@property (nonatomic,assign) NSInteger xAxisHorizontalMaxValue;// 横坐标数量超过指定的门限，若超过则横坐标竖排  黄启峰增加

@property (nonatomic ,strong) NSArray  *specialData;
@property (nonatomic ,assign) int specialRow;
@property (nonatomic ,strong) NSString  *title; //图表的title
@property (nonatomic,assign) int intervalTime;//横坐标间隔多少时间(单位)画下标label


@end
