//
//  AppTabChartView.h
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHDateSelectorView.h"
@interface AppTabChartView : UIView
@property (nonatomic, strong) NSArray *result;
@property (nonatomic, strong) NSArray *columns;
@property (nonatomic ,strong) NSArray  *specicalData;
@property (nonatomic ,assign) int  specialRow;


@property (nonatomic ,strong) NSArray  *model;
@property (nonatomic ,strong) NSString  *cityName;
@property (nonatomic,assign) HBDateType slicetype;

@property (strong,nonatomic) MTBaseViewController *parentVC;
@property (nonatomic ,strong) NSString  *funcName;

- (void)query;
@end
