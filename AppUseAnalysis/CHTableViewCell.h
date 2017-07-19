//
//  CHTableViewCell.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,CHTableViewCellFrameLine){
    CHTableViewCellFrameLineTop=1,
    CHTableViewCellFrameLineBottom=2,
    CHTableViewCellFrameLineLeft=4,
    CHTableViewCellFrameLineRight=8

};

@interface CHTableViewCell : UITableViewCell
@property (nonatomic,strong) UIColor *bgNormalColor;
@property (nonatomic,strong) UIColor *bgSelectedColor;
@property (nonatomic,strong) UIColor *framelineColor;
@property (nonatomic,strong) UIColor *topLineColor;
@property (nonatomic,strong) UIColor *bottomLineColor;
@property (nonatomic,strong) UIColor *leftLineColor;
@property (nonatomic,strong) UIColor *rightLineColor;
@property (nonatomic,assign) CHTableViewCellFrameLine frameLines;
@end
