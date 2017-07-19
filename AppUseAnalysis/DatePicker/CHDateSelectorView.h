//
//  CHDateSelectorView.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHDateSelector.h"
#import "HBDatePickerView.h"

@interface CHDateSelectorView : UIView<HBDatePickerViewDelegate>
@property (nonatomic,strong) UIButton *dateButton;


@property (nonatomic,assign) HBDateType slicetype;
@property (nonatomic ,strong) NSString *startDateStr;  //开始日期字串
@property (nonatomic ,strong) NSString *endDateStr;    //结束日期字串




@property (nonatomic,strong) MTBaseViewController<HBDatePickerViewDelegate> *parentVC;
- (id)initWithFrame:(CGRect)frame Slicetype:(HBDateType)slicetype;
-(void)setSliceType:(HBDateType)slicetype;
-(void)datePicker:(id)sender;
@end
