//
//  MTBaseViewController.m
//  MTFrameDevVesison
//
//  Created by song mj on 16/9/6.
//  Copyright © 2016年 mastercom. All rights reserved.
//

#import "MTBaseViewController.h"
#import "SVProgressHUD.h"

@interface MTBaseViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableDictionary * attributedDict;

@property (nonatomic, assign) NSInteger sliderViewWidth;

@property (nonatomic, strong) UIView *sliderCoverView;

@property (nonatomic, strong) UIView *sliderView;

@property (nonatomic, copy) NSArray *leftBarItems;

@end



NSString * const kLeftNaviBarNormal = @"btn_back_normal";
NSString * const kLeftNaviBarHightLight = @"btn_back_pressed";


@implementation MTBaseViewController

#pragma mark - life cycle
- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        self.navigationBarhidden = YES;
        self.naviBarLeftImageDelegate = nil;
        self.usingNewNaviBgColor = NO;
    }
    return self;
}

- (instancetype) init {
    if(self = [super init]) {
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        self.navigationBarhidden = YES;
        self.naviBarLeftImageDelegate = nil;
        self.usingNewNaviBgColor = NO;
    }
    return self;
}

- (void)viewDidLoad {
    self.navigationController.navigationBar.alpha = 1;
    [super viewDidLoad];
    
    [self setupBaseView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    
    @try {
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }
    }
    @catch (NSException* exception) {
    }
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = self.navigationBarhidden;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        //只有在二级页面生效
        if ([self.navigationController.viewControllers count] == 2) {
            self.navigationController.interactivePopGestureRecognizer.delegate = self;
        }
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark - Navigator related methods
- (void)pushViewController:(UIViewController*)vc {
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)setViewController:(UIViewController*)vc {
    [self.navigationController setViewControllers:@[ vc ]];
}


- (void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushViewController:(UIViewController*)vc navigationBarHidden:(BOOL)hidden {
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationBarhidden = hidden;
}


- (void)setNaviTitle:(NSString*)title leftButtonShow:(BOOL)leftButtonShow rightButtom:(id)rightButtom {
    self.navigationBarhidden = NO;
    if (!leftButtonShow) {
        _leftBarItems = self.navigationItem.leftBarButtonItems;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = YES;
    }
    else {
        self.navigationItem.leftBarButtonItems = _leftBarItems;
        self.navigationItem.hidesBackButton = NO;
    }
    
    [self.navigationItem setRightBarButtonItem:rightButtom];
    [self setTitle:title];
}


- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
    [SVProgressHUD dismiss];
}


- (void)backAction:(id)sender {
    [self backAction];
}


#pragma mark - Attribute related methods
- (void)putAttribute:(NSString*)key Value:(id)value
{
    if (_attributedDict == nil) {
        _attributedDict = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    [_attributedDict setObject:value forKey:key];
}


- (id)getAttribute:(NSString*)key
{
    if (_attributedDict == nil) {
        return nil;
    }
    return [_attributedDict valueForKey:key];
}


- (void)removeAttribute:(NSString*)key
{
    [_attributedDict removeObjectForKey:key];
}



#pragma mark - SliderVeiw related methods
- (void)setSliderView:(UIView*)view width:(int)width
{
    _sliderViewWidth = width;
    
    UIImageView* topImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_titlebar"]];
    int topHeight = topImage.frame.size.height;
    
    CGRect rect = [UIScreen mainScreen].bounds;
    
    _sliderView = [[UIView alloc] initWithFrame:CGRectMake(rect.size.width, 0, _sliderViewWidth, rect.size.height)];
    [_sliderView addSubview:topImage];
    [_sliderView addSubview:view];
    view.frame = CGRectMake(0, topHeight, _sliderViewWidth, rect.size.height - topHeight);
    
    _sliderCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    
    _sliderView.layer.shadowRadius = 3;
    _sliderView.layer.shadowOpacity = 0.2f;
    _sliderView.layer.shadowOffset = CGSizeMake(0 - 10 / 2, 0 - 10 / 2);
    _sliderView.layer.shadowColor = [UIColor blackColor].CGColor;
    _sliderView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_sliderView.bounds cornerRadius:5].CGPath;
    [[UIApplication sharedApplication].keyWindow addSubview:_sliderView];
    
    UITapGestureRecognizer* gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderCoverAction:)];
    _sliderCoverView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _sliderCoverView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_sliderCoverView];
    [_sliderCoverView addGestureRecognizer:gr];
    _sliderCoverView.hidden = YES;
    _sliderCoverView.translatesAutoresizingMaskIntoConstraints = NO;
}


- (void)toggleSliderView
{
    CGRect destination = self.navigationController.view.frame;
    CGRect frame = _sliderView.frame;
    
    if (destination.origin.x < 0) {
        destination.origin.x = 0;
        frame.origin.x = [UIScreen mainScreen].bounds.size.width;

        _sliderCoverView.hidden = YES;
        _sliderView.hidden = YES;
        _sliderView.layer.shadowRadius = 0;
    }
    else {
        destination.origin.x -= _sliderViewWidth;
        frame.origin.x = [UIScreen mainScreen].bounds.size.width - _sliderViewWidth;
        
        _sliderCoverView.hidden = NO;
        _sliderView.hidden = NO;
        _sliderView.layer.shadowRadius = 3;
    }
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.navigationController.view.frame = destination;
                         _sliderView.frame = frame;
                     }];
}

- (void)sliderCoverAction:(UIGestureRecognizer*)recognizer {
    //[self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleBordered];
    
    //The up methods was outtime
    [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
    
    _sliderCoverView.hidden = YES;
    
    CGRect destination = self.navigationController.view.frame;
    CGRect frame = _sliderView.frame;
    destination.origin.x = 0;
    frame.origin.x = [UIScreen mainScreen].bounds.size.width;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.navigationController.view.frame = destination;
                         _sliderView.frame = frame;
                     }];
}


- (void)setNavigationBarWithColor:(UIColor*)color
{
    UIImage* image = [self imageWithColor:color];
    
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setTranslucent:YES];
}




#pragma mark - InterfaceOrientation related methods

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


#pragma mark - pravited methods

- (UIImage*)imageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (void)setupBaseView {
    if (self) {
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    
    UIImage *normalImg = nil;
    UIImage *highlightedImg = nil;
    
    if(self.isUseNewNaviBgColor) {
        if(self.naviBarLeftImageDelegate) {
            if([self.naviBarLeftImageDelegate respondsToSelector:@selector(naviBarImgForStateNormal)]) {
                normalImg = [self.naviBarLeftImageDelegate naviBarImgForStateNormal];
            }
            
            if([self.naviBarLeftImageDelegate respondsToSelector:@selector(naviBarImgForStateHighlighted)]) {
                highlightedImg = [self.naviBarLeftImageDelegate naviBarImgForStateHighlighted];
            }
        }
    }
    
    if(nil == normalImg) {
        normalImg = [UIImage imageNamed:kLeftNaviBarNormal];
    }
    
    if(nil == highlightedImg) {
        highlightedImg = [UIImage imageNamed:kLeftNaviBarHightLight];
    }
    
    
    UIButton* backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(0, 0, 24, 24)];
    [backBtn setImage:normalImg forState:UIControlStateNormal];
    [backBtn setImage:highlightedImg forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    UIBarButtonItem* item1 = [[UIBarButtonItem alloc] initWithCustomView:[UIButton buttonWithType:UIButtonTypeCustom]];
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:item, item1, nil];
    _leftBarItems = [NSArray arrayWithObjects:item, item1, nil];
    
    [self setUpForDismissKeyboard];
    
}

#pragma mark - handle keyboard notification mentods
- (void)setUpForDismissKeyboard
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    UITapGestureRecognizer* singleTapGR =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapAnywhereToDismissKeyboard:)];
    NSOperationQueue* mainQuene = [NSOperationQueue mainQueue];
    __weak typeof(self) wSelf = self;
    [nc addObserverForName:UIKeyboardWillShowNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification* note) {
                    [wSelf.view addGestureRecognizer:singleTapGR];
                }];
    [nc addObserverForName:UIKeyboardWillHideNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification* note) {
                    [wSelf.view removeGestureRecognizer:singleTapGR];
                }];
}

- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer*)gestureRecognizer
{
    //此method会将self.view里所有的subview的first responder都resign掉
    [self.view endEditing:YES];
}

@end
