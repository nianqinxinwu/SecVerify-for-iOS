//
//  SVDVerifyViewController.m
//  SecVerifyDemo
//
//  Created by lujh on 2019/5/31.
//  Copyright © 2019 mob. All rights reserved.
//

#import "SVDVerifyViewController.h"

#import "SVDSuccessViewController.h"
#import "SVDSerive.h"

#import "FLAnimatedImage.h"

#import <SecVerify/SecVerify.h>

@interface SVDVerifyViewController ()

@property (nonatomic) dispatch_queue_t svdQueue;
@property (nonatomic) dispatch_semaphore_t svdSemaphore;

@property (nonatomic, strong) SVDSuccessViewController *successVC;

@property (nonatomic, assign) BOOL isPreLogin;

@property (nonatomic, assign) BOOL isLogining;

@property (nonatomic, strong) UIButton *verifyBtn;

@end

@implementation SVDVerifyViewController

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
            
            if(compeletion)
            {
                compeletion(nil,nil);
            }
        }
        
    });
}

// 登录
- (void)login
{
    [self enableVerifyBtn:NO];
    [self preLogin:^(NSDictionary *resultDic, NSError *error) {
        
        if(!error)
        {
            self.isLogining = YES;
            SecVerifyCustomModel *model = [[SecVerifyCustomModel alloc] init];
            model.currentViewController = self;
            //        model.appFPrivacyText = @"1234";
            //        model.appFPrivacyUrl = @"https://www.mob.com";
            //        model.appSPrivacyText = @"12345";
            //        model.appSPrivacyUrl = @"https://www.mob.com";
            //        model.privacyTextColor = [UIColor greenColor];
            //        model.privacyAgreementColor = [UIColor redColor];
            //        model.swithAccColor = [UIColor redColor];
            [SecVerify loginWithModel:model completion:^(NSDictionary *resultDic, NSError *error) {
                
                self.isPreLogin = NO;
                self.isLogining = NO;
                
                if (!error)
                {
                    [[SVDSerive sharedSerive] phoneLogin:resultDic completion:^(BOOL success, NSString * _Nonnull phone) {
                        
                        if (success)
                        {
                            self.successVC.phone = phone;
                            [self.navigationController pushViewController:self.successVC animated:YES];
                        }
                        else
                        {
                            NSLog(@"服务器验证失败");
                            [self showAlert:@"服务器验证失败" message:error.userInfo[@"description"]];
                        }
                        [self preLogin:nil];
                    }];
                }
                else
                {
                    NSLog(@"登录失败:%@", error);
                    [self showAlert:@"提示" message:error.userInfo[@"error_message"] ?: error.userInfo[@"description"]];
                    [self preLogin:nil];
                }
                
            }];

        }
        else
        {
            [self showAlert:@"当前网络状态不稳定" message:nil];
            
            [self enableVerifyBtn:YES];
        }
    }];
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
    imageView.bounds = CGRectMake(0, 0, SVD_ScreenWidth * 0.82, SVD_ScreenWidth);
    imageView.center = CGPointMake(SVD_ScreenWidth / 2.0,  SVD_StatusBarSafeBottomMargin + SVD_ScreenWidth / 2 + 44);
    
    UILabel *verifyLabel = [[UILabel alloc] init];
    verifyLabel.bounds = CGRectMake(0, 0, SVD_ScreenWidth, 30);
    verifyLabel.center = CGPointMake(SVD_ScreenWidth / 2.0, SVD_StatusBarSafeBottomMargin + SVD_ScreenWidth + 50.0 / 603 * (SVD_ScreenHeight - SVD_StatusBarSafeBottomMargin - 44 - SVD_TabbarSafeBottomMargin) + 15 + 44);
    
    verifyLabel.textAlignment = NSTextAlignmentCenter;
    verifyLabel.text = @"开始秒验!";
    verifyLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:22.f]? : [UIFont systemFontOfSize:22.f];
    verifyLabel.textColor = [UIColor colorWithRed:47/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
    
    self.verifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.verifyBtn.bounds = CGRectMake(0, 0, SVD_ScreenWidth - 40, 50);
    self.verifyBtn.center = CGPointMake(SVD_ScreenWidth / 2.0, SVD_StatusBarSafeBottomMargin + SVD_ScreenWidth + 86.0 / 603 * (SVD_ScreenHeight - SVD_StatusBarSafeBottomMargin - 44 - SVD_TabbarSafeBottomMargin) + 30 + 44 + 25);
    
    [self.verifyBtn setTitle:@"一键验证" forState:UIControlStateNormal];
//    [self.verifyBtn setTitle:@" 预取号中…" forState:UIControlStateDisabled];

    [self.verifyBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    
    [self.verifyBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:254/255.0 green:122/255.0 blue:78/255.0 alpha:1/1.0]] forState:UIControlStateNormal];
    [self.verifyBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:254/255.0 green:122/255.0 blue:78/255.0 alpha:1/1.0]] forState:UIControlStateHighlighted];
//    [self.verifyBtn setBackgroundImage:[self createImageWithColor:[UIColor grayColor]] forState:UIControlStateDisabled];
    
    self.verifyBtn.enabled = NO;
    
    [self.view addSubview:verifyLabel];
    [self.view addSubview:imageView];
    [self.view addSubview:self.verifyBtn];
}

- (SVDSuccessViewController *)successVC
{
    if (!_successVC)
    {
        _successVC = [[SVDSuccessViewController alloc] init];
    }
    return _successVC;
}

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

- (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
