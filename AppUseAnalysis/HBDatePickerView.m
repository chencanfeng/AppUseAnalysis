//
//  HBDatePickerView.m
//  FengurUWDatePickerDemo
//
//  Created by MasterCom on 2017/5/17.
//  Copyright © 2017年 UWFengur. All rights reserved.
//

#import "HBDatePickerView.h"
#import "NSDate+Extension.h"

#define MAXYEAR 2050
#define MINYEAR 1970

@interface HBDatePickerView()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSString *_selectDateStr;   //常用时间串
    NSString *_selectStartDateStr;  //起始时间串
    NSString *_selectEndDateStr;    //结束时间串
    
    
    NSMutableArray  *_yearArray;  //设置个20年够用了吧
    NSMutableArray  *_monthArray; //设置月份
    NSMutableArray  *_dayArray;   //天数组
    NSMutableArray  *_weekArray;  //周数组 一年多少周

    //记录位置
    NSInteger _yearIndex;
    NSInteger _monthIndex;
    NSInteger _dayIndex;
    NSInteger _weekIndex;
    
    NSInteger _yearIndex2;  //YearMonthAtoZType 结束年份
    NSInteger _monthIndex2; //YearMonthAtoZType 结束月份
}

@property (nonatomic, assign) HBDateType type;

@property (nonatomic, strong) NSDate *scrollToDate;//滚到指定日期
@property (nonatomic, strong) NSDate *startDate; //开始
@property (nonatomic, strong) NSDate *endDate;//结束

//根据type调整约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hbDatepickerViewH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerView1TopToTitleView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerView1BottomToSureBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerViewcenterY; //默认带导航栏

@end

@implementation HBDatePickerView

#pragma mark - Load
+ (HBDatePickerView *)instanceDatePickerView
{
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"HBDatePickerView" owner:nil options:nil];
    return [nibView objectAtIndex:0];
}

#pragma mark - Layout
- (void)layoutHBDatePickerViewWithDateType:(HBDateType)type
{
    [self initDatas];
    
    _type = type; //获取需求_type
    
    _pickerView1.delegate = self;
    _pickerView1.dataSource = self;
    
    HBViewBorderRadius(_pickerView1, 2, 2, [self colorWithHexString:@"#38b9dd"]);
    
    self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.7];

    _grayBgBtn.alpha = 0.2;
    _grayBgBtn.backgroundColor = [UIColor grayColor];
    
    switch (type)
    {
        case YearMonthDayType: case WeekOfYearType:
        {
            _hbDatepickerViewH.constant = 225;
            _datePickerView1TopToTitleView.constant = 20;
            _datePickerView1BottomToSureBtn.constant = 20;
            _startLabel.hidden = YES;
            _endLabel.hidden = YES;
            _pickerView2.hidden = YES;
        }
            break;

        case YearMonthAtoZType:
        {
            _hbDatepickerViewH.constant = 430;
            _pickerView2.delegate = self;
            _pickerView2.dataSource = self;
            HBViewBorderRadius(_pickerView2, 2, 2, [self colorWithHexString:@"#38b9dd"]);
        }
            break;
        default:
            break;
    }
    
    [self getNowDate:_scrollToDate animated:YES];
}

#pragma mark - Private
- (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // 判断前缀
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;
    //R、G、B
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}



#pragma mark - Tools
//数据源初始化
- (void)initDatas
{
    if (!_scrollToDate)
    {
        _scrollToDate = self.currentDate ? self.currentDate : [NSDate date];
    }
    
    _yearArray = [self setArray:_yearArray];
    _monthArray = [self setArray:_monthArray];
    _dayArray = [self setArray:_dayArray];
    _weekArray = [self setArray:_weekArray];
    
    //年
    for (NSInteger i = MINYEAR; i < MAXYEAR; i++)
    {
        NSString *yearNum = [NSString stringWithFormat:@"%ld",(long)i];
        [_yearArray addObject:yearNum];
    }
    
    //月
    for (NSInteger i = 1; i <= 12; i ++)
    {
        NSString *monthNum = [NSString stringWithFormat:@"%02ld",(long)i];
        [_monthArray addObject:monthNum];
    }

    
    //天由年月确定
    
    //周由年确定
    //_weekArray = [self ]
}

- (NSMutableArray *)setArray:(id)mutableArray
{
    if (mutableArray)
        [mutableArray removeAllObjects];
    else
        mutableArray = [NSMutableArray array];
    return mutableArray;
}

//通过年月求每月天数
- (NSInteger)daysfromYear:(NSInteger)year andMonth:(NSInteger)month
{
    NSInteger num_year  = year;
    NSInteger num_month = month;
    
    BOOL isrunNian = num_year%4==0 ? (num_year%100==0? (num_year%400==0?YES:NO):YES):NO;
    switch (num_month) {
        case 1:case 3:case 5:case 7:case 8:case 10:case 12:{
            [self setdayArray:31];
            return 31;
        }
        case 4:case 6:case 9:case 11:{
            [self setdayArray:30];
            return 30;
        }
        case 2:{
            if (isrunNian) {
                [self setdayArray:29];
                return 29;
            }else{
                [self setdayArray:28];
                return 28;
            }
        }
        default:
            break;
    }
    return 0;
}

//设置每月的天数数组
- (void)setdayArray:(NSInteger)num
{
    [_dayArray removeAllObjects];
    for (int i=1; i<=num; i++) {
        [_dayArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
}

- (NSArray *)getNumberOfRowsInComponent
{
    NSInteger yearNum = _yearArray.count;
    NSInteger monthNum = _monthArray.count;
    NSInteger dayNum = [self daysfromYear:[_yearArray[_yearIndex] integerValue] andMonth:[_monthArray[_monthIndex] integerValue]];

    NSInteger weekNum = 52; //默认52周
    //[[self getWeekWithYear:[_yearArray[_yearIndex] integerValue]] count];
    
    //NSInteger timeInterval = MAXYEAR - MINYEAR;
    
    switch (_type) {
        case YearMonthDayType:
            return @[@(yearNum),@(monthNum),@(dayNum)];
            break;
        case WeekOfYearType:
            return @[@(yearNum),@(weekNum)];
            break;
        case YearMonthAtoZType:
            return @[@(yearNum),@(monthNum)];
            break;
   
        default:
            return @[];
            break;
    }
}

//滚动到指定的时间位置
- (void)getNowDate:(NSDate *)date animated:(BOOL)animated
{
    if (!date)
    {
        date = [NSDate date];
    }
    
    _yearIndex  = date.year-MINYEAR;
    _monthIndex = date.month-1;
    _dayIndex = date.day-1;
    _weekIndex = 0; //默认为0
    
    //--->  当前所在的周(看需求)
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitWeekOfYear fromDate:date];
    _weekIndex = [comp weekOfYear];
    //----
    
    _yearIndex2 = _yearIndex; //默认
    _monthIndex2 = _monthIndex; //默认
    
    //更新周数组
    _weekArray = [NSMutableArray arrayWithArray:[self getWeekWithYear:(MINYEAR + _yearIndex)]];

    //更新天数组
    [self daysfromYear:date.year andMonth:date.month];

    
    //循环滚动时需要用到
    //preRow = (self.scrollToDate.year-MINYEAR)*12+self.scrollToDate.month-1;
    
    NSArray *indexArray;
    NSArray *indexArray2;

    
    switch (_type) {
        case YearMonthDayType:
        {
            indexArray = @[@(_yearIndex),@(_monthIndex),@(_dayIndex)];
        }
            break;
           
        case WeekOfYearType:
        {
            indexArray = @[@(_yearIndex),@(_weekIndex)];
            
            NSDateFormatter *ymdFormatter = [[NSDateFormatter alloc]init];
            ymdFormatter.dateFormat = @"yyyy-MM-dd";
            
            NSString *weekStr = _weekArray[_weekIndex];
            NSLog(@"%@ - %ld",weekStr,_weekIndex);
            NSArray *arr = [weekStr componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]];
            arr = [arr[1] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-月"]];
            NSLog(@"y:%@-%@-%@~%@-%@",_yearArray[_yearIndex],arr[0],arr[1],arr[2],arr[3]);
            
            //重新解析成date
            _startDate = [self getNowDateFromatAnDate:[ymdFormatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@",_yearArray[_yearIndex],arr[0],arr[1]]]];
            _endDate = [self getNowDateFromatAnDate:[ymdFormatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@",_yearArray[_yearIndex],arr[2],arr[3]]]];
        }
            break;
        case YearMonthAtoZType:
        {
            _monthIndex = _monthIndex2 - 1;

            NSDateFormatter *ymdFormatter = [[NSDateFormatter alloc]init];
            ymdFormatter.dateFormat = @"yyyy-MM";
            
            //开始时间提前一个月_monthIndex-1
            indexArray = @[@(_yearIndex),@(_monthIndex)];
            
            _yearIndex2 = date.year-MINYEAR;
            _monthIndex2 = date.month-1;
            indexArray2 = @[@(_yearIndex2),@(_monthIndex2)];
            
            [_pickerView2 reloadAllComponents];
            
            NSLog(@"%@-%@~%@%@",_yearArray[_yearIndex],_monthArray[_monthIndex],_yearArray[_yearIndex2],_monthArray[_monthIndex2]);
            
            //重新解析成date
            _startDate = [self getNowDateFromatAnDate:[ymdFormatter dateFromString:[NSString stringWithFormat:@"%@-%@",_yearArray[_yearIndex],_monthArray[_monthIndex]]]];
            _endDate = [self getNowDateFromatAnDate:[ymdFormatter dateFromString:[NSString stringWithFormat:@"%@-%@",_yearArray[_yearIndex],_monthArray[_monthIndex2]]]];
        }
            break;
        default:
            break;
    }
    

    //暂时无循环滚动
    for (int i = 0; i < indexArray.count; i++)
    {
        if (_type == YearMonthDayType || _type == WeekOfYearType) {

            [_pickerView1 selectRow:[indexArray[i] integerValue] inComponent:i animated:animated];
        }
        else
        {
            [_pickerView1 selectRow:[indexArray[i] integerValue] inComponent:i animated:animated];
            [_pickerView2 selectRow:[indexArray2[i] integerValue] inComponent:i animated:animated];
        }
    }
    
    [_pickerView1 reloadAllComponents];
}



#pragma mark - Action
- (IBAction)sureBtnAction:(id)sender {
    
    
    //获取数据
    if (_type == YearMonthDayType)
    {
        //这个使用扩展再转一次出现误差
        //NSDate *pickerView1Date = [_scrollToDate dateWithFormatter:@"yyyy-MM-dd"];
        //NSLog(@"pickerView1Str:%@",pickerView1Date);
        
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyy-MM-dd";
        
        NSLog(@"---%@",[formatter stringFromDate:_scrollToDate]);
        
        [self.delegate getSelectDates:@[_scrollToDate] type:_type];
        
    }
    else if (_type == WeekOfYearType)
    {
        [self.delegate getSelectDates:@[_startDate,_endDate] type:_type];
    }
    else
    {
        //起始结束日期
        
        [self.delegate getSelectDates:@[_startDate,_endDate] type:_type];

    }
    
    [self dissmiss];
}

- (IBAction)cancelBtnAction:(id)sender {
    
    [self dissmiss];
}

- (IBAction)backGroundBtnAction:(id)sender {
    
    [self dissmiss];
}

- (void)show
{
    [self setFrame:[UIApplication sharedApplication].keyWindow.bounds];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.pickerViewcenterY.constant = 0;
    [self layoutIfNeeded];
    
//    [UIView animateWithDuration:0.3 animations:^{
//        self.pickerViewcenterY.constant = -32;
//        [self layoutIfNeeded];
//    }];
}

- (void)dissmiss
{
    [UIView animateWithDuration:0.3 animations:^{
        self.pickerViewcenterY.constant = self.frame.size.height;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self removeFromSuperview];
    }];
}


#pragma mark - UIPickerViewDataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    switch (_type) {
        case YearMonthDayType:
        {
            return 3;
        }
            break;
        case WeekOfYearType:
        {
            return 2;
        }
            break;
        case YearMonthAtoZType:
        {
            return 2;
        }
            break;
        default:
            break;
    }
    return 0;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *numberArr = [self getNumberOfRowsInComponent];
    return [numberArr[component] integerValue];
}

    
#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (_type) {
        case YearMonthDayType:
        {
            return _pickerView1.bounds.size.width/3;
        }
            break;
        case WeekOfYearType:
        {
            if (component == 0)
            {
                return _pickerView1.bounds.size.width/4;
            }
            else
            {
                return _pickerView1.bounds.size.width *3/4;
            }
        }
            break;
        case YearMonthAtoZType:
        {
            return _pickerView1.bounds.size.width/3;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *customLabel = (UILabel *)view;
    if (!customLabel)
    {
        customLabel = [[UILabel alloc] init];
        customLabel.textAlignment = NSTextAlignmentCenter;
        [customLabel setFont:[UIFont systemFontOfSize:14]];
    }
    NSString *title;
    
    switch (_type) {
        case YearMonthDayType:
            if (component==0) {
                title = _yearArray[row];
            }
            if (component==1) {
                title = _monthArray[row];
            }
            if (component==2) {
                title = _dayArray[row];
            }
            break;
        case WeekOfYearType:
            if (component==0) {
                title = _yearArray[row];
            }
            if (component==1) {
                title = _weekArray[row];
            }
            break;
        case YearMonthAtoZType:
            if (component==0) {
                title = _yearArray[row];
            }
            if (component==1) {
                title = _monthArray[row];
            }
            break;
        default:
            title = @"";
            break;
    }
    
    //HBViewBorderRadius(customLabel, 0, 1, [UIColor blackColor]);
    
    customLabel.text = title;
    customLabel.textColor = [UIColor blackColor];
    if (row%2 ==0)
    {
        customLabel.backgroundColor = [self colorWithHexString:@"#dcfcff"];
    }
    
    return customLabel;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *dateStr = nil;
    
    switch (_type) {
        case YearMonthDayType:
        {
            NSDateFormatter *ymdFormatter = [[NSDateFormatter alloc]init];
            ymdFormatter.dateFormat = @"yyyy-MM-dd";
            
            if (component==0) {
                _yearIndex = row;
            }
            if (component==1) {
                _monthIndex = row;
            }
            if (component==2) {
                _dayIndex = row;
            }
            
            //更新天数
            if (component == 0 || component == 1)
            {
                [self daysfromYear:[_yearArray[_yearIndex] integerValue] andMonth:[_monthArray[_monthIndex] integerValue]];
                
                if (_dayArray.count -1 <_dayIndex)
                {
                    _dayIndex = _dayArray.count - 1;
                }
            }
            dateStr = [NSString stringWithFormat:@"%@-%@-%@",_yearArray[_yearIndex],_monthArray[_monthIndex],_dayArray[_dayIndex]];
            _scrollToDate = [self getNowDateFromatAnDate:[ymdFormatter dateFromString:dateStr]];
        }
            break;
        case WeekOfYearType:
        {
            NSDateFormatter *ymdFormatter = [[NSDateFormatter alloc]init];
            ymdFormatter.dateFormat = @"yyyy-MM-dd";
            
            if (component==0) {
                _yearIndex = row;
                
                //根据年份更新周数组
                _weekArray = [NSMutableArray arrayWithArray:[self getWeekWithYear:[_yearArray[_yearIndex] integerValue]]];
                
                //滑动年份时默认周选中第0行(这个看需求)
                //[_pickerView1 selectRow:0 inComponent:1 animated:YES];

                [pickerView reloadComponent:1];
            }
            if (component==1) {
                _weekIndex = row;
            }
            
            NSString *weekStr = _weekArray[_weekIndex];
            NSArray *arr = [weekStr componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]];
            arr = [arr[1] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-月"]];
            NSLog(@"y:%@-%@-%@~%@-%@",_yearArray[_yearIndex],arr[0],arr[1],arr[2],arr[3]);
            
            //2017-05-19 11:55:41.178 时间选择器[90190:1429263] y:2013-12-31~1-6
            //若前者月份大于后者, 年号应-1
            NSInteger yIndex1 = _yearIndex;
            NSInteger yIndex2 = _yearIndex;

            if([arr[0]intValue] > [arr[2] intValue])
            {
                yIndex1 -= 1;
            }
            
            //重新解析成date
            _startDate = [self getNowDateFromatAnDate:[ymdFormatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@",_yearArray[yIndex1],arr[0],arr[1]]]];
            _endDate = [self getNowDateFromatAnDate:[ymdFormatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@",_yearArray[yIndex2],arr[2],arr[3]]]];
        }
            break;
        case YearMonthAtoZType:
        {
            NSDateFormatter *ymFormatter = [[NSDateFormatter alloc]init];
            ymFormatter.dateFormat = @"yyyy-MM";
            
            
            if (pickerView == _pickerView1)
            {
                if (component==0) {
                    _yearIndex = row;
                }
                if (component==1) {
                    _monthIndex = row;
                }
                NSLog(@"YearMonthAtoZTypeStart:%@", [NSString stringWithFormat:@"%@-%@",_yearArray[_yearIndex],_monthArray[_monthIndex]]);
                
                _startDate = [self getNowDateFromatAnDate:[ymFormatter dateFromString:[NSString stringWithFormat:@"%@-%@",_yearArray[_yearIndex],_monthArray[_monthIndex]]]];
            }
            else
            {
                if (component==0) {
                    _yearIndex2 = row;
                }
                if (component==1) {
                    _monthIndex2 = row;
                }
                NSLog(@"YearMonthAtoZTypeEnd:%@", [NSString stringWithFormat:@"%@-%@",_yearArray[_yearIndex2],_monthArray[_monthIndex2]]);
                
                _endDate = [self getNowDateFromatAnDate:[ymFormatter dateFromString:[NSString stringWithFormat:@"%@-%@",_yearArray[_yearIndex2],_monthArray[_monthIndex2]]]];
            }
        }
            break;
        default:
            break;
    }
    
    NSLog(@"_yearIndex:%ld,_monthIndex:%ld,_dayIndex:%ld,_weekIndex:%ld",(long)_yearIndex,(long)_monthIndex,(long)_dayIndex,(long)_weekIndex);
    
    [pickerView reloadAllComponents];

}


#pragma mark ----------以下部分为获取周数组
- (NSArray *)getWeekWithYear:(NSInteger)year
{
    NSMutableArray *weekArr = [NSMutableArray array];
    
    // 日期格式化
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    
    //2017-1-1
    for (int i = 0; i < 52; i ++)
    {
        // 得到今年一月一号的时间
        NSDate *getFirstWeekOne = [NSDate dateWithTimeIntervalSinceNow:[self getYearFirstWeekOneWithYear:year].timeIntervalSinceNow + (24 * 60 * 60 * 7 * i)];
        
        //往后推6天
        NSDate *getEndWeek = [NSDate dateWithTimeIntervalSinceNow:getFirstWeekOne.timeIntervalSinceNow + (24 * 60 * 60 *6)];
        
        NSArray *startArr  = [[[formatter stringFromDate:getFirstWeekOne] componentsSeparatedByString:@" "][0] componentsSeparatedByString:@"-"];
        
        NSArray *endArr    = [[[formatter stringFromDate:getEndWeek] componentsSeparatedByString:@" "][0] componentsSeparatedByString:@"-"];
        
        NSString *weekDateStr = [NSString stringWithFormat:@"第%d周(%d月%d-%d月%d)",i+1,[startArr[1] intValue],[startArr[2] intValue],[endArr[1] intValue],[endArr[2] intValue]];
        
        [weekArr addObject:weekDateStr];
    }
    
    return weekArr;
}

- (NSDate *)getYearFirstWeekOneWithYear:(NSInteger)year
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"YYYY-MM-dd";
    // 得到year年一月一号的时间
    
    NSDate *yearFirstDate = [self getNowDateFromatAnDate:[formatter dateFromString:[NSString stringWithFormat:@"%ld-01-01",(long)year]]];
    
    //_scrollToDate = [[NSDate date:dateStr WithFormat:@"yyyy-MM-dd"] dateWithFormatter:@"yyyy-MM-dd"];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitWeekday| NSCalendarUnitWeekOfYear fromDate:yearFirstDate];
    
    //date:2016-05-18 09:23:51 +0000   ->  第21周
    NSInteger week = [comp weekOfYear];   //21
    
    // 4 -- > 星期三  (1 -- 7)  星期日 - > 六
    NSInteger weekDay = [comp weekday];  //是星期几
 
    NSDate *weekFirstDay;
    if(weekDay == 1) {
        //如果星期日则加一天，因为第一天是星期一
        weekFirstDay = [self getNowDateFromatAnDate:[NSDate dateWithTimeInterval: - 6 * 24 * 3600 sinceDate:yearFirstDate]];
    }else {
        //由周一开始改为(weekDay - 2)
        weekFirstDay = [self getNowDateFromatAnDate:[NSDate dateWithTimeInterval:- (weekDay - 2) * 24 * 3600 sinceDate:yearFirstDate]];
    }
    
    
    
    //返回当年第一周的第一天
    NSDate *yearFirstDay = [NSDate dateWithTimeInterval:- (week - 1) * 24 *3600 * 7 sinceDate:weekFirstDay];

    return yearFirstDay;
}

/**
 转换成UTC/GMT
 */
- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}


@end
