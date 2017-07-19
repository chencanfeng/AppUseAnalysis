//
//  CHDataGridTableViewCell.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//


#import "CHTableViewCell.h"
@protocol CHDataGridTableViewCellDelegate<NSObject>

-(void)didSelectedTableViewCell:(UITableViewCell *)cell column:(int)column;

@end

@interface CHDataGridTableViewCell : CHTableViewCell<UIGestureRecognizerDelegate>
/***/
@property (copy, nonatomic) NSArray *constraints;
/***/
@property (nonatomic,assign) BOOL cellCanSelect;
/***/
@property (nonatomic,assign) NSTextAlignment align;
/***/
@property (nonatomic,strong) UIColor *fontColor;
/***/
@property (nonatomic,strong) UIColor *splitLineColor;
/***/
@property (nonatomic,strong) NSMutableArray *colWidths;
/***/
@property (nonatomic,assign) float lineHeight;
/***/
@property (nonatomic,assign) float fontSize;
/***/
@property (nonatomic,strong) NSArray *columnsInfo;
/***/
@property (nonatomic,assign) BOOL textwrap;
/***/
@property (nonatomic,unsafe_unretained) id<CHDataGridTableViewCellDelegate> delegate;
/***/
@property (nonatomic,assign) BOOL isAvgWidth;


-(void)createGrids:(NSArray*)columnsInfo;
-(void)setCellData:(NSArray*)datasInfo;

//韶关添加 是否有留言
@property (nonatomic,assign) BOOL isHasMessage;
//韶关添加 是否加自选
@property (nonatomic,assign) BOOL isOptional;
@end
