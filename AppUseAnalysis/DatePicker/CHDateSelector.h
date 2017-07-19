//
//  CHDateSelector.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTActionSheet.h"

@protocol CHDateSelectorDelegate <NSObject>
@required
-(void) dateSelected:(NSDate*)startDate totaldays:(int)totaldays slicetype:(NSString*)slicetype;

@optional
-(void) dateSelected:(NSDate*)startDate slicetype:(NSString*)slicetype;//后续废弃
@end

@interface CHDateSelector : MTActionSheet<UIActionSheetDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
@property (nonatomic,strong) NSString* slicetype;
@property (nonatomic,strong) NSArray* validslicetypes;
@property (nonatomic,strong) NSDate* datetime;
@property (nonatomic,assign) int totaldays;
@property (nonatomic,strong) id<CHDateSelectorDelegate> dsdelegate;

- (id)initWithFrame:(CGRect)frame initdate:(NSDate*)datetime slicetype:(NSString*)slicetype validslicetypes:(NSArray*)validslicetypes totaldays:(int)totaldays;

@end
