//
//  ViewController.m
//  RuntimeArchiver
//
//  Created by niu_o0 on 2017/9/4.
//  Copyright © 2017年 niu_o0. All rights reserved.
//

#import "ViewController.h"
#import "SettingConfig.h"

@interface ViewController () {
    SettingConfig * _config;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _config = [SettingConfig new];
    
    NSLog(@"%@  %ld %@",_config.string, (long)_config.integer, _config.noWrite_ivar);
    
    _config.string = @"123";
    _config.integer = 456;
    _config.noWrite_ivar = @"789";
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
