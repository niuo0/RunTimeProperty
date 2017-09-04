//
//  SettingConfig.h
//  RuntimeArchiver
//
//  Created by niu_o0 on 2017/9/4.
//  Copyright © 2017年 niu_o0. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RuntimeArchiver.h"

@interface SettingConfig : RuntimeArchiver

@property (nonatomic, strong) NSString * string;
@property (nonatomic, assign) NSInteger integer;
@property (nonatomic, strong) NSString * noWrite_ivar;

@end
