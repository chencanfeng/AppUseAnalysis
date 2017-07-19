//
//  MTBaseViewController.h
//  MTFrameDevVesison
//
//  Created by song mj on 16/9/6.
//  Copyright © 2016年 mastercom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MTFuncInfo.h"

@protocol MTNaviBarImgeDelegate <NSObject>
@optional

/**
 *  导航栏左按钮图片（正常状态）
 *
 */
- (UIImage *) naviBarImgForStateNormal;


/**
 *  导航栏左按钮图片
 *
 */
- (UIImage *) naviBarImgForStateHighlighted;


@end

@interface MTBaseViewController : UIViewController <UIAlertViewDelegate>

/**
 *  是否显示导航栏
 */
@property(nonatomic, assign) BOOL navigationBarhidden;


/**
 *  是否定制导航栏的颜色
 */
@property(nonatomic, assign,getter=isUseNewNaviBgColor) BOOL usingNewNaviBgColor;

/**
 *  如果业务方需要定制特定的图片，需要设置该委托
 */
@property (nonatomic, weak) id<MTNaviBarImgeDelegate> naviBarLeftImageDelegate;


#pragma mark - Navigator related methods

- (void)pushViewController:(UIViewController *)vc;

- (void)setViewController:(UIViewController *)vc;

- (void)popViewController;

- (void)pushViewController:(UIViewController *)vc navigationBarHidden:(BOOL)hidden;

- (void)setNaviTitle:(NSString*)title leftButtonShow:(BOOL)leftButtonShow rightButtom:(id)rightButtom;

- (void)backAction;

- (void)backAction:(id)sender ;

- (void)setNavigationBarWithColor:(UIColor *)color;


#pragma mark - SliderVeiw related methods
- (void)setSliderView:(UIView*)view width:(int)width;

- (void)toggleSliderView;



#pragma mark - Attribute related methods
/**
 *  向Controller 增加属性
 *
 *  @param key   属性名
 *  @param value 对应的值
 */

- (void)putAttribute:(NSString*)key Value:(id)value;

/**
 *  获取Controller中的属性值
 *
 *  @param key 属性名
 *
 *  @return 对应的属性值
 */
- (id)getAttribute:(NSString*)key;


/**
 *  移除属性
 *
 *  @param key 属性名
 */
- (void)removeAttribute:(NSString*)key;

@end
