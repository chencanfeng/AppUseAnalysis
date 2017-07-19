//
//  MTActionSheet.h
//  
//
//  Created by ren wanqian on 14-9-25.
//
//

#import <UIKit/UIKit.h>
#import "MTPopupView.h"

@interface MTActionSheet : MTPopupView

@property (nonatomic,strong) id<UIActionSheetDelegate> delegate;

@property(nonatomic) UIActionSheetStyle actionSheetStyle;//暂不用，仅兼容UIActionSheet的接口

- (void)showInView:(UIView*)view;
- (void)setBounds:(CGRect)rect;

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;
- (void)showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated  ;
- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated  ;
@end
