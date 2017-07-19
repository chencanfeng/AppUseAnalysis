//
//  UIToastView.h
//  MTNOS_SH
//
//  Created by c0ming on 13-6-5.
//  Copyright (c) 2013年 c0ming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIToastView : UILabel

- (id)initWithTitle:(NSString *)title;
- (void)show;
@end
