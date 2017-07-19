//
//  CHTableView.h
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/16.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CHTableView;
@protocol CHTableViewProtocol <NSObject>

//点击某一个cell时的事件响应方法
- (void) CHTableView:(CHTableView *)view didSelectCell:(int)row column:(int)column rowData:(NSArray*)rowData;

- (void) CHTableView:(CHTableView *)view didSelectRow:(int)row rowData:(NSArray *)rowData;
    
@end

@interface CHTableView : UIView 
@property (nonatomic ,strong) NSArray  *result;
@property (nonatomic ,strong) NSArray  *columns;

@property (nonatomic ,strong) NSString *drillMore;

@property (nonatomic, weak) id<CHTableViewProtocol> delegate;

-(void)createTableViewWithFrame:(CGRect)frame;
@end
