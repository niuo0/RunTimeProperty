//
//  RuntimeArchiver+AutoWrite.m
//  RuntimeArchiver
//
//  Created by niu_o0 on 2017/9/4.
//  Copyright © 2017年 niu_o0. All rights reserved.
//

#if __has_feature(objc_arc)
#error "-fno-objc-arc"
#endif

#import "RuntimeArchiver+AutoWrite.h"

@implementation RuntimeArchiver (AutoWrite)


static void new_setter(id self, SEL _cmd, id newValue)
{
    
    NSString * setterName = NSStringFromSelector(_cmd);
    
    NSString *getterName = getterForSetter(setterName);
    
    NSString * s = @"_";
    
    s = [s stringByAppendingString:getterName];
    
    Ivar ivar = class_getInstanceVariable([self class], [s cStringUsingEncoding:NSUTF8StringEncoding]);
 
    object_setIvar(self, ivar, newValue);
    
    [NSKeyedArchiver archiveRootObject:self toFile:[self archiverPath]];
}

static NSString * getterForSetter(NSString *setter)
{
    if (setter.length <=0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) {
        return nil;
    }
    
    NSRange range = NSMakeRange(3, setter.length - 4);
    
    NSString *key = [setter substringWithRange:range];
    
    NSString *firstLetter = [[key substringToIndex:1] lowercaseString];
    
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                       withString:firstLetter];
    return key;
}

+ (void)autoWrite{
    
    unsigned int count = 0;
    
    Method  *a = class_copyMethodList([self class], &count);
    
    for (unsigned int i = 0; i < count; i ++) {
        
        NSString * methodName = NSStringFromSelector(method_getName(a[i]));
        
        if ([methodName hasPrefix:@"setNoWrite"]) continue;
        
        //获得set方法，更改set
        if([methodName hasPrefix:@"set"] && [[self propertyOfSelf] containsObject:getterForSetter(methodName)]){
            
            method_setImplementation(a[i], (IMP)new_setter);
        }
    }
    
    free(a);
}

+ (void)initialize
{
    if (objc_getClass("RuntimeArchiver") == [self class]) {
        
        return;
        
    }
    [self autoWrite];
}

@end
