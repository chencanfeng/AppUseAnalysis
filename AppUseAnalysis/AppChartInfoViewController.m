//
//  AppChartInfoViewController.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "AppChartInfoViewController.h"

#import "AppTabChartView.h"

#import "ArrowDirectionView.h"

@interface AppChartInfoViewController () {
    
    NSInteger _filterIndex;  //筛选下标(日,周,月)
    NSString *_startDateStr;  //开始日期字串
    NSString *_endDateStr;    //结束日期字串
    NSString *_granularity;    //当前选择粒度
}

@property (nonatomic , strong) ArrowDirectionView * rightBtnview;
//控制选择时间View的加载
@property (nonatomic,assign) BOOL showRightView;
@property (nonatomic, strong) AppTabChartView *curQueryView;

@end

@implementation AppChartInfoViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        
        _validslicetypes = @[@"天",@"周",@"月"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setNaviTitle:_navTitle leftButtonShow:YES rightButtom:nil];
    if([_funcName isEqualToString:@"用户活跃量分析"]) {
        //右上角的时间按钮
        UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [infoBtn setFrame:CGRectMake(0, 0, 25, 25)];
        [infoBtn setImage:[UIImage imageNamed:@"btn_timer"] forState:UIControlStateNormal];
        [infoBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoBtn];
    }
    
    //点击时间按钮弹出的查询面板
    [self createDateControl];
    [self.view addSubview:self.rightBtnview];
    self.rightBtnview.hidden = YES;
    
    
    //添加自定义view
    [self.view addSubview:self.curQueryView];
    _curQueryView.translatesAutoresizingMaskIntoConstraints=NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_curQueryView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_curQueryView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_curQueryView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_curQueryView)]];
    
    [self.view bringSubviewToFront:self.rightBtnview];
    
    
    
}
#pragma mark - Create UI



- (void)createDateControl {
    HBDateType sliceType = [self.model[0][@"slicetype"] integerValue];
    self.dateControl = [[CHDateSelectorView alloc] initWithFrame:CGRectZero Slicetype:sliceType];
    self.dateControl.backgroundColor = [UIColor clearColor];
    self.dateControl.parentVC = self;
    [self.dateControl setSliceType:0]; //天
    
    if([_funcName isEqualToString:@"用户体验时延"]) {
        self.dateControl.hidden = YES;
    }
}


#pragma mark - HBDatePickerViewDelegate
- (void)getSelectDates:(NSArray *)dates type:(HBDateType)type
{
    
    if (_curQueryView) {
        _curQueryView.slicetype = type;
        
        [_curQueryView query];
    }
}


// 点击时间 弹出下拉框
-(void) rightBtnClick:(UIButton *)sender {
    self.showRightView=!self.showRightView;
    if (self.showRightView==NO) {
        _rightBtnview.hidden = YES;
    }else{
        _rightBtnview.hidden = NO;
        
    }
}


- (void) touchDown {
    self.showRightView=!self.showRightView;
    if (self.showRightView==NO) {
        _rightBtnview.hidden = YES;
    }
}


#pragma mark - 懒加载
- (AppTabChartView *)curQueryView {
    
    if(_curQueryView == nil) {
        _curQueryView =  [[[NSBundle mainBundle] loadNibNamed:@"AppTabChartView"owner:nil options:nil] objectAtIndex:0];
        _curQueryView.parentVC = self;
        _curQueryView.funcName = self.funcName;
        _curQueryView.cityName = self.cityName;
        _curQueryView.model = self.model;
        
    }
    return _curQueryView;
    
}


- (ArrowDirectionView *)rightBtnview {
    
    if (_rightBtnview == nil) {
        _rightBtnview=[ArrowDirectionView new];
        _rightBtnview.arrowDirection=1;
        _rightBtnview.arrowPosition=1;
        _rightBtnview.borderColor=[UIColor grayColor];
        _rightBtnview.contentBgColor=[UIColor whiteColor];
        
        NSMutableArray * btnArr = [NSMutableArray array];
        for (NSString  * string in self.validslicetypes) {
            if ([string isEqualToString:@"天"] || [string isEqualToString:@"日"]) {
                [btnArr addObject:@"日粒度"];
            }
            if ([string isEqualToString:@"周"]) {
                [btnArr addObject:@"周粒度"];
            }
            if ([string isEqualToString:@"月"]) {
                [btnArr addObject:@"月粒度"];
            }
        }
        
        _rightBtnview.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-100, 0, 90, [btnArr count] * 40);
        
        for (int i = 0; i < btnArr.count; i ++) {
            
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeSystem];
            btn.frame=CGRectMake(0, i*40, 90, 40);
            [btn setTitle:btnArr[i] forState:UIControlStateNormal];
            btn.tag=100 + i;
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            [btn addTarget:_dateControl action:@selector(datePicker:) forControlEvents:UIControlEventTouchUpInside];
            [btn addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
            
            
            [_rightBtnview addSubview:btn];
        }
    }
    
    return _rightBtnview;
    
    
    
    
}
#pragma mark - others
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
