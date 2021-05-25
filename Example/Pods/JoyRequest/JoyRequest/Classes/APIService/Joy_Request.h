//
//  LeApiRequest.h
//  ApiRequestDemo
//
//  Created by Joymake on 16/6/23.
//  Copyright © 2016年 Joymake. All rights reserved.
//

#import "Joy_NetManager.h"

@interface Joy_Request : Joy_NetManager
/**
 restful接口请求 可设置扩展header头信息
 @author Joymake
 @param url url
 @param isHttps 是否https
 @param type restful类型
 @param headerExtention 扩展头
 @param param 入参
 @param success 成功回调
 @param failure 失败回调
 @param appType app类型
 */
+(void)restfulRequestUrl:(NSString *)url https:(BOOL)isHttps ype:(JoyRestfulType)type headerExtention:(NSDictionary *)headerExtention param:(NSDictionary *)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType;

/**
 restful接口请求
 @author Joymake
 @param url url
 @param isHttps 是否https
 @param type restful类型
 @param param 入参
 @param success 成功回调
 @param failure 失败回调
 @param appType app类型
 */
+(void)restfulRequestUrl:(NSString *)url https:(BOOL)isHttps ype:(JoyRestfulType)type param:(NSDictionary *)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType;

/**
 get方法
 @author Joymake
 @param url url地址
 @param param 入参
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getJsonWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType;

/**
 post方法
 @author Joymake
 @param url url地址
 @param param 入参
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)postJsonWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType;

/**
 delete方法
 @author Joymake
 @param url url地址
 @param param 入参
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)deleteJsonWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType;
/**
 put方法
 @author Joymake
 @param url url地址
 @param param 入参
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)putJsonWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType;

/**
 patch方法
 @author Joymake
 @param url url地址
 @param param 入参
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)patchJsonWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType;
/**
 getForm方法
 @author Joymake
 @param url url地址
 @param param 入参
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getFormWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType;

/**
 postForm方法
 @author Joymake
 @param url url地址
 @param param 入参
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)postFormWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType;

/**
 putForm方法
 @author Joymake
 @param url url地址
 @param param 入参
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)putFormWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType;
/**
 deleteForm方法
 @author Joymake
 @param url url地址
 @param param 入参
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)deleteFormWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType;
/**
 patchForm方法
 @author Joymake
 @param url url地址
 @param param 入参
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)patchFormWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType;

@end

