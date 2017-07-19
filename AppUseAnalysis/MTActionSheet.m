//
//  MTActionSheet.m
//  
//
//  Created by ren wanqian on 14-9-25.
//
//

#import "MTActionSheet.h"

@implementation MTActionSheet


- (void)showInView:(UIView*)view{
    [self show];
}
- (void)setBounds:(CGRect)rect{
    //暂时不处理，因为bounds已经根据subview自动处理了，仅兼容接口
}

- (void)addSubview:(UIView *)view{
    [self addContentview:view];
}

- (void)show{
    self.disappearOnTouchOutside = YES;
    self.vAlignment = MTPopupViewVertAlignmentBottom;
    [super show];
}
/**
 *  只为了兼容uiactionSheet
 *
 *  @param item     <#item description#>
 *  @param animated <#animated description#>
 */
- (void)showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated  {
     [self show];
}
/**
 *  只为了兼容uiactionSheet
 *
 *  @param rect     <#rect description#>
 *  @param view     <#view description#>
 *  @param animated <#animated description#>
 */
- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated
{
    [self show];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated{
    [self close];
}
@end
