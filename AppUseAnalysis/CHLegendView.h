//
//  CHLegendView.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CHLegendView;
@protocol CHLegendViewDelegate <NSObject>

- (void)legendView:(CHLegendView *)legendView  isChartFullScreen:(BOOL)state;
@end

@interface CHLegendView : UIView
@property (nonatomic, strong) UIFont *titlesFont;
@property (strong) NSArray *titles;
@property (strong) NSDictionary *colors; // maps titles to UIColors
@property (strong) NSDictionary *chartTypes;
@property (copy) NSString *xTitle;
@property (nonatomic ,strong) id delegate;

@end
