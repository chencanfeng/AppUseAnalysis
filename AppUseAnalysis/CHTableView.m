//
//  CHTableView.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/16.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHTableView.h"
#import "CHDataGridTableView.h"
#import "AppChartInfoViewController.h"

@interface CHTableView () <CHDataGridTableViewDelegate>
@property(nonatomic, strong) CHDataGridTableView *dataGridTableView;
@end

@implementation CHTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



-(void)createTableViewWithFrame:(CGRect)frame{
//    MTDataGridTableView *tableView;
    _dataGridTableView =[[CHDataGridTableView alloc] initWithFrame:frame];
    _dataGridTableView.parentDelegate=self;
    
    [self addSubview:_dataGridTableView];
    NSString *selectType= [_drillMore isEqualToString:@"YES"]?@"Cell":@"Line";
    int colCount = (int)[_columns count];
    NSMutableArray *headerInfo = [[NSMutableArray alloc] initWithCapacity:colCount];
    NSMutableArray *headerWidth = [[NSMutableArray alloc] initWithCapacity:colCount];
    NSMutableDictionary *colDict = [[NSMutableDictionary alloc] initWithCapacity:colCount];
    //初始化列宽并保存每列的序号字典
    for(int i=0;i<colCount;i++){
        [headerWidth addObject:[NSNumber numberWithInt:-1]];
        [colDict setObject:[NSNumber numberWithInt:i] forKey:_columns[i]];
    }
    float fixxedWidth = 0;
    int undefinedcols = 0;
    //将已定义列宽的设置列宽
    for(int i=0;i<colCount;i++){
        int width = [headerWidth[i] intValue];
        if(width == 0){
            continue;
        }else{
            undefinedcols++;
        }
    }
    //列头的定义
    NSMutableArray *orderColumns = [_columns mutableCopy];
    if([orderColumns containsObject:@"平均时延"]) {
        NSInteger index = [orderColumns indexOfObject:@"平均时延"];
        [orderColumns replaceObjectAtIndex:index withObject:@"平均时延(ms)"];
    }
    for(int i=0;i<colCount;i++){
        float width = [headerWidth[i] floatValue];
        if(width < 0){
            width=(1.0-fixxedWidth)/undefinedcols;
        }
        BOOL iskey = [_drillMore isEqualToString:@"YES"]?YES:NO;
        NSMutableDictionary *header = [[NSMutableDictionary alloc]
                                       initWithDictionary:@{@"datavalue":orderColumns[i],
                                                            @"datatype":@"String",
                                                            @"width":[NSNumber numberWithFloat:width],
                                                            @"iskey":(iskey==YES)?@1:@0,
                                                            @"type":@"text",
                                                            @"canorder":@0}];
        [headerInfo addObject:header];
    }
    _dataGridTableView.isCanGoMore = [_drillMore isEqualToString:@"YES"]?YES:NO;
    _dataGridTableView.headerInfo = headerInfo;
    _dataGridTableView.tableInfo = @{
                            @"bgHeaderColor":@"#D2EBF9",
                            @"bgCellColor":@"#FFFFFF",
                            @"bgCellAltColor":@"#F5F9FE",
                            @"bgFrameColor":@"#F1F1F1",
                            @"bgTopLineColor":@"#439CCA",
                            @"splitLineColor":@"#F1F1F1",
                            @"fontColor":@"#000000",
                            @"fontSize":@12,
                            @"lineHeight":@34,
                            @"headerHeight":@40,
                            @"align":@"center",
                            @"textwrap":@1,
                            @"autoAdjustWidth":@NO,
                            @"selectType":selectType,
                            @"bgSelectedColor":@"#e96539"
                            };
    
    //对于日期倒转顺序
    NSMutableArray  *orderedResult = [[NSMutableArray alloc] initWithArray:_result];
    BOOL isSameHour = NO;
    if([_result count]>1) {
        NSString *date1str = [_result[0] objectForKey:_columns[0]];
        NSString *date2str = [_result[1] objectForKey:_columns[0]];
        NSDate *date1;
        NSDate *date2;
        if(date1str && date2str) {
            if(date1str.length >= 19 && date2str.length >= 19) {
                if([[date1str substringFromIndex:11] isEqualToString:[date2str substringFromIndex:11]]) {
                    isSameHour = YES;
                    date1 =[NSDate dateFromString:[date1str substringToIndex:10] dateFormat:@"yyyy-MM-dd"];
                    date2 =[NSDate dateFromString:[date2str substringToIndex:10] dateFormat:@"yyyy-MM-dd"];
                }else {
                    date1 =[NSDate dateFromString:[date1str substringToIndex:19] dateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    date2 =[NSDate dateFromString:[date2str substringToIndex:19] dateFormat:@"yyyy-MM-dd HH:mm:ss"];
                }
                
            }else if(date1str.length >= 10 && date2str.length >= 10) {
                date1 =[NSDate dateFromString:[date1str substringToIndex:10] dateFormat:@"yyyy-MM-dd"];
                date2 =[NSDate dateFromString:[date2str substringToIndex:10] dateFormat:@"yyyy-MM-dd"];
                
            }
            if(isSameHour) {
                NSMutableArray *arrM = [_result mutableCopy];
                for (int i = 0; i < [_result count]; i ++) {
                    NSMutableDictionary *dicM = [arrM[i] mutableCopy];
                    NSString *str = [dicM objectForKey:_columns[0]];
                    str = [str substringToIndex:10];
                    [dicM setValue:str forKey:_columns[0]];
                    [arrM replaceObjectAtIndex:i withObject:dicM];
                }
                _result = [arrM copy];
            }
            
            //倒转顺序
            if([date2 compare:date1]==1){
                orderedResult = [[NSMutableArray alloc] initWithCapacity:[_result count]];
                for(int i=(int)[_result count]-1;i>=0;i--){
                    [(NSMutableArray*)orderedResult addObject:_result[i]];
                }
            }
            
            
        }
    }
    _result = [orderedResult copy];
    
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:[_result count]];
    for (int index=0;index<[_result count];index++) {
        NSMutableArray *rowdata = [self getRowData:index headerinfo:headerInfo];
        [data addObject:rowdata];
    }
    [_dataGridTableView putData:data];
    
}


-(NSMutableArray*)getRowData:(int)index headerinfo:(NSArray*)headerInfo{
    NSUInteger colCount = [_columns count];
    NSDictionary *row = [_result objectAtIndex:index];
    NSMutableArray *rowdata = [[NSMutableArray alloc] initWithCapacity:colCount];
    for(int j=0;j<colCount;j++){
        id value = [row objectForKey:_columns[j]];
        if(value!=nil){
            [rowdata addObject:value];
        }else{
            [rowdata addObject:[NSNull null]];
        }
    }
    return rowdata;
    
}


#pragma mark - CHDataGridTableView 代理方法
- (void)dataGridDidSelectRow:(int)row rowData:(NSArray *)rowData {
    NSLog(@"Row :%s",__func__);
    
    _dataGridTableView.specialRows = @[[NSString stringWithFormat:@"%d",row]];
    [_dataGridTableView reloadData];
    if(self.delegate && [self.delegate respondsToSelector:@selector(CHTableView:didSelectRow:rowData:)]) {
        [self.delegate CHTableView:self didSelectRow:row rowData:rowData];
    }
    
    
}
- (void)dataGridDidSelectCell:(int)row column:(int)column rowData:(NSArray*)rowData {
    NSLog(@"Cell :%s",__func__);
    _dataGridTableView.specialRows = @[[NSString stringWithFormat:@"%d",row]];
    [_dataGridTableView reloadData];
    if(self.delegate && [self.delegate respondsToSelector:@selector(CHTableView:didSelectCell:column:rowData:)]) {
        [self.delegate CHTableView:self didSelectCell:row column:column rowData:rowData];
    }
}

// 点击表格任意一行，此行背景色变灰
- (void) CHDataGridTableView:(UITableView *)tableView forSpecialCell:(CHDataGridTableViewCell *)cell {
    NSLog(@"%s",__func__);
    cell.bgNormalColor = [UIColor colorWithRed:0.894 green:0.894 blue:0.894 alpha:1.00];
}





@end
