//
//  CHDateSelectorView.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHDateSelectorView.h"


@interface CHDateSelectorView(){
    
}

@property (nonatomic ,strong) NSDate *currentDate;

@end

@implementation CHDateSelectorView

- (id)initWithFrame:(CGRect)frame Slicetype:(HBDateType)slicetype
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.slicetype = slicetype;
        [self setDatetime:[NSDate date]];
        
        _dateButton = [[UIButton alloc] init];
        self.userInteractionEnabled = YES;
        _dateButton.userInteractionEnabled = YES;
        [_dateButton addTarget:self action:@selector(datePicker:) forControlEvents:UIControlEventTouchUpInside];
        [_dateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [self addSubview:_dateButton];
        _dateButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setDatetime:(NSDate *)datetime {
    if(datetime == nil)return;
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc]init];
    dateformatter.dateFormat = @"yyyy-MM-dd";
    
    if (_slicetype == YearMonthDayType)
    {
        //默认前一天
        _startDateStr = [dateformatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-24 * 3600 * 1]];
        NSLog(@"_startDateStr:%@~ _endDateStr:%@",_startDateStr,_endDateStr);
    }
    else if(_slicetype == WeekOfYearType)
    {
        //默认一周前
        NSDate *previousWeekDate = [NSDate dateWithTimeIntervalSinceNow:- 24 * 3600 * 7];
        _startDateStr = [dateformatter stringFromDate:previousWeekDate];
        _endDateStr = [dateformatter stringFromDate:[NSDate date]];
        NSLog(@"_startDateStr:%@~ _endDateStr:%@",_startDateStr,_endDateStr);
    }
    else if(_slicetype == YearMonthAtoZType)
    {
        //默认以当月结束,上推一个月
        _endDateStr = [dateformatter stringFromDate:[NSDate date]];
        NSArray *endTimes   = [_endDateStr componentsSeparatedByString:@"-"];
        
        int ey = [endTimes[0]intValue];
        int em = [endTimes[1]intValue];
        
        NSArray *startTimes = @[@((em == 1)? ey-1: ey), (em == 1)? @12 : @(em - 1)];
        NSDate *startDate = [NSDate dateFromString:[NSString stringWithFormat:@"%@-%@",startTimes[0],startTimes[1]] dateFormat:@"yyyy-MM"];
        
        
//        NSDate *startDate = [dateformatter dateFromString:]];
        
        _startDateStr = [dateformatter stringFromDate:startDate];
        
        NSLog(@"_startDateStr:%@~ _endDateStr:%@",_startDateStr,_endDateStr);
        
    }else {
        _startDateStr = [dateformatter stringFromDate:[NSDate date]];
        NSLog(@"_startDateStr:%@~ _endDateStr:%@",_startDateStr,_endDateStr);
    }
    
    [self updateDatetime];
}

-(void)setSliceType:(HBDateType)slicetype {
    
    _slicetype = slicetype;
    [self setDatetime:[NSDate date]];
    [self updateDatetime];
    
}
-(void) layoutSubviews
{
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_dateButton(300)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_dateButton)]];
    //水平居中
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_dateButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_dateButton(20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_dateButton)]];
    
    //垂直居中
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_dateButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

    [super layoutSubviews];
}
- (void)updateDatetime{
    NSString *title=nil;
    if(_slicetype == YearMonthDayType) { //日
        NSArray *startTimes = [_startDateStr componentsSeparatedByString:@"-"];
        title = [NSString stringWithFormat:@"%d年%d月%d日",[startTimes[0] intValue],[startTimes[1] intValue],[startTimes[2] intValue]];
    }
    else if(_slicetype == WeekOfYearType){ //周
        
        NSArray *startTimes = [_startDateStr componentsSeparatedByString:@"-"];
        NSArray *endTimes   = [_endDateStr componentsSeparatedByString:@"-"];
        
        title = [NSString stringWithFormat:@"%d年%d月%d日~%d年%d月%d日",[startTimes[0] intValue],[startTimes[1] intValue],[startTimes[2] intValue],[endTimes[0] intValue],[endTimes[1] intValue],[endTimes[2] intValue]];
    }
    else if(_slicetype == YearMonthAtoZType){ //月
        NSArray *startTimes = [_startDateStr componentsSeparatedByString:@"-"];
        NSArray *endTimes   = [_endDateStr componentsSeparatedByString:@"-"];
        title = [NSString stringWithFormat:@"%d年%d月~%d年%d月",[startTimes[0] intValue],[startTimes[1] intValue],[endTimes[0] intValue],[endTimes[1] intValue]];
    }
    
    else{
        NSArray *startTimes = [_startDateStr componentsSeparatedByString:@"-"];
        title = [NSString stringWithFormat:@"%d年%d月%d日",[startTimes[0] intValue],[startTimes[1] intValue],[startTimes[2] intValue]];
    }
    [_dateButton setTitle:title forState:UIControlStateNormal];
 
}


- (void)datePicker:(UIButton *)sender{
    
    if(sender.tag >=100) {
        _slicetype = sender.tag - 100;
    }
    
    if(_currentDate == nil) {
        _currentDate = [NSDate dateWithTimeIntervalSinceNow:-24 * 3600 * 1];
    }
    
    
    HBDatePickerView *hbDatePickerView = [HBDatePickerView instanceDatePickerView];
    hbDatePickerView.currentDate = _currentDate;
    [hbDatePickerView layoutHBDatePickerViewWithDateType:_slicetype];
    [hbDatePickerView setDelegate:self];
    
    [hbDatePickerView show];
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
            _endDateStr = [dateformatter stringFromDate:[dates firstObject]];
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
    
    [self updateDatetime];
    
    
    if([_parentVC respondsToSelector:@selector(getSelectDates:type:)]){
        [_parentVC getSelectDates:dates type:type];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
