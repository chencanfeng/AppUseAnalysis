//
//  TitleView.m
//  LoopBrowsDemo
//
//  Created by Mac on 2017/2/16.
//  Copyright © 2017年 TUTK. All rights reserved.
//

#import "TitleView.h"

#define kpadding 2

@interface TitleView()
{
    UILabel *_indexLabel; //下标label
    NSArray *_titleArr;   //标题数组
}

@end

@implementation TitleView

- (instancetype)initWithFrame:(CGRect)frame andTitles:(NSArray *)titles
{
    if(self = [super initWithFrame:frame])
    {
        //layout
        NSInteger btnCount = [titles count];
        
       
        CGFloat btnWidth = ([titles count] > 1)? ((frame.size.width - ([titles count] - 1) * kpadding)/ btnCount) : frame.size.width;
        
        NSLog(@"btnWidth:%f",btnWidth);
        
        _titleArr = titles;
        
        CGRect assagnBtnRect = CGRectZero;
        
        for (NSInteger index = 0; index < [titles count]; index ++)
        {
            UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            if([titles count] > 1)
            {
                titleBtn.frame = CGRectMake((btnWidth + kpadding) * index, 2 * kpadding, btnWidth, frame.size.height - 4 * kpadding);
                //竖线
                if (index != ([titles count] - 1))
                {
                    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(titleBtn.frame.origin.x + titleBtn.frame.size.width,frame.size.height / 4, kpadding/2, frame.size.height / 2)];
                    lineView.backgroundColor = [UIColor blackColor];
                    [self addSubview:lineView];
                }
            }
            else
            {
                titleBtn.frame = CGRectMake(btnWidth* index, 2 * kpadding, btnWidth, frame.size.height - 4 * kpadding);
            }
            titleBtn.tag = index;
            titleBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
            [titleBtn setTitle:[titles objectAtIndex:index] forState:UIControlStateNormal];
            [titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [titleBtn addTarget:self action:@selector(tapTitleBtn:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:titleBtn];
            
            //titleBtn.layer.borderWidth = 1;

            assagnBtnRect = (index == 1)? titleBtn.frame : assagnBtnRect;
        }
        
        if([titles count] > 1)
        {
            //下标线
            CGRect indexLabelFrame = assagnBtnRect;
            indexLabelFrame.origin.y += (assagnBtnRect.size.height + kpadding / 2);
            indexLabelFrame.origin.x += (assagnBtnRect.size.height / 2);
            indexLabelFrame.size.width = assagnBtnRect.size.width - assagnBtnRect.size.height;
            indexLabelFrame.size.height = kpadding /2 ;
            
            _indexLabel = [[UILabel alloc]initWithFrame:indexLabelFrame];
            _indexLabel.backgroundColor =[UIColor blueColor];
            [self addSubview:_indexLabel];
        }
        return self;
    }
    return self;
}

//点击后, callback给调用者
- (void)tapTitleBtn:(UIButton *)sender
{
    NSLog(@"titleView:------%@",sender.titleLabel.text);

    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = _indexLabel.frame;
        rect.origin.x = sender.frame.origin.x + (sender.frame.size.height / 2);
        _indexLabel.frame = rect;
    }];
    
    _titleBtnBlock(sender.tag ,sender.titleLabel.text);
}

- (void)updataIndexLabelUIWithNum:(NSInteger)num
{
    if(num < 0 || num > _titleArr.count - 1) return;
   
    UIButton *tmpBtn = [self viewWithTag:num];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = _indexLabel.frame;
        rect.origin.x = tmpBtn.frame.origin.x + (tmpBtn.frame.size.height / 2);
        _indexLabel.frame = rect;
    }];
}

@end
