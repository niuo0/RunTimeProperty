//
//  RuntimeArchiver+AutoWrite.m
//  RuntimeArchiver
//
//  Created by niu_o0 on 2017/9/4.
//  Copyright © 2017年 niu_o0. All rights reserved.
//

#if __has_feature(objc_arc)
//#error "-fno-objc-arc"
#endif

#import "RuntimeArchiver+AutoWrite.h"

@implementation RuntimeArchiver (AutoWrite)

static void new_setterB(id self, SEL _cmd, long long newValue){
    
    NSString * setterName = NSStringFromSelector(_cmd);
    
    NSString *getterName = getterForSetter(setterName);
    
    NSString * s = @"_";
    
    s = [s stringByAppendingString:getterName];
    
    objc_property_t p = class_getProperty([self class], [getterName UTF8String]);
    
    const char * attrString = property_getAttributes(p);
    const char *typeString = attrString + 1;
    
    
    //参考
    //https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
    
    size_t length;
    if (typeString[0] == *(@encode(BOOL)) || typeString[0] == *(@encode(bool))){
        length = sizeof(BOOL);
    }else if (typeString[0] == *(@encode(char)) || typeString[0] == *(@encode(unsigned char))){
        length = sizeof(char);
    }else if (typeString[0] == *(@encode(int)) || typeString[0] == *(@encode(unsigned int))){
        length = sizeof(int);
    }else if (typeString[0] == *(@encode(short)) || typeString[0] == *(@encode(unsigned short))){
        length = sizeof(short);
    }else if (typeString[0] == *(@encode(long)) || typeString[0] == *(@encode(unsigned long))){
        length = sizeof(long);
    }else if (typeString[0] == *(@encode(long long)) || typeString[0] == *(@encode(unsigned long long))){
        length = sizeof(long long);
    }else{
        length = 0;
        NSAssert(NO, @"unknow encode !!!!");
        return;
    }
    
    ptrdiff_t ageOffset = ivar_getOffset(class_getInstanceVariable([self class], [s cStringUsingEncoding:NSUTF8StringEncoding]));
    
    char *agePtr = ((char *)(__bridge void *)self) + ageOffset;
    memcpy(agePtr, &newValue, length);
    
    [NSKeyedArchiver archiveRootObject:self toFile:[self archiverPath]];
    
}

static void new_setterDouble(id self, SEL _cmd, double_t newValue){
    
    NSString * setterName = NSStringFromSelector(_cmd);
    
    NSString *getterName = getterForSetter(setterName);
    
    NSString * s = @"_";
    
    s = [s stringByAppendingString:getterName];
    
    objc_property_t p = class_getProperty([self class], [getterName UTF8String]);
    
    const char * attrString = property_getAttributes(p);
    const char *typeString = attrString + 1;
    size_t length;
    if (typeString[0] == *(@encode(float))){
        length = sizeof(float);
    }else if (typeString[0] == *(@encode(double))){
        length = sizeof(double);
    }else{
        length = 0;
        NSAssert(NO, @"unknow encode !!!!");
        return;
    }
    
    
    ptrdiff_t ageOffset = ivar_getOffset(class_getInstanceVariable([self class], [s cStringUsingEncoding:NSUTF8StringEncoding]));
    
    char *agePtr = ((char *)(__bridge void *)self) + ageOffset;
    memcpy(agePtr, &newValue, length);
    
    [NSKeyedArchiver archiveRootObject:self toFile:[self archiverPath]];
    
}


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
        NSString * name = getterForSetter(methodName);
        if([methodName hasPrefix:@"set"] && [[self propertyOfSelf] containsObject:name]){
            
            objc_property_t p = class_getProperty([self class], [name UTF8String]);
            
            const char * attrString = property_getAttributes(p);
            const char *typeString = attrString + 1;
//            const char *next = NSGetSizeAndAlignment(typeString, NULL, NULL);
//            size_t typeLength = next - typeString;
            
            if (typeString[0] == *(@encode(id)) && typeString[1] == '"'){
                
                method_setImplementation(a[i], (IMP)new_setter);
                
            }else if (typeString[0] == *(@encode(float_t)) || typeString[0] == *(@encode(double_t))){
                
                method_setImplementation(a[i], (IMP)new_setterDouble);
                
            }else{
                
                method_setImplementation(a[i], (IMP)new_setterB);
                
            }
            
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
