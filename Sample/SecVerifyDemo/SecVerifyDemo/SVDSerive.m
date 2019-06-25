//
//  SVDSerive.m
//  SecVerifyDemo
//
//  Created by lujh on 2019/6/4.
//  Copyright © 2019 lujh. All rights reserved.
//

#import "SVDSerive.h"

#import "AFNetworking.h"

@implementation SVDSerive

+ (instancetype)sharedSerive
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)phoneLogin:(NSDictionary *)result completion:(void (^) (BOOL success, NSString *phone))handler
{
    NSDictionary *params = nil;
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSString *token = result[@"token"];
        NSString *operatorType = result[@"operatorType"];
        NSString *operatorToken = result[@"operatorToken"];
        
        if (token && operatorType && operatorToken)
        {
            params = @{
                       @"token" : token,
                       @"opToken" : operatorToken,
                       @"operator" : operatorType
                       };
        }
    }
    
    if (!params) return;
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [session POST:SVD_LoginURL
       parameters:params
          headers:nil
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable responseObject) {
              if ([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"status"] intValue] == 200)
              {
                  NSLog(@"服务器验证成功");
                  if ([responseObject[@"res"] isKindOfClass:[NSDictionary class]])
                  {
                      handler(YES, responseObject[@"res"][@"phone"]);
                  }
                  else
                  {
                      handler(YES, nil);
                  }
              }
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"http error %@",error);
              if (handler)
              {
                  handler(NO, nil);
              }
          }];
}


@end
