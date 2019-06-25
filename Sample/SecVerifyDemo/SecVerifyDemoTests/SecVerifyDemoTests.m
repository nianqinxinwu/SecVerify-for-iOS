//
//  SecVerifyDemoTests.m
//  SecVerifyDemoTests
//
//  Created by lujh on 2019/6/13.
//  Copyright © 2019 mob. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <SecVerify/SecVerify.h>

#import <MOBFoundation/MOBFoundation.h>

@interface SecVerifyDemoTests : XCTestCase

@end

@implementation SecVerifyDemoTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testProLogin
{
    sleep(2);
    
    __block XCTestExpectation *exp = [self expectationWithDescription:@"testProLogin"];
    
    [SecVerify preLogin:^(NSDictionary * _Nullable resultDic, NSError * _Nullable error) {
        XCTAssertNotNil(error,@"预取号不会成功的");
        NSLog(@"预取号失败：%@",error);
        [exp fulfill];
        exp = nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}

- (void)testLogin_NilModel
{
    sleep(2);
    __block XCTestExpectation *exp = [self expectationWithDescription:@"testLogin_NilModel"];
    [SecVerify loginWithModel:nil completion:^(NSDictionary * _Nullable resultDic, NSError * _Nullable error) {
        XCTAssertNotNil(error,@"必须报错哦");
        NSLog(@"登录失败：%@",error);
        [exp fulfill];
        exp = nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}

- (void)testPreLogin
{
//    sleep(2);
    
    __block XCTestExpectation *exp = [self expectationWithDescription:@"testProLogin"];
    
    dispatch_queue_t queue = dispatch_queue_create(0, DISPATCH_QUEUE_SERIAL);
    
    for (int i = 0; i < 1; i++)
    {
        dispatch_async(queue, ^{
            
            [SecVerify preLogin:^(NSDictionary * _Nullable resultDic, NSError * _Nullable error) {
                //            XCTAssertNotNil(error,@"预取号不会成功的");
                //            NSLog(@"预取号失败：%@",error);
                NSLog(@"预取号成功：%@",resultDic);
                //            [exp fulfill];
                //            exp = nil;
                SecVerifyCustomModel *model = [[SecVerifyCustomModel alloc] init];
                model.currentViewController = [MOBFViewController currentViewController];
                [SecVerify loginWithModel:model completion:^(NSDictionary * _Nullable resultDic, NSError * _Nullable error) {
                    NSLog(@"登录成功1：%@",resultDic);
                }];
                dispatch_async(queue, ^{
                    sleep(10);
                    [SecVerify loginWithModel:model completion:^(NSDictionary * _Nullable resultDic, NSError * _Nullable error) {
                        NSLog(@"登录成功2：%@",resultDic);
                    }];
                });
                
            }];
        });
    }
    
    [self waitForExpectationsWithTimeout:50 handler:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}


@end
