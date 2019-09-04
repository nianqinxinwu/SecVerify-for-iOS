//
//  AppDelegate.m
//  SecVerifyDemo
//
//  Created by lujh on 2019/5/16.
//  Copyright © 2019 mob. All rights reserved.
//

#import "AppDelegate.h"
#import <Bugly/Bugly.h>

#import "SVDVerifyViewController.h"



@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[SVDVerifyViewController new]];
    
    [Bugly startWithAppId:@"e21ce79e66"];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
