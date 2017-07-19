//
//  CHLineView.h
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/16.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CHLineChartView.h"

@interface CHLineView : UIView
@property (nonatomic ,strong) NSArray  *result;
@property (nonatomic ,strong) NSArray  *columns;

@property (nonatomic ,assign) int intervalTime; //时间间隔
@property (nonatomic ,strong) NSString  *title;
@property (nonatomic ,assign) BOOL showGradientLayer; //是否显示渐变图层
@property (nonatomic ,assign) BOOL showLegend;
@property (nonatomic ,strong) NSArray  *specailData; //显示垂直虚线的数据
@property (nonatomic ,assign) int  specialRow;

-(void)createLineChartViewWithFrame:(CGRect)frame type:(ChartType)type;

@end
