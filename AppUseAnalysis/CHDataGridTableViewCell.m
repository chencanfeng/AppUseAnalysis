//
//  CHDataGridTableViewCell.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHDataGridTableViewCell.h"


@interface CHDataGridTableViewCell(){
    NSMutableArray *subViews;
    

}
@end

@implementation CHDataGridTableViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _fontColor = [UIColor blackColor];
        _align = NSTextAlignmentCenter;
        _lineHeight = 25;
        _fontSize=13;
        _isAvgWidth=YES;
        subViews = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _fontColor = [UIColor blackColor];
        _align = NSTextAlignmentCenter;
        _lineHeight = 25;
        _fontSize=13;
        subViews = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return  self;
}
-(void)createGrids:(NSArray *)columnsInfo{
    if(columnsInfo == nil){
        return;
    }
    
    _isAvgWidth= YES;
    [subViews removeAllObjects];

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
        //列宽度
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
        }else if(width>1){
            _isAvgWidth = NO;
        }
        [_colWidths addObject:[NSNumber numberWithFloat:width]];
        //使用Button作为Cell内容
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(cellClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:_fontColor forState:UIControlStateNormal];
//        [button setBackgroundImage:[UIImage imageNamed:@"bg_OrageColor"] forState:UIControlStateHighlighted];
        button.titleLabel.font = [UIFont fontWithName: @"HelveticaNeue" size: fontSize];
        if(_textwrap==YES){
            button.titleLabel.numberOfLines=3;
            button.titleLabel.lineBreakMode=NSLineBreakByTruncatingMiddle;
        }else{
            button.titleLabel.adjustsFontSizeToFitWidth = YES;
        }
        [button setBackgroundColor: [UIColor clearColor]];
        
        //设置水平对齐方式
        NSTextAlignment align = _align;
        NSString *aligntext = [dict objectForKey:@"align"];
        if(aligntext){
            if([aligntext compare:@"left" options:NSCaseInsensitiveSearch]==NSOrderedSame){
                align = NSTextAlignmentLeft;
            }else if([aligntext compare:@"right" options:NSCaseInsensitiveSearch]==NSOrderedSame){
                align = NSTextAlignmentRight;
            }else if([aligntext compare:@"center" options:NSCaseInsensitiveSearch]==NSOrderedSame){
                align = NSTextAlignmentCenter;
            }

        }
        button.contentHorizontalAlignment = [self getContentAlignment:align];
        button.titleLabel.textAlignment = align;
        int iskey = [[dict objectForKey:@"iskey"] intValue];
        if(_cellCanSelect && iskey==1){
            button.userInteractionEnabled = YES;
        }else{
            button.userInteractionEnabled = NO;
        }
        button.tag=100+i;
        [subViews addObject:button];
        [self.contentView addSubview: button];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[button(%f)]",left+2,width>4?width-4:0] options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[button]-1-|"] options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
        //如果是html内容把webview加入到button里
        NSString *type = [dict objectForKey:@"type"];
        if(type && [type isEqualToString:@"html"]){
            UIWebView *webView = [[UIWebView alloc] init];
            webView.userInteractionEnabled=YES;
            webView.backgroundColor=[UIColor clearColor];
            webView.opaque=NO;
            webView.dataDetectorTypes = UIDataDetectorTypeNone;
            webView.autoresizesSubviews = YES;
            webView.tag = 1000+100+i;
            if(button.userInteractionEnabled){
                UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellClick:)];
                touch.delegate = self;
                [webView addGestureRecognizer:touch];
            }
            [button addSubview: webView];
            if(width<4){
                button.hidden=YES;
            }
            webView.translatesAutoresizingMaskIntoConstraints = NO;
            [button addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-0-[webView]-0-|"] options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
            [button addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[webView]-0-|"] options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
        }
        left += width;
    }
    if (self.constraints) {
        [self.contentView removeConstraints:self.constraints];
    }
    self.constraints = newConstraints;
    [self.contentView addConstraints:self.constraints];

}


-(void)updateConstraints
{
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
    else if(allWidth<maxWidth)
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
    int count = [subViews count];
    float left = 0;
    for(int i=0;i<count;i++){
        UIButton *button = (UIButton*)[subViews objectAtIndex:i];
        float width = [[_colWidths objectAtIndex:i] floatValue];
        if(width<4){
            button.hidden=YES;
        }
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[button(%f)]",left+2,width>4?width-4:0] options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
       [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[button]-1-|"] options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
        left += width;
    }
    if (self.constraints) {
        [self.contentView removeConstraints:self.constraints];
    }
    self.constraints = newConstraints;
    [self.contentView addConstraints:self.constraints];
    [super updateConstraints];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
-(void)cellClick:(id)sender{
    if([self.delegate respondsToSelector:@selector(didSelectedTableViewCell:column:)])
    {
        UIView *view = (UIView*)sender;
        if([sender isKindOfClass:UITapGestureRecognizer.class]){
            view = ((UITapGestureRecognizer*)sender).view;
        }
        
        [self.delegate didSelectedTableViewCell:self column: view.tag%1000-100];
    }
}
-(void)setCellData:(NSArray*)datasInfo{
    NSUInteger count = [datasInfo count];
    
    for(int index=0; index < count; index++){
        if(index >= [_columnsInfo count]){
            break;
        }
        NSDictionary *colDict = [_columnsInfo objectAtIndex:index];
        
        NSString *value = nil;
        UIButton *button = (UIButton*)[self viewWithTag:100 + index];
        if(button){
            value = [NSString fromObject:[datasInfo objectAtIndex:index] decimal:2];
         
            if(value == nil){
                [button setTitle:@"--" forState:UIControlStateNormal];
            }else{
                NSString *type = [colDict objectForKey:@"type"];
                if(type && [type isEqualToString:@"html"]){
                    UIWebView *webView = (UIWebView*)[button viewWithTag:1000+100+index];
                    const CGFloat *components = CGColorGetComponents(_fontColor.CGColor);
                    NSString *aligntext = [colDict objectForKey:@"align"];
                    if(aligntext==nil){
                        if(_align == NSTextAlignmentLeft){
                            aligntext = @"left";
                        }else if(_align == NSTextAlignmentRight){
                            aligntext = @"right";
                        }else{
                            aligntext = @"center";
                        }
                    }
                    NSString *style = [NSString stringWithFormat:@"<style>body{margin:0;background-color:transparent;color:#%02X%02u%02u}</style>",(int)components[0],(int)components[1],(int)components[2]];
                    int width = [_colWidths[index] intValue];
                    [webView loadHTMLString:[NSString stringWithFormat:@"%@<table><tr><td style=\"width:%dpx;height:%dpx;vertical-align:middle;text-align:%@;font:%dpx HelveticaNeue\"><div>%@</div></td></tr>",style,width,(int)_lineHeight,aligntext,(int)_fontSize,value] baseURL:nil];
                }else{
                    
                    [button setTitle:value forState:UIControlStateNormal];
                }
            }
        }
        
    }

}

-(void)handleCellColor:(int)index datasInfo:(NSArray*)datasInfo propertyValue:(NSString*)propertyValue{
    if(propertyValue == nil)return;
    int colorIndex = [propertyValue intValue];
    if(colorIndex < 0 || colorIndex >= [datasInfo count]){
        return;
    }
    UIColor *color = [UIColor colorWithHexString:[datasInfo objectAtIndex:colorIndex]];
    if(color){
        UIButton *button = (UIButton*)[self viewWithTag:100+index];
        [button setTitleColor:color forState:UIControlStateNormal];
    }
}

-(NSString *)stringPropertyValue:(NSString*)str key:(NSString*)key{
    NSRange range = [str rangeOfString:key  options:NSCaseInsensitiveSearch];
    if(range.location == NSNotFound)return nil;
    NSString *result = [str substringFromIndex:range.location+range.length];
    
    range = [result rangeOfString:@"|"];
    if(range.location == NSNotFound){
        return result;
    }else{
        return [result substringToIndex:range.location];
    }
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
    
    CGContextSetLineWidth(context,0.5);
    
    CGContextSetStrokeColorWithColor(context, self.framelineColor.CGColor);
    
    //上边框
    if((self.frameLines & CHTableViewCellFrameLineTop) == CHTableViewCellFrameLineTop){
        if(self.topLineColor){
            CGContextSetStrokeColorWithColor(context, self.topLineColor.CGColor);
        }else{
            CGContextSetStrokeColorWithColor(context, self.framelineColor.CGColor);
        }
        CGPoint points[2];
        points[0]=CGPointMake(0,0);
        points[1]=CGPointMake(rect.size.width,0);
        
        CGContextStrokeLineSegments(context,points, 2);
    }
    
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
        points[0]=CGPointMake(left,0);
        points[1]=CGPointMake(left,rect.size.height);
        CGContextStrokeLineSegments(context,points, 2);

    }

    
}


@end
