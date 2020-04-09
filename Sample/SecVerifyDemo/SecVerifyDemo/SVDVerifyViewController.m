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

static BOOL resetPushModel = NO;

@interface SVDVerifyViewController () <UIViewControllerTransitioningDelegate>

/// GIF image view
@property (nonatomic, strong) FLAnimatedImageView *gifImageView;

/// 一键验证Label
@property (nonatomic, strong) UILabel *verifyLabel;

/// 一键验证Button
@property (nonatomic, strong) UIButton *verifyButton;

/// 自定义授权页面UI按钮
@property (nonatomic, strong) UIButton *customUIButton;

/// 展示详细错误信息按钮
@property (nonatomic, strong) UIButton *detailErrorButton;

/// 手动关闭授权页面
@property (nonatomic, strong) UIButton *manualDismissButton;

/// 授权页从底部向上弹出按钮
@property (nonatomic, strong) UIButton *translucentButton;

/// 授权页弹出按钮
@property (nonatomic, strong) UIButton *alertButton;

/// 授权页Push推出
@property (nonatomic, strong) UIButton *pushButton;

/// 展示复杂授权页效果按钮
@property (nonatomic, strong) UIButton *complexButton;

/// 清空隐私协议授权结果缓存按钮
@property (nonatomic, strong) UIButton *clearPrivacyButton;

@property (nonatomic, assign) BOOL isPreLogin;

@property (nonatomic, assign) BOOL isLogining;

@property (nonatomic, weak) UIView *otherView;

@property (nonatomic, weak) UIView *topArrowView;

@property (nonatomic, weak) UIView *borderBtn;

@property (strong, nonatomic) UIView *tempView;

@end

@implementation SVDVerifyViewController

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
    
    [self setupSubViews];
    
    self.isPreLogin = NO;
    self.isLogining = NO;
    
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
//}




#pragma mark - 预取号

// 预取号
- (void)startPreLogin
{
    if (!self.isPreLogin)
    {
        [SecVerify preLogin:^(NSDictionary * _Nullable resultDic, NSError * _Nullable error) {
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
- (void)login
{
    WeakSelf
    [self enableVerifyBtn:NO];
    [SecVerify preLogin:^(NSDictionary * _Nullable resultDic, NSError * _Nullable error) {
        NSLog(@"---> 预取号 resultDic: %@ error: %@", resultDic, error);
        if (!error) {
            // 预取号成功
            weakSelf.isLogining = YES;
            SecVerifyCustomModel *model = [[SecVerifyCustomModel alloc] init];
            //当前VC,用于呈现登录视图(必须设置)
            model.currentViewController = weakSelf;
            // 设置是否手动关闭授权页面
            model.manualDismiss = @(dismissLoginVcBySelf);
            
            // 支持横屏
            model.shouldAutorotate = @(YES);
            model.supportedInterfaceOrientations = @(UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight);
            
            if (translucentBg) {
                //左边按钮隐藏
                model.leftControlHidden = @(YES);
                model.cancelBySingleClick = @(YES);
                model.showType = @(SVDShowStyleSheet);
            }
            else if (resetModel)
            {
                model.animateType = @(SVDAnimateStylePush);
                [weakSelf resetCustomModel:model];
            }
            else if (resetAlertModel)
            {
                model.leftControlHidden = @(YES);
                model.cancelBySingleClick = @(YES);
                model.showType = @(SVDShowStyleAlert);
            }
            else if (resetFuModel)
            {
                [weakSelf resetFuModel:model];
            }
            else if (resetPushModel)
            {
                model.animateType = @(SVDAnimateStylePush);
            }
            
            // 导航栏设置
            model.navLeftControlHidden = @(NO);
            model.navBarStyle = @(UIStatusBarStyleLightContent);
            model.privacyWebNavBarStyle = @(UIBarStyleDefault);
            
            
            [SecVerify loginWithModel:model
                          showLoginVc:^{
                // 授权页面成功展示回调
                NSLog(@"---> 授权页面成功展示");
            }
                      loginBtnClicked:^{
                // 授权页登陆按钮点击回调
                NSLog(@"---> 授权页登陆按钮点击");
            }
                    willHiddenLoading:^{
                //自定义loading,隐藏
                [SVProgressHUD dismiss];
            }
                           completion:^(NSDictionary * _Nullable resultDic, NSError * _Nullable error) {
                NSLog(@"登陆验证 resultDic: %@ error: %@",resultDic, error);
                weakSelf.isPreLogin = NO;
                weakSelf.isLogining = NO;
                if (!error) {
                    [SVProgressHUD showWithStatus:@"加载中..."];
                    // 授权成功,获取完整手机号
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
                        
                        if (!error)
                        {
                            SVDSuccessViewController *successVC = [[SVDSuccessViewController alloc] init];
                            successVC.phone = phone;
                            [weakSelf.navigationController pushViewController:successVC animated:YES];
                        }
                        else
                        {
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
                            NSLog(@"****************手动关闭界面***************");
                        }];
                    }
                    
                    if(showRealError)
                    {
                        [weakSelf showAlert:error.userInfo.description message:error.userInfo[@"description"]];
                    }
                    else
                    {
                        [weakSelf showAlert:@"提示" message:error.userInfo[@"error_message"] ?: error.userInfo[@"description"]];
                    }
                }
                
                // 提前预取号
                [weakSelf startPreLogin];
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

#pragma mark - Actions

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

- (void)qingBtnClicked:(UIButton *)qingBtn {
    [[SVDPolicyManager defaultManager] clearCache];
    [self showAlert:@"提示" message:@"缓存清理完成, 请重启App!"];
}

- (void)resetPushAction:(UIButton *)btn {
    resetPushModel = !resetPushModel;
    btn.selected = !btn.selected;
}

- (void)leftAction
{
    [SecVerify finishLoginVc:^{
        NSLog(@"手动关闭");
    }];
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
    // 导航栏左边按钮
    model.navLeftControl = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    // 导航栏右边按钮
    model.navRightControl = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    // 导航栏属性标题
    model.navAttributesText = attStr;
 
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
    
    model.phoneBorderWidth = @(1);
    model.phoneBorderColor =  [UIColor redColor];
    model.phoneCorner = @(6);
    //*******切换账号设置*******
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
    model.checkDefaultState = @(NO);
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
    model.privacyUnderlineStyle= @(NSUnderlineStyleSingle);
    // 隐私条款应用名称
    model.privacyAppName = @"秒验";
    // 协议文本前后符号@[@"《",@"》"]
    model.privacyProtocolMarkArr = @[@"《",@"》"];
    // 开发者隐私条款协议名称（第一组协议）
    model.privacyFirstTextArr = @[@"服务协议",@"https://www.mob.com",@"、"];
    // 开发者隐私条款协议名称（第二组协议）
    model.privacySecondTextArr =  @[@"百度协议",@"https://www.baidu.com",@"、"];
    // 开发者隐私条款协议名称（第三组协议）
    model.privacyThirdTextArr =  @[@"谷歌协议",@"https://www.google.com",@"、"];
    // 隐私条款多行时行距
    model.privacyLineSpacing = @(4.0);
    // 隐私条款WEB页面标题
//    model.privacyWebTitle = attStr;
    
    NSMutableAttributedString *privacyprivacyTitle1 = [[NSMutableAttributedString alloc] initWithString:@"协议名称"];
    
    model.privacytitleArray = @[attStr, privacyprivacyTitle1];
    
    // 隐私条款WEB页面返回按钮图片
    model.privacyWebBackBtnImage = [self createImageWithColor:[UIColor redColor]withSize:CGSizeMake(40, 40)];
    
    model.isPrivacyOperatorsLast = @(NO);
    
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
                               [self createImageWithColor:[UIColor redColor] withSize:CGSizeMake(SVD_ScreenWidth - 40, 40)],
                               [self createImageWithColor:[UIColor blueColor] withSize:CGSizeMake(SVD_ScreenWidth - 40, 40)]
                               ];
    
    
    //*******运营商品牌标签*******
    //运营商品牌文字字体
    model.sloganTextFont = [UIFont systemFontOfSize:10];
    //运营商品牌文字颜色
    model.sloganTextColor = [UIColor grayColor];
    //运营商品牌文字对齐方式
    model.sloganTextAlignment = @(NSTextAlignmentCenter);

    model.sloganBorderColor = [UIColor redColor];
    model.sloganBorderWidth = @(1);
    model.sloganCorner = @(6);
    
    //*******loading 视图*******
    // loading 是否显示
    model.hiddenLoading = @(NO);
 
    //自定义loading视图
    [model setLoadingView:^(UIView *contentView) {
//        [SVProgressHUD setContainerView:contentView];
//        [SVProgressHUD showWithStatus:@"数据加载中..."];
        
    }];
    
    [model setHasNotSelectedCheckViewBlock:^(UIView *checkView) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"请勾选协议" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];
    
    float realScreenWidth = (SVD_ScreenWidth > SVD_ScreenHeight)?SVD_ScreenHeight:SVD_ScreenWidth;
    float realScreenHeight = (SVD_ScreenWidth > SVD_ScreenHeight)?SVD_ScreenWidth:SVD_ScreenHeight;
    //自定义视图
    [model setCustomViewBlock:^(UIView *customView) {
        float height = [SVDVerifyViewController isPhoneX]?(115+36.0):115;
        
        UIView *bottomView = [[UIView alloc] init];
        {
            [customView addSubview:bottomView];
            [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(0);
                make.centerX.mas_equalTo(customView);
                make.width.mas_equalTo(realScreenWidth);
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
                make.width.height.mas_equalTo(40);
            }];
            
        }
        
        //获取当前横竖屏状态
        [SVSDKLoginManager getScreenStatus:^(SVDScreenStatus status, CGSize size) {
//            bottomView.hidden = status;
            NSLog(@"---> 当前横竖屏状态: %zd viewSize: %@", status, NSStringFromCGSize(size));
        }];
        
        [customView bringSubviewToFront:bottomView];
    }];
    
    
    //登录页面协议size
    CGSize size = [SVSDKHelpExt loginProtocolSize:model maxWidth:(realScreenWidth - 65)];
    
    //logo 距离上边距离
    float topHeight = 50.0/603.0 *(realScreenHeight - SVD_StatusBarSafeBottomMargin - 44 - SVD_TabbarSafeBottomMargin);
    
    SecVerifyCustomLayouts *layouts = nil;
    if (!model.portraitLayouts) {
        layouts = [[SecVerifyCustomLayouts alloc] init];
    }else {
        layouts = model.portraitLayouts;
    }
    
    // 竖屏布局
    if (!layouts.logoLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(topHeight);
        layout.layoutLeft = @(20);
        layout.layoutWidth = @(80);
        layout.layoutHeight = @(80);
        
        layouts.logoLayout = layout;
    }
    
    //phone
    if (!layouts.phoneLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(topHeight + 20);
        layout.layoutRight = @(-20);
        layout.layoutLeft = @(150);
        layout.layoutHeight = @(20);
        
        layouts.phoneLayout = layout;
    }
    
    //其他方式登录
    if (!layouts.switchLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(topHeight + 50);
        layout.layoutRight = @(-20);
        layout.layoutLeft = @(150);
        layout.layoutHeight = @(20);
        
        layouts.switchLayout = layout;
    }
    
    //登录按钮
    if (!layouts.loginLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(topHeight + 100);
        layout.layoutCenterX = @(0);
        layout.layoutWidth = @(realScreenWidth * 0.8);
        layout.layoutHeight = @(40);
        
        layouts.loginLayout = layout;
    }
    
    
    //check(相对隐私协议)复选框
    if (!layouts.checkPrivacyLayout) {
        SecVerifyCheckPrivacyLayout *layout = [[SecVerifyCheckPrivacyLayout alloc] init];
        layout.layoutCenterY = @(0);
        layout.layoutRight = @(-5);
        layout.layoutWidth = @(20);
        layout.layoutHeight = @(20);
        
        layouts.checkPrivacyLayout = layout;
    }
    
    
    //隐私条款
    if (!layouts.privacyLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutRight = @(-20);
        layout.layoutTop = @(topHeight + 150);
        layout.layoutLeft = @(50);
        layout.layoutHeight = @(size.height);

        layouts.privacyLayout = layout;
    }
    //运营商品牌
    if (!layouts.sloganLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
//        layout.layoutRight = @(-5);
        layout.layoutBottom = @(- 10 - SVD_TabbarSafeBottomMargin);
        layout.layoutWidth = @(120);
        layout.layoutHeight = @(20);
        layout.layoutCenterX = @(0);
        layouts.sloganLayout = layout;
    }
    
    model.portraitLayouts = layouts;
    
    
    SecVerifyCustomLayouts *landscapeLayouts = nil;
    if (!model.landscapeLayouts) {
        landscapeLayouts = [[SecVerifyCustomLayouts alloc] init];
    }else{
        landscapeLayouts = model.landscapeLayouts;
    }
    
    // 横屏布局
    float landscapeTopOffset = realScreenWidth*0.1;
    
    //logo
    if (!landscapeLayouts.logoLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(landscapeTopOffset-10);
        layout.layoutWidth = @(60);
        layout.layoutHeight = @(60);
        layout.layoutCenterX = @(-65);
        
        landscapeLayouts.logoLayout = layout;
    }
    
    //phone
    if (!landscapeLayouts.phoneLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(landscapeTopOffset);
        layout.layoutCenterX = @(25);
        layout.layoutHeight = @(20);
        layout.layoutWidth = @(100);
        
        landscapeLayouts.phoneLayout = layout;
    }
    
    //切换按钮
    if (!landscapeLayouts.switchLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(landscapeTopOffset + 30);
        layout.layoutCenterX = @(25);
        layout.layoutHeight = @(20);
        layout.layoutWidth = @(80);
        
        landscapeLayouts.switchLayout = layout;
    }
    
    //登录按钮
    if (!landscapeLayouts.loginLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(landscapeTopOffset + 60);
        layout.layoutCenterX = @(0);
        layout.layoutWidth = @(realScreenWidth * 0.8);
        layout.layoutHeight = @(40);
        
        landscapeLayouts.loginLayout = layout;
    }
    
    //check(相对隐私协议)复选框
    if (!landscapeLayouts.checkPrivacyLayout) {
        SecVerifyCheckPrivacyLayout *layout = [[SecVerifyCheckPrivacyLayout alloc] init];
        //            layout.layoutCenterY = @(0);
        layout.layoutRight = @(-5);
        layout.layoutWidth = @(20);
        layout.layoutHeight = @(20);
        layout.layoutTop = @(-3);
        landscapeLayouts.checkPrivacyLayout = layout;
    }
    
    //隐私条款
    if (!landscapeLayouts.privacyLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutTop = @(landscapeTopOffset + 110);
        layout.layoutWidth = @(realScreenWidth * 0.86);
        layout.layoutHeight = @(size.height);
        layout.layoutCenterX = @(15);
        landscapeLayouts.privacyLayout = layout;
    }
    
    //运营商品牌
    if (!landscapeLayouts.sloganLayout) {
        SecVerifyLayout *layout = [[SecVerifyLayout alloc] init];
        layout.layoutBottom = @(- 5 - SVD_TabbarSafeBottomMargin);
        layout.layoutHeight = @(20);
        layout.layoutWidth = @(250);
        layout.layoutCenterX = @(0);
        
        landscapeLayouts.sloganLayout = layout;
    }
    
    model.landscapeLayouts = landscapeLayouts;
}

// 复杂授权页选择“手机”
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

// 复杂授权页选择“其他”
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
    model.checkDefaultState = @(NO);
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
    
    model.portraitLayouts = layouts;
    
}

// 自定义授权页上微信按钮点击事件
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
            self.verifyButton.enabled = enable;
        }
        else
        {
            self.verifyButton.enabled = NO;
        }
    });
}



#pragma mark - Setup SubViews
- (void)setupSubViews
{
    // GIF Image View
    NSString *gifPath = [[NSBundle mainBundle] pathForResource:@"GIF" ofType:@"gif"];
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:gifPath]];
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    imageView.animatedImage = image;
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.backgroundColor = [UIColor redColor];
    self.gifImageView = imageView;
    
    [self.view addSubview:imageView];
    
    // 一键验证Label
    UILabel *verifyLabel = [[UILabel alloc] init];
    verifyLabel.textAlignment = NSTextAlignmentCenter;
    verifyLabel.text = [NSString stringWithFormat:@"开始验证! v%@", [SecVerify sdkVersion]];
    verifyLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:22.f]? : [UIFont systemFontOfSize:22.f];
    verifyLabel.textColor = [UIColor colorWithRed:47/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
    self.verifyLabel = verifyLabel;
    
    [self.view addSubview:verifyLabel];
    
    // 一键验证Button
    UIButton *verifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    verifyBtn.enabled = NO;
    [verifyBtn setTitle:@"一键验证" forState:UIControlStateNormal];
    [verifyBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [verifyBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:254/255.0 green:122/255.0 blue:78/255.0 alpha:1/1.0] withSize:CGSizeMake(1.0, 1.0)] forState:UIControlStateNormal];
    [verifyBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:254/255.0 green:122/255.0 blue:78/255.0 alpha:1/1.0] withSize:CGSizeMake(1.0, 1.0)] forState:UIControlStateHighlighted];
    self.verifyButton = verifyBtn;
    
    [self.view addSubview:verifyBtn];
    
    // 使用自定义视图
    UIButton *customModelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [customModelBtn setTitle:@"定" forState:UIControlStateNormal];
    [customModelBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [customModelBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3] withSize:CGSizeMake(30, 30)] forState:UIControlStateNormal];
    [customModelBtn setBackgroundImage:[self createImageWithColor:[UIColor redColor] withSize:CGSizeMake(30, 30)] forState:UIControlStateSelected];
    [customModelBtn addTarget:self action:@selector(resetModelAction:) forControlEvents:UIControlEventTouchUpInside];
    self.customUIButton = customModelBtn;
    
    [self.view addSubview:customModelBtn];
    
    // 展示详细错误日志
    UIButton *showRealErrbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [showRealErrbtn setTitle:@"细" forState:UIControlStateNormal];
    [showRealErrbtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [showRealErrbtn addTarget:self action:@selector(resetRealErrorAction:) forControlEvents:UIControlEventTouchUpInside];
    [showRealErrbtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3] withSize:CGSizeMake(30, 30)] forState:UIControlStateNormal];
    [showRealErrbtn setBackgroundImage:[self createImageWithColor:[UIColor redColor] withSize:CGSizeMake(30, 30)] forState:UIControlStateSelected];
    self.detailErrorButton = showRealErrbtn;
    
    [self.view addSubview:showRealErrbtn];
    
    // 手动关闭授权页面
    UIButton *manualDismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [manualDismissBtn setTitle:@"手" forState:UIControlStateNormal];
    [manualDismissBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    manualDismissBtn.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3];
    [manualDismissBtn addTarget:self action:@selector(autoDismissAction:) forControlEvents:UIControlEventTouchUpInside];
    [manualDismissBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3] withSize:CGSizeMake(30, 30)] forState:UIControlStateNormal];
    [manualDismissBtn setBackgroundImage:[self createImageWithColor:[UIColor redColor] withSize:CGSizeMake(30, 30)] forState:UIControlStateSelected];
    self.manualDismissButton = manualDismissBtn;
    
    [self.view addSubview:manualDismissBtn];
    
    // 授权页从底部向上弹出
    UIButton *translucentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [translucentBtn setTitle:@"上" forState:UIControlStateNormal];
    [translucentBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    translucentBtn.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3];
    [translucentBtn addTarget:self action:@selector(translucentAction:) forControlEvents:UIControlEventTouchUpInside];
    [translucentBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3] withSize:CGSizeMake(30, 30)] forState:UIControlStateNormal];
    [translucentBtn setBackgroundImage:[self createImageWithColor:[UIColor redColor] withSize:CGSizeMake(30, 30)] forState:UIControlStateSelected];
    self.translucentButton = translucentBtn;
    
    [self.view addSubview:translucentBtn];
    
    // 授权页弹出
    UIButton *alertBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [alertBtn setTitle:@"弹" forState:UIControlStateNormal];
    [alertBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    alertBtn.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3];
    [alertBtn addTarget:self action:@selector(resetAlertAction:) forControlEvents:UIControlEventTouchUpInside];
    [alertBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3] withSize:CGSizeMake(30, 30)] forState:UIControlStateNormal];
    [alertBtn setBackgroundImage:[self createImageWithColor:[UIColor redColor] withSize:CGSizeMake(30, 30)] forState:UIControlStateSelected];
    self.alertButton = alertBtn;
    
    [self.view addSubview:alertBtn];
    
    // 授权页Push推出
    UIButton *pushBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pushBtn setTitle:@"推" forState:UIControlStateNormal];
    [pushBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    pushBtn.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3];
    [pushBtn addTarget:self action:@selector(resetPushAction:) forControlEvents:UIControlEventTouchUpInside];
    [pushBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3] withSize:CGSizeMake(30, 30)] forState:UIControlStateNormal];
    [pushBtn setBackgroundImage:[self createImageWithColor:[UIColor redColor] withSize:CGSizeMake(30, 30)] forState:UIControlStateSelected];
    self.pushButton = pushBtn;
    
    [self.view addSubview:pushBtn];
    
    // 展示复杂授权页效果按钮
    UIButton *complexBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [complexBtn setTitle:@"复" forState:UIControlStateNormal];
    [complexBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    complexBtn.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3];
    [complexBtn addTarget:self action:@selector(resetFuAction:) forControlEvents:UIControlEventTouchUpInside];
    [complexBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3] withSize:CGSizeMake(30, 30)] forState:UIControlStateNormal];
    [complexBtn setBackgroundImage:[self createImageWithColor:[UIColor redColor] withSize:CGSizeMake(30, 30)] forState:UIControlStateSelected];
    self.complexButton = complexBtn;
    
    [self.view addSubview:complexBtn];
    
    // 清空隐私协议授权结果缓存
    UIButton *clearPrivacyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearPrivacyBtn setTitle:@"清" forState:UIControlStateNormal];
    [clearPrivacyBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    clearPrivacyBtn.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3];
    [clearPrivacyBtn addTarget:self action:@selector(qingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [clearPrivacyBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:0.3] withSize:CGSizeMake(30, 30)] forState:UIControlStateNormal];
    [clearPrivacyBtn setBackgroundImage:[self createImageWithColor:[UIColor redColor] withSize:CGSizeMake(30, 30)] forState:UIControlStateSelected];
    self.clearPrivacyButton = clearPrivacyBtn;
    
    [self.view addSubview:clearPrivacyBtn];
    
    // 布局子视图
    [self refreshSubviewsLayoutWithSize:self.view.frame.size];
}


#pragma mark - 刷新布局
- (void)refreshSubviewsLayoutWithSize:(CGSize)viewSize
{
    CGFloat width = viewSize.width;
    CGFloat height = viewSize.height;
    BOOL isPortrait = height > width;
    
    [self.gifImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.width.mas_equalTo(width * 0.82);
            make.height.mas_equalTo(width);
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(SVD_StatusBarSafeBottomMargin);
        } else {
            make.top.mas_equalTo(10);
            make.width.mas_equalTo(height);
            make.height.mas_equalTo(height * 0.8);
            make.centerX.mas_equalTo(0);
        }
    }];
    
    [self.verifyButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.width.mas_equalTo(width * 0.8);
            make.height.mas_equalTo(50);
            make.bottom.mas_equalTo( - SVD_TabbarSafeBottomMargin - 15);
            make.centerX.mas_equalTo(0);
        } else {
            make.width.mas_equalTo(width * 0.8);
            make.height.mas_equalTo(40);
            make.bottom.mas_equalTo( - SVD_TabbarSafeBottomMargin);
            make.centerX.mas_equalTo(0);
        }
        
    }];
    
    
    [self.verifyLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.bottom.mas_equalTo( - SVD_TabbarSafeBottomMargin - 15 - 65);
            make.centerX.mas_equalTo(0);
        } else {
            make.bottom.mas_equalTo( - SVD_TabbarSafeBottomMargin - 45);
            make.centerX.mas_equalTo(0);
        }
    }];
    
    [self.customUIButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.width.height.mas_equalTo(30);
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(100);
        } else {
            make.top.equalTo(self.gifImageView.mas_top).mas_offset(10);
            make.width.height.mas_equalTo(30);
            make.right.equalTo(self.gifImageView.mas_left).mas_offset(-10);
        }
        
    }];
    
    [self.detailErrorButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.width.height.mas_equalTo(30);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(100);
        } else {
            make.width.height.mas_equalTo(30);
            make.top.equalTo(self.gifImageView.mas_top).mas_offset(10);
            make.left.equalTo(self.gifImageView.mas_right).mas_offset(10);
        }
        
    }];
    
    [self.manualDismissButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.width.height.mas_equalTo(30);
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(150);
        } else {
            make.top.equalTo(self.customUIButton.mas_bottom).mas_offset(20);
            make.width.height.mas_equalTo(30);
            make.right.equalTo(self.gifImageView.mas_left).mas_offset(-10);
        }
        
    }];
    
    [self.translucentButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.width.height.mas_equalTo(30);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(150);
        } else {
            make.width.height.mas_equalTo(30);
            make.top.equalTo(self.detailErrorButton.mas_bottom).mas_offset(20);
            make.left.equalTo(self.gifImageView.mas_right).mas_offset(10);
        }
        
    }];
    
    [self.alertButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.width.height.mas_equalTo(30);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(200);
        } else {
            make.width.height.mas_equalTo(30);
            make.top.equalTo(self.translucentButton.mas_bottom).mas_offset(20);
            make.left.equalTo(self.gifImageView.mas_right).mas_offset(10);
        }
        
    }];
    
    [self.pushButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.width.height.mas_equalTo(30);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(250);
        } else {
            make.width.height.mas_equalTo(30);
            make.top.equalTo(self.alertButton.mas_bottom).mas_offset(20);
            make.left.equalTo(self.gifImageView.mas_right).mas_offset(10);
        }
        
    }];
    
    [self.complexButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.width.height.mas_equalTo(30);
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(200);
        } else {
            make.top.equalTo(self.manualDismissButton.mas_bottom).mas_offset(20);
            make.width.height.mas_equalTo(30);
            make.right.equalTo(self.gifImageView.mas_left).mas_offset(-10);
        }
        
    }];
    
    [self.clearPrivacyButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.width.height.mas_equalTo(30);
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(250);
        } else {
            make.top.equalTo(self.complexButton.mas_bottom).mas_offset(20);
            make.width.height.mas_equalTo(30);
            make.right.equalTo(self.gifImageView.mas_left).mas_offset(-10);
        }
        
    }];
    
}


#pragma mark - 屏幕旋转
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    NSLog(@"----> %@", NSStringFromCGSize(size));
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

@end
