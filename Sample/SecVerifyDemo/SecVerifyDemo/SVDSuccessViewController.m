//
//  SVDSuccessViewController.m
//  SecVerifyDemo
//
//  Created by lujh on 2019/5/31.
//  Copyright © 2019 lujh. All rights reserved.
//

#import "SVDSuccessViewController.h"
#import "Masonry.h"

@interface SVDSuccessViewController ()

/// 成功图片
@property (nonatomic, strong) UIImageView *successImageView;

/// 验证成功
@property (nonatomic, strong) UILabel *successLabel;

/// 完整手机号
@property (nonatomic, strong) UILabel *phoneNumberLabel;

/// 再次体验
@property (nonatomic, strong) UIButton *successButton;

@end

@implementation SVDSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupSubViews];
}

- (void)verifyAgain
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)setupSubViews
{
    // 成功Image
    UIImageView *imageV = [[UIImageView alloc] init];
    imageV.image = [UIImage imageNamed:@"success"];
    self.successImageView = imageV;
    
    [self.view addSubview:imageV];
    
    // 验证成功
    UILabel *successLabel = [[UILabel alloc] init];
    successLabel.text = @"验证成功";
    successLabel.textAlignment = NSTextAlignmentCenter;
    successLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20.f]? : [UIFont systemFontOfSize:20.f];
    successLabel.textColor = [UIColor colorWithRed:47/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
    [successLabel sizeToFit];
    self.successLabel = successLabel;
    
    [self.view addSubview:successLabel];
    
    // 完整手机号
    UILabel *phoneLabel = [[UILabel alloc] init];
    if ([self.phone isKindOfClass:[NSString class]] && self.phone.length > 0)
    {
        phoneLabel.text = self.phone;
    }
    else
    {
        phoneLabel.text = @"完整手机号异常";
    }
    
    phoneLabel.textAlignment = NSTextAlignmentCenter;
    phoneLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20.f]? : [UIFont systemFontOfSize:20.f];
    phoneLabel.textColor = [UIColor colorWithRed:47/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
    [phoneLabel sizeToFit];
    self.phoneNumberLabel = phoneLabel;
    
    [self.view addSubview:phoneLabel];
    
    // 再次体验
    UIButton *successBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [successBtn setTitle:@"再次体验" forState:UIControlStateNormal];
    [successBtn addTarget:self action:@selector(verifyAgain) forControlEvents:UIControlEventTouchUpInside];
    [successBtn setBackgroundColor:[UIColor colorWithRed:254/255.0 green:122/255.0 blue:78/255.0 alpha:1/1.0]];
    self.successButton = successBtn;
    
    [self.view addSubview:successBtn];
    
    // 刷新布局
    [self refreshSubviewsLayoutWithSize:self.view.frame.size];
    
}

- (void)refreshSubviewsLayoutWithSize:(CGSize)viewSize
{
    CGFloat width = viewSize.width;
    CGFloat height = viewSize.height;
    BOOL isPortrait = height > width;
    
    [self.successImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isPortrait) {
            make.centerX.mas_equalTo(0);
            make.width.height.mas_equalTo(width * 0.4);
            make.top.mas_equalTo(100);
        } else {
            make.centerX.mas_equalTo(0);
            make.width.height.mas_equalTo(height * 0.4);
            make.top.mas_equalTo(15);
        }
    }];
    
    [self.successLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.successImageView.mas_bottom).mas_offset(30);
        make.centerX.mas_equalTo(0);
    }];
    
    [self.phoneNumberLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.successLabel.mas_bottom).mas_offset(30);
        make.centerX.mas_equalTo(0);
    }];
    
    [self.successButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phoneNumberLabel.mas_bottom).mas_offset(30);
        make.width.mas_equalTo(width * 0.8);
        make.height.mas_equalTo(50);
        make.centerX.mas_equalTo(0);
    }];
}




#pragma mark - 屏幕旋转
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    NSLog(@"----> %@", NSStringFromCGSize(size));
    // 刷新布局
    [self refreshSubviewsLayoutWithSize:size];
}

@end
