//
//  NSError+Message.m
//  smartSDK
//
//  Created by Joymake on 2018/8/18.
//

#import "NSError+Joy_Message.h"
#import <objc/runtime.h>

@implementation NSError (Joy_Message)
-(void)setMessage:(NSString *)message{
    if ([message isKindOfClass:NSNull.class]) {
        message = @"";
    }
    objc_setAssociatedObject(self, _cmd, message, OBJC_ASSOCIATION_COPY);
}

-(NSString *)message{
    return objc_getAssociatedObject(self, @selector(setMessage:));
}

-(void)setStatusCode:(long)statusCode{
    objc_setAssociatedObject(self, _cmd, @(statusCode), OBJC_ASSOCIATION_ASSIGN);
}

-(long)statusCode{
    return [objc_getAssociatedObject(self, @selector(setStatusCode:)) longValue];
}

-(void)setResponseDict:(NSDictionary *)responseDict{
    objc_setAssociatedObject(self, _cmd, responseDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSDictionary *)responseDict{
    return objc_getAssociatedObject(self, @selector(setResponseDict:));
}
@end
