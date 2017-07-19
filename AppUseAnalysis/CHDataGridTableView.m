//
//  CHDataGridTableView.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHDataGridTableView.h"

#import "CHDataGridTableViewCell.h"


@interface CHDataGridTableView ()<CHDataGridHeaderCellDelegate> {
    NSMutableArray *_colWidths;
    BOOL _firstShow;
    
}
@end

@implementation CHDataGridTableView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.separatorStyle = UITableViewCellSelectionStyleNone;
        self.delegate = self;
        self.dataSource = self;
        self.needScrollTrigger = NO;
        self.bounces = NO;
        self.backgroundColor = [UIColor whiteColor];
        _maxcolwidth = 500;
        _firstShow = YES;
        _shouldDismissProgress = NO;
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (_dataInfo) {
        rows = [_dataInfo count];
    }
    if (_shouldDismissProgress && rows == 0 && _firstShow) {
        [SVProgressHUD dismiss];
        _firstShow = NO;
    }
    return rows;
}
- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    return [self getHeaderHeight];
}
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight= [self getLineHeight];
    
    return rowHeight;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
    
    CHDataGridHeaderCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"dataGridHeaderCell"];
    if (cell == nil || [cell.columnsInfo count] != [_headerInfo count]) {
        cell =
        [[CHDataGridHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:@"dataGridHeaderCell"];
        cell.isLocked = self.isLocked;
        cell.backgroundColor = [UIColor whiteColor];
        UIColor *bgColor =
        [UIColor colorWithHexString:[_tableInfo objectForKey:@"bgHeaderColor"]];
        if (bgColor) {
            cell.bgNormalColor = bgColor;
            cell.bgSelectedColor = [UIColor blueColor];
        }
        UIColor *bgFrameColor =
        [UIColor colorWithHexString:[_tableInfo objectForKey:@"bgFrameColor"]];
        if (bgFrameColor) {
            cell.framelineColor = bgFrameColor;
        }
        cell.topLineColor = [UIColor
                             colorWithHexString:[_tableInfo objectForKey:@"bgTopLineColor"]];
        cell.bottomLineColor = [UIColor
                                colorWithHexString:[_tableInfo objectForKey:@"bgBottomLineColor"]];
        cell.leftLineColor = [UIColor
                              colorWithHexString:[_tableInfo objectForKey:@"bgLeftLineColor"]];
        cell.rightLineColor = [UIColor
                               colorWithHexString:[_tableInfo objectForKey:@"bgRightLineColor"]];
        cell.splitLineColor = [UIColor
                               colorWithHexString:[_tableInfo objectForKey:@"splitLineColor"]];
        
        UIColor *fontColor =
        [UIColor colorWithHexString:[_tableInfo objectForKey:@"fontColor"]];
        if (fontColor) {
            cell.fontColor = fontColor;
        }
        
        NSString *align = [_tableInfo objectForKey:@"align"];
        if (align) {
            if ([align compare:@"left" options:NSCaseInsensitiveSearch] ==
                NSOrderedSame) {
                cell.align = NSTextAlignmentLeft;
            } else if ([align compare:@"right" options:NSCaseInsensitiveSearch] ==
                       NSOrderedSame) {
                cell.align = NSTextAlignmentRight;
            } else {
                cell.align = NSTextAlignmentCenter;
            }
        } else {
            cell.align = NSTextAlignmentCenter;
        }
        cell.lineHeight = [self getLineHeight];
        float fontSize = [[_tableInfo objectForKey:@"fontSize"] floatValue];
        if (fontSize > 0) {
            cell.fontSize = fontSize;
        }
        NSNumber *textwrap = [_tableInfo objectForKey:@"textwrap"];
        if (textwrap && [textwrap intValue] == 1) {
            cell.textwrap = YES;
        } else {
            cell.textwrap = NO;
        }
        
        NSNumber *framelines = [_tableInfo objectForKey:@"framelines"];
        if (framelines) {
            cell.frameLines = [framelines intValue];
        }
        
        cell.indicatorDesc = self.indicatorDesc;
        [cell createGrids:_headerInfo];
        
        if ([[_tableInfo valueForKey:@"autoAdjustWidth"] boolValue]) {
            cell.isAvgWidth = NO;
        }
    }
    
    if (_colWidths != nil) {
        for (int i = 0; i < [_colWidths count] && i < [cell.colWidths count]; i++) {
            [cell.colWidths setObject:[_colWidths objectAtIndex:i]
                   atIndexedSubscript:i];
        }
    }
    [cell setNeedsUpdateConstraints];
    cell.delegate = self;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_shouldDismissProgress && _firstShow) {
        [SVProgressHUD dismiss];
        _firstShow = NO;
    }
    
    CHDataGridTableViewCell *cell = [tableView
                                     dequeueReusableCellWithIdentifier:
                                     [NSString stringWithFormat:@"dataGridTableViewCell_%ld_%ld",
                                      (long)indexPath.row,
                                      (long)indexPath.section]];
    if (cell == nil || [cell.columnsInfo count] != [_headerInfo count]) {
        cell = [[CHDataGridTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"dataGridTableViewCell"];
        
        UIColor *bgFrameColor =
        [UIColor colorWithHexString:[_tableInfo objectForKey:@"bgFrameColor"]];
        if (bgFrameColor) {
            cell.framelineColor = bgFrameColor;
        }
        
       
        
        if (self.isCanGoMore) {
            //添加下钻 提示图标
            UIImageView * imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(self.frame.size.width - 20,(cell.frame.size.height - 20 - 10)/2.0, 20, 20);
            imageView.image = [UIImage imageNamed:@"ic_tuiji"];
            [cell addSubview:imageView];
        }
        
        
        cell.topLineColor = [UIColor
                             colorWithHexString:[_tableInfo objectForKey:@"bgTopLineColor"]];
        cell.bottomLineColor = [UIColor
                                colorWithHexString:[_tableInfo objectForKey:@"bgBottomLineColor"]];
        cell.leftLineColor = [UIColor
                              colorWithHexString:[_tableInfo objectForKey:@"bgLeftLineColor"]];
        cell.rightLineColor = [UIColor
                               colorWithHexString:[_tableInfo objectForKey:@"bgRightLineColor"]];
        cell.splitLineColor = [UIColor
                               colorWithHexString:[_tableInfo objectForKey:@"splitLineColor"]];
        
        UIColor *bgSelectedColor = [UIColor
                                    colorWithHexString:[_tableInfo objectForKey:@"bgSelectedColor"]];
        if (bgSelectedColor) {
            cell.bgSelectedColor = bgSelectedColor;
        }
        
        UIColor *fontColor =
        [UIColor colorWithHexString:[_tableInfo objectForKey:@"fontColor"]];
        if (fontColor) {
            cell.fontColor = fontColor;
        }
        
        NSString *selectType = [_tableInfo objectForKey:@"selectType"];
        if (selectType) {
            if ([selectType compare:@"Line" options:NSCaseInsensitiveSearch] ==
                NSOrderedSame) {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.cellCanSelect = NO;
            } else if ([selectType compare:@"Cell" options:NSCaseInsensitiveSearch] ==
                       NSOrderedSame) {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.cellCanSelect = YES;
            } else {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
        
        NSString *align = [_tableInfo objectForKey:@"align"];
        if (align) {
            if ([align compare:@"left" options:NSCaseInsensitiveSearch] ==
                NSOrderedSame) {
                cell.align = NSTextAlignmentLeft;
            } else if ([align compare:@"right" options:NSCaseInsensitiveSearch] ==
                       NSOrderedSame) {
                cell.align = NSTextAlignmentRight;
            } else {
                cell.align = NSTextAlignmentCenter;
            }
        } else {
            cell.align = NSTextAlignmentCenter;
        }
        cell.lineHeight = [self getLineHeight];
        float fontSize = [[_tableInfo objectForKey:@"fontSize"] floatValue];
        if (fontSize > 0) {
            cell.fontSize = fontSize;
        }
        
        NSNumber *textwrap = [_tableInfo objectForKey:@"textwrap"];
        if (textwrap && [textwrap intValue] == 1) {
            cell.textwrap = YES;
        } else {
            cell.textwrap = NO;
        }
        
        NSNumber *framelines = [_tableInfo objectForKey:@"framelines"];
        if (framelines) {
            cell.frameLines = [framelines intValue];
        }
        
        [cell createGrids:_headerInfo];
        
        if ([[_tableInfo valueForKey:@"autoAdjustWidth"] boolValue]) {
            cell.isAvgWidth = NO;
        }
    }
    
    cell.delegate = self;
    if (indexPath.row % 2 == 1) {
        UIColor *bgColor =
        [UIColor colorWithHexString:[_tableInfo objectForKey:@"bgCellColor"]];
        if (bgColor) {
            cell.bgNormalColor = bgColor;
        }
    } else {
        UIColor *bgColor = [UIColor
                            colorWithHexString:[_tableInfo objectForKey:@"bgCellAltColor"]];
        if (bgColor == nil) {
            bgColor =
            [UIColor colorWithHexString:[_tableInfo objectForKey:@"bgCellColor"]];
        }
        if (bgColor) {
            cell.bgNormalColor = bgColor;
        }
    }
    NSArray*data= [_dataInfo objectAtIndex:indexPath.row];
    
    if (_specialRows&&_specialRows.count>0) {
        for (id specialRow in _specialRows) {
            if ([specialRow integerValue]==indexPath.row) {
                if (self.parentDelegate&&[self.parentDelegate respondsToSelector:@selector(CHDataGridTableView:forSpecialCell:)]) {
                    [self.parentDelegate CHDataGridTableView:tableView forSpecialCell:cell];
                }
            }
        }
    }

    [cell setCellData:data];
    
    //检测last cell
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    NSInteger lastRowIndex =
    [tableView numberOfRowsInSection:lastSectionIndex] - 1;
    if ((indexPath.section == lastSectionIndex) &&
        (indexPath.row == lastRowIndex)) {
        if ([self.parentDelegate respondsToSelector:@selector(detectingLastCell)]) {
            [self.parentDelegate detectingLastCell];
        }
    }
    
    if (_colWidths != nil) {
        for (int i = 0; i < [_colWidths count] && i < [cell.colWidths count]; i++) {
            [cell.colWidths setObject:[_colWidths objectAtIndex:i]
                   atIndexedSubscript:i];
        }
    }
    [cell setNeedsUpdateConstraints];
    
    return cell;
}

- (int)getHeaderHeight {
    CGFloat headHeight = [[_tableInfo objectForKey:@"headerHeight"] floatValue];
    if (headHeight < 0) {
        return 0;
    }
    if (headHeight == 0) {
        headHeight = 36;
    }
    return headHeight;
}

- (NSInteger)getLineHeight {
    NSInteger lineHeight = -1;
    @try {
        lineHeight = [[_tableInfo valueForKey:@"lineHeight"] integerValue];
    } @catch (NSException *ex) {
    }
    if (lineHeight < 5 || lineHeight > 200) {
        lineHeight = 33;
    }
    return lineHeight;
}
- (void)didSelectedTableViewCell:(UITableViewCell *)cell column:(int)column {
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    NSInteger row = indexPath.row;
    if (row >= [_dataInfo count] || column < 0 || column >= [_headerInfo count]) {
        return;
    }
    
    NSArray *rowData = [_dataInfo objectAtIndex:row];
    if (self.delegate &&
        [self.parentDelegate
         respondsToSelector:@selector(dataGridDidSelectCell:
                                      column:
                                      rowData:)]) {
             [self.parentDelegate dataGridDidSelectCell:row
                                                 column:column
                                                rowData:rowData];
         }
}
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 0 || indexPath.row >= [_dataInfo count]) {
        return;
    }
    
    NSString *selectType = [_tableInfo objectForKey:@"selectType"];
    if (selectType &&
        [selectType compare:@"Line" options:NSCaseInsensitiveSearch] !=
        NSOrderedSame) {
        return;
    }
    
    NSArray *rowData = [_dataInfo objectAtIndex:indexPath.row];
    if (self.delegate &&
        [self.parentDelegate
         respondsToSelector:@selector(dataGridDidSelectRow:rowData:)]) {
            [self.parentDelegate dataGridDidSelectRow:indexPath.row rowData:rowData];
        }
    return;
}

- (void)putData:(NSArray *)data {
    self.dataInfo = data;
    if ([[_tableInfo valueForKey:@"autoAdjustWidth"] boolValue]) {
        [_colWidths removeAllObjects];
        [self adjustColumnsWidth:data];
    } else {
    }
    
    [self reloadData];
}

- (void)adjustColumnsWidth:(NSArray *)data {
    NSInteger count = [_headerInfo count];
    NSInteger lineHeight = [self getLineHeight];
    if (_colWidths == nil) {
        _colWidths = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    float totalwidth = 0;
    
    float fontSize = lineHeight - 12;
    if (fontSize < 10) {
        fontSize = lineHeight - 4;
    } else {
        fontSize = [[_tableInfo objectForKey:@"fontSize"] floatValue];
    }
    if (fontSize == 0) {
        fontSize = 12;
    }
    UIFont *headerFont =
    [UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize];
    UIFont *cellFont = [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
    
    int padding = 10;
    for (int i = 0; i < count; i++) {
        NSDictionary *dict = [_headerInfo objectAtIndex:i];
        
        NSNumber* orgwidth = [dict objectForKey:@"width"];
        
        if(orgwidth && orgwidth.floatValue == 0){
            [_colWidths setObject:[NSNumber numberWithFloat:0] atIndexedSubscript:i];
            continue;
        }
        NSString *title = [dict objectForKey:@"datavalue"];
        
        float width = 20;
        
        CGSize size = [title sizeWithAttributeFont:headerFont];
        
        // CGSize size = [title sizeWithFont:headerFont];
        if (size.width + padding > width) {
            width = size.width + padding;
        }
        
        for (NSArray *datasInfo in data) {
            
            NSString *svalue =
            [NSString fromObject:[datasInfo objectAtIndex:i] decimal:2];
            
            if (svalue == nil) {
                svalue = @"--";
            }
            // <font color = '#008000'>0.11</font>
            
            NSString* tags=@"<[font].*?>(.*?)</[font].*?>";
            NSString *regTags = tags;
            NSError *error;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regTags                                                                         options:NSRegularExpressionCaseInsensitive error:&error];
            NSArray *matches = [regex matchesInString:svalue
                                              options:0
                                                range:NSMakeRange(0, [svalue length])];
            if(matches.count >0){
                for (NSTextCheckingResult *match in matches) {
                    svalue = [svalue substringWithRange:[match rangeAtIndex:1]];
                    
                }
            }
            
            size = [svalue sizeWithAttributeFont:cellFont];
            
            if (size.width + padding > width) {
                width = size.width + padding;
            }
        }
        if (width > _maxcolwidth) {
            width = _maxcolwidth;
        }
        
        [_colWidths setObject:[NSNumber numberWithFloat:width]
           atIndexedSubscript:i];
        
        totalwidth += width;
    }
    _totalwidth = totalwidth;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_needScrollTrigger) {
        if (self.delegate && [self.parentDelegate
                              respondsToSelector:@selector(dataGridDidScroll:)]) {
            [self.parentDelegate dataGridDidScroll:scrollView];
        }
    } else {
    }
}

#pragma mark 排序
- (void)didSelectedTableViewHeaderName:(NSString *)headerName{ //MTLockedColumnsTableView排序
    if([self.parentDelegate respondsToSelector:@selector(dataGridDidClickHeaderName:)]){
        [self.parentDelegate dataGridDidClickHeaderName:headerName];
    }
}



#pragma mark 字符串转数字 去掉“%” “↑” “↑”
- (NSString *) changetStr:(NSString*) string{
    if ([string hasPrefix:@"↑"]||[string hasPrefix:@"↓"]) {
        string = [string substringFromIndex:1];
    }
    if ([string hasSuffix:@"↑"]||[string hasSuffix:@"↓"]||[string hasSuffix:@"%"]) {
        string = [string substringToIndex:string.length-1];
    }
    return string;
}

- (BOOL) isNumber:(NSString*)str{

    for (int i=0; i<str.length; i++) {
        unichar chari = [str characterAtIndex:i];
        if ((chari != '.') && (chari>'9' || chari<'0')) {
            return NO;
        }
    }
        return YES;
}
@end
