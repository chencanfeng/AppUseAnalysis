//
//  GDFunctionAnalyzeController.m
//  GDWWNOP
//
//  Created by MasterCom on 2017/5/15.
//  Copyright © 2017年 cn.mastercom. All rights reserved.
//

#import "GDFunctionAnalyzeController.h"

#import "TitleView.h"
//#import "LineChartView.h"
#import "CHLineView.h"
//#import "MTDataGridTableView.h"
#import "CHTableView.h"

#import "HBDatePickerView.h"

#import "TimeSelectBtn.h"

@interface GDFunctionAnalyzeController ()<CHTableViewProtocol,HBDatePickerViewDelegate>
{
    NSString *_startDateStr;  //开始日期字串
    NSString *_endDateStr;    //结束日期字串
    NSString *_granularity;    //当前选择粒度
}
@property (nonatomic,strong) TitleView *titleView;
@property (nonatomic,strong) TimeSelectBtn *timeChooseBtn;
@property (nonatomic,strong) CHLineView *lineChartView;
@property (nonatomic,strong) CHTableView *colTableview;
@property (nonatomic,strong) NSArray *columns;
@property (nonatomic,strong) NSArray *datas;
@property (nonatomic,strong) NSArray *result;
@property (nonatomic ,strong) NSArray  *specicalData;
@property (nonatomic ,assign) int  specialRow;

@property (nonatomic,strong) HBDatePickerView *hbDatePickerView;

@property (nonatomic, strong) NSDate *currentDate;

@end

@implementation GDFunctionAnalyzeController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if(!_isShowCityAnalyze && !_isShowDepartmentAnalyze)
    {
        [self setNaviTitle:[NSString stringWithFormat:@"%@使用分析",_naviTitle] leftButtonShow:YES rightButtom:nil];
    }
    else if(_isShowCityAnalyze)
    {
        [self setNaviTitle:[NSString stringWithFormat:@"%@使用地市分析",_naviTitle] leftButtonShow:YES rightButtom:nil];
    }
    else
    {
        [self setNaviTitle:[NSString stringWithFormat:@"%@使用分析(%@)",_naviTitle,_city] leftButtonShow:YES rightButtom:nil];
    }
    
    [self initDatas];
    
    [self layoutHeaderTitle];
    
    [self layoutSubHeaderTitle];
   
    [self sendRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initDatas
{
    //首次默认周粒度
    _filterIndex = (_filterIndex == -1)? 1 : _filterIndex;
    
    _isShowHeaderTitle = YES;
}

#pragma mark - Lay out
- (void)layoutHeaderTitle
{
    if(!_isShowHeaderTitle) return;
    
    self.headerTitles = @[@"日使用量",@"周使用量",@"月使用量"];
    
    _titleView = [[TitleView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 40) andTitles:self.headerTitles];
    
    [self.view addSubview:_titleView];
    
    _titleView.layer.borderWidth = 1;
    _titleView.layer.borderColor = [[UIColor lightGrayColor] CGColor];

    //默认选中前一天
    [_titleView updataIndexLabelUIWithNum:_filterIndex];
    
    __weak GDFunctionAnalyzeController *weakSelf = self;
    _titleView.titleBtnBlock = ^(NSInteger index, NSString *title){
        
        NSLog(@"index:%ld--title:%@",(long)index,title);
        
        if(_filterIndex == index) return;
        
        _filterIndex = index;
        
        [weakSelf layoutSubHeaderTitle];
        //必须刷新请求,否则点击报表会解析出错
        [weakSelf sendRequest];
    };
}

- (void)layoutSubHeaderTitle
{
    //======
    CGFloat timeChooseBtnX = (_filterIndex == 0)? (kScreenWidth *2/7) :kScreenWidth *0.15;
    CGFloat timeChooseBtnY = ( _isShowHeaderTitle)? (CGRectGetMaxY(_titleView.frame) + 5) : 0;
    CGFloat timeChooseBtnW = (_filterIndex == 0)? (kScreenWidth *3/7) :kScreenWidth *0.7;
    
    if(_timeChooseBtn == nil)
    {
        _timeChooseBtn = [TimeSelectBtn buttonWithType:UIButtonTypeCustom];
        [_timeChooseBtn setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        [self.view addSubview:_timeChooseBtn];
        [_timeChooseBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _timeChooseBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        _timeChooseBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
   
    _timeChooseBtn.frame = CGRectMake(timeChooseBtnX, timeChooseBtnY, timeChooseBtnW, 25);
    _timeChooseBtn.layer.borderWidth = 1;
    _timeChooseBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    _timeChooseBtn.layer.masksToBounds = YES;
    _timeChooseBtn.layer.cornerRadius  = _timeChooseBtn.frame.size.height/2;
    
    [_timeChooseBtn addTarget:self action:@selector(dateChooseAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc]init];
    dateformatter.dateFormat = @"yyyy-MM-dd";
    

    //默认选择周
    if (_filterIndex == 0)
    {
        //默认显示前一天
        _startDateStr = [dateformatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:- 24 * 3600]];
        //_endDateStr = [dateformatter stringFromDate:[NSDate date]];
        
        NSLog(@"_startDateStr:%@~ _endDateStr:%@",_startDateStr,_endDateStr);

        NSArray *startTimes = [_startDateStr componentsSeparatedByString:@"-"];
        //NSArray *endTimes   = [_endDateStr componentsSeparatedByString:@"-"];
        
        [_timeChooseBtn setTitle:[NSString stringWithFormat:@"%d年%d月%d日",[startTimes[0] intValue],[startTimes[1] intValue],[startTimes[2] intValue]] forState:UIControlStateNormal];
    }
    else if(_filterIndex == 1)
    {
        //默认一周前
        NSDate *previousWeekDate = [NSDate dateWithTimeIntervalSinceNow:- 24 * 3600 * 7];
        _startDateStr = [dateformatter stringFromDate:previousWeekDate];
        _endDateStr = [dateformatter stringFromDate:[NSDate date]];
        NSLog(@"_startDateStr:%@~ _endDateStr:%@",_startDateStr,_endDateStr);

        NSArray *startTimes = [_startDateStr componentsSeparatedByString:@"-"];
        NSArray *endTimes   = [_endDateStr componentsSeparatedByString:@"-"];
        
        [_timeChooseBtn setTitle:[NSString stringWithFormat:@"%d年%d月%d日~%d年%d月%d日",[startTimes[0] intValue],[startTimes[1] intValue],[startTimes[2] intValue],[endTimes[0] intValue],[endTimes[1] intValue],[endTimes[2] intValue]] forState:UIControlStateNormal];
    }
    else
    {
        //默认以当月结束,上推一个月
        _endDateStr = [dateformatter stringFromDate:[NSDate date]];
        NSArray *endTimes   = [_endDateStr componentsSeparatedByString:@"-"];
        
        int ey = [endTimes[0]intValue];
        int em = [endTimes[1]intValue];
        
        NSArray *startTimes = @[@((em == 1)? ey-1: ey), (em == 1)? @12 : @(em - 1)];

        NSDate *startDate = [dateformatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@",startTimes[0],startTimes[1],endTimes[2]]];
        
        _startDateStr = [dateformatter stringFromDate:startDate];

        NSLog(@"_startDateStr:%@~ _endDateStr:%@",_startDateStr,_endDateStr);

        [_timeChooseBtn setTitle:[NSString stringWithFormat:@"%d年%d月~%d年%d月",[startTimes[0] intValue],[startTimes[1] intValue],[endTimes[0] intValue],[endTimes[1] intValue]] forState:UIControlStateNormal];
    }
}

- (void)refreshSubHeaderTitle
{
    NSLog(@"refreshSubHeaderTitle||_startDateStr:%@~ _endDateStr:%@",_startDateStr,_endDateStr);

    if (_filterIndex == 0)
    {
        NSArray *startTimes = [_startDateStr componentsSeparatedByString:@"-"];
        //NSArray *endTimes   = [_endDateStr componentsSeparatedByString:@"-"];
        
        [_timeChooseBtn setTitle:[NSString stringWithFormat:@"%d年%d月%d日",[startTimes[0] intValue],[startTimes[1] intValue],[startTimes[2] intValue]] forState:UIControlStateNormal];
    }
    else if(_filterIndex == 1)
    {
        NSArray *startTimes = [_startDateStr componentsSeparatedByString:@"-"];
        NSArray *endTimes   = [_endDateStr componentsSeparatedByString:@"-"];
        
        [_timeChooseBtn setTitle:[NSString stringWithFormat:@"%d年%d月%d日~%d年%d月%d日",[startTimes[0] intValue],[startTimes[1] intValue],[startTimes[2] intValue],[endTimes[0] intValue],[endTimes[1] intValue],[endTimes[2] intValue]] forState:UIControlStateNormal];
    }
    else
    {
        NSArray *startTimes = [_startDateStr componentsSeparatedByString:@"-"];
        NSArray *endTimes   = [_endDateStr componentsSeparatedByString:@"-"];
        
        [_timeChooseBtn setTitle:[NSString stringWithFormat:@"%d年%d月~%d年%d月",[startTimes[0] intValue],[startTimes[1] intValue],[endTimes[0] intValue],[endTimes[1] intValue]] forState:UIControlStateNormal];
    }
}

- (void)layoutLineChartView
{
    _lineChartView = [[CHLineView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(_timeChooseBtn.frame),kScreenWidth, 0.37 *kScreenHeight)];
    _lineChartView.result = _result;
    _lineChartView.columns = _columns;
    _lineChartView.specailData = _specicalData;
    _lineChartView.specialRow = _specialRow;
    
    [_lineChartView createLineChartViewWithFrame:_lineChartView.bounds type:Line];
    [self.view addSubview:_lineChartView];
}

- (void)layoutReportView
{
    _colTableview = [[CHTableView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(_lineChartView.frame) + 20, kScreenWidth, kScreenHeight - (CGRectGetMaxY(_lineChartView.frame) + 20) - 64)];
    [self.view addSubview:_colTableview];

    _colTableview.columns = _columns;
    _colTableview.result = _result;
    _colTableview.drillMore = @"NO"; //默认不可钻取
    if(_isShowCityAnalyze || (!_isShowCityAnalyze && !_isShowDepartmentAnalyze)) {
        _colTableview.drillMore = @"YES";
    }
    
    [_colTableview createTableViewWithFrame:_colTableview.bounds];
    _colTableview.delegate = self;
}

#pragma mark - Action
- (void)sendRequest
{
    if (_lineChartView) {
        [_lineChartView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_lineChartView removeFromSuperview];
    }
    if (_colTableview) {
        [_colTableview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_colTableview removeFromSuperview];
    }
    
    NSString *urlStr = nil;
    
    if(_isShowCityAnalyze)
    {
        urlStr = @"/gdmt/analysis/AplicationAmountOfCity.mt";
    }
    else if(_isShowDepartmentAnalyze)
    {
        urlStr = @"/gdmt/analysis/AplicationAmountOfDepartment.mt";
    }
    else
    {
        urlStr = @"/gdmt/analysis/AplicationAmountOfTime.mt";
    }
    
    NSDictionary *granularityDict = @{@0 : @"天",
                                      @1 : @"周",
                                      @2 : @"月"};
    
    //获取粒度
    _granularity = [granularityDict objectForKey:@(_filterIndex)];
    
    //判断粒度赋值
    NSArray *startTimes = [_startDateStr componentsSeparatedByString:@"-"];
    NSArray *endTimes   = [_endDateStr componentsSeparatedByString:@"-"];
    
    NSString *startTimeStr = (_filterIndex == 2)? [NSString stringWithFormat:@"%@-%@",startTimes[0],startTimes[1]]:_startDateStr;
    NSString *endTimeStr = (_filterIndex == 2)? [NSString stringWithFormat:@"%@-%@",endTimes[0],endTimes[1]]:_endDateStr;

    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{@"granularity": _granularity,
                                   @"beginTime"  : startTimeStr == nil?@"":startTimeStr,
                                   @"endTime"    : endTimeStr == nil?@"":endTimeStr,
                                   @"function"   : _naviTitle}];
    
    if(_isShowDepartmentAnalyze)
    {
        [param addEntriesFromDictionary:@{@"city":_city}];
    }
    
    __weak GDFunctionAnalyzeController *weakSelf = self;
    self.view.userInteractionEnabled = NO;
    
        
    [[MTAPICenterCallManager sharedInstance] callAPIWithMethodName:urlStr params:param loadingHint:@"加载中..." doneHint:nil handleBlock:^(NSDictionary * _Nullable response) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.view.userInteractionEnabled = YES;
//            [[[UIToastView alloc]initWithTitle:@"获取成功"]show];
            [SVProgressHUD dismiss];
        });
        
        if ([response[@"success"] isEqualToNumber:@(1)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
             
                //默认返回10个
                NSLog(@"dates:%@",response[@"dates"]);
                
                _columns = response[@"columns"];
                _datas   = response[@"dates"];
                
                NSMutableArray *arrM = [NSMutableArray new];
                for (int i = 0 ; i < [_datas count]; i ++) {
                    NSArray *arr = _datas[i];
                    NSMutableDictionary *dicM = [NSMutableDictionary new];
                    for (int j = 0; j < [_columns count]; j ++) {
                        [dicM setValue:arr[j] forKey:_columns[j]];
                    }
                    [arrM addObject:dicM];
                }
                _result = arrM;
                
                
                if([_datas count])
                {
                    [weakSelf layoutLineChartView];

                    [weakSelf layoutReportView];
                }
                else
                {
                    [_lineChartView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                    [_colTableview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                    [_lineChartView removeFromSuperview];
                    [_colTableview removeFromSuperview];
                    
                    [[[UIToastView alloc]initWithTitle:@"没有查询到数据"]show];
                }
            });
        }
    }];
}


- (void)dateChooseAction:(UIButton *)sender
{
    //NSLog(@"datechooseAction");
    if(_currentDate == nil) {
        _currentDate = [NSDate dateWithTimeIntervalSinceNow:-24 * 3600 * 1];
    }
    
    _hbDatePickerView = [HBDatePickerView instanceDatePickerView];
    _hbDatePickerView.currentDate = _currentDate;
    [_hbDatePickerView layoutHBDatePickerViewWithDateType:_filterIndex];
    [_hbDatePickerView setDelegate:self];
    [_hbDatePickerView show];
}

#pragma mark - CHTableViewProtocol
- (void)CHTableView:(CHTableView *)view didSelectRow:(int)row rowData:(NSArray *)rowData {
    if(_lineChartView)
    {
        [_lineChartView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_lineChartView removeFromSuperview];
    }
    
    _specicalData = [rowData copy];
    _specialRow = row;
    
    [self layoutLineChartView];
    
}

- (void) CHTableView:(CHTableView *)view didSelectCell:(int)row column:(int)column rowData:(NSArray*)rowData
{
    NSLog(@"row:%d,column:%d,rowData:%@",row,column,rowData);
    
    if(column == 0)
    {
        if(_lineChartView)
        {
            [_lineChartView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [_lineChartView removeFromSuperview];
        }
        
        _specicalData = [rowData copy];
        _specialRow = row;
        
        [self layoutLineChartView];        
    }
    else
    {
        NSLog(@"跳转到2.1.5功能使用分析（钻取地市和部门）--");
        
        //禁用或者响应左侧的点击事件
        if(_isShowDepartmentAnalyze) return;
        
        //跳转地市
        GDFunctionAnalyzeController *vc = [[GDFunctionAnalyzeController alloc]init];
        
        if(!_isShowCityAnalyze && !_isShowDepartmentAnalyze)
        {
            vc.isShowCityAnalyze = YES;
        }
        else if (_isShowCityAnalyze && !_isShowDepartmentAnalyze)
        {
            vc.isShowCityAnalyze = NO;
            vc.isShowDepartmentAnalyze = YES;
            vc.city = _datas[row][0];
        }
        vc.filterIndex = _filterIndex;
        //_naviTitle 为功能项
        vc.naviTitle = _naviTitle;
        [self pushViewController:vc];
    }
}

#pragma mark - HBDatePickerViewDelegate
- (void)getSelectDates:(NSArray *)dates type:(HBDateType)type
{
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc]init];
    dateformatter.dateFormat = @"yyyy-MM-dd";
    
    switch (type) {
        case YearMonthDayType: // TODO 日期确定选择
        {
            NSLog(@"YearMonthDayType:%@",[dateformatter stringFromDate:[dates firstObject]]);
            
            _startDateStr = [dateformatter stringFromDate:[dates firstObject]];
        }
            break;
        case WeekOfYearType:  // TODO 日期确定选择
        {
            NSLog(@"WeekOfYearType:%@ %@",[dateformatter stringFromDate:dates[0]], [dateformatter stringFromDate:dates[1]]);
            
            _startDateStr = [dateformatter stringFromDate:dates[0]];
            _endDateStr   = [dateformatter stringFromDate:dates[1]];
        }
            break;
        case YearMonthAtoZType: // TODO 起始结束日期确定选择
        {
            NSLog(@"YearMonthAtoZType:%@ %@",[dateformatter stringFromDate:dates[0]], [dateformatter stringFromDate:dates[1]]);
            
            //间隔（不超过10个月）
            NSArray *startArr = [[dateformatter stringFromDate:dates[0]] componentsSeparatedByString:@"-"];
            NSArray *endArr   = [[dateformatter stringFromDate:dates[1]]componentsSeparatedByString:@"-"];
            
            int sy = [startArr[0] intValue];
            int ey = [endArr[0] intValue];
            int sm = [startArr[1] intValue];
            int em = [endArr[1] intValue];
            
            //年相同, 或不同
            if(((sy == ey) && (em - sm <= 10)) || ((sy < ey) && (em + 12 - sm <= 10)))
            {
                _startDateStr = [dateformatter stringFromDate:dates[0]];
                _endDateStr   = [dateformatter stringFromDate:dates[1]];
            }
            else
            {
                [[[UIToastView alloc]initWithTitle:@"输入的月份间隔大于10,请重新输入!"]show];
                return;
            }
        }
            break;
        default:
            break;
    }
    
    _currentDate = [NSDate dateFromString:_endDateStr dateFormat:@"yyyy-MM-dd"];
    //如果选择的时间大于今天
    if([_currentDate compare:[NSDate date]] == NSOrderedDescending) {
        _currentDate = [NSDate date];
    }
    
    //更新标题视图
    [self refreshSubHeaderTitle];
    
    //请求 暂时注释, 修改折线图的字典参数有误
    [self sendRequest];
}
@end
