//
//  RuntimeArchiver.h
//  RuntimeArchiver
//
//  Created by niu_o0 on 2017/9/4.
//  Copyright © 2017年 niu_o0. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>

@interface RuntimeArchiver : NSObject <NSCoding>

+ (NSArray *)propertyOfSelf;

- (NSString *)archiverPath;

@end
