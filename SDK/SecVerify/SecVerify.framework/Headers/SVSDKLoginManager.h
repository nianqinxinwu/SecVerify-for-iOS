//
//  SVSDKLoginManager.h
//  SecVerify
//
//  Created by yoozoo on 2019/8/14.
//  Copyright © 2019 mob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SVSDKWidgetLayout.h"
#import "SecVerifyCustomModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, SVSDKLoginItemType) {
    SVSDKLoginItemTypeLogo = 1 << 0,  //logo
    SVSDKLoginItemTypePhone = 1 << 1,  //电话号码
    SVSDKLoginItemTypeOtherLogin = 1 << 2,  //其他登录方式
    SVSDKLoginItemTypeLogin = 1 << 3,  //登录
    SVSDKLoginItemTypePrivacy = 1 << 4,  //协议
    SVSDKLoginItemTypeSlogan = 1 << 5,  //底部描述
    SVSDKLoginItemTypeCheck = 1 << 6,  //复选框
};

typedef NS_ENUM(NSInteger, SVDScreenStatus) {
    //竖屏
    SVDScreenStatusPortrait = 0,
    //横屏
    SVDScreenStatusLandscape,
};

@interface SVSDKLoginManager : NSObject

+ (instancetype)defaultManager;
/**
 显示loading 视图
 适用于自定义事件，需要在登录界面显示loading场景
 */
+ (void)showLoadingViewOnLoginVc;

/**
 隐藏loading 视图
 适用于自定义事件，需要在登录界面隐藏loading场景
 */
+ (void)hiddenLoadingViewOnLoginVc;


/**
 修改登录视图背景色
 适用于自定义背景视图动画
 */
+ (void)setLoginVcBgColor:(UIColor *)color;


/**
 控制子视图显隐

 @param item item子视图
 @param hide 是否隐藏
 */
+ (void)setHideLogin:(SVSDKLoginItemType)item hide:(BOOL)hide;


/**
 LoginVc是否响应事件

 */
+ (void)setLoginVCEnable:(BOOL)enable;

/**
 获取当前屏幕状态
 
 */
+ (void)getScreenStatus:(void(^)(SVDScreenStatus status, CGSize size))status;


#pragma mark WidgetLayout -- 获取控件位置

/**
用户获取控件位置方便用户调整授权页控件位置

*/

//弹窗视图
+ (SVSDKWidgetLayout *)alertWidgetLayout;

//logo视图
+ (SVSDKWidgetLayout *)logoWidgetLayout;

//手机号码视图
+ (SVSDKWidgetLayout *)phoneWidgetLayout;

//登录按钮视图
+ (SVSDKWidgetLayout *)loginWidgetLayout;

//其他登录方式
+ (SVSDKWidgetLayout *)otherLoginWidgetLayout;

//Slogan标签视图
+ (SVSDKWidgetLayout *)sloganWidgetLayout;

//隐私条款视图
+ (SVSDKWidgetLayout *)privacyWidgetLayout;

//弹窗左侧按钮视图
+ (SVSDKWidgetLayout *)leftControlWidgetLayout;

//弹窗右侧按钮视图
+ (SVSDKWidgetLayout *)rightControlWidgetLayout;


@end

NS_ASSUME_NONNULL_END
