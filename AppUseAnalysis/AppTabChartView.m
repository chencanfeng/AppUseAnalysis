//
//  AppTabChartView.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "AppTabChartView.h"

#import "CHLineView.h"

#import "CHTableView.h"
#import "CHDateSelectorView.h"
#import "AppChartInfoViewController.h"



@interface AppTabChartView () <CHTableViewProtocol>
@property (weak, nonatomic) IBOutlet UILabel *dateL;
@property (weak, nonatomic) IBOutlet UIView *topTabV;
@property (weak, nonatomic) IBOutlet UIView *dateV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateViewH;

@property (weak, nonatomic) IBOutlet UIScrollView *chartScrollView;
@property (weak, nonatomic) IBOutlet UIView *listTableView;

@property (nonatomic, strong) CHLineView *lineView;
@property (nonatomic, strong) CHTableView *tableView;

@property (nonatomic, strong) UIView *bLine;

@property (nonatomic, strong) CHDateSelectorView *dateControl;
//@property (nonatomic,strong) HBDatePickerView *hbDatePickerView;
//参数
@property (nonatomic ,strong) NSArray * topButtons;
@property (nonatomic, strong) NSArray * urls;
@property (nonatomic, strong) NSArray * slicetypes;
@property (nonatomic, strong) NSArray * drillMores;
@property (nonatomic, strong) NSArray * urlParams;



@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) NSDictionary *urlparam;
@property (nonatomic,strong) NSString *drillMore;


@end

@implementation AppTabChartView




- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    
    
    
}

- (void)setModel:(NSArray *)model {
    _model = model;
    NSMutableArray *arrM1 = [NSMutableArray new];
    NSMutableArray *arrM2 = [NSMutableArray new];
    NSMutableArray *arrM3 = [NSMutableArray new];
    NSMutableArray *arrM4 = [NSMutableArray new];
    NSMutableArray *arrM5 = [NSMutableArray new];
    for (NSDictionary *dic in model) {
        [arrM1 addObject:dic[@"title"]];
        [arrM2 addObject:dic[@"url"]];
        [arrM3 addObject:dic[@"slicetype"]];
        [arrM4 addObject:dic[@"drillMore"]];
        [arrM5 addObject:dic[@"urlParams"]];
    }
    _topButtons = [arrM1 copy];
    _urls = [arrM2 copy];
    _slicetypes = [arrM3 copy];
    _drillMores = [arrM4 copy];
    _urlParams = [arrM5 copy];
    
    self.url = _urls[0];
    self.slicetype = [_slicetypes[0] integerValue];
    self.drillMore = _drillMores[0];
    self.urlparam = _urlParams[0];
    
    AppChartInfoViewController *vc = (AppChartInfoViewController*)self.parentVC;
    _dateControl = vc.dateControl;
    
    [self createTopV];
    
    [self query];
    
}

#pragma mark - Create UI
- (void)createTopV {
    
    CGFloat width = (kScreenWidth - ([_topButtons count] - 1))/[_topButtons count];
    
    for (int i = 0; i < [_topButtons count]; i ++)  {
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((width + 1) * i, 0, width, 32)];
        [self.topTabV addSubview:button];
        [button setTitle:_topButtons[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15.f];
        [button addTarget:self action:@selector(clickedTopV:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        if(i != [_topButtons count]) {
            UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(width * (i+1), 4, 1, 27)];
            [self.topTabV addSubview:lineV];
            lineV.backgroundColor = [UIColor lightGrayColor];
        }
    }
    
    _bLine = [[UIView alloc] initWithFrame:CGRectMake(width/4.f, 30, width/2.f, 1)];
    [self.topTabV addSubview:_bLine];
    _bLine.backgroundColor = [UIColor colorWithRed:0.220 green:0.529 blue:1.000 alpha:1.00];
    
    
    self.dateV.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.dateV.layer.borderWidth = 1.0;
    self.dateV.layer.cornerRadius = 10.f;
    [self.dateV.layer setMasksToBounds:YES];
    
    //时间显示的View
    [self.dateV addSubview:_dateControl];
    
    _dateControl.translatesAutoresizingMaskIntoConstraints=NO;
    [self.dateV addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_dateControl]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_dateControl)]];
    [self.dateV addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_dateControl]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_dateControl)]];
    [self updateDateViewWidth:_slicetype];
    
    if([_funcName isEqualToString:@"用户体验时延"]) {
        self.dateV.hidden = YES;
        self.dateViewH.constant = 0;
    }
}


-(void)updateDateViewWidth:(HBDateType)slicetype {
    if(slicetype == 0) {
        _dateViewWidth.constant = 150.f;
    }else if(slicetype ==1) {
        _dateViewWidth.constant = 300.f;
    }else if(slicetype ==2) {
        _dateViewWidth.constant = 300.f;
    }else {
        _dateViewWidth.constant = 150.f;
    }
}

- (void)createChartView {
    
    for (UIView *view in _lineView.subviews) {
        [view removeFromSuperview];
    }
    
    _lineView = nil;
    
    if(_lineView == nil) {
        _lineView = [[CHLineView alloc] initWithFrame:self.chartScrollView.bounds];
        [self.chartScrollView addSubview:_lineView];
    }
    
    _lineView.result = _result;
    _lineView.columns = _columns;
    _lineView.specailData = _specicalData;
    _lineView.specialRow = _specialRow;
    [_lineView createLineChartViewWithFrame:self.chartScrollView.bounds type:Line];

}

- (void)createTableView {
    
    for (UIView *view in _tableView.subviews) {
        [view removeFromSuperview];
    }
    
    _tableView = nil;
    
    if(_tableView == nil) {
        _tableView = [[CHTableView alloc] initWithFrame:self.listTableView.bounds];
        [self.listTableView addSubview:_tableView];
    }
    
    _tableView.result = _result;
    _tableView.columns = _columns;
    _tableView.drillMore = _drillMore;
    _tableView.delegate = self;
    [_tableView createTableViewWithFrame:self.listTableView.bounds];
    
}

#pragma mark - CHTableView 代理
- (void)CHTableView:(CHTableView *)view didSelectRow:(int)row rowData:(NSArray *)rowData {
    
    _specicalData = [rowData copy];
    _specialRow = (int)[_result count] - row - 1;
    
    [self createChartView];
}


- (void)CHTableView:(CHTableView *)view didSelectCell:(int)row column:(int)column rowData:(NSArray *)rowData {
    if(column == 0) {
        _specicalData = [rowData copy];
        _specialRow = (int)[_result count] - row - 1;
        
        [self createChartView];
    }else {
        AppChartInfoViewController *vc = [[AppChartInfoViewController alloc] init];
        vc.navTitle = @"部门活跃分析量";
        vc.funcName = @"部门活跃分析量";
        vc.cityName = rowData[0];
        vc.model = @[
                     @{@"title":@"日活跃量",
                       @"url":@"/gdmt/analysis/UserActivityOfDepartment.mt",
                       @"urlParams":@{},
                       @"slicetype":@0,
                       @"drillMore":@"NO"},
                     @{@"title":@"周活跃量",
                       @"url":@"/gdmt/analysis/UserActivityOfDepartment.mt",
                       @"urlParams":@{},
                       @"slicetype":@1,
                       @"drillMore":@"NO"},
                     @{@"title":@"月活跃量",
                       @"url":@"/gdmt/analysis/UserActivityOfDepartment.mt",
                       @"urlParams":@{},
                       @"slicetype":@2,
                       @"drillMore":@"NO"}
                     ];
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
    
    
}

- (UIViewController*) viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}



#pragma mark - 点击按钮
- (void)clickedTopV:(UIButton *)sender {
    CGFloat width = (kScreenWidth - ([_topButtons count] - 1))/[_topButtons count];
    CGRect rect = _bLine.frame;
    rect.origin.x = (width + 1) * sender.tag + width/4.f;
    _bLine.frame = rect;
    
    self.url = _urls[sender.tag];
    self.urlparam = _urlParams[sender.tag];
    self.slicetype = [_slicetypes[sender.tag] integerValue];
    self.drillMore = _drillMores[sender.tag];
    [self.dateControl setSliceType:_slicetype];
    [self query];
}


#pragma mark - 请求数据
- (void)query{
    [self updateDateViewWidth:_slicetype];
    if([_funcName isEqualToString:@"用户体验时延"]) {
        _urlparam = [_urlparam copy];
    }
    else if([_funcName isEqualToString:@"部门活跃分析量"]) {
        NSMutableDictionary *queryDateParams = [[self getQueryDatetime] mutableCopy];
        [queryDateParams setValue:_cityName == nil?@"":_cityName forKey:@"city"];
        _urlparam = [queryDateParams copy];
    }
    else {
        NSDictionary *queryDateParams = [self getQueryDatetime];
        _urlparam = [queryDateParams copy];
    }

    [[MTAPICenterCallManager sharedInstance] callAPIWithMethodName:_url params:_urlparam loadingHint:@"正在加载中.." doneHint:nil handleBlock:^(NSDictionary * _Nullable response) {
        
        if (![response[@"success"]isEqual:@(1)]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.16 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //错误提示写这里
                return ;
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [SVProgressHUD dismiss];
                NSArray *columns = response[@"columns"];
                NSArray *datas = response[@"dates"];
                
                NSMutableArray *arrM = [NSMutableArray new];
                for (int i = 0 ; i < [datas count]; i ++) {
                    NSArray *arr = datas[i];
                    NSMutableDictionary *dicM = [NSMutableDictionary new];
                    for (int j = 0; j < [columns count]; j ++) {
                        [dicM setValue:arr[j] forKey:columns[j]];
                    }
                    [arrM addObject:dicM];
                }
                _result = arrM;
                _columns = columns;
                
                
                if([_result count] == 0 || [_columns count] == 0) {
                    for (UIView *view in _lineView.subviews) {
                        [view removeFromSuperview];
                    }
                    
                    for (UIView *view in _tableView.subviews) {
                        [view removeFromSuperview];
                    }
                }else {
                
                    [self createChartView];
                    [self createTableView];
                }
                
            });
        }
    }];
    
    
}

- (NSDictionary *)getQueryDatetime{
    NSString *slicetype = @"天";
    NSString *begintime = @"";
    NSString *endtime= @"";
    
    NSArray *startTimes = [_dateControl.startDateStr componentsSeparatedByString:@"-"];
    NSArray *endTimes   = [_dateControl.endDateStr componentsSeparatedByString:@"-"];
    if(_slicetype == 0){
        begintime = [NSString stringWithFormat:@"%@-%@-%@",startTimes[0],startTimes[1],startTimes[2]];
        slicetype = @"天";
    }
    else if(_slicetype == 1){
        
        begintime = [NSString stringWithFormat:@"%@-%@-%@",startTimes[0],startTimes[1],startTimes[2]];
        endtime =  [NSString stringWithFormat:@"%@-%@-%@",endTimes[0],endTimes[1],endTimes[2]];
        slicetype = @"周";
    }
    else if(_slicetype == 2){
        
        begintime = [NSString stringWithFormat:@"%@-%@",startTimes[0],startTimes[1]];
        endtime =  [NSString stringWithFormat:@"%@-%@",endTimes[0],endTimes[1]];
        slicetype = @"月";
    }else{
        
        begintime = [NSString stringWithFormat:@"%@-%@-%@",startTimes[0],startTimes[1],startTimes[2]];
        slicetype = @"天";
    }
    
    NSDictionary *params = @{
                             @"granularity":slicetype,
                             @"beginTime":begintime,
                             @"endTime":endtime};
    
    return params;
}



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
@end
