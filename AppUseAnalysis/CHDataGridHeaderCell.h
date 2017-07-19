//
//  CHDataGridHeaderCell.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHTableViewCell.h"

@protocol CHDataGridHeaderCellDelegate<NSObject>

-(void)didSelectedTableViewHeaderIndex:(int)index;
-(void)didSelectedTableViewHeaderName:(NSString*)headerName;
@end

@interface CHDataGridHeaderCell : CHTableViewCell
@property (copy, nonatomic) NSArray *constraints;
/**锁定表格分割线的颜色*/
@property (nonatomic,strong) UIColor *splitLineColor;
/**字体颜色*/
@property (nonatomic,strong) UIColor *fontColor;
/**字体对其方式*/
@property (nonatomic,assign) NSTextAlignment align;
/***/
@property (nonatomic,assign) float lineHeight;
/***/
@property (nonatomic,assign) float fontSize;
/**存放标题栏单元格宽度的数组*/
@property (nonatomic,strong) NSMutableArray *colWidths;
/***/
@property (nonatomic,assign) BOOL textwrap;
/**配置的标题栏信息*/
@property (nonatomic,strong) NSArray *columnsInfo;
/**标题栏的指标说明  如果有值 标题栏会显示⚠️标识，并且长按会弹出标题说明*/
@property (nonatomic,strong) NSArray* indicatorDesc;
/***/
@property (nonatomic,assign) BOOL isAvgWidth;
/** 是否是锁定表格的一部分*/
@property (nonatomic,assign) BOOL isLocked;
-(void)createGrids:(NSArray*)columnsInfo;
@property (nonatomic,weak) id<CHDataGridHeaderCellDelegate> delegate;

@end
