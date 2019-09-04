//
//  SVDVerifyViewController.m
//  SecVerifyDemo
//
//  Created by lujh on 2019/5/31.
//  Copyright © 2019 lujh. All rights reserved.
//

#import "SVDVerifyViewController.h"

#import "SVDSuccessViewController.h"
#import "SVDSerive.h"

#import "FLAnimatedImage.h"

#import <SecVerify/SecVerify.h>
#import <SecVerify/SVSDKHelpExt.h>
#import <SecVerify/SVSDKLoginManager.h>

#import "Masonry.h"

#import "SVProgressHUD.h"

//是否重置model 属性
static BOOL resetModel = NO;

//是否显示具体的错误码
static BOOL showRealError = NO;

//是否手动销毁登录vc
static BOOL dismissLoginVcBySelf = NO;
//半透明页面
static BOOL translucentBg = NO;
//弹窗
static BOOL resetAlertModel = NO;
//复杂登录
static BOOL resetFuModel = NO;

@interface SVDSheetPresentAnimation : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isPresent;

@end

@implementation SVDSheetPresentAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.2f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView* toView = nil;
    UIView* fromView = nil;
    UIView* transView = nil;
    
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        fromView = fromViewController.view;
        toView = toViewController.view;
    }
    
    if (_isPresent) {
        transView = toView;
        [[transitionContext containerView] addSubview:toView];
        
    }else {
        transView = fromView;
        [[transitionContext containerView] insertSubview:toView belowSubview:fromView];
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    transView.frame = CGRectMake( 0,_isPresent ?height :0, width, height);
    if(_isPresent)
    {
        transView.alpha = 0;
        [SVSDKLoginManager setLoginVcBgColor:[UIColor clearColor]];
    }
    else
    {
        [SVSDKLoginManager setLoginVcBgColor:[UIColor colorWithRed:0/225.0 green:0/225.0 blue:0/225.0 alpha:0.5]];
        
        
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        if(self->_isPresent)
        {
            transView.alpha = 1;
            [SVSDKLoginManager setLoginVcBgColor:[UIColor colorWithRed:0/225.0 green:0/225.0 blue:0/225.0 alpha:0.5]];
        }
        else
        {
            [SVSDKLoginManager setLoginVcBgColor:[UIColor clearColor]];
        }
        transView.frame = CGRectMake(0,self->_isPresent ?0 :height, width, height);
        
    } completion:^(BOOL finished) {
        transView.alpha = 0;
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
    
}

@end


@interface SVDPushPresentAnimation : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isPresent;

@end

@implementation SVDPushPresentAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.2f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView* toView = nil;
    UIView* fromView = nil;
    UIView* transView = nil;
    
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        fromView = fromViewController.view;
        toView = toViewController.view;
    }
    
    if (_isPresent) {
        transView = toView;
        [[transitionContext containerView] addSubview:toView];
        
    }else {
        transView = fromView;
        [[transitionContext containerView] insertSubview:toView belowSubview:fromView];
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    transView.frame = CGRectMake(_isPresent ?width :0, 0, width, height);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        transView.frame = CGRectMake(_isPresent ?0 :width, 0, width, height);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
    
}

@end

@interface SVDAlertPresentAnimation : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isPresent;

@end

@implementation SVDAlertPresentAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.2f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView* toView = nil;
    UIView* fromView = nil;
    UIView* transView = nil;
    
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        fromView = fromViewController.view;
        toView = toViewController.view;
    }
    
    if (_isPresent) {
        transView = toView;
        [[transitionContext containerView] addSubview:toView];
        
    }else {
        transView = fromView;
        [[transitionContext containerView] insertSubview:toView belowSubview:fromView];
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    transView.frame = CGRectMake(0, 0, width, height);
    if(_isPresent)
    {
        // 第一步：将view宽高缩至无限小（点）
        transView.transform = CGAffineTransformScale(CGAffineTransformIdentity,
                                                     CGFLOAT_MIN, CGFLOAT_MIN);
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        if(_isPresent)
        {
            // 第二步： 以动画的形式将view慢慢放大至原始大小的1.2倍
            transView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
        }
        else
        {
            // 第一步： 以动画的形式将view慢慢放大至原始大小的1.2倍
            transView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
        }
        
    } completion:^(BOOL finished) {
        
        if(_isPresent)
        {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 // 第三步： 以动画的形式将view恢复至原始大小
                                 transView.transform = CGAffineTransformIdentity;
                                 
                             } completion:^(BOOL finished) {
                                 [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                                 
                             }];
        }
        else
        {
            [SVSDKLoginManager setLoginVcBgColor:[UIColor colorWithRed:0/225.0 green:0/225.0 blue:0/225.0 alpha:0]];
            
            [UIView animateWithDuration:0.3
                             animations:^{
                                 // 第二步： 以动画的形式将view缩小至原来的1/1000分之1倍
                                 transView.transform = CGAffineTransformScale(
                                                                              CGAffineTransformIdentity, 0.001, 0.001);
                             }
                             completion:^(BOOL finished) {
                                 [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                             }];
        }
        
        
    }];
    
}

@end

//static UIView *topArrowView = nil;
////static UIView *otherView = nil;
//static UIButton *borderBtn = nil;

@interface SVDVerifyViewController () <UIViewControllerTransitioningDelegate>

@property (nonatomic) dispatch_queue_t svdQueue;
@property (nonatomic) dispatch_semaphore_t svdSemaphore;

@property (nonatomic, strong) SVDSuccessViewController *successVC;

@property (nonatomic, assign) BOOL isPreLogin;

@property (nonatomic, assign) BOOL isLogining;

@property (nonatomic, strong) UIButton *verifyBtn;

@property (nonatomic, weak) UIView *otherView;

@property (nonatomic, weak) UIView *topArrowView;

@property (nonatomic, weak) UIView *borderBtn;

@end

@implementation SVDVerifyViewController

// present动画
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    
    id<UIViewControllerAnimatedTransitioning> presentAnimation = nil;
    if(resetModel)
    {
        presentAnimation = [[SVDPushPresentAnimation alloc] init];
        [(SVDPushPresentAnimation*)presentAnimation setIsPresent:YES];
    }
    else if(resetAlertModel)
    {
        presentAnimation = [[SVDAlertPresentAnimation alloc] init];
        [(SVDAlertPresentAnimation*)presentAnimation setIsPresent:YES];
        
    }
    else if(translucentBg)
    {
        presentAnimation = [[SVDSheetPresentAnimation alloc] init];
        [(SVDSheetPresentAnimation*)presentAnimation setIsPresent:YES];
        
    }
    return presentAnimation;
    
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    id<UIViewControllerAnimatedTransitioning> presentAnimation = nil;
    if(resetModel)
    {
        presentAnimation = [[SVDPushPresentAnimation alloc] init];
        [(SVDPushPresentAnimation*)presentAnimation setIsPresent:NO];
    }
    else if(resetAlertModel)
    {
        presentAnimation = [[SVDAlertPresentAnimation alloc] init];
        [(SVDAlertPresentAnimation*)presentAnimation setIsPresent:NO];
        
    }
    return presentAnimation;
    
}


+ (BOOL)isPhoneX {
    BOOL iPhoneX = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {//判断是否是手机
        return iPhoneX;
    }
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneX = YES;
        }
    }
    return iPhoneX;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.svdQueue = dispatch_queue_create("Verify_Queue", DISPATCH_QUEUE_SERIAL);
    self.svdSemaphore = dispatch_semaphore_create(1);
    self.isPreLogin = NO;
    self.isLogining = NO;
    
    [self setupSubViews];
    
    [self preLogin:^(NSDictionary *resultDic, NSError *error) {
        
        [self enableVerifyBtn:YES];
    }];
    
    self.verifyBtn.enabled = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
}

//支持旋转
-(BOOL)shouldAutorotate{
    return NO;
}

//支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}


// 预取号
- (void)preLogin:(void (^) (NSDictionary *resultDic, NSError *error))compeletion
{
    dispatch_async(self.svdQueue, ^{
        
        dispatch_semaphore_wait(self.svdSemaphore, DISPATCH_TIME_FOREVER);
        
        if (!self.isPreLogin)
        {
            [SecVerify preLogin:^(NSDictionary * _Nullable resultDic, NSError * _Nullable error) {
                
                [self enableVerifyBtn:YES];
                
                if (!error)
                {
                    NSLog(@"预取号成功");
                    self.isPreLogin = YES;
                }
                else
                {
                    NSLog(@"预取号失败%@", error);
                }
                dispatch_semaphore_signal(self.svdSemaphore);
                
                if(compeletion)
                {
                    compeletion(resultDic,error);
                }
                
                
            }];
        }
        else
        {
            dispatch_semaphore_signal(self.svdSemaphore);
            [self enableVerifyBtn:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(compeletion)
                {
                    compeletion(nil,nil);
                }
            });
            
            
            
        }
        
    });
}


- (void)resetModelAction:(UIButton *)btn
{
    resetModel = !resetModel;
    btn.selected = !btn.selected;
}

- (void)resetRealErrorAction:(UIButton *)btn
{
    showRealError = !showRealError;
    btn.selected = !btn.selected;
}

- (void)autoDismissAction:(UIButton *)btn
{
    dismissLoginVcBySelf = !dismissLoginVcBySelf;
    btn.selected = !btn.selected;
    
}

- (void)translucentAction:(UIButton *)btn
{
    translucentBg = !translucentBg;
    btn.selected = !btn.selected;
    
}

- (void)resetAlertAction:(UIButton *)btn
{
    resetAlertModel = !resetAlertModel;
    btn.selected = !btn.selected;
    
}


- (void)resetFuAction:(UIButton *)btn
{
    resetFuModel = !resetFuModel;
    btn.selected = !btn.selected;
    
}

//test login

- (void)leftAction
{
    [SecVerify finishLoginVc:nil];
    self.isLogining = NO;
}

- (void)rightAction
{
    [SecVerify finishLoginVc:nil];
    self.isLogining = NO;
}

- (UIButton *)backBtn
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 50, 50);
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    // 让按钮内部的所有内容左对齐
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backButton addTarget:self action:@selector(leftAction) forControlEvents:UIControlEventTouchUpInside];
    backButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0); // 这里微调返回键的位置可以让它看上去和左边紧贴
    
    return backButton;
}

- (UIButton *)rightBtn
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 50, 50);
    [backButton setTitle:@"关闭" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    // 让按钮内部的所有内容左对齐
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [backButton addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
    backButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0); // 这里微调返回键的位置可以让它看上去和左边紧贴
    
    return backButton;
}


- (void)resettranslucentBgCustomModel:(SecVerifyCustomModel *)model
{
    //左侧按钮
    UIButton *backButton = [self backBtn];
    
    //右侧按钮
    UIButton *rightButton = [self rightBtn];
    
    //导航title属性文字
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"登录验证"];
    UIColor *titleColor = [UIColor colorWithRed:254/255.0 green:122/255.0 blue:78/255.0 alpha:1/1.0];
    
    NSRange range = NSMakeRange(0, 4);
    if(range.location != NSNotFound)
    {
        
        [attStr addAttributes:@{
                                NSForegroundColorAttributeName : titleColor,
                                NSFontAttributeName: [UIFont systemFontOfSize:25.0f]
                                }
                        range:NSMakeRange(2, 2)];
    }
    
    
    //*******导航条设置*******
    //  导航栏背景色
    //    model.navBarTintColor = [UIColor grayColor];
    // 导航栏标题
    model.navText = @"登录";
    // 导航返回图标
    model.navReturnImg = [UIImage imageNamed:@"close"];
    // 隐藏导航栏尾部线条
    model.navBottomLineHidden = @(YES);
    // 导航栏隐藏
    model.navBarHidden = @(YES);
    // 导航栏隐藏
    model.navStatusBarHidden = @(NO);
    // 导航栏返回按钮隐藏
    model.navTranslucent = @(NO);
    // 导航栏返回按钮隐藏
    model.navBackBtnHidden = @(YES);
    //针对电信卡执行动画
    model.animateCtccType = translucentBg ? @(SVDCtccAnimateStyleSheet) : @(NO);
    // 导航栏左边按钮
    //    model.navLeftControl = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    // 导航栏右边按钮
    model.navRightControl = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    // 导航栏属性标题
    model.navAttributesText = attStr;
    //    // 导航栏标题颜色
    //    model.navTintColor = [UIColor redColor];
    //    //  导航栏文字字体
    //    model.navTextFont = [UIFont systemFontOfSize:25];
    //  导航栏背景图片
    //model.navBackgroundImage = [self createImageWithColor:[UIColor redColor]withSize:CGSizeMake(SVD_ScreenWidth, 44)];
    //  导航栏配合背景图片设置，用来控制在不同状态下导航栏的显示(横竖屏是否显示)
    model.navBarMetrics = @(UIBarMetricsDefault);
    //  导航栏导航栏底部分割线
    model.navShadowImage = [self createImageWithColor:[UIColor greenColor] withSize:CGSizeMake(300, 2)];
    //  导航栏barStyle
    model.navBarStyle = @(UIBarStyleDefault);
    //  导航栏背景透明
    model.navBackgroundClear = @(NO);
    
    
    //*******授权页背景*******
    // 授权页背景颜色
    model.backgroundColor = [UIColor colorWithRed:0/225.0 green:0/225.0 blue:0/225.0 alpha:0.5];
    
    //    model.backgroundColor = [UIColor lightGrayColor];
    //背景图片
    //    model.bgImg = [UIImage imageNamed:@"loginbgimg.jpeg"];
    //单击实现取消操作
    model.cancelBySingleClick = @(YES);
    
    model.modalPresentationStyleOCC = @(YES);
    
    
    //*******授权页logo*******
    // Logo图片
    model.logoImg = [UIImage imageNamed:@"AppIcon"];
    // Logo是否隐藏
    model.logoHidden = @(NO);
    // Logos圆角
    model.logoCornerRadius = @(10);
    
    //*******号码设置*******
    // 手机号码字体颜色
    model.numberColor = [UIColor grayColor];
    // 字体
    model.numberFont = [UIFont boldSystemFontOfSize:16];
    // 手机号对其方式
    model.numberTextAlignment = @(NSTextAlignmentCenter);
    // 手机号码背景颜色
    //    model.numberBgColor = [UIColor redColor];
    
    //*******切换账号设置*******
    // 切换账号背景颜色
    //    model.switchBgColor = [UIColor yellowColor];
    // 切换账号字体颜色
    model.switchColor = [UIColor orangeColor];
    // 切换账号字体
    model.switchFont =  [UIFont systemFontOfSize:14];
    // 切换账号对其方式
    model.switchTextHorizontalAlignment = @(UIControlContentHorizontalAlignmentLeft);
    // 切换账号标题
    model.switchText = @"切换账号";
    // 隐藏切换账号按钮
    model.switchHidden = @(YES);
    
    
    //*******复选框*******
    // 复选框选中时的图片
    model.checkedImg = [UIImage imageNamed:@"checked"];
    // 复选框未选中时的图片
    model.uncheckedImg = [UIImage imageNamed:@"unchecked"];
    // 隐私条款check框默认状态
    model.checkDefaultState = @(YES);
    // 复选框尺寸
    model.checkSize = [NSValue valueWithCGSize:CGSizeMake(20, 20)];
    // 隐私条款check框是否隐藏
    model.checkHidden = @(NO);
    
    //*******隐私条款设置*******
    // 隐私条款基本文字颜色
    model.privacyTextColor = [UIColor greenColor];
    // 隐私条款协议文字字体
    model.privacyTextFont =  [UIFont systemFontOfSize:12];
    // 隐私条款对其方式
    model.privacyTextAlignment = @(NSTextAlignmentCenter);
    // 隐私条款协议文字颜色
    model.privacyAgreementColor = [UIColor redColor];
    // 隐私条款协议背景颜色
    //    model.privacyAgreementBgColor = [UIColor yellowColor];
    // 隐私条款应用名称
    model.privacyAppName = @"秒验";
    // 协议文本前后符号@[@"《",@"》"]
    //    model.privacyProtocolMarkArr = @[@"《",@"》"];
    // 隐私条款多行时行距
    model.privacyLineSpacing = @(4.0);
    // 隐私条款WEB页面标题
    model.privacyWebTitle = attStr;
    // 隐私条款WEB页面返回按钮图片
//    model.privacyWebBackBtnImage = [self createImageWithColor:[UIColor redColor]withSize:CGSizeMake(40, 40)];
    
    
    //*******登陆按钮设置*******
    // 登录按钮文本
    model.loginBtnText = @"登录";
    // 登录按钮文本颜色
    //    model.loginBtnTextColor = [UIColor greenColor];
    // 登录按钮背景颜色
    //    model.loginBtnBgColor = [UIColor blueColor];
    // 登录按钮边框宽度
    //    model.loginBtnBorderWidth = @(1);
    // 登录按钮边框颜色
    //    model.loginBtnBorderColor = [UIColor cyanColor];
    // 登录按钮圆角
    model.loginBtnCornerRadius = @(5);
    // 登录按钮文字字体
    model.loginBtnTextFont = [UIFont boldSystemFontOfSize:14];
    // 登录按钮背景图片
    model.loginBtnBgImgArr = @[
                               [self createImageWithColor:[UIColor blueColor] withSize:CGSizeMake(SVD_ScreenWidth - 40, 40)],
                               [self createImageWithColor:[UIColor grayColor] withSize:CGSizeMake(SVD_ScreenWidth - 40, 40)],
                               [self createImageWithColor:[UIColor redColor] withSize:CGSizeMake(SVD_ScreenWidth - 40, 40)]
                               ];
    
    //*******运营商品牌标签*******
    //运营商品牌文字字体
    model.sloganTextFont = [UIFont systemFontOfSize:10];
    //运营商品牌文字颜色
    model.sloganTextColor = [UIColor grayColor];
    //运营商品牌文字对齐方式
    model.sloganTextAlignment = @(NSTextAlignmentCenter);
    //运营商品牌背景颜色
    //    model.sloganBgColor = [UIColor redColor];
    
    
    //*******loading 视图*******
    // loading 是否显示
    model.hiddenLoading = @(NO);
    //    //Loading 背景色
    //    model.loadingBackgroundColor = [UIColor blackColor];
    //    //Loading Indicator渲染色
    //    model.loadingTintColor = [UIColor whiteColor];
    //    //Loading 圆角
    //    model.loadingCornerRadius = @(10);
    //    //style (例:@(UIActivityIndicatorViewStyleWhiteLarge))
    //    model.loadingIndicatorStyle = @(UIActivityIndicatorViewStyleGray);
    //    //Loading 大小
    //    model.loadingSize = [NSValue valueWithCGSize:CGSizeMake(100, 100)];
    
    //自定义loading视图
    [model setLoadingView:^(UIView *contentView) {
        
        [SVProgressHUD setContainerView:contentView];
        [SVProgressHUD showWithStatus:@"数据加载中..."];
        
    }];
    
    //自定义视图
    [model setCustomViewBlock:^(UIView *customView) {
        
        UIView *bottomView = [[UIView alloc] init];
        bottomView.backgroundColor = [UIColor whiteColor];
        {
            [customView addSubview:bottomView];
            
            [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(0);
                make.centerX.mas_equalTo(customView);
                make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
                make.height.mas_equalTo(372 + SVD_TabbarSafeBottomMargin);
            }];
            
            UIButton *button = [[UIButton alloc] init];
            [button setImage:[UIImage imageNamed:@"success"] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
            [button addTarget:self action:@selector(weixinLoginAction) forControlEvents:UIControlEventTouchUpInside];
            [bottomView addSubview:button];
            
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-330);
                make.right.mas_equalTo(-20);
                make.width.height.mas_equalTo(30);
            }];
            
        }
        
        [customView bringSubviewToFront:bottomView];
        
        
    }];
    
    
    //logo 距离上边距离
    float topHeight = 412 - 60;
    
    //登录页面协议size
    CGSize size = [SVSDKHelpExt loginProtocolSize:model maxWidth:(SVD_ScreenWidth - 65)];
    
    
    //布局
    SecVerifyCustomLayouts *layouts = [[SecVerifyCustomLayouts alloc] init];
    
    //logo
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutBottom = @(-topHeight+80 - SVD_TabbarSafeBottomMargin);
        layout.layoutCenterX = @(0);
        layout.layoutWidth = @(40);
        layout.layoutHeight = @(40);
        
        layouts.logoLayout = layout;
    }
    
    //phone
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutBottom = @(-topHeight + 60 + 50 - SVD_TabbarSafeBottomMargin);
        layout.layoutRight = @(-20);
        layout.layoutLeft = @(20);
        layout.layoutHeight = @(20);
        
        layouts.phoneLayout = layout;
    }
    
    
    //登录按钮
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutBottom = @(-topHeight + 160 - SVD_TabbarSafeBottomMargin);
        layout.layoutRight = @(-30);
        layout.layoutLeft = @(30);
        layout.layoutHeight = @(30);
        
        layouts.loginLayout = layout;
    }
    
    
    //check(相对隐私协议)复选框
    {
        SecVerifyCheckPrivacyLayout *layout = [[SecVerifyCheckPrivacyLayout alloc] init];
        layout.layoutCenterY = @(0);
        layout.layoutRight = @(-5);
        layout.layoutWidth = @(20);
        layout.layoutHeight = @(20);
        
        layouts.checkPrivacyLayout = layout;
    }
    
    //隐私条款
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutRight = @(-20);
        layout.layoutBottom = @(-topHeight + 240 - SVD_TabbarSafeBottomMargin);
        layout.layoutLeft = @(50);
        layout.layoutHeight = @(size.height);
        
        layouts.privacyLayout = layout;
    }
    
    
    //运营商品牌
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutRight = @(-20);
        layout.layoutBottom = @(- 10 - SVD_TabbarSafeBottomMargin);
        layout.layoutLeft = @(20);
        layout.layoutHeight = @(20);
        
        layouts.sloganLayout = layout;
    }
    
    model.layouts = layouts;
    
}

- (void)resetCustomModel:(SecVerifyCustomModel *)model
{
    //左侧按钮
    UIButton *backButton = [self backBtn];
    
    //右侧按钮
    UIButton *rightButton = [self rightBtn];
    
    //导航title属性文字
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"登录验证"];
    UIColor *titleColor = [UIColor colorWithRed:254/255.0 green:122/255.0 blue:78/255.0 alpha:1/1.0];
    
    NSRange range = NSMakeRange(0, 4);
    if(range.location != NSNotFound)
    {
        
        [attStr addAttributes:@{
                                NSForegroundColorAttributeName : titleColor,
                                NSFontAttributeName: [UIFont systemFontOfSize:25.0f]
                                }
                        range:NSMakeRange(2, 2)];
    }
    
    
    //*******导航条设置*******
    //  导航栏背景色
    //    model.navBarTintColor = [UIColor grayColor];
    // 导航栏标题
    model.navText = @"登录";
    // 导航返回图标
    model.navReturnImg = [UIImage imageNamed:@"close"];
    // 隐藏导航栏尾部线条
    model.navBottomLineHidden = @(YES);
    // 导航栏隐藏
    model.navBarHidden = @(NO);
    // 导航栏隐藏
    model.navStatusBarHidden = @(NO);
    // 导航栏返回按钮隐藏
    model.navTranslucent = @(NO);
    // 导航栏返回按钮隐藏
    model.navBackBtnHidden = @(YES);
     model.animateCtccType = resetModel ? @(SVDCtccAnimateStylePush) : @(NO);
    // 导航栏左边按钮
    model.navLeftControl = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    // 导航栏右边按钮
    model.navRightControl = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    // 导航栏属性标题
    model.navAttributesText = attStr;
    //    // 导航栏标题颜色
    //    model.navTintColor = [UIColor redColor];
    //    //  导航栏文字字体
    //    model.navTextFont = [UIFont systemFontOfSize:25];
    //  导航栏背景图片
    //model.navBackgroundImage = [self createImageWithColor:[UIColor redColor]withSize:CGSizeMake(SVD_ScreenWidth, 44)];
    //  导航栏配合背景图片设置，用来控制在不同状态下导航栏的显示(横竖屏是否显示)
    model.navBarMetrics = @(UIBarMetricsDefault);
    //  导航栏导航栏底部分割线
    model.navShadowImage = [self createImageWithColor:[UIColor greenColor] withSize:CGSizeMake(300, 2)];
    //  导航栏barStyle
    model.navBarStyle = @(UIBarStyleDefault);
    //  导航栏背景透明
    model.navBackgroundClear = @(NO);
    
    //*******授权页背景*******
    // 授权页背景颜色
    model.backgroundColor = [UIColor lightGrayColor];
    //背景图片
    model.bgImg = [UIImage imageNamed:@"loginbgimg.jpeg"];
    //自定义动画效果
    model.presentAnimationDelegate = self;
    
    
    //*******授权页logo*******
    // Logo图片
    model.logoImg = [UIImage imageNamed:@"AppIcon"];
    // Logo是否隐藏
    model.logoHidden = @(NO);
    // Logos圆角
    model.logoCornerRadius = @(10);
    
    //*******号码设置*******
    // 手机号码字体颜色
    model.numberColor = [UIColor grayColor];
    // 字体
    model.numberFont = [UIFont boldSystemFontOfSize:16];
    // 手机号对其方式
    model.numberTextAlignment = @(NSTextAlignmentLeft);
    // 手机号码背景颜色
    //    model.numberBgColor = [UIColor redColor];
    
    //*******切换账号设置*******
    // 切换账号背景颜色
    //    model.switchBgColor = [UIColor yellowColor];
    // 切换账号字体颜色
    model.switchColor = [UIColor orangeColor];
    // 切换账号字体
    model.switchFont =  [UIFont systemFontOfSize:14];
    // 切换账号对其方式
    model.switchTextHorizontalAlignment = @(UIControlContentHorizontalAlignmentLeft);
    // 切换账号标题
    model.switchText = @"切换账号";
    // 隐藏切换账号按钮
    model.switchHidden = @(NO);
    
    
    //*******复选框*******
    // 复选框选中时的图片
    model.checkedImg = [UIImage imageNamed:@"checked"];
    // 复选框未选中时的图片
    model.uncheckedImg = [UIImage imageNamed:@"unchecked"];
    // 隐私条款check框默认状态
    model.checkDefaultState = @(YES);
    // 复选框尺寸
    model.checkSize = [NSValue valueWithCGSize:CGSizeMake(20, 20)];
    // 隐私条款check框是否隐藏
    model.checkHidden = @(NO);
    
    //*******隐私条款设置*******
    // 隐私条款基本文字颜色
    model.privacyTextColor = [UIColor greenColor];
    // 隐私条款协议文字字体
    model.privacyTextFont =  [UIFont systemFontOfSize:12];
    // 隐私条款对其方式
    model.privacyTextAlignment = @(NSTextAlignmentLeft);
    // 隐私条款协议文字颜色
    model.privacyAgreementColor = [UIColor redColor];
    // 隐私条款协议背景颜色
    //    model.privacyAgreementBgColor = [UIColor yellowColor];
    // 隐私条款应用名称
    model.privacyAppName = @"秒验";
    // 协议文本前后符号@[@"《",@"》"]
    model.privacyProtocolMarkArr = @[@"《",@"》"];
    // 开发者隐私条款协议名称（第一组协议）
    model.privacyFirstTextArr = @[@"服务协议",@"https://www.mob.com",@"、"];
    // 开发者隐私条款协议名称（第二组协议）
    model.privacySecondTextArr =  @[@"百度协议",@"https://www.baidu.com",@"、"];
    // 隐私条款多行时行距
    model.privacyLineSpacing = @(4.0);
    // 隐私条款WEB页面标题
    model.privacyWebTitle = attStr;
    // 隐私条款WEB页面返回按钮图片
//    model.privacyWebBackBtnImage = [self createImageWithColor:[UIColor redColor]withSize:CGSizeMake(30, 30)];
    
    //*******登陆按钮设置*******
    // 登录按钮文本
    model.loginBtnText = @"登录";
    // 登录按钮文本颜色
    //    model.loginBtnTextColor = [UIColor greenColor];
    // 登录按钮背景颜色
    //    model.loginBtnBgColor = [UIColor blueColor];
    // 登录按钮边框宽度
    //    model.loginBtnBorderWidth = @(1);
    // 登录按钮边框颜色
    //    model.loginBtnBorderColor = [UIColor cyanColor];
    // 登录按钮圆角
    model.loginBtnCornerRadius = @(5);
    // 登录按钮文字字体
    model.loginBtnTextFont = [UIFont boldSystemFontOfSize:20];
    // 登录按钮背景图片
    model.loginBtnBgImgArr = @[
                               [self createImageWithColor:[UIColor blueColor] withSize:CGSizeMake(SVD_ScreenWidth - 40, 40)],
                               [self createImageWithColor:[UIColor grayColor] withSize:CGSizeMake(SVD_ScreenWidth - 40, 40)],
                               [self createImageWithColor:[UIColor redColor] withSize:CGSizeMake(SVD_ScreenWidth - 40, 40)]
                               ];
    
    //*******运营商品牌标签*******
    //运营商品牌文字字体
    model.sloganTextFont = [UIFont systemFontOfSize:10];
    //运营商品牌文字颜色
    model.sloganTextColor = [UIColor grayColor];
    //运营商品牌文字对齐方式
    model.sloganTextAlignment = @(NSTextAlignmentRight);
    //运营商品牌背景颜色
    //    model.sloganBgColor = [UIColor redColor];
    
    //*******loading 视图*******
    // loading 是否显示
    model.hiddenLoading = @(NO);
    //    //Loading 背景色
    //    model.loadingBackgroundColor = [UIColor blackColor];
    //    //Loading Indicator渲染色
    //    model.loadingTintColor = [UIColor whiteColor];
    //    //Loading 圆角
    //    model.loadingCornerRadius = @(10);
    //    //style (例:@(UIActivityIndicatorViewStyleWhiteLarge))
    //    model.loadingIndicatorStyle = @(UIActivityIndicatorViewStyleGray);
    //    //Loading 大小
    //    model.loadingSize = [NSValue valueWithCGSize:CGSizeMake(100, 100)];
    
    //自定义loading视图
    [model setLoadingView:^(UIView *contentView) {
        
        [SVProgressHUD setContainerView:contentView];
        [SVProgressHUD showWithStatus:@"数据加载中..."];
        
    }];
    
    //自定义视图
    [model setCustomViewBlock:^(UIView *customView) {
        
        float height = [SVDVerifyViewController isPhoneX]?(160+36.0):160;
        
        UIView *bottomView = [[UIView alloc] init];
        {
            [customView addSubview:bottomView];
            
            [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(0);
                make.centerX.mas_equalTo(customView);
                make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
                make.height.mas_equalTo(height);
            }];
            
            
            UILabel *mLbl = [[UILabel alloc] init];
            mLbl.textAlignment = NSTextAlignmentCenter;
            mLbl.font = [UIFont systemFontOfSize:12.0f];
            mLbl.textColor = [UIColor lightGrayColor];
            mLbl.backgroundColor = [UIColor clearColor];
            mLbl.text = @"-- 您可以使用以下方式登录 --";
            [bottomView addSubview:mLbl];
            
            [mLbl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(10);
                make.centerX.mas_equalTo(bottomView);
                make.width.mas_equalTo(200);
                make.height.mas_equalTo(20);
            }];
            
            
            UIButton *button = [[UIButton alloc] init];
            [button setImage:[UIImage imageNamed:@"weixin"] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
            [button addTarget:self action:@selector(weixinLoginAction) forControlEvents:UIControlEventTouchUpInside];
            [bottomView addSubview:button];
            
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(40);
                make.centerX.mas_equalTo(bottomView);
                make.width.height.mas_equalTo(50);
            }];
            
        }
        
        [customView bringSubviewToFront:bottomView];
        
        
    }];
    
    
    //logo 距离上边距离
    float topHeight = 50.0/603.0 *(SVD_ScreenHeight - SVD_StatusBarSafeBottomMargin - 44 - SVD_TabbarSafeBottomMargin);
    
    //登录页面协议size
    CGSize size = [SVSDKHelpExt loginProtocolSize:model maxWidth:(SVD_ScreenWidth - 65)];
    
    
    //布局
    SecVerifyCustomLayouts *layouts = [[SecVerifyCustomLayouts alloc] init];
    
    //logo
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(topHeight);
        layout.layoutLeft = @(20);
        layout.layoutWidth = @(80);
        layout.layoutHeight = @(80);
        
        layouts.logoLayout = layout;
    }
    
    //phone
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(topHeight + 20);
        layout.layoutRight = @(-20);
        layout.layoutLeft = @(150);
        layout.layoutHeight = @(20);
        
        layouts.phoneLayout = layout;
    }
    
    //其他方式登录
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(topHeight + 50);
        layout.layoutRight = @(-20);
        layout.layoutLeft = @(150);
        layout.layoutHeight = @(20);
        
        layouts.switchLayout = layout;
    }
    
    //登录按钮
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(topHeight + 100);
        layout.layoutRight = @(-20);
        layout.layoutLeft = @(20);
        layout.layoutHeight = @(40);
        
        layouts.loginLayout = layout;
    }
    
    
    //check(相对隐私协议)复选框
    {
        SecVerifyCheckPrivacyLayout *layout = [[SecVerifyCheckPrivacyLayout alloc] init];
        layout.layoutCenterY = @(0);
        layout.layoutRight = @(-5);
        layout.layoutWidth = @(20);
        layout.layoutHeight = @(20);
        
        layouts.checkPrivacyLayout = layout;
    }
    
    //隐私条款
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutRight = @(-20);
        layout.layoutTop = @(topHeight + 150);
        layout.layoutLeft = @(50);
        layout.layoutHeight = @(size.height);
        
        layouts.privacyLayout = layout;
    }
    
    
    //运营商品牌
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutRight = @(-5);
        layout.layoutBottom = @(- 10 - SVD_TabbarSafeBottomMargin);
        layout.layoutWidth = @(250);
        layout.layoutHeight = @(20);
        
        layouts.sloganLayout = layout;
    }
    
    model.layouts = layouts;
    
  
    
}


- (void)resetAlertCustomModel:(SecVerifyCustomModel *)model
{
    
    
    //*******导航条设置*******
    //  导航栏背景色
    //    model.navBarTintColor = [UIColor grayColor];
    // 导航栏标题
    
    // 导航栏隐藏
    model.navBarHidden = @(YES);
    // 导航栏隐藏
    model.navStatusBarHidden = @(NO);
    
    
    //*******授权页背景*******
    // 授权页背景颜色
    model.backgroundColor = [UIColor colorWithRed:0/225.0 green:0/225.0 blue:0/225.0 alpha:0.5];
    
    //    model.backgroundColor = [UIColor lightGrayColor];
    //背景图片
    //    model.bgImg = [UIImage imageNamed:@"loginbgimg.jpeg"];
    //单击实现取消操作
    model.cancelBySingleClick = @(YES);
    
    model.modalPresentationStyleOCC = @(YES);
    
    model.presentAnimationDelegate = self;
    
    //*******授权页logo*******
    // Logo图片
    model.logoImg = [UIImage imageNamed:@"AppIcon"];
    // Logo是否隐藏
    model.logoHidden = @(NO);
    // Logos圆角
    model.logoCornerRadius = @(10);
    
    //*******号码设置*******
    // 手机号码字体颜色
    model.numberColor = [UIColor grayColor];
    // 字体
    model.numberFont = [UIFont boldSystemFontOfSize:16];
    // 手机号对其方式
    model.numberTextAlignment = @(NSTextAlignmentCenter);
    // 手机号码背景颜色
    //    model.numberBgColor = [UIColor redColor];
    
    //*******切换账号设置*******
    // 切换账号背景颜色
    //    model.switchBgColor = [UIColor yellowColor];
    // 切换账号字体颜色
    model.switchColor = [UIColor orangeColor];
    // 切换账号字体
    model.switchFont =  [UIFont systemFontOfSize:14];
    // 切换账号对其方式
    model.switchTextHorizontalAlignment = @(UIControlContentHorizontalAlignmentLeft);
    // 切换账号标题
    model.switchText = @"切换账号";
    // 隐藏切换账号按钮
    model.switchHidden = @(YES);
    model.animateCtccType = resetAlertModel ? @(SVDCtccAnimateStyleAlert) : @(NO);
    
    //*******复选框*******
    // 复选框选中时的图片
    model.checkedImg = [UIImage imageNamed:@"checked"];
    // 复选框未选中时的图片
    model.uncheckedImg = [UIImage imageNamed:@"unchecked"];
    // 隐私条款check框默认状态
    model.checkDefaultState = @(YES);
    // 复选框尺寸
    model.checkSize = [NSValue valueWithCGSize:CGSizeMake(20, 20)];
    // 隐私条款check框是否隐藏
    model.checkHidden = @(NO);
    
    //*******隐私条款设置*******
    // 隐私条款基本文字颜色
    model.privacyTextColor = [UIColor greenColor];
    // 隐私条款协议文字字体
    model.privacyTextFont =  [UIFont systemFontOfSize:12];
    // 隐私条款对其方式
    model.privacyTextAlignment = @(NSTextAlignmentCenter);
    // 隐私条款协议文字颜色
    model.privacyAgreementColor = [UIColor redColor];
    // 隐私条款协议背景颜色
    //    model.privacyAgreementBgColor = [UIColor yellowColor];
    // 隐私条款应用名称
    model.privacyAppName = @"秒验";
    // 协议文本前后符号@[@"《",@"》"]
    //    model.privacyProtocolMarkArr = @[@"《",@"》"];
    // 隐私条款多行时行距
    model.privacyLineSpacing = @(4.0);
    // 隐私条款WEB页面返回按钮图片
//    model.privacyWebBackBtnImage = [self createImageWithColor:[UIColor redColor]withSize:CGSizeMake(40, 40)];
    
    
    //*******登陆按钮设置*******
    // 登录按钮文本
    model.loginBtnText = @"登录";
    // 登录按钮文本颜色
    //    model.loginBtnTextColor = [UIColor greenColor];
    // 登录按钮背景颜色
    //    model.loginBtnBgColor = [UIColor blueColor];
    // 登录按钮边框宽度
    //    model.loginBtnBorderWidth = @(1);
    // 登录按钮边框颜色
    //    model.loginBtnBorderColor = [UIColor cyanColor];
    // 登录按钮圆角
    model.loginBtnCornerRadius = @(5);
    // 登录按钮文字字体
    model.loginBtnTextFont = [UIFont boldSystemFontOfSize:14];
    // 登录按钮背景图片
    model.loginBtnBgImgArr = @[
                               [self createImageWithColor:[UIColor blueColor] withSize:CGSizeMake(SVD_ScreenWidth - 40, 40)],
                               [self createImageWithColor:[UIColor grayColor] withSize:CGSizeMake(SVD_ScreenWidth - 40, 40)],
                               [self createImageWithColor:[UIColor redColor] withSize:CGSizeMake(SVD_ScreenWidth - 40, 40)]
                               ];
    
    //*******运营商品牌标签*******
    //运营商品牌文字字体
    model.sloganTextFont = [UIFont systemFontOfSize:10];
    //运营商品牌文字颜色
    model.sloganTextColor = [UIColor grayColor];
    //运营商品牌文字对齐方式
    model.sloganTextAlignment = @(NSTextAlignmentCenter);
    //运营商品牌背景颜色
    //    model.sloganBgColor = [UIColor redColor];
    
    
    //*******loading 视图*******
    // loading 是否显示
    model.hiddenLoading = @(NO);
    //Loading 背景色
    model.loadingBackgroundColor = [UIColor blackColor];
    //Loading Indicator渲染色
    model.loadingTintColor = [UIColor whiteColor];
    //Loading 圆角
    model.loadingCornerRadius = @(10);
    //style (例:@(UIActivityIndicatorViewStyleWhiteLarge))
    model.loadingIndicatorStyle = @(UIActivityIndicatorViewStyleGray);
    //Loading 大小
    model.loadingSize = [NSValue valueWithCGSize:CGSizeMake(100, 100)];
    
    //自定义loading视图
    //    [model setLoadingView:^(UIView *contentView) {
    //
    //        [SVProgressHUD setContainerView:contentView];
    //        [SVProgressHUD showWithStatus:@"数据加载中..."];
    //
    //    }];
    
    //自定义视图
    [model setCustomViewBlock:^(UIView *customView) {
        
        UIView *bottomView = [[UIView alloc] init];
        bottomView.backgroundColor = [UIColor whiteColor];
        {
            [customView addSubview:bottomView];
            
            [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(customView);
                make.centerY.mas_equalTo(customView);
                make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width*0.8);
                make.height.mas_equalTo(372);
            }];
            
            UIButton *button = [[UIButton alloc] init];
            [button setImage:[UIImage imageNamed:@"success"] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
            [button addTarget:self action:@selector(weixinLoginAction) forControlEvents:UIControlEventTouchUpInside];
            [bottomView addSubview:button];
            
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(10);
                make.right.mas_equalTo(-10);
                make.width.height.mas_equalTo(30);
            }];
            
        }
        
        [customView bringSubviewToFront:bottomView];
        
        
    }];
    
    
    //logo 距离上边距离
    float topHeight = (SVD_ScreenHeight-372)/2.0+ 372;
    
    //登录页面协议size
    CGSize size = [SVSDKHelpExt loginProtocolSize:model maxWidth:(SVD_ScreenWidth - 65)];
    
    
    //布局
    SecVerifyCustomLayouts *layouts = [[SecVerifyCustomLayouts alloc] init];
    
    //logo
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutBottom = @(-topHeight+80);
        layout.layoutCenterX = @(0);
        layout.layoutWidth = @(40);
        layout.layoutHeight = @(40);
        
        layouts.logoLayout = layout;
    }
    
    //phone
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutBottom = @(-topHeight + 60 + 50 );
        layout.layoutRight = @(-20);
        layout.layoutLeft = @(20);
        layout.layoutHeight = @(20);
        
        layouts.phoneLayout = layout;
    }
    
    
    //登录按钮
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutBottom = @(-topHeight + 160 );
        layout.layoutRight = @(-30-SVD_ScreenWidth*0.1);
        layout.layoutLeft = @(30+SVD_ScreenWidth*0.1);
        layout.layoutHeight = @(25);
        
        layouts.loginLayout = layout;
    }
    
    
    //check(相对隐私协议)复选框
    {
        SecVerifyCheckPrivacyLayout *layout = [[SecVerifyCheckPrivacyLayout alloc] init];
        layout.layoutCenterY = @(0);
        layout.layoutRight = @(-5);
        layout.layoutWidth = @(20);
        layout.layoutHeight = @(20);
        
        layouts.checkPrivacyLayout = layout;
    }
    
    //隐私条款
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutRight = @(-20-SVD_ScreenWidth*0.1);
        layout.layoutBottom = @(-topHeight + 240 );
        layout.layoutLeft = @(50+SVD_ScreenWidth*0.1);
        layout.layoutHeight = @(size.height);
        
        layouts.privacyLayout = layout;
    }
    
    
    //运营商品牌
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutRight = @(-20);
        layout.layoutBottom = @(- 10 - (SVD_ScreenHeight - 371)/2.0);
        layout.layoutLeft = @(20);
        layout.layoutHeight = @(20);
        
        layouts.sloganLayout = layout;
    }
    
    model.layouts = layouts;
    
}

// 登录
- (void)login
{
    WeakSelf
    [self enableVerifyBtn:NO];
    
    [self preLogin:^(NSDictionary *resultDic, NSError *error) {
        
        if(!error)
        {
            weakSelf.isLogining = YES;

            SecVerifyCustomModel *model = [[SecVerifyCustomModel alloc] init];
            
            //当前VC,用于呈现登录视图
            model.currentViewController = weakSelf;
            //外部手动管理关闭界面
            model.manualDismiss = @(dismissLoginVcBySelf);
            
            //半透明设置
            /*
             {
             model.bgImg = [UIImage imageNamed:@"loginbgimg.jpeg"];
             model.navBackgroundImage = [UIImage new];
             model.navShadowImage = [UIImage new];
             model.navTranslucent = @(YES);
             }
             */
            
            
            
            //重置ui
            if(translucentBg)
            {
                [weakSelf resettranslucentBgCustomModel:model];
            }
            else if(resetModel)
            {
                [weakSelf resetCustomModel:model];
                
            }
            else if(resetAlertModel)
            {
                [weakSelf resetAlertCustomModel:model];
                
            }
            else if(resetFuModel)
            {
                [weakSelf resetFuModel:model];
            }
            
            
            [SecVerify loginWithModel:model showLoginVc:^{
                
            } loginBtnClicked:^{
                
            } willHiddenLoading:^{
                
                //自定义loading,隐藏
                [SVProgressHUD dismiss];
                
            } completion:^(NSDictionary * _Nullable resultDic, NSError * _Nullable error) {
                
                weakSelf.isPreLogin = NO;
                weakSelf.isLogining = NO;
                
                if (!error)
                {
                    [SVProgressHUD showWithStatus:@"加载中..."];
                    
                    [[SVDSerive sharedSerive] phoneLogin:resultDic completion:^(NSError *error, NSString * _Nonnull phone) {
                        
                        
                        //手动关闭界面的时候使用
                        if(dismissLoginVcBySelf)
                        {
                            [SecVerify finishLoginVc:^{
                                
                            }];
                        }
                        
                        if (!error)
                        {
                            
                            weakSelf.successVC = [[SVDSuccessViewController alloc] init];
                            weakSelf.successVC.phone = phone;
                            if(![weakSelf.navigationController.viewControllers containsObject:self.successVC])
                            {
                                [weakSelf.navigationController pushViewController:self.successVC animated:YES];
                            }
                        }
                        else
                        {
                            NSLog(@"服务器验证失败");
                            if(showRealError)
                            {
                                
                                
                                [weakSelf showAlert:error.userInfo[@"description"] message:[NSString stringWithFormat:@"%ld", (long)error.code]];
                            }
                            else
                            {
                                NSString *des = error.userInfo[@"description"];
                                NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                                NSString *retStr = [[NSString alloc] initWithData:[des dataUsingEncoding:enc] encoding:enc];
                                
                                if(error.code == 170601)
                                {
                                    [weakSelf showAlert:retStr message:nil];
                                }
                                else
                                {
                                    [weakSelf showAlert:@"当前网络状态不稳定" message:nil];
                                }
                            }
                        }
                        [weakSelf preLogin:nil];
                        
                        [SVProgressHUD dismiss];
                        
                    }];
                }
                else
                {
                    //手动关闭界面的时候使用
                    //170602 自定义事件，手动关闭登录vc
                    //170204 取消登录
                    if(dismissLoginVcBySelf && error.code != 170602 && error.code != 170204)
                    {
                        [SecVerify finishLoginVc:^{
                            
                        }];
                    }
                    
                    NSLog(@"登录失败:%@", error);
                    if(showRealError)
                    {
                        [weakSelf showAlert:error.userInfo.description message:error.userInfo[@"description"]];
                    }
                    else
                    {
                        [weakSelf showAlert:@"提示" message:error.userInfo[@"error_message"] ?: error.userInfo[@"description"]];
                    }
                    [weakSelf preLogin:nil];
                }
                
                
            }];
            
        }
        else
        {
            NSString *title = @"当前网络状态不稳定";
            if (error.code == 170005)
            {
                title = @"当前手机无SIM卡，请插入后重试";
            }
            if (error.code == 170003)
            {
                title = @"不支持的运营商";
            }
            
            if(error.code == 170601)
            {
                title = @"请打开蜂窝网络";
            }
            if(error.code == 170606)
            {
                title = @"获取授权码数量超限";
            }
            if(showRealError)
            {
                [weakSelf showAlert:error.userInfo[@"error_message"] message:[NSString stringWithFormat:@"%ld", (long)error.code]];
            }
            else
            {
                [weakSelf showAlert:title message:nil];
            }
            
            [weakSelf enableVerifyBtn:YES];
        }
    }];
    
    
   
}

- (void)phoneAction
{
    [self.topArrowView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(20);
        make.centerX.mas_equalTo(-SVD_ScreenWidth/4.0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    
    self.otherView.hidden= YES;
    self.borderBtn.hidden = NO;
    [SVSDKLoginManager setHideLogin:SVSDKLoginItemTypeLogin |SVSDKLoginItemTypeOtherLogin | SVSDKLoginItemTypePhone | SVSDKLoginItemTypeSlogan | SVSDKLoginItemTypePrivacy | SVSDKLoginItemTypeCheck
                               hide:NO];
}

- (void)otherAction
{
    [self.topArrowView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(20);
        make.centerX.mas_equalTo(SVD_ScreenWidth/4.0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    
    self.otherView.hidden= NO;
    self.borderBtn.hidden = YES;
    [SVSDKLoginManager setHideLogin: SVSDKLoginItemTypeLogin|SVSDKLoginItemTypeOtherLogin | SVSDKLoginItemTypePhone | SVSDKLoginItemTypeSlogan | SVSDKLoginItemTypePrivacy | SVSDKLoginItemTypeCheck hide:YES];
}

- (void)resetFuModel:(SecVerifyCustomModel *)model
{
    
    //*******导航条设置*******
    // 隐藏导航栏尾部线条
    model.navBottomLineHidden = @(YES);
    // 导航栏隐藏
    model.navBarHidden = @(YES);
    // 导航栏隐藏
    model.navStatusBarHidden = @(NO);
    
    
    //*******授权页背景*******
    //自定义动画效果
    model.presentAnimationDelegate = self;
    
    
    //*******授权页logo*******
    // Logo是否隐藏
    model.logoHidden = @(YES);
    
    //*******号码设置*******
    // 手机号码字体颜色
    model.numberColor = [UIColor lightGrayColor];
    // 字体
    model.numberFont = [UIFont boldSystemFontOfSize:14];
    // 手机号对其方式
    model.numberTextAlignment = @(NSTextAlignmentLeft);
    
    
    //*******切换账号设置*******
    
    // 切换账号字体颜色
    model.switchColor = [UIColor redColor];
    // 切换账号字体
    model.switchFont =  [UIFont systemFontOfSize:14];
    // 切换账号对其方式
    model.switchTextHorizontalAlignment = @(UIControlContentHorizontalAlignmentLeft);
    // 切换账号标题
    model.switchText = @"更换号码登录";
    // 隐藏切换账号按钮
    model.switchHidden = @(NO);
    
    
    //*******复选框*******
    // 隐私条款check框默认状态
    model.checkDefaultState = @(YES);
    // 隐私条款check框是否隐藏
    model.checkHidden = @(NO);
    
    //*******隐私条款设置*******
    model.privacyHidden = @(NO);
//    model.privacyNormalTextFirst = @"同意";
//    model.privacyNormalTextSecond = @"允许";
//    model.privacyNormalTextThird = @"获取本机号码";
    model.privacyAppName = @"秒验";
    //*******登陆按钮设置*******
    // 登录按钮文本
    model.loginBtnText = @"本机号码一键登录";
    // 登录按钮文本颜色
    //    model.loginBtnTextColor = [UIColor greenColor];
    // 登录按钮背景颜色
    //    model.loginBtnBgColor = [UIColor blueColor];
    // 登录按钮边框宽度
    //    model.loginBtnBorderWidth = @(1);
    // 登录按钮边框颜色
    //    model.loginBtnBorderColor = [UIColor cyanColor];
    // 登录按钮圆角
    model.loginBtnCornerRadius = @(20);
    // 登录按钮文字字体
    model.loginBtnTextFont = [UIFont boldSystemFontOfSize:20];
    // 登录按钮背景图片
    model.loginBtnBgImgArr = @[
                               [self createImageWithColor:[UIColor colorWithRed:157/255.0 green:156/255.0 blue:213 /255.0 alpha:1] withSize:CGSizeMake(SVD_ScreenWidth - 40, 40)],
                               [self createImageWithColor:[UIColor colorWithRed:157/255.0 green:156/255.0 blue:213/255.0 alpha:1] withSize:CGSizeMake(SVD_ScreenWidth - 40, 40)],
                               [self createImageWithColor:[UIColor colorWithRed:157/255.0 green:156/255.0 blue:213/255.0 alpha:1] withSize:CGSizeMake(SVD_ScreenWidth - 40, 40)]
                               ];
    
    //*******运营商品牌标签*******
    //运营商品牌文字字体
//    model.sloganTextFont = [UIFont systemFontOfSize:10];
//    //运营商品牌文字颜色
//    model.sloganTextColor = [UIColor grayColor];
//    //运营商品牌文字对齐方式
//    model.sloganTextAlignment = @(NSTextAlignmentRight);
    //运营商品牌背景颜色
    //    model.sloganBgColor = [UIColor redColor];
    model.sloganHidden = @(NO);
    //*******loading 视图*******
    // loading 是否显示
    model.hiddenLoading = @(NO);
    //Loading 背景色
    model.loadingBackgroundColor = [UIColor blackColor];
    //Loading Indicator渲染色
    model.loadingTintColor = [UIColor whiteColor];
    //Loading 圆角
    model.loadingCornerRadius = @(10);
    //style (例:@(UIActivityIndicatorViewStyleWhiteLarge))
    model.loadingIndicatorStyle = @(UIActivityIndicatorViewStyleGray);
    //Loading 大小
    model.loadingSize = [NSValue valueWithCGSize:CGSizeMake(100, 100)];
    
    
    //自定义视图
    [model setCustomViewBlock:^(UIView *customView) {
        
        float height = [SVDVerifyViewController isPhoneX]?(160+36.0):160;
        
        
        UIImageView *topImgView = [[UIImageView alloc] init];
        topImgView.userInteractionEnabled = YES;
        topImgView.image = [UIImage imageNamed:@"bg12"];
        [customView addSubview:topImgView];
        [topImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(213);
        }];
        
        {
            UIButton *mLbl = [[UIButton alloc] init];
            [mLbl.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [mLbl.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
            [mLbl setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            mLbl.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:0.2];
            [mLbl setTitle:@"跳过" forState:UIControlStateNormal];
            [mLbl addTarget:self action:@selector(weixinLoginAction) forControlEvents:UIControlEventTouchUpInside];
            [topImgView addSubview:mLbl];
            
            [mLbl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(40);
                make.right.mas_equalTo(-10);
                make.width.mas_equalTo(48);
                make.height.mas_equalTo(22);
            }];
        }
        
        UILabel *mLbl = [[UILabel alloc] init];
        mLbl.textAlignment = NSTextAlignmentCenter;
        mLbl.font = [UIFont systemFontOfSize:23.0f];
        mLbl.textColor = [UIColor whiteColor];
        mLbl.backgroundColor = [UIColor clearColor];
        mLbl.text = @"即言";
        [topImgView addSubview:mLbl];
        
        [mLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(-10);
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(150);
            make.height.mas_equalTo(50);
        }];
        
        {
            UIButton *mLbl = [[UIButton alloc] init];
            [mLbl.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [mLbl.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
            [mLbl setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            mLbl.backgroundColor = [UIColor clearColor];
            [mLbl setTitle:@"手机" forState:UIControlStateNormal];
            [mLbl addTarget:self action:@selector(phoneAction) forControlEvents:UIControlEventTouchUpInside];
            [topImgView addSubview:mLbl];
            
            [mLbl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-30);
                make.left.mas_equalTo(0);
                make.width.mas_equalTo(SVD_ScreenWidth/2.0);
                make.height.mas_equalTo(20);
            }];
        }
        
        {
            UIButton *mLbl = [[UIButton alloc] init];
            [mLbl.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [mLbl.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
            [mLbl setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            mLbl.backgroundColor = [UIColor clearColor];
            [mLbl setTitle:@"其他" forState:UIControlStateNormal];
            [mLbl addTarget:self action:@selector(otherAction) forControlEvents:UIControlEventTouchUpInside];
            [topImgView addSubview:mLbl];
            
            [mLbl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-30);
                make.right.mas_equalTo(0);
                make.width.mas_equalTo(SVD_ScreenWidth/2.0);
                make.height.mas_equalTo(20);
            }];
        }
        
        {
            UIButton *mLbl = [[UIButton alloc] init];
            mLbl.layer.borderColor = [UIColor colorWithRed:157/255.0 green:156/255.0 blue:213/255.0 alpha:1].CGColor;
            mLbl.layer.cornerRadius = 20;
            mLbl.layer.borderWidth = 1;
            mLbl.layer.masksToBounds = YES;
            [customView addSubview:mLbl];
            
            [mLbl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(213 + 72);
                make.right.mas_equalTo(-30);
                make.left.mas_equalTo(30);
                make.height.mas_equalTo(40);
            }];
            
            self.borderBtn  = mLbl;
        }
        
        
        UIImageView *topArrowImgView = [[UIImageView alloc] init];
        topArrowImgView.image = [UIImage imageNamed:@"success"];
        [topImgView addSubview:topArrowImgView];
        [topArrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(20);
            make.centerX.mas_equalTo(-SVD_ScreenWidth/4.0);
            make.bottom.mas_equalTo(0);
            make.height.mas_equalTo(20);
        }];
        
        self.topArrowView = topArrowImgView;
        
        
        UIView *view = [[UIView alloc] init];
        {

            [customView addSubview:self.otherView];
            self.otherView.hidden = YES;
            
            [self.otherView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(0);
                make.centerX.mas_equalTo(customView);
                make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
                make.height.mas_equalTo(height);
            }];
            
            self.otherView = view;
            
            UIButton *button = [[UIButton alloc] init];
            [button setImage:[UIImage imageNamed:@"weixin"] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
            [button addTarget:self action:@selector(weixinLoginAction) forControlEvents:UIControlEventTouchUpInside];
            [self.otherView addSubview:button];
            
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(40);
                make.centerX.mas_equalTo(self.otherView);
                make.width.height.mas_equalTo(50);
            }];
        }
    }];
    
    //logo 距离上边距离
//    float topHeight = 50.0/603.0 *(SVD_ScreenHeight - SVD_StatusBarSafeBottomMargin - 44 - SVD_TabbarSafeBottomMargin);
    
    //登录页面协议size
    CGSize size = [SVSDKHelpExt loginProtocolSize:model maxWidth:(SVD_ScreenWidth - 65)];
    
    
    //布局
    SecVerifyCustomLayouts *layouts = [[SecVerifyCustomLayouts alloc] init];
    
    //phone
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(213 + 82);
        layout.layoutRight = @(-20);
        layout.layoutLeft = @(60);
        layout.layoutHeight = @(20);
        
        layouts.phoneLayout = layout;
    }
    
    //其他方式登录
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(213 + 82);
        layout.layoutRight = @(-30);
        layout.layoutWidth = @(100);
        layout.layoutHeight = @(20);
        
        layouts.switchLayout = layout;
    }
    
    //登录按钮
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(213 + 82 + 50);
        layout.layoutRight = @(-30);
        layout.layoutLeft = @(30);
        layout.layoutHeight = @(40);
        
        layouts.loginLayout = layout;
    }
    
    //check(相对隐私协议)复选框
    {
        SecVerifyCheckPrivacyLayout *layout = [[SecVerifyCheckPrivacyLayout alloc] init];
        layout.layoutTop = @(0);
        layout.layoutRight = @(-5);
        layout.layoutWidth = @(20);
        layout.layoutHeight = @(20);
        
        layouts.checkPrivacyLayout = layout;
    }
    
    //隐私条款
    {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutRight = @(-30);
        layout.layoutTop = @(213 + 82 + 100);
        layout.layoutLeft = @(50);
        layout.layoutHeight = @(size.height);
        
        layouts.privacyLayout = layout;
    }
    
    model.layouts = layouts;
    
}

- (void)weixinLoginAction
{
    
    
    [SVSDKLoginManager showLoadingViewOnLoginVc];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //自定义loading,注意回收
        [SVProgressHUD dismiss];
        [SVSDKLoginManager hiddenLoadingViewOnLoginVc];
        
        //关闭登录视图
        [SecVerify finishLoginVc:^{
            NSLog(@"微信登录");
        }];
        
        self.isLogining = NO;
    });
    
}

- (void)enableVerifyBtn:(BOOL)enable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.isLogining)
        {
            self.verifyBtn.enabled = enable;
        }
        else
        {
            self.verifyBtn.enabled = NO;
        }
    });
}

- (void)setupSubViews
{
    NSString *gifPath = [[NSBundle mainBundle] pathForResource:@"GIF" ofType:@"gif"];
    
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:gifPath]];
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    imageView.animatedImage = image;
    
    
    UILabel *verifyLabel = [[UILabel alloc] init];
    verifyLabel.textAlignment = NSTextAlignmentCenter;
    verifyLabel.text = @"开始验证!";
    verifyLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:22.f]? : [UIFont systemFontOfSize:22.f];
    verifyLabel.textColor = [UIColor colorWithRed:47/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
    
    self.verifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.verifyBtn setTitle:@"一键验证" forState:UIControlStateNormal];
    //    [self.verifyBtn setTitle:@" 预取号中…" forState:UIControlStateDisabled];
    
    [self.verifyBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    
    [self.verifyBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:254/255.0 green:122/255.0 blue:78/255.0 alpha:1/1.0] withSize:CGSizeMake(1.0, 1.0)] forState:UIControlStateNormal];
    [self.verifyBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:254/255.0 green:122/255.0 blue:78/255.0 alpha:1/1.0] withSize:CGSizeMake(1.0, 1.0)] forState:UIControlStateHighlighted];
    //    [self.verifyBtn setBackgroundImage:[self createImageWithColor:[UIColor grayColor]] forState:UIControlStateDisabled];
    
    self.verifyBtn.enabled = NO;
    
    UIButton *resetModelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [resetModelBtn setTitle:@"定" forState:UIControlStateNormal];
    [resetModelBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [resetModelBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3] withSize:CGSizeMake(30, 30)] forState:UIControlStateNormal];
    [resetModelBtn setBackgroundImage:[self createImageWithColor:[UIColor redColor] withSize:CGSizeMake(30, 30)] forState:UIControlStateSelected];
    [resetModelBtn addTarget:self action:@selector(resetModelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetModelBtn];
    
    UIButton *showRealErrbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [showRealErrbtn setTitle:@"细" forState:UIControlStateNormal];
    [showRealErrbtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [showRealErrbtn addTarget:self action:@selector(resetRealErrorAction:) forControlEvents:UIControlEventTouchUpInside];
    [showRealErrbtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3] withSize:CGSizeMake(30, 30)] forState:UIControlStateNormal];
    [showRealErrbtn setBackgroundImage:[self createImageWithColor:[UIColor redColor] withSize:CGSizeMake(30, 30)] forState:UIControlStateSelected];
    
    
    UIButton *autoDismissbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [autoDismissbtn setTitle:@"手" forState:UIControlStateNormal];
    [autoDismissbtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    autoDismissbtn.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3];
    [autoDismissbtn addTarget:self action:@selector(autoDismissAction:) forControlEvents:UIControlEventTouchUpInside];
    [autoDismissbtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3] withSize:CGSizeMake(30, 30)] forState:UIControlStateNormal];
    [autoDismissbtn setBackgroundImage:[self createImageWithColor:[UIColor redColor] withSize:CGSizeMake(30, 30)] forState:UIControlStateSelected];
    
    
    UIButton *translucentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [translucentBtn setTitle:@"上" forState:UIControlStateNormal];
    [translucentBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    translucentBtn.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3];
    [translucentBtn addTarget:self action:@selector(translucentAction:) forControlEvents:UIControlEventTouchUpInside];
    [translucentBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3] withSize:CGSizeMake(30, 30)] forState:UIControlStateNormal];
    [translucentBtn setBackgroundImage:[self createImageWithColor:[UIColor redColor] withSize:CGSizeMake(30, 30)] forState:UIControlStateSelected];
    
    UIButton *alertBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [alertBtn setTitle:@"弹" forState:UIControlStateNormal];
    [alertBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    alertBtn.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3];
    [alertBtn addTarget:self action:@selector(resetAlertAction:) forControlEvents:UIControlEventTouchUpInside];
    [alertBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3] withSize:CGSizeMake(30, 30)] forState:UIControlStateNormal];
    [alertBtn setBackgroundImage:[self createImageWithColor:[UIColor redColor] withSize:CGSizeMake(30, 30)] forState:UIControlStateSelected];
    
    UIButton *fuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [fuBtn setTitle:@"复" forState:UIControlStateNormal];
    [fuBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    fuBtn.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3];
    [fuBtn addTarget:self action:@selector(resetFuAction:) forControlEvents:UIControlEventTouchUpInside];
    [fuBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3] withSize:CGSizeMake(30, 30)] forState:UIControlStateNormal];
    [fuBtn setBackgroundImage:[self createImageWithColor:[UIColor redColor] withSize:CGSizeMake(30, 30)] forState:UIControlStateSelected];
    
    [self.view addSubview:fuBtn];
    
    [self.view addSubview:verifyLabel];
    [self.view addSubview:imageView];
    [self.view addSubview:self.verifyBtn];
    
    [self.view addSubview:resetModelBtn];
    [self.view addSubview:showRealErrbtn];
    [self.view addSubview:autoDismissbtn];
    [self.view addSubview:translucentBtn];
    [self.view addSubview:alertBtn];
    
    
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(SVD_ScreenWidth * 0.82);
        make.height.mas_equalTo(SVD_ScreenWidth);
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(SVD_StatusBarSafeBottomMargin);
    }];
    
    [showRealErrbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.height.mas_equalTo(30);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(100);
    }];
    
    [translucentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.height.mas_equalTo(30);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(150);
    }];
    
    [alertBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.height.mas_equalTo(30);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(200);
    }];
    
    [resetModelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.height.mas_equalTo(30);
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(100);
    }];
    
    [autoDismissbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.height.mas_equalTo(30);
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(150);
    }];
    
    [fuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.height.mas_equalTo(30);
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(200);
    }];
    
    [verifyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(30);
        make.left.mas_equalTo(20);
        make.bottom.mas_equalTo( - SVD_TabbarSafeBottomMargin - 20 - 80);
    }];
    
    [self.verifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(50);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo( - SVD_TabbarSafeBottomMargin - 20);
    }];
    
}

//- (SVDSuccessViewController *)successVC
//{
//    if (!_successVC)
//    {
//        _successVC = [[SVDSuccessViewController alloc] init];
//    }
//    return _successVC;
//}

- (void)showAlert:(NSString *)title message:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                              }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (UIImage *)createImageWithColor:(UIColor *)color withSize:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
