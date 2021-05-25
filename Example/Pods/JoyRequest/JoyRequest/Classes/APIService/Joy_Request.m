

//
//  LeApiRequest.m
//  ApiRequestDemo
//
//  Created by Joymake on 16/6/23.
//  Copyright © 2016年 Joymake. All rights reserved.
//

#import "Joy_Request.h"
#import "Joy_App.h"


@interface Joy_Request ()

@end

@implementation Joy_Request

- (id)init {
	self = [super init];
    if (self) {}
	return self;
}

+ (instancetype)requestWithUrl:(NSString*)url param:(NSDictionary*)param {
    Joy_Request *request = [[Joy_Request alloc]init];
    request.url = url;
    request.param = param;
    return request;
}

+(void)restfulRequestUrl:(NSString *)url https:(BOOL)isHttps ype:(JoyRestfulType)type headerExtention:(NSDictionary *)headerExtention param:(NSDictionary *)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType{
    switch (type) {
        case JoyRestfulTypeGetJson:
            [Joy_Request getWithUrl:url isHttps:isHttps isForm:NO headerExtention:headerExtention param:param Success:success failure:failure app:appType];
            break;
        case JoyRestfulTypePostJson:
            [Joy_Request postWithUrl:url isHttps:isHttps isForm:NO headerExtention:headerExtention param:param Success:success failure:failure app:appType];
            break;
        case JoyRestfulTypePutJson:
            [Joy_Request putWithUrl:url isHttps:isHttps isForm:NO headerExtention:headerExtention param:param Success:success failure:failure app:appType];
            break;
        case JoyRestfulTypeDelteJson:
            [Joy_Request deleteWithUrl:url isHttps:isHttps isForm:NO headerExtention:headerExtention param:param Success:success failure:failure app:appType];
            break;
        case JoyRestfulTypePatchJson:
            [Joy_Request patchWithUrl:url isHttps:isHttps isForm:NO headerExtention:headerExtention param:param Success:success failure:failure app:appType];
            break;
        case JoyRestfulTypeGetForm:
            [Joy_Request getWithUrl:url isHttps:isHttps isForm:YES headerExtention:headerExtention param:param Success:success failure:failure app:appType];
            break;
        case JoyRestfulTypePostForm:
            [Joy_Request postWithUrl:url isHttps:isHttps isForm:YES headerExtention:headerExtention param:param Success:success failure:failure app:appType];
            break;
        case JoyRestfulTypePutForm:
            [Joy_Request putWithUrl:url isHttps:isHttps isForm:YES headerExtention:headerExtention param:param Success:success failure:failure app:appType];
            break;
        case JoyRestfulTypeDelteForm:
            [Joy_Request deleteWithUrl:url isHttps:isHttps isForm:YES headerExtention:headerExtention param:param Success:success failure:failure app:appType];
            break;
        case JoyRestfulTypePatchForm:
            [Joy_Request patchWithUrl:url isHttps:isHttps isForm:YES headerExtention:headerExtention param:param Success:success failure:failure app:appType];
            break;
    }
}

#pragma mark restful接口
+(void)restfulRequestUrl:(NSString *)url https:(BOOL)isHttps ype:(JoyRestfulType)type param:(NSDictionary *)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType{
    [Joy_Request restfulRequestUrl:url https:isHttps ype:type headerExtention:nil param:param Success:success failure:failure app:appType];
}

#pragma mark JsonGet方法
+ (void)getJsonWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType{
    [Joy_Request getWithUrl:url isHttps:YES isForm:NO headerExtention:nil param:param Success:success failure:failure app:appType];
}

#pragma mark JsonPost方法
+ (void)postJsonWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType{
    [Joy_Request postWithUrl:url isHttps:YES isForm:NO headerExtention:nil param:param Success:success failure:failure app:appType];
}

#pragma mark JsonPost方法
+ (void)deleteJsonWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType{
    [Joy_Request deleteWithUrl:url isHttps:YES isForm:NO headerExtention:nil param:param Success:success failure:failure app:appType];
}

#pragma mark JsonPut方法
+ (void)putJsonWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType{
    [Joy_Request putWithUrl:url isHttps:YES isForm:NO headerExtention:nil param:param Success:success failure:failure app:appType];
}

#pragma mark JsonPatch方法
+ (void)patchJsonWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType{
    [Joy_Request patchWithUrl:url isHttps:YES isForm:NO headerExtention:nil param:param Success:success failure:failure app:appType];
}

#pragma mark FormGet方法
+ (void)getFormWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType{
    [Joy_Request getWithUrl:url isHttps:YES isForm:YES headerExtention:nil param:param Success:success failure:failure app:appType];
}

#pragma mark FormPost方法
+ (void)postFormWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType{
    [Joy_Request postWithUrl:url isHttps:YES isForm:YES headerExtention:nil param:param Success:success failure:failure app:appType];
}

#pragma mark FormPut方法
+ (void)putFormWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType{
    [Joy_Request putWithUrl:url isHttps:YES isForm:YES headerExtention:nil param:param Success:success failure:failure app:appType];
}

#pragma mark FormDelete方法
+ (void)deleteFormWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType{
    [Joy_Request deleteWithUrl:url isHttps:YES isForm:YES headerExtention:nil param:param Success:success failure:failure app:appType];
}

#pragma mark FormPatch方法
+ (void)patchFormWithUrl:(NSString*)url param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType{
    [Joy_Request patchWithUrl:url isHttps:YES isForm:YES headerExtention:nil param:param Success:success failure:failure app:appType];
}

#pragma mark JsonGet方法
+ (void)getWithUrl:(NSString*)url isHttps:(BOOL)isHttps isForm:(BOOL)isFrom headerExtention:(NSDictionary *)headerExtention param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType{
    Joy_Request *request = [Joy_Request requestWithUrl:url param:param];
    request.requestMethod = REQUEST_GET;
    request.isCloseHttps = !isHttps;
    request.isFormRequest = isFrom;
    request.appType = appType;
    [request.customHeader setDictionary:headerExtention];;
    [request extentionHeader];
    [request startRequestWithSuccess:success failure:failure];
}

#pragma mark JsonPost方法
+ (void)postWithUrl:(NSString*)url isHttps:(BOOL)isHttps isForm:(BOOL)isFrom headerExtention:(NSDictionary *)headerExtention param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType{
    Joy_Request *request = [Joy_Request requestWithUrl:url param:param];
    request.requestMethod = REQUEST_POST;
    request.appType = appType;
    [request.customHeader setDictionary:headerExtention];;
    [request extentionHeader];
    request.isFormRequest = isFrom;
    [request startRequestWithSuccess:success failure:failure];
}

#pragma mark JsonPost方法
+ (void)deleteWithUrl:(NSString*)url isHttps:(BOOL)isHttps isForm:(BOOL)isFrom headerExtention:(NSDictionary *)headerExtention param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType{
    Joy_Request *request = [Joy_Request requestWithUrl:url param:param];
    request.requestMethod = REQUEST_DELETE;
    request.isCloseHttps = !isHttps;
    request.isFormRequest = isFrom;
    request.appType = appType;
    [request.customHeader setDictionary:headerExtention];;
    [request extentionHeader];
    [request startRequestWithSuccess:success failure:failure];
}

#pragma mark JsonPut方法
+ (void)putWithUrl:(NSString*)url isHttps:(BOOL)isHttps isForm:(BOOL)isFrom headerExtention:(NSDictionary *)headerExtention param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType{
    Joy_Request *request = [Joy_Request requestWithUrl:url param:param];
    request.requestMethod = REQUEST_PUT;
    request.isCloseHttps = !isHttps;
    request.isFormRequest = isFrom;
    request.appType = appType;
    [request.customHeader setDictionary:headerExtention];;
    [request extentionHeader];
    [request startRequestWithSuccess:success failure:failure];
}

#pragma mark JsonPatch方法
+ (void)patchWithUrl:(NSString*)url isHttps:(BOOL)isHttps isForm:(BOOL)isFrom headerExtention:(NSDictionary *)headerExtention param:(NSDictionary*)param Success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure app:(JoyAppRequestType)appType{
    Joy_Request *request = [Joy_Request requestWithUrl:url param:param];
    request.requestMethod = REQUEST_PATCH;
    request.appType = appType;
    request.isCloseHttps = !isHttps;
    request.isFormRequest = isFrom;
    [request.customHeader setDictionary:headerExtention];;
    [request extentionHeader];
    [request startRequestWithSuccess:success failure:failure];
}

@end
