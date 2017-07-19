//
//  CHLegendView.m
//  AppUseAnalysis
//
//  Created by 陈灿锋 on 17/5/17.
//  Copyright © 2017年 陈灿锋. All rights reserved.
//

#import "CHLegendView.h"
#import <CoreGraphics/CoreGraphics.h>



@implementation CHLegendView
@synthesize titlesFont=_titlesFont;

#define COLORPADDING 15
#define PADDING 5

#define kscreenW  [UIScreen mainScreen].bounds.size.width
#define kscreenH  [UIScreen mainScreen].bounds.size.height

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGFloat h=[self.titlesFont lineHeight];
    int count=(int)[self.titles count];
    CGFloat y=PADDING+h;
    if (self.xTitle) {

       
        NSMutableParagraphStyle* paraStyle = [[NSMutableParagraphStyle alloc] init];
        [paraStyle setAlignment:NSTextAlignmentLeft];

        [paraStyle setLineBreakMode:NSLineBreakByWordWrapping];

        
        NSDictionary* dictitleFont = [NSDictionary dictionaryWithObjectsAndKeys:self.titlesFont, NSFontAttributeName, paraStyle,NSParagraphStyleAttributeName, [UIColor grayColor], NSForegroundColorAttributeName,nil];

        NSString* xTitleString ;
        if (self.xTitle) {
             xTitleString =[NSString stringWithFormat:@"横坐标: %@",self.xTitle];
        }
       
        NSString * yTitle=@"纵坐标:";
        [[UIColor blackColor] set];
        
        CGRect xTitleFrame = CGRectMake(PADDING*2 , PADDING, 60,h);
        CGRect yTitleFrame = CGRectMake(PADDING*2 , 2*PADDING+h, 40,h);
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            [xTitleString drawInRect:xTitleFrame withAttributes:dictitleFont];
            [yTitle drawInRect:yTitleFrame withAttributes:dictitleFont];
        }else{
            NSAttributedString *att_title = [[NSAttributedString alloc] initWithString:xTitleString attributes:dictitleFont];
            [att_title drawInRect:xTitleFrame];
            att_title = [[NSAttributedString alloc] initWithString:yTitle attributes:dictitleFont];
            [att_title drawInRect:yTitleFrame];
            
        }
        
    }
    for(int i=0;i<count;i++) {
        int yOffset=i%2;
        
        NSString *title=self.titles[i];
        UIColor *color = [self.colors objectForKey:title];
        NSString* chartType= [self.chartTypes objectForKey:title];
        CGFloat x=0.0f;
        if (yOffset==0) {
            x=PADDING+35;
            
        }
        else{
            x=self.frame.size.width/2+PADDING+35;
        }
        if(color) {
            [color setFill];
            if ([chartType isEqualToString:@"Line"]) {
                CGContextSetStrokeColorWithColor(c, [color CGColor]);
                CGContextMoveToPoint(c, x,  PADDING + round(y) + self.titlesFont.xHeight  + 1);
                CGContextAddLineToPoint(c,x+20,PADDING + round(y) + self.titlesFont.xHeight  + 1);
                CGContextStrokePath(c);
            }
            else if ([chartType isEqualToString:@"Column"]){
                CGContextFillRect(c, CGRectMake(x + 2, PADDING + round(y) + self.titlesFont.xHeight / 2 + 1, 8, 8));
            }
        }
        [[UIColor whiteColor] set];

        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            [title drawAtPoint:CGPointMake(x+COLORPADDING + 2*PADDING, y + PADDING) withAttributes:@{NSFontAttributeName: self.titlesFont}];
        }else{
            NSAttributedString *att_title = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: self.titlesFont}];
            [att_title drawAtPoint:CGPointMake(x+COLORPADDING + 2*PADDING, y + PADDING)];
        }
        if (yOffset==1) {
            y += [self.titlesFont lineHeight];
        }
    }
}
- (UIFont *)titlesFont {
    if(_titlesFont == nil)
        _titlesFont = [UIFont fontWithName:@"HelveticaNeue" size:8];
    return _titlesFont;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat h = [self.titlesFont lineHeight] * [self.titles count];
    CGFloat w = 0;
    for(NSString *title in self.titles) {
        CGSize s = [title sizeWithAttributeFont:self.titlesFont];
        w = MAX(w, s.width);
    }
    return CGSizeMake(COLORPADDING + w + 2 * PADDING, h + 2 * PADDING);
}
@end
