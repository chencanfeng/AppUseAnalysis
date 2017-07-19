//
//  HBDatePickerView.h
//  FengurUWDatePickerDemo
//
//  Created by MasterCom on 2017/5/17.
//  Copyright © 2017年 UWFengur. All rights reserved.
//

#import <UIKit/UIKit.h>


#define HBViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

typedef NS_ENUM(NSUInteger, HBDateType) {
    // 常用类型
    YearMonthDayType  = 0,    //H 0.5
    // 第几周
    WeekOfYearType    = 1,    //H 0.5
    // 开始日期 结束日期  (只有年月)
    YearMonthAtoZType,        //H 0.76
};


@protocol HBDatePickerViewDelegate <NSObject>

/**
 *  选择日期确定后的代理事件
 *
 *  @param dates 日期数组
 *  @param type 时间选择器状态
 */
- (void)getSelectDates:(NSArray *)dates type:(HBDateType)type;

@end


@interface HBDatePickerView : UIView

@property (nonatomic, copy) NSString *title;
@property (weak, nonatomic) IBOutlet UIView *bgView;  //选框视图
@property (weak, nonatomic) IBOutlet UIButton *grayBgBtn;

@property (nonatomic, weak)   id<HBDatePickerViewDelegate> delegate;


@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet UILabel  *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel  *startLabel;
@property (weak, nonatomic) IBOutlet UILabel  *endLabel;

@property (nonatomic, weak) IBOutlet UIPickerView *pickerView1;  //年月日/周/ 起始
@property (nonatomic, weak) IBOutlet UIPickerView *pickerView2;  //截止

@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property (nonatomic, strong) NSDate *currentDate; //默认显示时间


//
+ (HBDatePickerView *)instanceDatePickerView;

- (void)layoutHBDatePickerViewWithDateType:(HBDateType)type;

- (void)show;
- (void)dissmiss;



- (IBAction)sureBtnAction:(id)sender;
- (IBAction)cancelBtnAction:(id)sender;
- (IBAction)backGroundBtnAction:(id)sender;

@end
