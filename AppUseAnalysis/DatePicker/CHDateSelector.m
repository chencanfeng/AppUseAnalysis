//
//  CHDateSelector.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHDateSelector.h"

#define TOOLBAR_HEIGHT 44
@interface CHDateSelector(){
    UIToolbar *toolbar;
    
    UIDatePicker *datePicker;
    UIPickerView *monthPicker;
    UIPickerView *weekPicker;
    UIPickerView *quarterPicker;
    UIView *multidayPicker;
    UIDatePicker *startPicker;
    UIDatePicker *endPicker;
    UIButton *startBtn;
    UIButton *endBtn;
    
    NSArray *yearName;
    NSArray *yearValues;
    
    NSArray *monthName;
    NSArray *monthValues;
    
    NSArray *weekNames;
    NSArray *weekValues;
    
    UIButton *dateButton;
    UIButton *monthButton;
    UIButton *weekButton;
    UIButton *quarterButton;
    UIButton *multidayButton;
    
    int totalweeks;
    
}

@end

@implementation CHDateSelector

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _slicetype = @"天";
        _validslicetypes = [NSArray arrayWithObject:_slicetype];
        NSString *datestr = [NSDate dayStringFromNow:-1];
        _datetime = [NSDate dateFromString:datestr dateFormat:@"yyyy-MM-dd"];
        _totaldays = 1;
        [self createSubViews:frame];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame initdate:(NSDate*)datetime slicetype:(NSString*)slicetype validslicetypes:(NSArray*)validslicetypes totaldays:(int)totaldays
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _slicetype = slicetype;
        _validslicetypes = validslicetypes;
        _datetime = datetime;
        _totaldays = totaldays;
        [self createSubViews:frame];
    }
    return self;
}

-(void)createSubViews:(CGRect)rect{
    
    [self setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    //PickerView高度只有三个：162,180,216，这里选定216,并重置rect
    rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, TOOLBAR_HEIGHT+216);
    
    toolbar = [self createToolbar:CGRectMake(0, 0, rect.size.width, TOOLBAR_HEIGHT)];
    [self addSubview:toolbar];
    datePicker = [self createDatePicker:CGRectMake(0, TOOLBAR_HEIGHT, rect.size.width, rect.size.height-TOOLBAR_HEIGHT)];
    datePicker.backgroundColor=[UIColor grayColor];
    [self addSubview:datePicker];
    datePicker.hidden=YES;
    
    monthPicker = [self createMonthPicker:CGRectMake(0, TOOLBAR_HEIGHT, rect.size.width, rect.size.height-TOOLBAR_HEIGHT)];
    monthPicker.backgroundColor=[UIColor grayColor];
    [self addSubview:monthPicker];
    monthPicker.hidden=YES;
    
    multidayPicker = [self createMultidayPicker:CGRectMake(0, TOOLBAR_HEIGHT, rect.size.width, rect.size.height-TOOLBAR_HEIGHT)];
    multidayPicker.backgroundColor=[UIColor grayColor];
    [self addSubview:multidayPicker];
    multidayPicker.hidden=YES;
    
    weekPicker = [self createWeekPicker:CGRectMake(0, TOOLBAR_HEIGHT, rect.size.width, rect.size.height-TOOLBAR_HEIGHT)];
    weekPicker.backgroundColor=[UIColor grayColor];
    [self addSubview:weekPicker];
    weekPicker.hidden=YES;
    
    quarterPicker = [self createQuarterPicker:CGRectMake(0, TOOLBAR_HEIGHT, rect.size.width, rect.size.height-TOOLBAR_HEIGHT)];
    quarterPicker.backgroundColor=[UIColor grayColor];
    [self addSubview:quarterPicker];
    quarterPicker.hidden=YES;
    
    if([_slicetype isEqualToString:@"天"]){
        datePicker.hidden = NO;
    }else if([_slicetype isEqualToString:@"月"]){
        monthPicker.hidden = NO;
    }else if([_slicetype isEqualToString:@"周"]){
        weekPicker.hidden = NO;
    }else if([_slicetype isEqualToString:@"季"]){
        quarterPicker.hidden = NO;
    }else if([_slicetype isEqualToString:@"多天"]){
        multidayPicker.hidden = NO;
    }else{
        datePicker.hidden = NO;
    }
}

-(UIToolbar*)createToolbar:(CGRect)rect{
    UIToolbar *tb = [[UIToolbar alloc]initWithFrame:rect];
    [tb setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#D2EBF9"]] forToolbarPosition:0 barMetrics:0];
    [tb setTranslucent:NO];
	tb.barStyle = UIBarStyleDefault;
    NSMutableArray *buttons = [[NSMutableArray alloc]init];
    
    UIImage *bgSliceImage = [[UIImage imageNamed:@"bg_titlebar" bundle:[MTGlobalInfo sharedInstance].commBundle] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0) resizingMode:UIImageResizingModeStretch];
    
    UIView *sliceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    
    UIButton *button = nil;
    if([_validslicetypes count]<=1){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
        [label setTextColor:[UIColor blackColor]];
        label.text=@"请选择日期";
        [sliceView addSubview:label];
    }else{
        int left = 0;
        if([_validslicetypes containsObject:@"天"]){
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(left, 0, 40, 30)];
            [button setTitle:@"天" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setBackgroundImage:bgSliceImage forState:UIControlStateSelected];
            [button setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
            [button setSelected:[_slicetype isEqualToString:@"天"]];
            [button addTarget:self action:@selector(changeSliceToDay:) forControlEvents:UIControlEventTouchUpInside];
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = 8.0;
            dateButton = button;
            
            [sliceView addSubview:button];
            left += 40;
        }
        
        if([_validslicetypes containsObject:@"月"]){
            
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(left, 0, 40, 30)];
            [button setTitle:@"月" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setBackgroundImage:bgSliceImage forState:UIControlStateSelected];
            [button setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
            [button setSelected:[_slicetype isEqualToString:@"月"]];
            [button addTarget:self action:@selector(changeSliceToMonth:) forControlEvents:UIControlEventTouchUpInside];
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = 8.0;
            monthButton = button;
            
            [sliceView addSubview:button];
            left += 40;
        }
        
        if([_validslicetypes containsObject:@"周"]){
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(left, 0, 40, 30)];
            [button setTitle:@"周" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setBackgroundImage:bgSliceImage forState:UIControlStateSelected];
            [button setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
            [button setSelected:[_slicetype isEqualToString:@"周"]];
            [button addTarget:self action:@selector(changeSliceToWeek:) forControlEvents:UIControlEventTouchUpInside];
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = 8.0;
            weekButton = button;
            
            [sliceView addSubview:button];
            [sliceView addSubview:button];
            left += 40;
        }
        
        if([_validslicetypes containsObject:@"季"]){
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(left, 0, 40, 30)];
            [button setTitle:@"季" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setBackgroundImage:bgSliceImage forState:UIControlStateSelected];
            [button setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
            [button setSelected:[_slicetype isEqualToString:@"季"]];
            [button addTarget:self action:@selector(changeSliceToQuarter:) forControlEvents:UIControlEventTouchUpInside];
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = 8.0;
            quarterButton = button;
            
            [sliceView addSubview:button];
            [sliceView addSubview:button];
            left += 40;
        }
        
        if([_validslicetypes containsObject:@"多天"]){
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(left, 0, 40, 30)];
            [button setTitle:@"多天" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setBackgroundImage:bgSliceImage forState:UIControlStateSelected];
            [button setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
            [button setSelected:[_slicetype isEqualToString:@"多天"]];
            [button addTarget:self action:@selector(changeSliceToMultiday:) forControlEvents:UIControlEventTouchUpInside];
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = 8.0;
            multidayButton = button;
            
            [sliceView addSubview:button];
            [sliceView addSubview:button];
            left += 40;
        }
    }
    
    [buttons addObject:[[UIBarButtonItem alloc] initWithCustomView:sliceView]];
    
    
    
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [buttons addObject:spaceButton];
    
    UIImage *bgImage = [[UIImage imageNamed:@"bg_button_normal" bundle:[MTGlobalInfo sharedInstance].commBundle] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0) resizingMode:UIImageResizingModeStretch];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setFrame:CGRectMake(0, 0, 60, 30)];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [button setBackgroundImage:bgImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pickerCancel:) forControlEvents:UIControlEventTouchUpInside];
    [buttons addObject:[[UIBarButtonItem alloc] initWithCustomView:button]];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setFrame:CGRectMake(0, 0, 60, 30)];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [button setBackgroundImage:bgImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pickerDone:) forControlEvents:UIControlEventTouchUpInside];
    [buttons addObject:[[UIBarButtonItem alloc] initWithCustomView:button]];

    [tb setItems:buttons];
    return tb;
}

-(UIDatePicker*)createDatePicker:(CGRect)rect{
    UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:rect];
    picker.datePickerMode=UIDatePickerModeDate;
    [picker setDate:_datetime animated:YES];
    return picker;
}

-(UIPickerView*)createMonthPicker:(CGRect)rect{
    UIPickerView *view = [[UIPickerView alloc] initWithFrame:rect];
    view.showsSelectionIndicator = YES;
    view.dataSource = self;
    view.delegate = self;
    view.tag=1;
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dc = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:_datetime];
    NSInteger year = dc.year;
    NSInteger month = dc.month;
    
    [view selectRow:year-1900 inComponent:0 animated:YES];
    [view selectRow:month-1 inComponent:1 animated:YES];

    
    return view;
}

-(UIPickerView*)createWeekPicker:(CGRect)rect{
    UIPickerView *view = [[UIPickerView alloc] initWithFrame:rect];
    view.showsSelectionIndicator = YES;
    view.dataSource = self;
    view.delegate = self;
    view.tag=2;
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dc = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekOfYearCalendarUnit fromDate:_datetime];
    NSInteger year = dc.year;

    NSInteger week = dc.weekOfYear;
    
    NSDate *dateend = [NSDate dateFromString:[NSString stringWithFormat:@"%04d-%02d-%02d",1900+(int)year,12,24] dateFormat:@"yyyy-MM-dd"];
    NSDateComponents *dcend = [cal components:NSWeekOfYearCalendarUnit fromDate:dateend];
    totalweeks = (int)dcend.weekOfYear;
    
    [view selectRow:year-1900 inComponent:0 animated:YES];
    [view selectRow:week-1 inComponent:1 animated:YES];
    
    return view;
}


-(UIPickerView*)createQuarterPicker:(CGRect)rect{
    UIPickerView *view = [[UIPickerView alloc] initWithFrame:rect];
    view.showsSelectionIndicator = YES;
    view.dataSource = self;
    view.delegate = self;
    view.tag=3;
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dc = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:_datetime];
    NSInteger year = dc.year;
    NSInteger month = dc.month;
    
    [view selectRow:year-1900 inComponent:0 animated:YES];
    [view selectRow:(month-1)/3 inComponent:1 animated:YES];
    
    
    return view;
}

-(UIView*)createMultidayPicker:(CGRect)rect{
    //PickerView高度只有三个：162,180,216,为兼容其他页面，这里选择162,这样每个Button高度为(216-162)/2=27
    CGFloat pickViewHeight = 162.0;
    CGFloat buttonHeight = 27;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, pickViewHeight+2*buttonHeight)];
    NSDate *startDate = _datetime;
    NSDate *endDate = [NSDate jsDateFromBeginDate:_datetime todays:_totaldays];
    startBtn = [UIButton buttonWithType:UIButtonTypeCustom] ;
    startBtn.layer.borderWidth = 0.5;
    startBtn.layer.borderColor = [UIColor grayColor].CGColor;
    startBtn.layer.backgroundColor = [UIColor whiteColor].CGColor;
    startBtn.frame = CGRectMake(0, 0, rect.size.width, buttonHeight);
    [startBtn setTitle:[NSString stringWithFormat:@"开始日期: %@",[startDate dateStringWithFormat:@"yyyy年MM月dd日"]] forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(changeStartDate:) forControlEvents:UIControlEventTouchUpInside];
    
    endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    endBtn.layer.borderWidth = 0.5;
    endBtn.layer.borderColor = [UIColor grayColor].CGColor;
    endBtn.layer.backgroundColor = [UIColor whiteColor].CGColor;
    endBtn.frame = CGRectMake(0, buttonHeight+pickViewHeight, rect.size.width, buttonHeight);
    [endBtn setTitle:[NSString stringWithFormat:@"结束日期: %@",[endDate dateStringWithFormat:@"yyyy年MM月dd日"]] forState:UIControlStateNormal];
    [endBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [endBtn addTarget:self action:@selector(changeEndDate:) forControlEvents:UIControlEventTouchUpInside];
    
    startPicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    startPicker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    startPicker.frame = CGRectMake(0, buttonHeight, rect.size.width,pickViewHeight);
    startPicker.datePickerMode=UIDatePickerModeDate;
    [startPicker setDate:startDate animated:YES];
    startPicker.hidden = NO;
    [startPicker addTarget:self action:@selector(startDateSelected:) forControlEvents:UIControlEventValueChanged];
    
    endPicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    endPicker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    endPicker.frame = CGRectMake(0, buttonHeight*2, rect.size.width,pickViewHeight);
    endPicker.datePickerMode=UIDatePickerModeDate;
    [endPicker setDate: endDate animated:YES];
    endPicker.hidden = YES;
    [endPicker addTarget:self action:@selector(endDateSelected:) forControlEvents:UIControlEventValueChanged];
    
    [view addSubview:startBtn];
    [view addSubview:startPicker];
    [view addSubview:endBtn];
    [view addSubview:endPicker];
    return view;
}

-(void)changeStartDate:(id)sender{
    CGRect rect = multidayPicker.frame;
    CGFloat pickViewHeight = 162.0;
    CGFloat buttonHeight = 27;
    [startBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal] ;
    [endBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    endBtn.frame = CGRectMake(0, buttonHeight+pickViewHeight, rect.size.width, buttonHeight);
    startPicker.hidden = NO;
    endPicker.hidden = YES;
    
}

-(void)changeEndDate:(id)sender{
    CGRect rect = multidayPicker.frame;
    CGFloat buttonHeight = 27;
    [startBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal] ;
    [endBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    endBtn.frame = CGRectMake(0, buttonHeight, rect.size.width, buttonHeight);
    startPicker.hidden = YES;
    endPicker.hidden = NO;
    
}

-(void)startDateSelected:(id)sender{
    [startBtn setTitle:[NSString stringWithFormat:@"开始日期: %@",[startPicker.date dateStringWithFormat:@"yyyy年MM月dd日"]] forState:UIControlStateNormal];
}

-(void)endDateSelected:(id)sender{
    [endBtn setTitle:[NSString stringWithFormat:@"结束日期: %@",[endPicker.date dateStringWithFormat:@"yyyy年MM月dd日"]] forState:UIControlStateNormal];
}

-(void)changeSliceToDay:(id)sender{
    _slicetype = @"天";
    datePicker.hidden = NO;
    monthPicker.hidden = YES;
    weekPicker.hidden = YES;
    quarterPicker.hidden = YES;
    multidayPicker.hidden = YES;
    
    dateButton.selected = YES;
    monthButton.selected = NO;
    weekButton.selected = NO;
    quarterButton.selected = NO;
    multidayButton.selected = NO;
}

-(void)changeSliceToWeek:(id)sender{
    _slicetype = @"周";
    datePicker.hidden = YES;
    monthPicker.hidden = YES;
    weekPicker.hidden = NO;
    quarterPicker.hidden = YES;
    multidayPicker.hidden = YES;
    
    dateButton.selected = NO;
    monthButton.selected = NO;
    weekButton.selected = YES;
    quarterButton.selected = NO;
    multidayButton.selected = NO;
}

-(void)changeSliceToMonth:(id)sender{
    _slicetype = @"月";
    datePicker.hidden = YES;
    monthPicker.hidden = NO;
    weekPicker.hidden = YES;
    quarterPicker.hidden = YES;
    multidayPicker.hidden = YES;
    
    
    dateButton.selected = NO;
    monthButton.selected = YES;
    weekButton.selected = NO;
    quarterButton.selected = NO;
    multidayButton.selected = NO;
}


-(void)changeSliceToQuarter:(id)sender{
    _slicetype = @"季";
    datePicker.hidden = YES;
    monthPicker.hidden = YES;
    weekPicker.hidden = YES;
    quarterPicker.hidden = NO;
    multidayPicker.hidden = YES;
    
    
    dateButton.selected = NO;
    monthButton.selected = NO;
    weekButton.selected = NO;
    quarterButton.selected = YES;
    multidayButton.selected = NO;
}

-(void)changeSliceToMultiday:(id)sender{
    _slicetype = @"多天";
    datePicker.hidden = YES;
    monthPicker.hidden = YES;
    weekPicker.hidden = YES;
    quarterPicker.hidden = YES;
    multidayPicker.hidden = NO;
    
    
    dateButton.selected = NO;
    monthButton.selected = NO;
    weekButton.selected = NO;
    quarterButton.selected = NO;
    multidayButton.selected = YES;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 30.0;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if(pickerView.tag == 1){//月粒度
        return 2;
    }else if(pickerView.tag==2){//周粒度
        return 2;
    }else if(pickerView.tag==3){//季粒度
        return 2;
    }else{
        return 1;
    }

}

- (CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if(pickerView.tag == 2){
        if(1 == component)
            return pickerView.frame.size.width * .6;
        else
            return pickerView.frame.size.width * .4;
    }
    return 200;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(pickerView.tag == 1){//月粒度
        if(component==0){
            return 200;
        }else{
            return 12;
        }
    }else if(pickerView.tag==2){//周粒度
        if(component==0){
            return 200;
        }else{
            return totalweeks;
        }
    }else if(pickerView.tag == 3){//季粒度
        if(component==0){
            return 200;
        }else{
            return 4;
        }
    }else{
        return 0;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(pickerView.tag == 1){//月粒度
        if(component==0){
            return [NSString stringWithFormat:@"%d年",1900+(int)row];
        }else{
            return [NSString stringWithFormat:@"%d月",1+(int)row];;
        }
    }else if(pickerView.tag==2){//周粒度
        if(component==0){
            return [NSString stringWithFormat:@"%d年",1900+(int)row];
        }else{
            
            NSInteger year = [weekPicker selectedRowInComponent:0] + 1900;
            NSInteger week = row + 1;
            
            NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            
            NSDate *date = [NSDate dateFromString:[NSString stringWithFormat:@"%04d-01-01",(int)year] dateFormat:@"yyyy-MM-dd"];
            NSDateComponents *dc = [cal components:NSWeekdayCalendarUnit fromDate:date];
            _datetime = [NSDate jsDateFromBeginDate:date todays:(int)((week-1)*7-dc.weekday+1 + 1)];//不修改设置，只是 +1，让星期一为一个星期的第一天
            NSString *mdStrings = [_datetime dateStringWithFormat:@"MM-dd"];
            
            return [NSString stringWithFormat:@"第%d周 (%@)",1+(int)row,mdStrings];
            //return [NSString stringWithFormat:@"(%@)",mdStrings];
        }
    }else if(pickerView.tag==3){//季粒度
        if(component==0){
            return [NSString stringWithFormat:@"%d年",1900+(int)row];
        }else{
            return [NSString stringWithFormat:@"第%d季",1+(int)row];
        }
    }else{
        return @"";
    }

}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(pickerView.tag == 1){//月粒度
        if(component==0){
            [pickerView reloadComponent:1];
            [pickerView selectRow:0 inComponent:1 animated:YES];
        }
    }else if(pickerView.tag==2){//周粒度
        if(component==0){
            NSInteger yearindex = [pickerView selectedRowInComponent:0];
            NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *dateend = [NSDate dateFromString:[NSString stringWithFormat:@"%04d-%02d-%02d",1900+(int)yearindex,12,24] dateFormat:@"yyyy-MM-dd"];
            NSDateComponents *dcend = [cal components:NSWeekOfYearCalendarUnit fromDate:dateend];
            totalweeks = (int)dcend.weekOfYear;

            [pickerView reloadComponent:1];
            [pickerView selectRow:0 inComponent:1 animated:YES];
        }
    }else if(pickerView.tag == 3){//季粒度
        if(component==0){
            [pickerView reloadComponent:1];
            [pickerView selectRow:0 inComponent:1 animated:YES];
        }
    }
}
-(void)pickerCancel:(id)sender{
    [self dismissWithClickedButtonIndex:1 animated:YES];
}

-(void)pickerDone:(id)sender{
    if([_slicetype isEqualToString:@"月"]){
        NSInteger year = [monthPicker selectedRowInComponent:0] + 1900;
        NSInteger month = [monthPicker selectedRowInComponent:1] + 1;
        _datetime = [NSDate dateFromString:[NSString stringWithFormat:@"%04d-%02d-01",(int)year,(int)month] dateFormat:@"yyyy-MM-dd"];
        NSDate *endtime = [NSDate jsDateFromBeginDate:_datetime tomonths:1];
        _totaldays = [endtime timeIntervalSinceDate:_datetime]/(24*3600);
        
    }else if([_slicetype isEqualToString:@"周"]){
        NSInteger year = [weekPicker selectedRowInComponent:0] + 1900;
        NSInteger week = [weekPicker selectedRowInComponent:1]+1;
        
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSDate *date = [NSDate dateFromString:[NSString stringWithFormat:@"%04d-01-01",(int)year] dateFormat:@"yyyy-MM-dd"];
        NSDateComponents *dc = [cal components:NSWeekdayCalendarUnit fromDate:date];
        _datetime = [NSDate jsDateFromBeginDate:date todays:(int)((week-1)*7-dc.weekday+1 + 1)];//不修改设置，只是 +1，让星期一为一个星期的第一天
        _totaldays = 7;
    }else if([_slicetype isEqualToString:@"季"]){
        NSInteger year = [monthPicker selectedRowInComponent:0] + 1900;
        NSInteger month = [monthPicker selectedRowInComponent:1]*3 + 1;
        _datetime = [NSDate dateFromString:[NSString stringWithFormat:@"%04d-%02d-01",(int)year,(int)month] dateFormat:@"yyyy-MM-dd"];
        
        NSInteger endyear = year;
        NSInteger endmonth = month+3;
        if(endmonth>12){
            endmonth -= 12;
            endyear += 1;
        }
        NSDate *endtime = [NSDate dateFromString:[NSString stringWithFormat:@"%04d-%02d-01",(int)endyear,(int)endmonth] dateFormat:@"yyyy-MM-dd"];
        _totaldays = [endtime timeIntervalSinceDate:_datetime]/(24*3600);
        
        
    }else if([_slicetype isEqualToString:@"多天"]){
        _datetime = startPicker.date;
        _totaldays = [endPicker.date timeIntervalSinceDate:_datetime]/(24*3600);
        if(_totaldays<=0){
            [SVProgressHUD showErrorWithStatus:@"结束时间大于等于开始时间!"];
            return;
        }
        
    }else{
        _datetime = datePicker.date;
        _totaldays = 1;
    }
    
    [self.dsdelegate dateSelected:_datetime totaldays:_totaldays slicetype:_slicetype];
    
    
    [self dismissWithClickedButtonIndex:1 animated:YES];
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
