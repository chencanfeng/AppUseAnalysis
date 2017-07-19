//
//  GDFunctionAnalyzeController.h
//  GDWWNOP
//
//  Created by MasterCom on 2017/5/15.
//  Copyright © 2017年 cn.mastercom. All rights reserved.
//

#import "MTBaseViewController.h"

/** 使用分析 (1.1.2   功能使用分析)*/
@interface GDFunctionAnalyzeController : MTBaseViewController


/**
 标题
 */
@property (nonatomic,copy) NSString *naviTitle;


/**
 筛选下标(日,周,月)
 */
@property (nonatomic,assign)NSInteger filterIndex;
/**
 是否显示顶部标题
 */
@property (nonatomic,assign) BOOL isShowHeaderTitle;

/**
 顶部标题数组
 */
@property (nonatomic,strong) NSArray *headerTitles;

/**
 是否跳转到地市
 */
@property (nonatomic,assign) BOOL isShowCityAnalyze;

/**
 是否跳转到部门
 */
@property (nonatomic,assign) BOOL isShowDepartmentAnalyze;
@property (nonatomic,copy) NSString *city;//城市

@end
