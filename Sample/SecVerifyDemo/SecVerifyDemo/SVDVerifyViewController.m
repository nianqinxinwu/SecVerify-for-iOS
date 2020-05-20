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
#import <SecVerify/SVSDKLoginManager.h>
#import "Masonry.h"
#import "SVProgressHUD.h"
#import "SVDPolicyManager.h"
#import "SVDLoginViewController.h"

//是否显示错误弹框(因账号密码登陆关闭的loginVC不需要显示)
static BOOL showErrorAlert = YES;
//是否显示具体的错误码
static BOOL showRealError = NO;

//是否手动销毁登录vc
static BOOL dismissLoginVcBySelf = NO;

@interface SVDVerifyViewController () <UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) BOOL isSmallScreen;

/// 背景图片 View
@property (nonatomic, strong) UIImageView *bgImageView;

/// logo按钮
@property (nonatomic, strong) UIButton *logoButton;

/// 秒验Title Label
@property (nonatomic, strong) UILabel *secVerifyTitleLabel;

/// 秒验 slogan Label
@property (nonatomic, strong) UILabel *secVerifySloganLabel;

/// GIF image view
@property (nonatomic, strong) FLAnimatedImageView *gifImageView;

/// 底部视图容器
@property (nonatomic, strong) UIView *bottomContainerView;

/// 一键登陆全屏
@property (nonatomic, strong) UIButton *fullScreenLoginButton;

/// 一键登陆弹窗
@property (nonatomic, strong) UIButton *alertLoginButton;

/// 版本号 Label
@property (nonatomic, strong) UILabel *verisonLabel;



@property (nonatomic, assign) BOOL isPreLogin;

@property (nonatomic, assign) BOOL isLogining;

@property (nonatomic, weak) UIView *otherView;

@property (nonatomic, weak) UIView *topArrowView;

@property (nonatomic, weak) UIView *borderBtn;

@property (strong, nonatomic) UIView *tempView;

@end

@implementation SVDVerifyViewController

+ (BOOL)isPhoneXor11Pro {
    BOOL isPhoneXor11Pro = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {//判断是否是手机
        return isPhoneXor11Pro;
    }
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0 && [UIScreen mainScreen].bounds.size.width <= 375) {
            isPhoneXor11Pro = YES;
        }
    }
    return isPhoneXor11Pro;
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
    self.isSmallScreen = [UIScreen mainScreen].bounds.size.width <= 375 && ![SVDVerifyViewController isPhoneX];
    
    [self setupSubViews];
    
    self.isPreLogin = NO;
    self.isLogining = NO;
    NSLog(@"****>>>22: %f", [NSDate date].timeIntervalSince1970);
    [self startPreLogin];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
//    
//    [self login];
//}


#pragma mark - 预取号

// 预取号
- (void)startPreLogin
{
    if (!self.isPreLogin)
    {
        [SecVerify preLogin:^(NSDictionary * _Nullable resultDic, NSError * _Nullable error) {
            NSLog(@"****>>>end: %f", [NSDate date].timeIntervalSince1970);
            [self enableVerifyBtn:YES];
            
            if (!error)
            {
                NSLog(@"### 预取号成功: %@", resultDic);
                self.isPreLogin = YES;
            }
            else
            {
                NSLog(@"### 预取号失败%@", error);
            }
        }];
    }
    else
    {
        [self enableVerifyBtn:YES];
    }
}


#pragma mark - 登陆
- (void)loginClicked:(UIButton *)button {
    showErrorAlert = YES;
    
//    [self enableVerifyBtn:NO];
    WeakSelf
    [SecVerify preLogin:^(NSDictionary * _Nullable resultDic, NSError * _Nullable error) {
        NSLog(@"---> Demo预取号 resultDic: %@ error: %@", resultDic, error);
        weakSelf.isPreLogin = NO;
        if (error) {
            NSString *title = nil;
            switch (error.code) {
                case 170005:
                    title = @"当前手机无SIM卡，请插入后重试";
                    break;
                case 170003:
                    title = @"不支持的运营商";
                    break;
                case 170601:
                    title = @"请打开蜂窝网络";
                    break;
                case 170606:
                    title = @"获取授权码数量超限";
                    break;
                    
                default:
                    title = @"当前网络状态不稳定";
                    break;
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
            return;
        }
        
        // 预取号成功
        weakSelf.isLogining = YES;
        SecVerifyCustomModel *model = [[SecVerifyCustomModel alloc] init];
        //当前VC,用于呈现登录视图(必须设置)
        model.currentViewController = weakSelf;
        
        if (button.tag == 10011) {
            // 自定义弹窗授权页(可选)
            [weakSelf resetAlertModel:model];
        } else {
            // 自定义授权页(可选)
            [weakSelf resetCustomModel:model];
        }
        
        // 一键登录
        [SecVerify loginWithModel:model
                      showLoginVc:^{
            //
        }
                  loginBtnClicked:^{
            //
        }
                willHiddenLoading:^{
            //
        }
                       completion:^(NSDictionary * _Nullable resultDic, NSError * _Nullable error) {
            NSLog(@"登陆验证 resultDic: %@ error: %@",resultDic, error);
            weakSelf.isLogining = NO;
            
            // 提前预取号
            [weakSelf startPreLogin];
            
            if (error) {
                //手动关闭界面的时候使用
                //170602 自定义事件，手动关闭登录vc
                //170204 取消登录
                if(dismissLoginVcBySelf && error.code != 170602 && error.code != 170204)
                {
                    [SecVerify finishLoginVc:^{
                        NSLog(@"****************手动关闭界面***************");
                    }];
                }
                
                if(showErrorAlert && showRealError)
                {
                    [weakSelf showAlert:error.userInfo.description message:error.userInfo[@"description"]];
                }
                else if (showErrorAlert)
                {
                    [weakSelf showAlert:@"提示" message:error.userInfo[@"error_message"] ?: error.userInfo[@"description"]];
                }
                return;
            }
            
            // 授权成功,获取完整手机号
            [SVProgressHUD showWithStatus:@"加载中..."];
            [[SVDSerive sharedSerive] verifyGetPhoneNumberWith:resultDic completion:^(NSError *error, NSString * _Nonnull phone) {
                NSLog(@"获取完整手机号 phone: %@ error: %@",phone, error);
                [SVProgressHUD dismiss];
                //手动关闭界面的时候使用
                if(dismissLoginVcBySelf)
                {
                    [SecVerify finishLoginVc:^{
                        NSLog(@"****************手动关闭界面***************");
                    }];
                }
                
                // 界面跳转
                SVDSuccessViewController *successVC = [[SVDSuccessViewController alloc] init];
                successVC.phone = phone;
                successVC.error = error;
                successVC.isShowRealError = showRealError;
                [weakSelf.navigationController pushViewController:successVC animated:YES];
                
            }];
            
        }];
        
    }];
}


#pragma mark - Actions

- (void)leftAction
{
    [SecVerify finishLoginVc:^{
        NSLog(@"手动关闭");
    }];
    self.isLogining = NO;
}

// 自定义全屏授权页model
- (void)resetCustomModel:(SecVerifyCustomModel *)model
{
    WeakSelf
    // 设置是否手动关闭授权页面
//    model.manualDismiss = @(YES);
    
    // 支持横屏
    model.shouldAutorotate = @(YES);
    model.supportedInterfaceOrientations = @(UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight);
    
    //*******导航条设置*******
    // 导航栏隐藏
    model.navBarHidden = @(YES);
    
    //*******授权页背景*******
    // 授权页背景颜色
    model.backgroundColor = [UIColor whiteColor];
    
    
    //*******授权页logo*******
    // Logo图片
    model.logoImg = [UIImage imageNamed:@"icon_m"];
    
    //*******号码设置*******
    // 手机号码字体颜色
//    model.numberColor = [UIColor blackColor];
    // 字体
    model.numberFont = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
    // 手机号对其方式
    model.numberTextAlignment = @(NSTextAlignmentCenter);
    
    //*******切换账号设置*******
    // 隐藏切换账号按钮
    model.switchHidden = @(YES);
    
    
    //*******复选框*******
    // 复选框选中时的图片
//    model.checkedImg = [UIImage imageNamed:@"checked"];
    // 复选框未选中时的图片
//    model.uncheckedImg = [UIImage imageNamed:@"unchecked"];
    // 隐私条款check框默认状态
    model.checkDefaultState = @(YES);
    // 复选框尺寸
//    model.checkSize = [NSValue valueWithCGSize:CGSizeMake(20, 20)];
    // 隐私条款check框是否隐藏
    model.checkHidden = @(YES);
    
    //*******隐私条款设置*******
    // 隐私条款基本文字颜色
    model.privacyTextColor = [UIColor colorWithRed:184/255.0 green:184/255.0 blue:188/255.0 alpha:1/1.0];
    // 隐私条款协议文字字体
    model.privacyTextFont =  [UIFont fontWithName:@"PingFangSC-Regular" size:11];
    // 隐私条款对其方式
    model.privacyTextAlignment = @(NSTextAlignmentCenter);
    // 隐私条款协议文字颜色
    model.privacyAgreementColor = [UIColor colorWithRed:0/255.0 green:182/255.0 blue:181/255.0 alpha:1/1.0];
    // 隐私条款应用名称
    model.privacyAppName = @"秒验Demo";
    // 协议文本前后符号@[@"《",@"》"]
    model.privacyProtocolMarkArr = @[@"《",@"》"];
    // 隐私条款多行时行距
    model.privacyLineSpacing = @(4.0);
    
    //*******登陆按钮设置*******
    // 登录按钮文本
    model.loginBtnText = @"一键登录";
    // 登录按钮文本颜色
    model.loginBtnTextColor = [UIColor whiteColor];
    // 登录按钮背景颜色
    model.loginBtnBgColor = [UIColor colorWithRed:0/255.0 green:182/255.0 blue:181/255.0 alpha:1/1.0];
    // 登录按钮圆角
    model.loginBtnCornerRadius = @(5);
    // 登录按钮文字字体
    model.loginBtnTextFont = [UIFont boldSystemFontOfSize:20];
    
    //*******运营商品牌标签*******
    //运营商品牌文字字体
    model.sloganTextFont = [UIFont fontWithName:@"PingFangSC-Regular" size:11];
    //运营商品牌文字颜色
    model.sloganTextColor = [UIColor colorWithRed:184/255.0 green:184/255.0 blue:188/255.0 alpha:1/1.0];
    //运营商品牌文字对齐方式
    model.sloganTextAlignment = @(NSTextAlignmentCenter);
    
    float realScreenWidth = (SVD_ScreenWidth > SVD_ScreenHeight)?SVD_ScreenHeight:SVD_ScreenWidth;
    float realScreenHeight = (SVD_ScreenWidth > SVD_ScreenHeight)?SVD_ScreenWidth:SVD_ScreenHeight;
    //自定义视图
    [model setCustomViewBlock:^(UIView *customView) {
        // 自定义返回按钮
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[UIImage imageNamed:@"fh"] forState:UIControlStateNormal];
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor colorWithRed:35/255.0 green:35/255.0 blue:38/255.0 alpha:1/1.0] forState:UIControlStateNormal];
        backButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
        [backButton addTarget:weakSelf action:@selector(leftAction) forControlEvents:UIControlEventTouchUpInside];
        
        [customView addSubview:backButton];
        
        float height = [SVDVerifyViewController isPhoneX]?(115+36.0):115;
        
        UIView *bottomView = [[UIView alloc] init];
//        bottomView.backgroundColor = [UIColor redColor];
        [customView addSubview:bottomView];
        
        UILabel *mLbl = [[UILabel alloc] init];
        mLbl.textAlignment = NSTextAlignmentCenter;
        mLbl.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
        mLbl.textColor = [UIColor colorWithRed:184/255.0 green:184/255.0 blue:188/255.0 alpha:1/1.0];
        mLbl.text = @"其他方式登录";
        [mLbl sizeToFit];
        
        [bottomView addSubview:mLbl];
        
        UIButton *wxBtn = [[UIButton alloc] init];
        [wxBtn setBackgroundImage:[UIImage imageNamed:@"wc"] forState:UIControlStateNormal];
        [wxBtn addTarget:weakSelf action:@selector(weixinLoginAction) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:wxBtn];
        
        UIButton *zhBtn = [[UIButton alloc] init];
        [zhBtn setBackgroundImage:[UIImage imageNamed:@"zh"] forState:UIControlStateNormal];
        [zhBtn addTarget:weakSelf action:@selector(usernameLoginAction) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:zhBtn];
        
        [customView bringSubviewToFront:bottomView];
        
        // 自定义视图根据横竖屏刷新布局
        [SVSDKLoginManager getScreenStatus:^(SVDScreenStatus status, CGSize size) {
            BOOL isPortrait = size.width < size.height;
            CGFloat topOffset = isPortrait ? 20 : 5;
            [backButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.height.mas_equalTo(50);
                make.left.mas_equalTo(15);
                make.top.mas_equalTo(isPortrait ? 34 : 15);
            }];
            
            // bottomView
            [bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (isPortrait) {
                    make.bottom.mas_equalTo(- SVD_TabbarSafeBottomMargin - 10);
                    make.centerX.mas_equalTo(customView);
                    make.width.mas_equalTo(realScreenWidth);
                    make.height.mas_equalTo(height);
                } else {
                    make.bottom.mas_equalTo(- SVD_TabbarSafeBottomMargin - 10);
                    make.centerX.mas_equalTo(customView);
                    make.width.mas_equalTo(realScreenWidth);
                    make.height.mas_equalTo(70+mLbl.bounds.size.height);
                }
                
            }];
            
            [mLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(10);
                make.centerX.mas_equalTo(0);
            }];
            
            [wxBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(mLbl.mas_bottom).offset(topOffset);
                make.centerX.mas_equalTo(-50);
                make.width.height.mas_equalTo(48);
            }];
            
            [zhBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(wxBtn);
                make.centerX.mas_equalTo(50);
                make.width.height.mas_equalTo(48);
            }];
            
        }];
        
        
    }];
    
    
    //登录页面协议size
    CGSize privacySize = [SVSDKHelpExt loginProtocolSize:model maxWidth:(realScreenWidth - 110)];
    
    //logo 距离上边距离
    float topHeight = realScreenHeight * 0.15; //50.0/603.0 *(realScreenHeight - SVD_StatusBarSafeBottomMargin - 44 - SVD_TabbarSafeBottomMargin);
    
    // 竖屏布局
    SecVerifyCustomLayouts *layouts = nil;
    if (!model.portraitLayouts) {
        layouts = [[SecVerifyCustomLayouts alloc] init];
    }else {
        layouts = model.portraitLayouts;
    }
    
    // logo
    if (!layouts.logoLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(topHeight);
        layout.layoutCenterX = @(0);
        layout.layoutWidth = @(80);
        layout.layoutHeight = @(80);
        
        layouts.logoLayout = layout;
    }
    
    //phone
    if (!layouts.phoneLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(topHeight + 110);
        layout.layoutCenterX = @(0);
        layout.layoutWidth = @(realScreenWidth * 0.8);
        layout.layoutHeight = @(30);
        
        layouts.phoneLayout = layout;
    }
    
    //运营商品牌
    if (!layouts.sloganLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(topHeight + 150);
        layout.layoutWidth = @(realScreenWidth * 0.8);
        layout.layoutHeight = @(30);
        layout.layoutCenterX = @(0);
        
        layouts.sloganLayout = layout;
    }
    
    //登录按钮
    if (!layouts.loginLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(topHeight + 200);
        layout.layoutCenterX = @(0);
        layout.layoutWidth = @(realScreenWidth * 0.8);
        layout.layoutHeight = @(48);
        
        layouts.loginLayout = layout;
    }
    
    
    //隐私条款
    if (!layouts.privacyLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(topHeight + 260);
        layout.layoutCenterX = @(0);
        layout.layoutWidth = @(privacySize.width);
        layout.layoutHeight = @(privacySize.height);

        layouts.privacyLayout = layout;
    }
    
    
    model.portraitLayouts = layouts;
    
    
    SecVerifyCustomLayouts *landscapeLayouts = nil;
    if (!model.landscapeLayouts) {
        landscapeLayouts = [[SecVerifyCustomLayouts alloc] init];
    }else{
        landscapeLayouts = model.landscapeLayouts;
    }
    
    // 横屏布局
    float landscapeTopOffset = realScreenWidth * 0.03;
    
    //logo
    if (!landscapeLayouts.logoLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(landscapeTopOffset);
        layout.layoutWidth = @(70);
        layout.layoutHeight = @(70);
        layout.layoutCenterX = @(0);
        
        landscapeLayouts.logoLayout = layout;
    }
    
    //phone
    if (!landscapeLayouts.phoneLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(landscapeTopOffset + 70 + 10);
        layout.layoutCenterX = @(0);
        layout.layoutWidth = @(realScreenWidth * 0.8);
        layout.layoutHeight = @(30);
        
        landscapeLayouts.phoneLayout = layout;
    }
    
    //运营商品牌
    if (!landscapeLayouts.sloganLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(landscapeTopOffset + 70 + 10 + 30);
        layout.layoutCenterX = @(0);
        layout.layoutWidth = @(realScreenWidth * 0.8);
        layout.layoutHeight = @(30);
        
        landscapeLayouts.sloganLayout = layout;
    }
    
    //登录按钮
    if (!landscapeLayouts.loginLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(landscapeTopOffset + 70 + 10 + 30 + 30 + 10);
        layout.layoutCenterX = @(0);
        layout.layoutWidth = @(realScreenWidth * 0.8);
        layout.layoutHeight = @(48);
        
        landscapeLayouts.loginLayout = layout;
    }
    
    //隐私条款
    if (!landscapeLayouts.privacyLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutBottom = @(10);
        layout.layoutWidth = @(realScreenHeight);
        layout.layoutHeight = @(privacySize.height);
        layout.layoutCenterX = @(0);
        
        landscapeLayouts.privacyLayout = layout;
    }
    
    model.landscapeLayouts = landscapeLayouts;
}


// 自定义弹窗授权页model
- (void)resetAlertModel:(SecVerifyCustomModel *)model
{
    // 弹窗
    model.leftControlHidden = @(YES);
    model.cancelBySingleClick = @(YES);
    model.showType = @(SVDShowStyleAlert);
    
    // 支持横屏
    model.shouldAutorotate = @(YES);
    model.supportedInterfaceOrientations = @(UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight);
    
    //*******导航条设置*******
    // 导航栏隐藏
    model.navBarHidden = @(YES);
    
    //*******授权页背景*******
    // 授权页背景颜色
    model.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    // 弹窗背景视图圆角
//    model.bgViewColor = [UIColor redColor];
    model.bgViewCorner = @(10.0);
    
    //*******授权页logo*******
    // Logo图片
    model.logoImg = [UIImage imageNamed:@"icon_m"];
    
    //*******号码设置*******
    // 手机号码字体颜色
    model.numberColor = [UIColor blackColor];
    // 字体
    model.numberFont = [UIFont fontWithName:@"PingFangSC-Semibold" size:21];
    // 手机号对其方式
    model.numberTextAlignment = @(NSTextAlignmentCenter);
    
    //*******切换账号设置*******
    // 隐藏切换账号按钮
    model.switchHidden = @(YES);
    
    //*******复选框*******
    // 隐私条款check框默认状态
    model.checkDefaultState = @(YES);
    // 隐私条款check框是否隐藏
    model.checkHidden = @(YES);
    
    //*******隐私条款设置*******
    // 隐私条款基本文字颜色
    model.privacyTextColor = [UIColor colorWithRed:184/255.0 green:184/255.0 blue:188/255.0 alpha:1/1.0];
    // 隐私条款协议文字字体
    model.privacyTextFont =  [UIFont fontWithName:@"PingFangSC-Regular" size:13];
    // 隐私条款对其方式
    model.privacyTextAlignment = @(NSTextAlignmentCenter);
    // 隐私条款协议文字颜色
    model.privacyAgreementColor = [UIColor colorWithRed:0/255.0 green:182/255.0 blue:181/255.0 alpha:1/1.0];
    // 隐私条款应用名称
    model.privacyAppName = @"秒验Demo";
    // 协议文本前后符号@[@"《",@"》"]
    model.privacyProtocolMarkArr = @[@"《",@"》"];
    // 隐私条款多行时行距
    model.privacyLineSpacing = @(4.0);
    
    //*******登陆按钮设置*******
    // 登录按钮文本
    model.loginBtnText = @"一键登录";
    // 登录按钮文本颜色
    model.loginBtnTextColor = [UIColor whiteColor];
    // 登录按钮背景颜色
    model.loginBtnBgColor = [UIColor colorWithRed:0/255.0 green:182/255.0 blue:181/255.0 alpha:1/1.0];
    // 登录按钮圆角
    model.loginBtnCornerRadius = @(5);
    // 登录按钮文字字体
    model.loginBtnTextFont = [UIFont boldSystemFontOfSize:20];
    
    //*******运营商品牌标签*******
    //运营商品牌文字字体
    model.sloganTextFont = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
    //运营商品牌文字颜色
    model.sloganTextColor = [UIColor colorWithRed:184/255.0 green:184/255.0 blue:188/255.0 alpha:1/1.0];
    //运营商品牌文字对齐方式
    model.sloganTextAlignment = @(NSTextAlignmentCenter);
    
    //自定义视图
    float realScreenWidth = (SVD_ScreenWidth > SVD_ScreenHeight) ? SVD_ScreenHeight * 0.8 : SVD_ScreenWidth * 0.8;
    float realScreenHeight = (SVD_ScreenWidth > SVD_ScreenHeight)?SVD_ScreenWidth:SVD_ScreenHeight;
    [model setCustomViewBlock:^(UIView *customView) {
        UILabel *mLbl = [[UILabel alloc] init];
        mLbl.textAlignment = NSTextAlignmentCenter;
        mLbl.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:32];
        mLbl.textColor = [UIColor blackColor];
        mLbl.text = @"秒验";
        [mLbl sizeToFit];
        
        [customView addSubview:mLbl];
        
        // 自定义视图根据横竖屏刷新布局
        [SVSDKLoginManager getScreenStatus:^(SVDScreenStatus status, CGSize size) {
            BOOL isPortrait = size.width < size.height;
            [mLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(customView.mas_centerX).offset(5);
                make.top.mas_equalTo(45);
            }];
        }];
        
    }];
    
    //登录页面协议size
    CGSize privacySize = [SVSDKHelpExt loginProtocolSize:model maxWidth:(realScreenWidth - 50)];
    
    //logo 距离上边距离
    float topHeight = 35.0;//realScreenHeight * 0.15;
    
    // 竖屏布局
    SecVerifyCustomLayouts *layouts = nil;
    if (!model.portraitLayouts) {
        layouts = [[SecVerifyCustomLayouts alloc] init];
    }else {
        layouts = model.portraitLayouts;
    }
    
    // logo
    if (!layouts.logoLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(topHeight);
        layout.layoutCenterX = @(-40);
        layout.layoutWidth = @(60);
        layout.layoutHeight = @(60);
        
        layouts.logoLayout = layout;
    }
    
    //phone
    if (!layouts.phoneLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(topHeight + 80);
        layout.layoutCenterX = @(0);
        layout.layoutWidth = @(realScreenWidth * 0.8);
        layout.layoutHeight = @(30);
        
        layouts.phoneLayout = layout;
    }
    
    //运营商品牌
    if (!layouts.sloganLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(topHeight + 110);
        layout.layoutWidth = @(realScreenWidth * 0.8);
        layout.layoutHeight = @(30);
        layout.layoutCenterX = @(0);
        
        layouts.sloganLayout = layout;
    }
    
    //登录按钮
    if (!layouts.loginLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(topHeight + 150);
        layout.layoutCenterX = @(0);
        layout.layoutWidth = @(realScreenWidth * 0.8);
        layout.layoutHeight = @(48);
        
        layouts.loginLayout = layout;
    }
    
    
    //隐私条款
    if (!layouts.privacyLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutBottom = @(-20);
        layout.layoutCenterX = @(0);
        layout.layoutWidth = @(privacySize.width);
        layout.layoutHeight = @(privacySize.height);

        layouts.privacyLayout = layout;
    }
    
    model.portraitLayouts = layouts;
    
    
    // 横屏布局
    SecVerifyCustomLayouts *landscapeLayouts = nil;
    if (!model.landscapeLayouts)
    {
        landscapeLayouts = [[SecVerifyCustomLayouts alloc] init];
    }
    else
    {
        landscapeLayouts = model.landscapeLayouts;
    }
    
    float landscapeTopOffset = 35; //realScreenWidth * 0.03;
    
    //logo
    if (!landscapeLayouts.logoLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(landscapeTopOffset);
        layout.layoutWidth = @(60);
        layout.layoutHeight = @(60);
        layout.layoutCenterX = @(-40);
        
        landscapeLayouts.logoLayout = layout;
    }
    
    //phone
    if (!landscapeLayouts.phoneLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(landscapeTopOffset + ((self.isSmallScreen || [SVDVerifyViewController isPhoneXor11Pro])? 65 : 80));
        layout.layoutCenterX = @(0);
        layout.layoutWidth = @(realScreenWidth * 0.8);
        layout.layoutHeight = @(30);
        
        landscapeLayouts.phoneLayout = layout;
    }
    
    //运营商品牌
    if (!landscapeLayouts.sloganLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(landscapeTopOffset + ((self.isSmallScreen || [SVDVerifyViewController isPhoneXor11Pro]) ? 90 : 110));
        layout.layoutCenterX = @(0);
        layout.layoutWidth = @(realScreenWidth * 0.8);
        layout.layoutHeight = @(30);
        
        landscapeLayouts.sloganLayout = layout;
    }
    
    //登录按钮
    if (!landscapeLayouts.loginLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(landscapeTopOffset + ((self.isSmallScreen || [SVDVerifyViewController isPhoneXor11Pro]) ? 120 : 150));
        layout.layoutCenterX = @(0);
        layout.layoutWidth = @(realScreenWidth * 0.8);
        layout.layoutHeight = @(48);
        
        landscapeLayouts.loginLayout = layout;
    }
    
    //隐私条款
    if (!landscapeLayouts.privacyLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutBottom = @(-5);
        layout.layoutWidth = @(privacySize.width);
        layout.layoutHeight = @(privacySize.height);
        layout.layoutCenterX = @(0);
        
        landscapeLayouts.privacyLayout = layout;
    }
    
    model.landscapeLayouts = landscapeLayouts;
    
}


// 开启详细错误
- (void)logoButtonClicked:(UIButton *)button {
    button.selected = !button.isSelected;
    showRealError = button.isSelected;
}


// 自定义授权页上微信按钮点击事件
- (void)weixinLoginAction
{
    showErrorAlert = YES;
    //关闭登录视图
    [SecVerify finishLoginVc:^{
        NSLog(@"点击微信登录...");
    }];
    
    self.isLogining = NO;
    
}

// 自定义授权页上账号按钮点击事件
- (void)usernameLoginAction
{
    WeakSelf
    // 使用授权页push一个账号密码的VC
    dispatch_async(dispatch_get_main_queue(), ^{
        SVDLoginViewController *vc = [SVDLoginViewController new];
        vc.loginButtonClickedBlock = ^(UIButton * _Nonnull button) {
            // 账号密码登陆页面点击登陆事件回调
            showErrorAlert = NO;
            //关闭登录视图
            [SecVerify finishLoginVc:^{
                [SVProgressHUD showWithStatus:@"加载中..."];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0), dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    // 界面跳转
                    SVDSuccessViewController *successVC = [[SVDSuccessViewController alloc] init];
                    successVC.phone = @"admin";
                    [weakSelf.navigationController pushViewController:successVC animated:YES];
                });
            }];
        };
        [[SVSDKLoginManager defaultManager].secLoginViewController.navigationController pushViewController:vc animated:YES];
    });
    
}


- (void)enableVerifyBtn:(BOOL)enable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.isLogining)
        {
            self.fullScreenLoginButton.enabled = enable;
            self.alertLoginButton.enabled = enable;
        }
        else
        {
            self.fullScreenLoginButton.enabled = NO;
            self.alertLoginButton.enabled = NO;
        }
    });
}



#pragma mark - Setup SubViews
- (void)setupSubViews
{
    // 头部
    [self setupHeaderViews];
    
    // 底部
    [self setupBottomViews];
    
    // 布局子视图
    [self refreshSubviewsLayoutWithSize:self.view.frame.size];
}

// 头部视图
- (void)setupHeaderViews {
    // bg image view
    UIImageView *bgImageV = [[UIImageView alloc] init];
    bgImageV.contentMode = UIViewContentModeScaleToFill;
    bgImageV.image = [UIImage imageNamed:@"bg_my"];
    bgImageV.userInteractionEnabled = YES;
    self.bgImageView = bgImageV;
    
    // logo
    UIButton *logoBtn = [[UIButton alloc] init];
    [logoBtn setBackgroundImage:[UIImage imageNamed:@"icon_w"] forState:UIControlStateNormal];
    [logoBtn setBackgroundImage:[self createImageWithColor:[UIColor redColor] withSize:CGSizeMake(1, 1)] forState:UIControlStateSelected];
    [logoBtn addTarget:self action:@selector(logoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.logoButton = logoBtn;
    
    [self.bgImageView addSubview:logoBtn];
    
    // 秒验 title
    UILabel *svTitleL = [[UILabel alloc] init];
    svTitleL.text = @"秒验";
    svTitleL.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:[UIScreen mainScreen].bounds.size.width > 375 ? 62 : 48];
    svTitleL.textColor = [UIColor whiteColor];
    [svTitleL sizeToFit];
    self.secVerifyTitleLabel = svTitleL;
    
    [self.bgImageView addSubview:svTitleL];
    
    // 秒验 slogan
    UILabel *svSloganL = [[UILabel alloc] init];
    svSloganL.text = @"让用户不再等待";
    svSloganL.font = [UIFont fontWithName:@"PingFangSC-Regular" size:28];
    svSloganL.textColor = [UIColor whiteColor];
    [svSloganL sizeToFit];
    self.secVerifySloganLabel = svSloganL;
    
    [self.bgImageView addSubview:svSloganL];
    
    // GIF Image View
    NSString *gifPath = [[NSBundle mainBundle] pathForResource:@"SVDemo" ofType:@"gif"];
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:gifPath]];
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    imageView.animatedImage = image;
    imageView.contentMode = UIViewContentModeScaleToFill;
//    imageView.backgroundColor = [UIColor redColor];
    self.gifImageView = imageView;
    
    [self.bgImageView addSubview:imageView];
    
    [self.view addSubview:bgImageV];
}

// 底部视图
- (void)setupBottomViews {
    UIView *containerV = [[UIView alloc] init];
    containerV.backgroundColor = [UIColor whiteColor];
    containerV.layer.cornerRadius = 15;
    containerV.layer.masksToBounds = YES;
    self.bottomContainerView = containerV;
    
    [self.view addSubview:containerV];
    
    UIButton *fullScreenLoginBtn = [[UIButton alloc] init];
    fullScreenLoginBtn.tag = 10010;
    [fullScreenLoginBtn setTitle:@"一键登录（全屏）" forState:UIControlStateNormal];
    [fullScreenLoginBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:0/255.0 green:182/255.0 blue:181/255.0 alpha:1/1.0] withSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * 0.7, 48) withRadius:7] forState:UIControlStateNormal];
    [fullScreenLoginBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:182/255.0 green:182/255.0 blue:181/255.0 alpha:1/1.0] withSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * 0.7, 48) withRadius:7] forState:UIControlStateDisabled];
    fullScreenLoginBtn.enabled = NO;
    [fullScreenLoginBtn addTarget:self action:@selector(loginClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.fullScreenLoginButton = fullScreenLoginBtn;
    
    [self.view addSubview:fullScreenLoginBtn];
    
    UIButton *alertLoginBtn = [[UIButton alloc] init];
    alertLoginBtn.tag = 10011;
    [alertLoginBtn setTitle:@"一键登录（弹窗）" forState:UIControlStateNormal];
    [alertLoginBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:0/255.0 green:182/255.0 blue:181/255.0 alpha:1/1.0] withSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * 0.7, 48) withRadius:7] forState:UIControlStateNormal];
    [alertLoginBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:182/255.0 green:182/255.0 blue:181/255.0 alpha:1/1.0] withSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * 0.7, 48) withRadius:7] forState:UIControlStateDisabled];
    alertLoginBtn.enabled = NO;
    [alertLoginBtn addTarget:self action:@selector(loginClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.alertLoginButton = alertLoginBtn;
    
    [self.view addSubview:alertLoginBtn];
    
    UILabel *versionL = [[UILabel alloc] init];
    versionL.text = [NSString stringWithFormat:@"版本号 %@", [SecVerify sdkVersion]];
    versionL.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    versionL.textColor = [UIColor colorWithRed:184/255.0 green:184/255.0 blue:188/255.0 alpha:1/1.0];
    [versionL sizeToFit];
    self.verisonLabel = versionL;
    
    [self.view addSubview:versionL];
    
    
    
}


// 横竖屏切换时刷新控件状态
- (void)refrashSubViewsWithViewSize:(CGSize)viewSize {
    CGFloat width = viewSize.width;
    CGFloat height = viewSize.height;
    BOOL isLandScape = width > height;
    
    self.gifImageView.hidden = isLandScape;
    self.bottomContainerView.hidden = isLandScape;
    
    self.bgImageView.image = isLandScape ? [UIImage imageNamed:@"qp_my"] : [UIImage imageNamed:@"bg_my"];
    
    UIImage *normalImg = isLandScape ? [self createImageWithColor:[UIColor whiteColor] withSize:CGSizeMake([UIScreen mainScreen].bounds.size.height * 0.7, 48) withRadius:7] : [self createImageWithColor:[UIColor colorWithRed:0/255.0 green:182/255.0 blue:181/255.0 alpha:1/1.0] withSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * 0.7, 48) withRadius:7];
    [self.fullScreenLoginButton setBackgroundImage:normalImg forState:UIControlStateNormal];
    [self.alertLoginButton setBackgroundImage:normalImg forState:UIControlStateNormal];
    
    UIColor *titleColor = isLandScape ? [UIColor colorWithRed:0/255.0 green:182/255.0 blue:181/255.0 alpha:1/1.0] : [UIColor whiteColor];
    [self.fullScreenLoginButton setTitleColor:titleColor forState:UIControlStateNormal];
    [self.alertLoginButton setTitleColor:titleColor forState:UIControlStateNormal];
    
    self.verisonLabel.textColor = isLandScape ? [UIColor whiteColor] : [UIColor colorWithRed:184/255.0 green:184/255.0 blue:188/255.0 alpha:1/1.0];
}


#pragma mark - 刷新布局
- (void)refreshSubviewsLayoutWithSize:(CGSize)viewSize
{
    CGFloat width = viewSize.width;
    CGFloat height = viewSize.height;
    BOOL isPortrait = height > width;
    
    [self.bgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(height * 0.6);
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(0);
        } else {
            make.top.left.bottom.right.mas_equalTo(0);
        }
    }];
    
    [self.gifImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.width.mas_equalTo(self.isSmallScreen ? (width * 0.82) : (width * 0.9));
            make.height.mas_equalTo(self.isSmallScreen ? (width * 0.82 * 0.75) : (width * 0.9 * 0.8));
            make.centerX.mas_equalTo(25);
            make.bottom.mas_equalTo(-10);
        }
    }];
    
    [self.secVerifySloganLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.centerX.mas_equalTo(0);
            make.bottom.equalTo(self.gifImageView.mas_top).offset(-15);
        } else {
            make.top.mas_equalTo(120);
            make.centerX.mas_equalTo(0);
        }
    }];
    
    
    [self.logoButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.width.height.mas_equalTo(self.isSmallScreen ? 54 : 64);
            make.leading.equalTo(self.secVerifySloganLabel.mas_leading).offset(15);
            make.top.mas_equalTo(SVD_TabbarSafeBottomMargin + (self.isSmallScreen ? 24 : 54));
        } else {
            make.width.height.mas_equalTo(74);
            make.leading.equalTo(self.secVerifySloganLabel.mas_leading);
            make.bottom.equalTo(self.secVerifySloganLabel.mas_top).offset(-10);
        }
    }];
    
    [self.secVerifyTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.centerY.equalTo(self.logoButton);
            make.left.equalTo(self.logoButton.mas_right).offset(10);
        } else {
            make.centerY.equalTo(self.logoButton);
            make.left.equalTo(self.logoButton.mas_right).offset(10);
        }
    }];
    
    
    [self.bottomContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(height * 0.43);
            make.bottom.mas_equalTo(0);
            make.centerX.mas_equalTo(0);
        }
        
    }];
    
    [self.verisonLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.centerX.mas_equalTo(0);
            make.bottom.mas_equalTo(- SVD_TabbarSafeBottomMargin - 10);
        } else {
            make.bottom.mas_equalTo(- SVD_TabbarSafeBottomMargin);
            make.centerX.mas_equalTo(0);
        }
    }];
    
    [self.alertLoginButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.bottom.equalTo(self.verisonLabel.mas_top).offset(self.isSmallScreen ? -30 : -50);
            make.width.mas_equalTo(width * 0.7);
            make.height.mas_equalTo(48);
            make.centerX.mas_equalTo(0);
        } else {
            make.bottom.equalTo(self.verisonLabel.mas_top).offset(-10);
            make.width.mas_equalTo(height * 0.7);
            make.height.mas_equalTo(48);
            make.centerX.mas_equalTo(0);
        }
    }];
    
    
    [self.fullScreenLoginButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.bottom.equalTo(self.alertLoginButton.mas_top).offset(self.isSmallScreen ? -40 : -60);
            make.width.mas_equalTo(width * 0.7);
            make.height.mas_equalTo(48);
            make.centerX.mas_equalTo(0);
        } else {
            make.bottom.equalTo(self.alertLoginButton.mas_top).offset(-20);
            make.width.mas_equalTo(height * 0.7);
            make.height.mas_equalTo(48);
            make.centerX.mas_equalTo(0);
        }
    }];
    
}


#pragma mark - 屏幕旋转
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self refrashSubViewsWithViewSize:size];
    [self refreshSubviewsLayoutWithSize:size];
}


#pragma mark - Private

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

/// 使用颜色创建带圆角的图片
/// @param color 颜色
/// @param size 大小
/// @param radius 圆角
- (UIImage *)createImageWithColor:(UIColor *)color withSize:(CGSize)size withRadius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 使用Core Graphics设置圆角以避免离屏渲染
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    CGContextAddPath(context, path.CGPath);
    CGContextClip(context);
    // 设置context颜色
    CGContextSetFillColorWithColor(context, color.CGColor);
    // 填充context
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


- (void)dealloc
{
    NSLog(@"===> %s", __func__);
}

@end
