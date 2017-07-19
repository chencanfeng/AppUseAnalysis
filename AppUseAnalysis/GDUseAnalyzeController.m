//
//  GDUseAnalyzeController.m
//  GDWWNOP
//
//  Created by MasterCom on 2017/5/16.
//  Copyright © 2017年 cn.mastercom. All rights reserved.
//

#import "GDUseAnalyzeController.h"

#import "GDFunctionAnalyzeController.h"

#import "HBColumnChartView.h"

#import "CHDataGridTableView.h"

@interface GDUseAnalyzeController ()<CHDataGridTableViewDelegate>
@property (nonatomic,strong) HBColumnChartView *columnChartview;
@property (nonatomic,strong) CHDataGridTableView *colTableview;
@property (nonatomic,strong) NSArray *columns;
@property (nonatomic,strong) NSArray *datas;
@end

@implementation GDUseAnalyzeController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNaviTitle:@"功能使用量分析" leftButtonShow:YES rightButtom:nil];
    
    [self sendRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)sendRequest
{
    //获取功能使用量排名
    NSString *urlStr = @"/gdmt/analysis/AplicationAmountRanking.mt";
    
    __weak GDUseAnalyzeController *weakSelf = self;
    
    self.view.userInteractionEnabled = NO;
//    [[HttpCommon sharedInstance] requestWithURL:urlStr Params:nil LoadingHint:@"加载中..." Handler:^(NSDictionary *response) {
     [[MTAPICenterCallManager sharedInstance] callAPIWithMethodName:urlStr params:nil loadingHint:@"加载中.." doneHint:nil handleBlock:^(NSDictionary * _Nullable response) {
         
        weakSelf.view.userInteractionEnabled = YES;

        if ([response[@"success"] isEqualToNumber:@(1)]) {
//            [[[UIToastView alloc]initWithTitle:@"获取成功"]show];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [SVProgressHUD dismiss];
                //默认返回10个
                NSLog(@"dates:%@",response[@"dates"]);
                
                [weakSelf layoutColumnChartViewWithDatas:response[@"dates"]];
 
                _columns = response[@"columns"];
                _datas   = response[@"dates"];

                [weakSelf layoutReportViewWithColumns:_columns datas:_datas];

            });
        }
    }];
}

#pragma mark - Lay out
- (void)layoutColumnChartViewWithDatas:(NSArray *)datas
{
    _columnChartview = [[HBColumnChartView alloc]initWithFrame:CGRectMake(0, 20, kScreenWidth, kScreenHeight * 0.6 - 30)];
    _columnChartview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_columnChartview];
    
    _columnChartview.layer.borderWidth = 1;
    _columnChartview.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    //数据
    //颜色传了2个,只用了一组???
    _columnChartview.colorDatas = @[@[@"#f75b89",@"#ff96ce"],
                                    @[@"#f76168",@"#fd9a98"],
                                    @[@"#ff9b4c",@"#f8d2b0"],
                                    @[@"#f7d587",@"#ffe6a0"],
                                    @[@"#00d2cc",@"#72f2ee"],
                                    @[@"#00a589",@"#93ebdc"],
                                    @[@"#4497f6",@"#59f0fd"],
                                    @[@"#00a4f3",@"#86c9f7"],
                                    @[@"#0db0d0",@"#9adae8"],
                                    @[@"#9f78c1",@"#d4b2f2"]];
    
    NSMutableArray *xArr = [[NSMutableArray alloc]init];
    NSMutableArray *titleArr = [[NSMutableArray alloc]init];
    NSMutableArray *valuesArr = [[NSMutableArray alloc]init];

    for (int i = 0; i < [datas count]; i ++)
    {
        [xArr addObject:@(i + 1)];
        [titleArr addObject:datas[i][0]];
        [valuesArr addObject:datas[i][1]];
    }
    
    _columnChartview.yTitleDatas = xArr;//@[@1,@2,@3,@4,@5,@6,@7,@8,@9,@10];
    _columnChartview.titleDatas  = titleArr;
    _columnChartview.titleValues = valuesArr;
    
    //由于默认datas第一组为峰值
    int dataValueMax = [datas[0][1] intValue];
    
    //分几列(即x轴的刻度)
    int col = 7;
    
    //x轴刻度比例(若能整除直接选整除数, 若不能选下个能被(7, 10)整除项)
    int xscale = (dataValueMax%(10 * col) == 0) ? dataValueMax/col : ( dataValueMax/(10 * col) + 1) * ( 10 * col)/col;
    
    _columnChartview.xMaxScaleValues = xscale *col;
    
    NSMutableArray *yArr = [[NSMutableArray alloc]init];
    for (int j = 0; j < col; j ++)
    {
        [yArr addObject:@((j + 1)*xscale)];
    }
    
    _columnChartview.xTitleDatas = yArr;
    _columnChartview.drawDuration = 1.5f;
}

- (void)layoutReportViewWithColumns:(NSArray *)columns datas:(NSArray *)datas
{
    _colTableview = [[CHDataGridTableView alloc] initWithFrame:CGRectMake(0, kScreenHeight * 0.6, kScreenWidth, kScreenHeight * 0.4 - 64)];
    _colTableview.parentDelegate = self;

    //注意一定要设定lockColumnCount,否则putDatas即使传入正确数值也无法布局报表
    //锁定一起的可以同时变灰
//    _colTableview.lockColumnCount = (int)[columns count];
    
    NSMutableArray* headerInfoArray=[[NSMutableArray alloc] init];
    for (NSString* columnName in columns) {
        NSDictionary *headerInfo=@{@"datavalue":columnName,
                                   @"datatype":@"String",
                                   @"fontSize":@(14),
                                   @"autoAdjustWidth":@NO,
                                   @"width":@(kScreenWidth/2),
                                   @"iskey":@1,
                                   @"canorder":@0,
                                   @"bgFrameColor":@"#F1F1F1",
                                   @"textwrap":@YES
                                   };
        [headerInfoArray addObject:headerInfo];
    }
    _colTableview.headerInfo = headerInfoArray;
    _colTableview.tableInfo = @{
                                @"bgHeaderColor":@"#D2EBF9",
                                @"bgCellColor":@"#FFFFFF",
                                @"bgCellAltColor":@"#F5F9FE",
                                @"bgFrameColor":@"#F1F1F1",
                                @"bgTopLineColor":@"#439CCA",
                                @"splitLineColor":@"#F1F1F1",
                                @"fontColor":@"#000000",
                                @"fontSize":@12,
                                @"lineHeight":@36,
                                @"headerHeight":@40,
                                @"align":@"center",
                                @"textwrap":@1,
                                @"autoAdjustWidth":@NO,
                                @"selectType":@"Line"
                                };
    
    [_colTableview putData:datas];
    
    [self.view addSubview:_colTableview];
}


#pragma mark - MTLockedColumnsTableViewDelegate
- (void)dataGridDidSelectRow:(int)row rowData:(NSArray *)rowData
{
    NSLog(@"row:%d--rowData:%@",row,rowData);
    _colTableview.specialRows = @[[NSString stringWithFormat:@"%d",row]];
    [_colTableview reloadData];
    
    GDFunctionAnalyzeController *funcVc = [[GDFunctionAnalyzeController alloc]init];
    funcVc.filterIndex = -1;
    funcVc.naviTitle = rowData[0];
    
    [self pushViewController:funcVc];
}

- (void)dataGridDidSelectCell:(int)row column:(int)column rowData:(NSArray*)rowData
{
    
}

// 点击表格任意一行，此行背景色变灰
- (void) CHDataGridTableView:(UITableView *)tableView forSpecialCell:(CHDataGridTableViewCell *)cell {
    NSLog(@"%s",__func__);
    cell.bgNormalColor = [UIColor colorWithRed:0.894 green:0.894 blue:0.894 alpha:1.00];
}



@end
