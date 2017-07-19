//
//  MTPopupView.h
//  TestProject
//
//  Created by ren wanqian on 14-9-25.
//  Copyright (c) 2014年 mastercom. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,MTPopupViewVertAlignment){
    MTPopupViewVertAlignmentTop=0,
    MTPopupViewVertAlignmentMiddle=1,
    MTPopupViewVertAlignmentBottom=2
};

@interface MTPopupView : UIView<UIGestureRecognizerDelegate>
@property (nonatomic,assign) MTPopupViewVertAlignment vAlignment;
@property (nonatomic,assign) BOOL disappearOnTouchOutside;
@property (nonatomic,assign) CGFloat cornerRadius;

- (void)show;
- (void)showAtPosition:(CGPoint)point;
- (void)close;
- (void)addContentview:(UIView *)view;


@end
