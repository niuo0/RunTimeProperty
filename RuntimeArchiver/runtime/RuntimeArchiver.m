//
//  RuntimeArchiver.m
//  RuntimeArchiver
//
//  Created by niu_o0 on 2017/9/4.
//  Copyright © 2017年 niu_o0. All rights reserved.
//

#import "RuntimeArchiver.h"

@interface RuntimeArchiver ()

@end

@implementation RuntimeArchiver

// 返回self的所有对象名称
+ (NSArray *)propertyOfSelf{
    unsigned int count;
    
    // 1. 获得类中的所有成员变量
    Ivar *ivarList = class_copyIvarList(self, &count);
    
    NSMutableArray *properNames =[NSMutableArray array];
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        
        // 2.获得成员属性名
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        // 3.除去下划线，从第一个角标开始截取
        NSString *key = [name substringFromIndex:1];
        
        if ([key hasPrefix:@"noWrite"]) continue;
        
        [properNames addObject:key];
    }
    
    free(ivarList);
    
    return [properNames copy];
}


// 归档
- (void)encodeWithCoder:(NSCoder *)enCoder
{
    // 取得所有成员变量名
    NSArray *properNames = [[self class] propertyOfSelf];
    
    for (NSString *propertyName in properNames) {
        
        if ([propertyName hasPrefix:@"noWrite"]) continue;
        
        id obj = [self valueForKey:propertyName];
        
        if (obj == nil) continue;
        
        [enCoder encodeObject:obj forKey:propertyName];
    }
}

// 解档
- (instancetype)initWithCoder:(NSCoder *)coder
{
    {
        // 取得所有成员变量名
        NSArray *properNames = [[self class] propertyOfSelf];
        
        for (NSString *propertyName in properNames) {
            
            if ([propertyName hasPrefix:@"noWrite"]) continue;
            
            id value = [coder decodeObjectForKey:propertyName];
            
            if (value == nil) continue;
            
            [self setValue:value forKey:propertyName];
        }
    }
    return self;
    ;
}

- (NSString *)archiverPath{
    return [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/%s.archiver", object_getClassName(self)]];
}

- (instancetype)init
{
    //objc_msgSend(self, @selector(archiverPath));
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self archiverPath]]?:[super init];
}

@end
