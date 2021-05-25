//
//  JViewController.m
//  JoyWKWeb
//
//  Created by joy on 05/24/2021.
//  Copyright (c) 2021 joy. All rights reserved.
//

#import "JViewController.h"
#import "ResourcePackageManager.h"

@interface JViewController ()

@end

@implementation JViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *label = [[UILabel alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:label];
    label.text = @"加载页......\n\n\n";
    label.font = [UIFont boldSystemFontOfSize:25];
    label.textAlignment = NSTextAlignmentCenter;
    __weak __typeof(&*self)weakSelf = self;
    [[ResourcePackageManager shareInstance] downLoadConfig:@"http://127.0.0.1:8000/appConfig.json" Success:^{
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        strongSelf.successBlock?strongSelf.successBlock():nil;
    } failure:^(NSError *error) {
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        strongSelf.successBlock?strongSelf.successBlock():nil;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
