//
//  ArrowDirectionView.h
//  UICommon
//
//  Created by jianke on 14-12-17.
//  Copyright (c) 2014年 YN. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  箭头方向
 */
typedef NS_ENUM(NSInteger, ArrowDirection)
{
    /**
     *  上
     */
    ArrowDirectionUp=1,
    /**
     *  下
     */
    ArrowDirectionBottom=2,
    /**
     *  左
     */
    ArrowDirectionLeft=3,
    /**
     *  右
     */
    ArrowDirectionRight=4
};

@interface ArrowDirectionView : UIView

@property (nonatomic) UIView*contentView;
@property (nonatomic) ArrowDirection arrowDirection;
/**
 *  箭头指示位置
 */
@property (nonatomic) CGFloat arrowPosition;

@property (nonatomic,strong) UIColor* borderColor;

@property (nonatomic,strong) UIColor* contentBgColor;
@end