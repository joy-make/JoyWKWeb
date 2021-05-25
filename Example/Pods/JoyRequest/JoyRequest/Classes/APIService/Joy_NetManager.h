//
//  ApiRequest.h
//  ApiRequestDemo
//
//  Created by CaoQuan on 16/6/15.
//  Copyright © 2016年 CaoQuan. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import "Joy_RequestResponse.h"
#import "Joy_NetCacheTool.h"
#import "Joy_NetHeader.h"

@interface Joy_NetManager : NSObject
@property (nonatomic, readonly) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, assign)JoyRequestCachePolicy cacheMode;
@property (nonatomic,assign)JoyAppRequestType appType;
@property (nonatomic,assign)BOOL isCloseHttps;
@property (nonatomic, copy) NSString *url;	                            //请求url
@property (nonatomic, copy) NSDictionary *param;	                    //传递的JSON 参数
@property (nonatomic, copy) NSString *requestMethod;	                //POST、GET、PUT、DELETE	默认是POST
@property (nonatomic, strong) NSMutableDictionary *defaultHeader;       //自定义header
@property (nonatomic, strong) NSMutableDictionary *customHeader;        //自定义header
@property (nonatomic, assign) BOOL isFormRequest;                       //是否是表单的请求方式 application/x-www-form-urlencoded

@property (nonatomic, copy) JoySuccessBlock successBlock;               //成功回调
@property (nonatomic, copy) JoyFailureBlock failureBlock;               //失败回调
/**
 单例
 */
+ (instancetype)shareInstance;

//检查接口是否满足条件，子类重载这个方法可拦截请求
- (BOOL)checkAllowRequest;
// 设置header信息
- (void)extentionHeader;
//开始请求
- (void)startRequest;

- (void)configSessionManagerHeader;
//结束请求
- (void)cancelRequest;

+ (void)clearAllRequest;

- (void)startRequestWithSuccess:(JoySuccessBlock)success failure:(JoyFailureBlock)failure;

//请求成功处理
- (void)handleSuccessTask:(NSURLSessionDataTask*)task response:(id)responseObj;
//请求失败处理
- (void)handleFailureTask:(NSURLSessionDataTask*)task error:(NSError*)error;

- (Joy_RequestResponse*)responseWithCache;

- (Joy_RequestResponse*)responseWithResult:(NSDictionary*)result;
@end

