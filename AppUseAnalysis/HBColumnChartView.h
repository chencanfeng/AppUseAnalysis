//
//  HBColumnChartView.h
//  柱形图
//
//  Created by MasterCom on 2017/5/15.
//  Copyright © 2017年 MasterCom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBColumnChartView : UIView

/**
 布局必要数据源
 1. 象限一(默认)
 2. x,y轴标题数组
 3. 柱形图上标题
 4. 对应颜色数组
 */

//--- 布局数据源----
/**
 x轴标题数组
 */
@property (nonatomic, strong) NSArray *xTitleDatas;

/**
 y轴标题数组
 */
@property (nonatomic, strong) NSArray *yTitleDatas;

/**
 柱形图填充颜色数组
 */
@property (nonatomic, strong) NSArray *colorDatas;

/**
 Y轴间距
 */
@property (nonatomic, assign) NSUInteger paddingH;


/**
 y轴标签的宽度
 */
@property (nonatomic, assign) CGFloat yLabelW;

/**
 x轴标签的高度
 */
@property (nonatomic, assign) CGFloat xLabelH;

//--- 数据源----
/**
 柱形图上显示的标题数组
 */
@property (nonatomic, strong) NSArray *titleDatas;

/**
 标题对应项的值
 */
@property (nonatomic, strong) NSArray *titleValues;



/**
 x轴最大刻度值
 */
@property (nonatomic, assign) int xMaxScaleValues;


/**
 动画绘制时长
 */
@property (nonatomic, assign) CGFloat drawDuration;



@end
