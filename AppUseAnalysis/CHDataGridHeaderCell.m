//
//  CHDataGridHeaderCell.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//
#import "CHDataGridHeaderCell.h"
@interface CHDataGridHeaderCell(){
    NSMutableArray *subViews;
}
@end

@implementation CHDataGridHeaderCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isAvgWidth=YES;
        _fontColor = [UIColor blackColor];
        _align = NSTextAlignmentCenter;
        _lineHeight = 36;
        _fontSize=14;
        subViews = [[NSMutableArray alloc] initWithCapacity:10];
        
    }
    return self;
}
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _fontColor = [UIColor blackColor];
        _align = NSTextAlignmentCenter;
        _lineHeight = 36;
        _fontSize=14;
        subViews = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}
-(void)createGrids:(NSArray *)columnsInfo{
    if(columnsInfo == nil){
        return;
    }
    _isAvgWidth=YES;
    _columnsInfo = columnsInfo;
    CGSize size = self.frame.size;
    int colCount = [columnsInfo count];
    _colWidths = [[NSMutableArray alloc] initWithCapacity:colCount];
    
    float left = 0;
    float fontSize = _lineHeight - 12;
    if(fontSize < 10){
        fontSize = _lineHeight -4;
    }
    else{
        fontSize=_fontSize;
    }
    
    NSMutableArray *newConstraints = [NSMutableArray array];
    
    
    for(int i=0;i<colCount;i++){
        NSDictionary *dict = [columnsInfo objectAtIndex:i];
        
        float width = 0;
        NSString *strWidth = [dict objectForKey:@"width"];
        if(strWidth){
            @try{
                width = [strWidth floatValue];
            }@catch(NSException *ex){
                
            }
        }
        if(width<0){
            width = size.width/colCount;
        }else if(width>0 && width<=1){
            width = size.width * width;
        }
        else if(width>1){
            _isAvgWidth = NO;
        }
        [_colWidths addObject:[NSNumber numberWithFloat:width]];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:[dict objectForKey:@"datavalue"] forState:UIControlStateNormal];
        [button setTitleColor:_fontColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName: @"HelveticaNeue-Bold" size: fontSize];
        if(_textwrap==YES){
            button.titleLabel.numberOfLines=0;
            button.titleLabel.lineBreakMode=NSLineBreakByCharWrapping;
        }else{
            button.titleLabel.adjustsFontSizeToFitWidth = YES;
        }
        [button setBackgroundColor: [UIColor clearColor]];
        button.contentHorizontalAlignment = [self getContentAlignment:_align];
        button.titleLabel.textAlignment = _align;
        button.tag = (i<<8);//序号存储在高8位
        [subViews addObject:button];
        [self.contentView addSubview: button];
        button.translatesAutoresizingMaskIntoConstraints = NO;

        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[button(%f)]",left+2,width>=4?width-4:0] options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[button]|"] options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
        
        //[button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
        NSString* column = [dict objectForKey:@"datavalue"];
        NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            NSDictionary* indecatorInfo = evaluatedObject;
            NSString* indecatorName = [indecatorInfo valueForKey:@"指标名称"];
            return [indecatorName isEqualToString:column];
        }];
        NSArray* filtered = [self.indicatorDesc filteredArrayUsingPredicate:predicate];
        
        if (filtered.count >0) {
            UIImageView* imgView = [[UIImageView alloc]initWithFrame:CGRectZero];
            [button addSubview:imgView];
            imgView.image = [UIImage imageNamed:@"info"];
            
            button.tag += [self.indicatorDesc indexOfObject:filtered.firstObject];
            
            imgView.translatesAutoresizingMaskIntoConstraints = NO;
            [button addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[imgView(12)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imgView)]];
            [button addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imgView(12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imgView)]];
            
            [button addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showIndicatorDescription:)]];
        }
        
        left += width;
        
        //TODO:增加排序的图标
    }
    self.constraints = newConstraints;
    [self.contentView  addConstraints:self.constraints];
    
    
}


-(void)updateConstraints{
    CGFloat maxWidth=self.frame.size.width;
    int colcount = [_colWidths count];
    float allWidth = 0;
    for(int i=0;i<colcount;i++){
        allWidth += [[_colWidths objectAtIndex:i] floatValue];
    }
    if(_isAvgWidth)
    {
        for(int i=0;i<colcount;i++){
            [_colWidths replaceObjectAtIndex:i withObject:@(self.frame.size.width*[[_colWidths objectAtIndex:i] floatValue]/allWidth )];
        }
    }
    else if(allWidth<maxWidth)//调整宽度以适应屏幕 平均分配为基本原则
    {
        [_colWidths sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:nil ascending:NO]]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %f", 0];
        NSArray *results = [_colWidths filteredArrayUsingPredicate:predicate];
        
        CGFloat subWidth=maxWidth;
        NSInteger largerAvgWidthCount=0;
        float avgWidth= 0;
        for(int i=0;i<colcount;i++)
        {
            CGFloat count=(colcount-results.count-i);
            if (count==0) {
                continue;
            }
            avgWidth = subWidth/(colcount-results.count-i);
            CGFloat width=  [_colWidths[i] floatValue];
            
            if (width>avgWidth) {
                subWidth=subWidth-width;
                largerAvgWidthCount++;
            }else{
                break;
            }
        }
        
        for (NSInteger i = largerAvgWidthCount; i< colcount; i++) {
            CGFloat width=  [_colWidths[i] floatValue];
            if (width!=0) {
                
                [_colWidths replaceObjectAtIndex:i withObject:@(avgWidth)];
            }

        }
    }

    NSMutableArray *newConstraints = [NSMutableArray array];
    
    NSInteger count = [subViews count];
    float left = 0;
    for(int i=0;i<count;i++){
        UIButton *button = (UIButton*)[subViews objectAtIndex:i];
        float width = [[_colWidths objectAtIndex:i] floatValue];
        if(width<4){
            button.hidden=YES;
        }
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[button(%f)]",left+2,width>4?width-4:0] options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[button]-0-|"] options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
    
        left += width;
    }
    
    if (self.constraints) {
        [self.contentView removeConstraints:self.constraints];
    }
    
    self.constraints = newConstraints;
    [self.contentView  addConstraints:self.constraints];
    
    [super updateConstraints];
}


-(UIControlContentHorizontalAlignment)getContentAlignment:(NSTextAlignment)alignment{
    if(alignment == NSTextAlignmentLeft){
        return UIControlContentHorizontalAlignmentLeft;
    }else if(alignment == NSTextAlignmentRight){
        return UIControlContentHorizontalAlignmentRight;
    }else{
        return UIControlContentHorizontalAlignmentCenter;
    }
}
// 自绘边框
- (void)drawRect:(CGRect)rect
{

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, self.bgNormalColor.CGColor);
    CGContextFillRect(context, rect);

    //上边框
    {
        if(self.topLineColor){
            CGContextSetStrokeColorWithColor(context, self.topLineColor.CGColor);
        }else{
            CGContextSetStrokeColorWithColor(context, self.framelineColor.CGColor);
        }
        CGPoint points[2];
        points[0]=CGPointMake(0,0);
        points[1]=CGPointMake(rect.size.width,0);
        
        CGContextSetLineWidth(context,3);
        CGContextStrokeLineSegments(context,points, 2);
    }
    
    CGContextSetLineWidth(context,0.5);
    //下边框
    if((self.frameLines & CHTableViewCellFrameLineBottom) == CHTableViewCellFrameLineBottom){
        if(self.bottomLineColor){
            CGContextSetStrokeColorWithColor(context, self.bottomLineColor.CGColor);
        }else{
            CGContextSetStrokeColorWithColor(context, self.framelineColor.CGColor);
        }
        CGPoint points[2];
        points[0]=CGPointMake(0,rect.size.height);
        points[1]=CGPointMake(rect.size.width,rect.size.height);
        CGContextStrokeLineSegments(context,points, 2);
    }
    
    //左边框
    if((self.frameLines & CHTableViewCellFrameLineLeft) == CHTableViewCellFrameLineLeft){
        if(self.leftLineColor){
            CGContextSetStrokeColorWithColor(context, self.leftLineColor.CGColor);
        }else{
            CGContextSetStrokeColorWithColor(context, self.framelineColor.CGColor);
        }
        CGPoint points[2];
        points[0]=CGPointMake(0,0);
        points[1]=CGPointMake(0,rect.size.height);
        CGContextStrokeLineSegments(context,points, 2);
    }
    
    //右边框
    if((self.frameLines & CHTableViewCellFrameLineRight) == CHTableViewCellFrameLineRight){
        if(self.rightLineColor){
            CGContextSetStrokeColorWithColor(context, self.rightLineColor.CGColor);
        }else{
            CGContextSetStrokeColorWithColor(context, self.framelineColor.CGColor);
        }
        CGPoint points[2];
        points[0]=CGPointMake(rect.size.width,0);
        points[1]=CGPointMake(rect.size.width,rect.size.height);
        CGContextStrokeLineSegments(context,points, 2);
    }
    
    //每格的竖直分割线
    if(_splitLineColor){
        CGContextSetStrokeColorWithColor(context, _splitLineColor.CGColor);
    }else{
        CGContextSetStrokeColorWithColor(context, self.framelineColor.CGColor);
    }
    
    int colCount = [_colWidths count];
    float left = 0;
    for(int i=0;i<colCount-1;i++){
        left += [[_colWidths objectAtIndex:i] floatValue];
        
        CGPoint points[2];
        points[0]=CGPointMake(left,2);
        points[1]=CGPointMake(left,rect.size.height);
        
        CGContextSetLineWidth(context,0.5);
        CGContextStrokeLineSegments(context,points, 2);
        
    }

    
}

- (void)dealloc{
    
}

@end
