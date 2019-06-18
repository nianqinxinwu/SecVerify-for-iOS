//
//  SecVerify.h
//  SecVerify
//
//  Created by lujh on 2019/5/16.
//  Copyright © 2019 lujh. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SecVerifyCustomModel.h"
#import "SVSDKDefine.h"

@interface SecVerify : NSObject

/**
 预登录

 @param handler 返回字典和error , 字典中包含运营商类型. error为nil即为成功.
 */
+ (void)preLogin:(SecVerifyResultHander)handler;

/**
 登录

 @param model 需要配置的model属性（控制器必传）
 @param completion 回调. error为nil即为成功. 成功则得到token、operatorToken、operatorType，之后向Mob服务器请求获取完整手机号
 */
+ (void)loginWithModel:(nonnull SecVerifyCustomModel *)model completion:(SecVerifyResultHander)completion;

/**
 当前sdk版本号

 @return 版本号
 */
+ (nonnull NSString *)sdkVersion;

@end
