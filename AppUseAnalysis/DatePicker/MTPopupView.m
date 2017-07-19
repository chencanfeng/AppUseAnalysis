//
//  MTPopupView.m
//  TestProject
//
//  Created by ren wanqian on 14-9-25.
//  Copyright (c) 2014年 mastercom. All rights reserved.
//

#import "MTPopupView.h"

@implementation MTPopupView{
    UIView *_dialogView;
}
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self prepare];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        [self prepare];
        
        
    }
    return self;
}

- (void)prepare{

    _cornerRadius = 0.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _dialogView = [[UIView alloc] init];
    _dialogView.backgroundColor=[UIColor whiteColor];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = _dialogView.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0f] CGColor],
                       nil];
    
    //gradient.cornerRadius = _cornerRadius;
    [_dialogView.layer insertSublayer:gradient atIndex:0];
    
    _dialogView.layer.cornerRadius = _cornerRadius;
    
    _dialogView.layer.borderColor = [[UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f] CGColor];
    _dialogView.layer.borderWidth = 0;//1;
    _dialogView.layer.shadowRadius = _cornerRadius + 5;
    _dialogView.layer.shadowOpacity = 0.1f;
    _dialogView.layer.shadowOffset = CGSizeMake(0 - (_cornerRadius+5)/2, 0 - (_cornerRadius+5)/2);
    _dialogView.layer.shadowColor = [UIColor blackColor].CGColor;
    _dialogView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_dialogView.bounds cornerRadius:_dialogView.layer.cornerRadius].CGPath;
    
    [super addSubview:_dialogView];
    
}
- (void)showAtPosition:(CGPoint)point{
    CGRect dialogRect = [self getContentRect];
    _dialogView.frame = CGRectMake(point.x, point.y, dialogRect.size.width, dialogRect.size.height);
    [self showView];
}
- (void)show
{
    _dialogView.layer.cornerRadius = _cornerRadius;
    _dialogView.layer.shadowRadius = _cornerRadius + 5;
    _dialogView.layer.shadowOffset = CGSizeMake(0 - (_cornerRadius+5)/2, 0 - (_cornerRadius+5)/2);
    
    [self relocation:CGSizeMake(0,0) animate:NO];
    [self showView];
}

- (void)showView{
    _dialogView.layer.shouldRasterize = YES;
    _dialogView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    _dialogView.layer.masksToBounds = YES;
    _dialogView.layer.opacity = 0.5f;
    _dialogView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self setFrame:[UIScreen mainScreen].bounds];
    
    if(self.disappearOnTouchOutside){
        UITapGestureRecognizer *tapRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [tapRecognizer setDelegate:self];
        [self addGestureRecognizer:tapRecognizer];
    }
    
    [[[[UIApplication sharedApplication] windows] lastObject] addSubview:self];
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
                         _dialogView.layer.opacity = 1.0f;
                         _dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                         
                     }
                     completion:NULL
     ];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
 
    if (touch.view != self) {
        return NO; // 不理event
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        int touchIndex = sender.numberOfTouches-1;
        if(touchIndex<0){
            touchIndex = 0;
        }
        CGPoint point = [sender locationOfTouch:touchIndex inView:self];
        if(!CGRectContainsPoint(_dialogView.frame, point)){
            [self close];
        }
    }
}

- (void)close
{
    CATransform3D currentTransform = _dialogView.layer.transform;
    
    CGFloat startRotation = [[_dialogView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);
    
    _dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
    _dialogView.layer.opacity = 1.0f;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         _dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         _dialogView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
//                         for (UIView *v in [self subviews]) {
//                             [v removeFromSuperview];
//                         }
                         [self removeFromSuperview];
                     }
     ];
}

- (void)addContentview:(UIView *)view
{

    [_dialogView addSubview:view];
    
}

- (void)relocation:(CGSize)keyboardSize animate:(BOOL)animate{
    CGRect dialogRect = [self getContentRect];

    float dialogWidth = dialogRect.size.width;
    float dialogHeight = dialogRect.size.height;
    

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGRect newFrame;
    if(self.vAlignment==MTPopupViewVertAlignmentTop){
        newFrame = CGRectMake((screenWidth - dialogWidth) / 2, 20, dialogWidth, dialogHeight);
    }else if(self.vAlignment==MTPopupViewVertAlignmentMiddle){
        newFrame = CGRectMake((screenWidth - dialogWidth) / 2, (screenHeight - keyboardSize.height - dialogHeight)/2, dialogWidth, dialogHeight);
    }else if(self.vAlignment==MTPopupViewVertAlignmentBottom){
        newFrame = CGRectMake((screenWidth - dialogWidth) / 2, (screenHeight - keyboardSize.height - dialogHeight), dialogWidth, dialogHeight);
    }
    
    _dialogView.layer.transform = CATransform3DIdentity;

    if(animate){
        [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _dialogView.frame = newFrame;
                     }
                     completion:nil
         ];
    }else{
        _dialogView.frame = newFrame;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (CGRect)getContentRect{
    CGRect rect = CGRectMake(0, 0, 0, 0);
    for(UIView *view in _dialogView.subviews){
        rect = CGRectUnion(rect, view.frame);
    }
    return rect;
}
- (void)keyboardWillShow: (NSNotification *)notification
{
 
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [self relocation:keyboardSize animate:YES];
}

- (void)keyboardWillHide: (NSNotification *)notification
{
    [self relocation:CGSizeMake(0,0) animate:YES];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
