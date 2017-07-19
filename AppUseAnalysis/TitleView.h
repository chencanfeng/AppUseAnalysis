//
//  TitleView.h
//  LoopBrowsDemo
//
//  Created by Mac on 2017/2/16.
//  Copyright © 2017年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleView : UIView


/**
 实现被点击的按钮下标和内容回调
 */
@property (nonatomic, copy) void (^ titleBtnBlock) (NSInteger index, NSString *title);

/**
 重写init方法

 @param frame 设置位置
 @param titles 标题数组
 @return titleView对象
 */
- (instancetype)initWithFrame:(CGRect)frame andTitles:(NSArray *)titles;



/**
 若要实现联合滚动,必须加上setter方法

 @param num 下标数
 */
- (void)updataIndexLabelUIWithNum:(NSInteger)num;

@end
