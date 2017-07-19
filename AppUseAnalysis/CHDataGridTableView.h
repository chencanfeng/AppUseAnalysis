//
//  CHDataGridTableView.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHDataGridTableViewCell.h"
#import "CHDataGridHeaderCell.h"
@class CHDataGridTableView;
@protocol CHDataGridTableViewDelegate <NSObject>
@required
- (void)dataGridDidSelectRow:(int)row rowData:(NSArray *)rowData;
- (void)dataGridDidSelectCell:(int)row column:(int)column rowData:(NSArray*)rowData;

@optional
- (void)dataGridDidScroll:(UIScrollView *)scrollView;
- (void)detectingLastCell;
- (void)dataGridDidClickHeaderName:(NSString*)headerName;
/**
 *  需要特殊处理的cell
 *
 *  @param tableView <#tableView description#>
 *  @param cell      <#cell description#>
 */
- (void) CHDataGridTableView:(UITableView *)tableView forSpecialCell:(CHDataGridTableViewCell *)cell;
@end

@interface CHDataGridTableView : UITableView<UITableViewDataSource,UITableViewDelegate,CHDataGridTableViewCellDelegate>
@property (nonatomic,strong) NSDictionary *tableInfo;
/**
 *  @[]
 */
@property (nonatomic,strong) NSArray *headerInfo;
/**
 *  @[]
 */
@property (nonatomic,strong) NSArray *dataInfo;
/**
 *  需要特殊处理的行 只传行序号 eg:@[1,2,3,4]
 */
@property(nonatomic) NSArray*specialRows;
/** 用来排序的一组数据*/
@property (nonatomic) NSMutableArray * keyArr;
/** 是否是锁定表格的一部分*/
@property (nonatomic,assign) BOOL isLocked;
/**标题栏的指标说明  如果有值 标题栏会显示⚠️标识，并且长按会弹出标题说明*/
@property (nonatomic,strong) NSArray* indicatorDesc;
/***/
@property (nonatomic,assign) BOOL needScrollTrigger;
/***/
@property (nonatomic,assign) float totalwidth;
/***/
@property (nonatomic,assign) float maxcolwidth;
/***/
@property (nonatomic,assign) id <CHDataGridTableViewDelegate> parentDelegate; 
/** 是否调用 SVProgressHUD 的 dismiss 的方法 */
@property (nonatomic,assign) BOOL shouldDismissProgress;
-(void)putData:(NSArray *)data;
/**
 是否能进入下一层
 */
@property (nonatomic,assign) BOOL isCanGoMore;


- (int)getHeaderHeight;
- (NSInteger)getLineHeight;
@end
