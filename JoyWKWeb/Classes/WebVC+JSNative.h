//
//  WebVC+JSNative.h
//  WKWebDemo
//
//  Created by Joymake on 2019/8/14.
//  Copyright © 2019 IB. All rights reserved.
//  WebVC的扩展工具类，可以根据实际需要选用

#import "WebVC.h"
#import "WebVC+JSNative.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark 提供常用js的方法
@interface WebVC (JSNative)

@end

#pragma mark 提供转换到H5可执行的jsonString
@interface WebVC (JSTransfer)

//转换对象为js可执行字符串
-(NSString *)transferToJsBridgeJSonWithObject:(NSObject *)obj methodName:(NSString *)methodName;

//转换对象为js可执行对象
- (NSString *)transferToJSObjectWithDict:(NSDictionary *)dict methodName:(NSString *)methodName;

//转换对象为js json字符串
- (NSString *)transferToJSonWithDict:(NSObject *)obj methodName:(NSString *)methodName;

- (NSObject *)convertjsonStringToObj:(NSString *)jsonString;
@end

#pragma mark 拦截HTTP接口
@interface WebVC (FiltUrl)
//设置拦截http https
- (void)filtHTTP;
@end

NS_ASSUME_NONNULL_END
