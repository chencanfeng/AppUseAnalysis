//
//  AppChartInfoViewController.h
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHDateSelectorView.h"



@interface AppChartInfoViewController : MTBaseViewController <HBDatePickerViewDelegate>

@property (nonatomic ,strong) NSString  *navTitle;
@property (nonatomic ,strong) NSString  *funcName;

@property (nonatomic ,strong) NSArray  *model;
@property (nonatomic ,strong) NSString  *cityName;

/** 获取界面功能的 url 字符串 */
@property (strong,nonatomic) NSString *url;
@property (strong,nonatomic) NSDictionary *urlparams;

@property (strong,nonatomic) NSString *slicetype;//时间粒度 日 周 月
@property (nonatomic ,strong) NSArray  *validslicetypes;  //有效的时间粒度

@property (strong,nonatomic) CHDateSelectorView *dateControl;


@end
