//
//  CLTBarView.h
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/11.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLTBarView : UIView

@property (nonatomic, strong) NSArray *xTitleDatas;
@property (nonatomic, strong) NSArray *yTitleDatas;

@property (nonatomic, strong) NSArray *titleDatas;
@property (nonatomic, strong) NSArray *titleValues;


@property (nonatomic ,strong) NSString  *title;
@property (nonatomic, assign) int xMaxScaleValues;

@end
