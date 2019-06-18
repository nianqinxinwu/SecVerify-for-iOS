//
//  SecVerifyCustomModel.h
//  SecVerify
//
//  Created by lujh on 2019/5/28.
//  Copyright © 2019 lujh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SecVerifyCustomModel : NSObject

#pragma mark - 当前控制器
// VC，必传
@property (nonatomic, strong) UIViewController *currentViewController;

#pragma mark - 导航条设置
// 导航栏背景颜色
@property (nonatomic, strong) UIColor *navBgColor;
// 导航栏标题
@property (nonatomic, strong) NSString *navText;
// 导航栏标题颜色
@property (nonatomic, strong) UIColor *navTextColor;
// 导航返回图标
@property (nonatomic, strong) UIImage *navReturnImg;

#pragma mark - 授权页背景
// 授权页背景颜色
@property (nonatomic, strong) UIColor *backgroundColor;

#pragma mark - 授权页logo
// Logo图片
@property (nonatomic, strong) UIImage *logoImg;

#pragma mark - 号码设置
// 手机号码字体颜色
@property (nonatomic, strong) UIColor *numberColor;
// 手机号码字体大小
@property (nonatomic, assign) CGFloat numberSize;

#pragma mark - 切换账号设置
// 切换账号字体颜色
@property (nonatomic, strong) UIColor *swithAccColor;
// 隐藏切换账号按钮, 默认为NO
@property (nonatomic, assign) BOOL switchAccHidden;

#pragma mark - 复选框
// 复选框选中时的图片
@property (nonatomic, strong) UIImage *checkedImg;
// 复选框未选中时的图片
@property (nonatomic, strong) UIImage *uncheckedImg;
// 隐私条款check框默认状态，默认为YES
@property (nonatomic, assign) BOOL checkDefaultState;

#pragma mark - 隐私条款设置
// 隐私条款基本文字颜色
@property (nonatomic, strong) UIColor *privacyTextColor;
// 隐私条款协议文字颜色
@property (nonatomic, strong) UIColor *privacyAgreementColor;
// 开发者隐私条款协议名称（第一个协议）
@property (nonatomic, copy) NSString *appFPrivacyText;
// 开发者隐私条款协议Url（第一个协议）
@property (nonatomic, copy) NSString *appFPrivacyUrl;
// 开发者隐私条款协议名称（第二个协议）
@property (nonatomic, copy) NSString *appSPrivacyText;
// 开发者隐私条款协议Url（第二个协议）
@property (nonatomic, copy) NSString *appSPrivacyUrl;

#pragma mark - 登陆按钮设置

// 登录按钮文本
@property (nonatomic, copy) NSString *logBtnText;
// 登录按钮文本颜色
@property (nonatomic, strong) UIColor *logBtnTextColor;
// 登录按钮背景颜色(可用状态)
@property (nonatomic, strong) UIColor *logBtnUsableBGColor;
// 登录按钮背景颜色(不可用状态)
@property (nonatomic, strong) UIColor *logBtnUnusableBGColor;

@end


