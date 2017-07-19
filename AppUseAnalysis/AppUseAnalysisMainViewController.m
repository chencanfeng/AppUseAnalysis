//
//  AppUseAnalysisMainViewController.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/11.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "AppUseAnalysisMainViewController.h"

#import "CLTRoundView.h"
#import "CLTBarView.h"
#import "CLTLineView.h"

#import "CHLineView.h"
//#import "CLTBarView.h"
#import "HBColumnChartView.h"

#import "AppChartInfoViewController.h"
#import "GDUseAnalyzeController.h"

@interface AppUseAnalysisMainViewController ()
@property (weak, nonatomic) IBOutlet UIView *chartView1;
@property (weak, nonatomic) IBOutlet UIView *chartView2;
@property (weak, nonatomic) IBOutlet UIView *chartView3;
@property (weak, nonatomic) IBOutlet UILabel *chartView3Title;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chartView1Height;

@property (nonatomic,strong) CLTRoundView *roudView;

@property (nonatomic,strong) CHLineView *lineView;
//@property (nonatomic,strong) CLTBarView *barView;
@property (nonatomic, strong)HBColumnChartView *columnChartview;

@end

@implementation AppUseAnalysisMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    _chartView1Height.constant = (kScreenHeight - 150)/3.f;
    
    
    [self requestData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)requestData
{
    [[MTAPICenterCallManager sharedInstance] callAPIWithMethodName:@"/gdmt/analysis/AppAnalysis.mt" params:nil loadingHint:@"正在请求数据.." doneHint:nil handleBlock:^(NSDictionary * _Nullable response) {
//        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
//        NSString *fileName = [NSString stringWithFormat:@"%@/%@",path,@"AppAnalysis.data"];
//        if(![response writeToFile:fileName atomically:YES]) {
//           
//        }
        if (![response[@"success"]isEqual:@(1)]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.16 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //错误提示写这里
                return ;
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                //体验时延
                UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chartView1Tap:)];
                [self.chartView1 addGestureRecognizer:tap1];
                double time = [response[@"平均时延"] doubleValue]/1000.f;
                [self.chartView1 addSubview:self.roudView];
                
                self.roudView.ratio = time;
                
                //用户活跃度
                NSArray *activeColumns = response[@"用户活跃度列名"];
                NSArray *activeDatas = response[@"用户活跃度"];
                
                NSMutableArray *arrM = [NSMutableArray new];
                for (int i = 0 ; i < [activeDatas count]; i ++) {
                    NSArray *arr = activeDatas[i];
                    NSMutableDictionary *dicM = [NSMutableDictionary new];
                    for (int j = 0; j < [activeColumns count]; j ++) {
                        if(j == 0) {
                            NSString *str = arr[j];
                            if([str length]>=10) {
                                str = [str substringToIndex:10];
                            }
                            [dicM setValue:str forKey:activeColumns[j]];
                        }else {
                            [dicM setValue:arr[j] forKey:activeColumns[j]];
                        }
                    }
                    [arrM addObject:dicM];
                }
                UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chartView2Tap:)];
                [self.chartView2 addGestureRecognizer:tap2];
                [self.chartView2 addSubview:self.lineView];
                
                
                if([arrM count] != 0 || [activeColumns count] != 0) {
                    _lineView.columns = activeColumns;
                    _lineView.result = arrM;
                    _lineView.intervalTime = 12;
                    _lineView.showLegend = NO;
                    _lineView.title = @"用户小时活跃趋势";
                    [_lineView createLineChartViewWithFrame:self.chartView2.bounds type:Line];
                }
                
                //功能使用量
//                NSArray *functionColumns = response[@"功能使用量列名"];
                NSArray *functionDatas = response[@"功能使用量"];
                UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chartView3Tap:)];
                [self.chartView3 addGestureRecognizer:tap3];
                
                [self.chartView3 addSubview:self.columnChartview];
                
                NSMutableArray *xArr = [[NSMutableArray alloc]init];
                NSMutableArray *titleArr = [[NSMutableArray alloc]init];
                NSMutableArray *valuesArr = [[NSMutableArray alloc]init];
                
                for (int i = 0; i < [functionDatas count]; i ++)
                {
                    [xArr addObject:@(i + 1)];
                    [titleArr addObject:functionDatas[i][0]];
                    [valuesArr addObject:functionDatas[i][1]];
                }
                _chartView3Title.text = @"功能使用量排名";
                _chartView3Title.textColor = [UIColor colorWithRed:0.541 green:0.537 blue:0.631 alpha:1.00];
                
                _columnChartview.yTitleDatas = xArr;//@[@1,@2,@3,@4,@5,@6,@7,@8,@9,@10];
                _columnChartview.titleDatas  = titleArr;
                _columnChartview.titleValues = valuesArr;
//                _columnChartview.title = @"功能使用量排名";
                
                //由于默认datas第一组为峰值
                int dataValueMax = [functionDatas[0][1] intValue];
                
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
                
            });
        }
    }];
    
}


/**
 跳转到使用量分析

 */
- (void)chartView1Tap:(UITapGestureRecognizer *)tap1
{
    AppChartInfoViewController *vc = [[AppChartInfoViewController alloc] init];
    vc.navTitle = @"用户体验时延";
    vc.funcName = @"用户体验时延";
    
    vc.model = @[
                 @{@"title":@"最近2小时",
                   @"url":@"/gdmt/analysis/UserDelayOfTime.mt",
                   @"urlParams":@{@"granularity":@"小时"},
                   @"slicetype":@0,
                   @"drillMore":@"NO"},
                 @{@"title":@"最近24小时",
                   @"url":@"/gdmt/analysis/UserDelayOfTime.mt",
                   @"urlParams":@{@"granularity":@"天"},
                   @"slicetype":@0,
                   @"drillMore":@"NO"},
                 @{@"title":@"最近1周",
                   @"url":@"/gdmt/analysis/UserDelayOfTime.mt",
                   @"urlParams":@{@"granularity":@"周"},
                   @"slicetype":@0,
                   @"drillMore":@"NO"}
                 
                 
                 
                 
                 ];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)chartView2Tap:(UITapGestureRecognizer *)tap2
{
    AppChartInfoViewController *vc = [[AppChartInfoViewController alloc] init];
    vc.navTitle = @"用户活跃量分析";
    vc.funcName = @"用户活跃量分析";
    vc.model = @[
                 @{@"title":@"趋势分析",
                   @"url":@"/gdmt/analysis/UserActivityOfTime.mt",
                   @"urlParams":@{},
                   @"slicetype":@0,
                   @"drillMore":@"NO"},
                 @{@"title":@"地市分析",
                   @"url":@"/gdmt/analysis/UserActivityOfCity.mt",
                   @"urlParams":@{},
                   @"slicetype":@0,
                   @"drillMore":@"YES"}
                 ];
    
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)chartView3Tap:(UITapGestureRecognizer *)tap3
{
    GDUseAnalyzeController *vc = [[GDUseAnalyzeController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - 懒加载

-(CLTRoundView *)roudView
{
    if (!_roudView) {
        
        _roudView = [[CLTRoundView alloc]initWithFrame:self.chartView1.bounds];
    }
    
    return _roudView;
}

- (CHLineView *)lineView {
    
    if (!_lineView) {
        _lineView = [[CHLineView alloc] initWithFrame:self.chartView2.bounds];
    }
    
    return _lineView;
}

- (HBColumnChartView *)columnChartview {
    
    if(_columnChartview == nil) {
        
        _columnChartview = [[HBColumnChartView alloc] initWithFrame:self.chartView3.bounds];
        _columnChartview.backgroundColor = [UIColor whiteColor];
        
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
    }
    return _columnChartview;
    
}

//- (CLTBarView *)barView {
//    
//    if(_barView == nil) {
//        _barView = [[CLTBarView alloc] initWithFrame:self.chartView3.bounds];
//        
//    }
//    return _barView;
//}



//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    // 传入百分比的时候，传入 小数，  0.1 - 1 范围内  <==>  1 - 100
////    self.roudView.ratio = arc4random_uniform(12 + 1) ;
//    self.roudView.ratio = 12.f;
//    NSLog(@"%d",self.roudView.ratio);
////    self.roudView.percent = 0.10f;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
