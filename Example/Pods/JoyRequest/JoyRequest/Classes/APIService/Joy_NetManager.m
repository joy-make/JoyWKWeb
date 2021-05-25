//
//  ApiRequest.m
//  ApiRequestDemo
//
//  Created by CaoQuan on 16/6/15.
//  Copyright © 2016年 CaoQuan. All rights reserved.
//

#import "Joy_NetManager.h"
#import "Joy_Request.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSError+Joy_Message.h"
#import "Joy_App.h"

static NSString* const KAuthorization = @"Authorization";

@interface Joy_NetManager()
@property (nonatomic, copy) NSString *cacheKey;
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;
@end

@implementation Joy_NetManager

static Joy_NetManager *instance = nil;
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[Joy_NetManager alloc] init] ;
    }) ;
    return instance ;
}


- (void)dealloc {
	if (_task)
		[_task cancel];
}

- (id)init {
	self = [super init];
	if (self) {
        _sessionManager = [AFHTTPSessionManager manager];
        //用于将请求序列化成二进制 初始化一个AFJSONResponseSerializer用于将请求回来的二进制数据反序列化成JSON格式的数据。
        _sessionManager.requestSerializer= [AFJSONRequestSerializer serializer];
        //申明返回的结果是json类型
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        //如果报接受类型不一致请替换一致text/html或别的
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain",@"text/html",@"text/json", @"text/javascript", nil];
        //默认缓存方式
        _cacheMode =JoyRequestCachePolicyIgnoreCache;
	}
	return self;
}

/**
 * 是否是表单请求方式，如果是，则重置请求头
 */
- (void)setIsFormRequest:(BOOL)isFormRequest{
    _isFormRequest = isFormRequest;
    [self configSessionManagerHeader];
    //设置服务器超时时间
    _sessionManager.requestSerializer.timeoutInterval = 15.f;
}

/**
 * 设置请求头（最终）
 */
- (void)configSessionManagerHeader{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    if (_isFormRequest) {
        _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [_sessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }else{
        [self.defaultHeader setValuesForKeysWithDictionary:@{@"Content-Type":@"application/json",}];
    }
    
    __weak __typeof(&*self)weakSelf = self;
    [self.defaultHeader enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        [strongSelf.sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    //https ssl 验证。
    if(!self.isCloseHttps){
        [_sessionManager setSecurityPolicy:self.securityPolicy];
    }
}


-(AFSecurityPolicy *)securityPolicy{
    if (!_securityPolicy) {
        _securityPolicy = [AFSecurityPolicy defaultPolicy];
        _securityPolicy.allowInvalidCertificates = YES;
        _securityPolicy.validatesDomainName = NO;
    }
    return _securityPolicy;
}

- (void)startRequest {
	//如果请求正在进行，则返回
	if (_task && _task.state == NSURLSessionTaskStateRunning) {
		return;
	}
	[self configSessionManagerHeader];
	
	if (_sessionManager.reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {	//无网络
        if (self.cacheMode ==JoyRequestCachePolicyOffLine
            || self.cacheMode ==JoyRequestCachePolicyCacheOnly
            || self.cacheMode ==JoyRequestCachePolicyBoth) {
            Joy_RequestResponse *response = [self responseWithCache];
            //如果有缓存，读取缓存数据返回
            if (response) {
                    self.successBlock?self.successBlock(response):nil;
                return;
            }
        } else {
			NSError *error = [NSError errorWithDomain:@"StatusCodeError" code:JoyUnNetwork userInfo:@{NSLocalizedDescriptionKey:@"无网络连接"}];
                self.failureBlock?self.failureBlock(error):nil;
			return;
        }
	} else {	//有网络
		NSDictionary *data = [self getCache];
		Joy_RequestResponse *response = [Joy_RequestResponse responseWithObject:data];
		response.isCache = YES;
		if (data) {
			if (self.cacheMode ==JoyRequestCachePolicyCacheOnly) {
                self.successBlock?self.successBlock(response):nil;
				return;	//缓存优先模式下有缓存数据直接使用缓存数据，不再请求后台
			} else if (self.cacheMode ==JoyRequestCachePolicyBoth) {
                self.successBlock?self.successBlock(response):nil;
			}
		}
	}
	if ([self checkAllowRequest]) {
		[self sendRequest];
	}
}

- (void)sendRequest {
    NSLog(@"\n请求方式：%@\n请求头： %@\n请求接口地址： %@\n请求参数：%@ \n", self.requestMethod,self.defaultHeader,self.url,self.param?:@"无参数");
	if ([self.requestMethod isEqualToString:REQUEST_POST]) {
        
        _task = [_sessionManager POST:self.url parameters:self.param headers:@{} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
			if (task.response && [task.response isKindOfClass:[NSHTTPURLResponse class]]) {
				NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
				if (httpResponse.statusCode == 200 && self.cacheMode !=JoyRequestCachePolicyIgnoreCache) {	//返回200时缓存请求数据
					[self saveDataToCache:responseObject];
				}
			}
			[self handleSuccessTask:task response:responseObject];
		} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
			[self handleFailureTask:task error:error];
		}];
	}
    else if ([self.requestMethod isEqualToString:REQUEST_GET]) {
        _task = [_sessionManager GET:self.url parameters:self.param headers:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
			
		} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
			if (task.response && [task.response isKindOfClass:[NSHTTPURLResponse class]]) {
				NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
				if (httpResponse.statusCode == 200 && self.cacheMode !=JoyRequestCachePolicyIgnoreCache) {	//返回200时缓存请求数据
					[self saveDataToCache:responseObject];
				}
			}
			[self handleSuccessTask:task response:responseObject];
		} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
			[self handleFailureTask:task error:error];
		}];
	}
    else if ([self.requestMethod isEqualToString:REQUEST_PUT]) {
        _task = [_sessionManager PUT:self.url parameters:self.param headers:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
			[self handleSuccessTask:task response:responseObject];
		} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
			[self handleFailureTask:task error:error];
		}];
	}
    else if ([self.requestMethod isEqualToString:REQUEST_DELETE]) {
        _task = [_sessionManager DELETE:self.url parameters:self.param headers:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
			[self handleSuccessTask:task response:responseObject];
		} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
			[self handleFailureTask:task error:error];
		}];
    }
    else if ([self.requestMethod isEqualToString:REQUEST_PATCH]){
        _task = [_sessionManager PATCH:self.url parameters:self.param headers:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self handleSuccessTask:task response:responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleFailureTask:task error:error];
        }];
    }
}

- (void)cancelRequest {
	if (self.task) {
		[self.task cancel];
	}
}

+ (void)clearAllRequest {
    [[AFHTTPSessionManager manager].dataTasks enumerateObjectsUsingBlock:^(NSURLSessionDataTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cancel];
    }];
}

- (void)startRequestWithSuccess:(JoySuccessBlock)success failure:(JoyFailureBlock)failure {
	self.successBlock = success;
	self.failureBlock = failure;
	[self startRequest];
}


- (BOOL)checkAllowRequest {
    NSString *accessToken  = self.defaultHeader[KAuthorization];
    if (!(accessToken == nil || [accessToken isKindOfClass:[NSNull class]] || accessToken.length == 0) || self.appType == JoyAppRequestTypeLogin) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark 设置header信息
- (void)extentionHeader {
    NSMutableDictionary *headerDict = [NSMutableDictionary dictionaryWithCapacity:0];
    Joy_App *app = [Joy_App getAppWithType:self.appType];
    if(app.access_token){
        [headerDict setObject:app.access_token forKey:KAuthorization];
    }
    if (self.customHeader) {
        [headerDict setValuesForKeysWithDictionary:self.customHeader];
    }
    self.defaultHeader = headerDict;
}
#pragma mark 请求成功处理回调
- (void)handleSuccessTask:(NSURLSessionDataTask*)task response:(id)responseObj {
    if (task.response && [task.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        switch (httpResponse.statusCode) {
            case 200://返回200时缓存请求数据
            case 201://201表示创建资源请求成功，并且资源已经被创建
                [self blockSuccess:responseObj response:httpResponse];
                break;
            default:
                [self blockErrorInfo:[NSError errorWithDomain:@"StatusCodeError" code:JoyNetworkError userInfo:@{NSLocalizedDescriptionKey:@"请求失败，返回码错误"}]];
                break;
        }
    } else {
        self.successBlock?self.successBlock(nil):nil;
    }
}

- (void)blockSuccess:(id)responseObj response:(NSHTTPURLResponse*)httpResponse{
    Joy_RequestResponse *response = [Joy_RequestResponse responseWithObject:responseObj];
    response.response = httpResponse;
    NSLog(@"\n返回200成功数据%@",response.responseObject);
    self.successBlock?self.successBlock(response):nil;
}

#pragma mark 请求失败处理回调
- (void)handleFailureTask:(NSURLSessionDataTask*)task error:(NSError*)error {
    if (task.response && [task.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        [self handleError:httpResponse error:error];
    } else {
        self.failureBlock?self.failureBlock(error):nil;
    }
}

- (void)handleError:(NSHTTPURLResponse*)response error:(NSError*)error {
    NSData *responseData = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
    NSString *receiveStr = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    NSData * data = [receiveStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    NSLog(@"\njsonDict:%@",responseDict);
    if ([responseDict isKindOfClass:[NSDictionary class]]){
        if([[responseDict objectForKey:@"error_description"] isKindOfClass:NSString.class]){
            error.message = [responseDict objectForKey:@"error_description"];
        }else if ([[responseDict objectForKey:@"message"] isKindOfClass:NSString.class]){
            error.message = [responseDict objectForKey:@"message"];
        }else if ([[responseDict objectForKey:@"error"] isKindOfClass:NSString.class]){
            error.message = [responseDict objectForKey:@"error"];
        }
        NSString *errorpath = [[NSBundle mainBundle] pathForResource:@"errorText" ofType:@"plist"];
        NSDictionary *errorDict = [NSDictionary dictionaryWithContentsOfFile:errorpath];
        NSString *errorKey = [responseDict objectForKey:@"error"];
        NSString *errorTopic = errorKey&&![errorKey isKindOfClass:NSNull.class]?[errorDict objectForKey:errorKey]:@"";
        if(errorTopic && ![errorTopic isKindOfClass:NSNull.class]){
            error.message = errorTopic;
        }else{
            error.message = @"数据异常";
        }
        error.responseDict = responseDict;
    }
    error.statusCode = response.statusCode;
    if(self.appType ==JoyAppRequestTypeLogin){
        [self blockErrorInfo:error];
    }else{
        NSInteger statusCode = response.statusCode;
        if (statusCode) {
            switch (statusCode) {
                case 401:
                    [self tokenInvalidAction];
                    break;
                default:
                    [self blockErrorInfo:error];
                    break;
            }
        }else{
            [self blockErrorInfo:error];
        }
    }
}

- (void)blockErrorInfo:(NSError *)error{
    NSLog(@"\nerror:%@",error);
    self.failureBlock?self.failureBlock(error):nil;
}

#pragma mark token刷新仍然无效则发送通知跳转响应页面
- (void)tokenInvalidAction{
    [[NSNotificationCenter defaultCenter] postNotificationName:KTOKEN_REFRESH_FAILURED object:nil];
}

/**
 使用__cachekey得到缓存key值
  @return 返回缓存数据
 */
- (NSDictionary*)getCache {
	if (!_cacheKey)
		_cacheKey = [self getCacheKey];
	NSDictionary *data = [self getCacheWithKey:self.cacheKey];
	return data;
}

/**
 获取缓存存储的key，md5加密
 @return 获取缓存存储的key
 */
- (NSString*)getCacheKey {
	NSString *str = [NSString stringWithFormat:@"%@+%@", self.url, self.param.description];
	str = [self MD5StringWithStr:str];
	return str;
}
/**
 * SCBUDataCacheService 缓存
 * dic 为要缓存的数据
 */
- (NSDictionary*)getCacheWithKey:(NSString *)key {
	Joy_NetCacheTool *cacheService = [Joy_NetCacheTool cacheWithType:DataCacheServiceHttp];
	return [cacheService getDictionary:key];
}

- (void)saveDataToCache:(NSDictionary*)dic {
	if (!_cacheKey)
		_cacheKey = [self getCacheKey];
	Joy_NetCacheTool *cacheService = [Joy_NetCacheTool cacheWithType:DataCacheServiceHttp];
	[cacheService saveDictionary:_cacheKey dictionary:dic];
}

- (Joy_RequestResponse*)responseWithCache {
	NSDictionary *cacheDic = [self getCache];
	if (cacheDic) {
		Joy_RequestResponse *response = [Joy_RequestResponse responseWithObject:cacheDic];
		response.isCache = YES;
		return response;
	}
	return nil;
}

- (Joy_RequestResponse*)responseWithResult:(NSDictionary*)result {
	Joy_RequestResponse *response = [Joy_RequestResponse responseWithObject:result];
	response.isCache = YES;
	return response;
}

-(NSMutableDictionary *)defaultHeader{
    return _defaultHeader = _defaultHeader?:[NSMutableDictionary dictionary];
}

-(NSMutableDictionary *)customHeader{
    return _customHeader = _customHeader?:[NSMutableDictionary dictionary];
}

- (NSString *)MD5StringWithStr:(NSString *)str {
    const char *cstr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, strlen(cstr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
