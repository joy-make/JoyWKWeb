//
//  SCBUNetHeader.h
//  smartSDK
//
//  Created by Joymake on 2018/7/12.
//

#ifndef Joy_NetHeader_h
#define Joy_NetHeader_h
#import "Joy_RequestResponse.h"

#define REQUEST_POST @"POST"
#define REQUEST_GET @"GET"
#define REQUEST_PUT @"PUT"
#define REQUEST_DELETE @"DELETE"
#define REQUEST_PATCH @"PATCH"

#define KTOKEN_REFRESH_FAILURED @"KTOKEN_REFRESH_FAILURED"

typedef void(^JoySuccessBlock) (Joy_RequestResponse *response);
typedef void(^JoyFailureBlock) (NSError *error);
typedef void(^JoyProgressBlock)(NSProgress *uploadProgress);
typedef void(^JoyTokenInvalidBlock)(void);
typedef void(^JoyDownLoadCompleteBlock) (NSURL *filePath, NSError *error);

typedef NS_ENUM(NSUInteger,JoyRequestCachePolicy) {
   JoyRequestCachePolicyIgnoreCache,              //不使用缓存
   JoyRequestCachePolicyOffLine,                  //离线状态才使用缓存
   JoyRequestCachePolicyCacheOnly,                //只要缓存
   JoyRequestCachePolicyBoth,                     //有网络先加载缓存，同时网络请求继续，请求返回加载新数据
};

typedef NS_ENUM(NSInteger,JoyAppRequestType) {
   JoyAppRequestTypeLogin=1000,//登录
   JoyAppRequestTypeUser,//用户 header：@{@"access_token":user_token}
};

typedef NS_ENUM(NSInteger,JoyRestfulType) {
   JoyRestfulTypeGetJson,
   JoyRestfulTypePostJson,
   JoyRestfulTypePutJson,
   JoyRestfulTypeDelteJson,
   JoyRestfulTypePatchJson,
   JoyRestfulTypeGetForm,
   JoyRestfulTypePostForm,
   JoyRestfulTypePutForm,
   JoyRestfulTypeDelteForm,
   JoyRestfulTypePatchForm
};
typedef NS_ENUM(NSInteger,JoyNetErrorCode) {
   JoyUnkownError = 999999999,            //默认错误码，如果服务器端未返回时定义此错误码
   JoyNetworkError = 999999998,            //网络连接错误
   JoyUnableGetAccessToken = 999999990,    //无法获取AccessToken
   JoyUnableGetSessionToken = 999999997,    //无法获取SessioToken
   JoyUserSessionExpired = 401000002,        //UserSession过期，需要重新申请User Session
   JoyUserSessionUnMatch = 401000003,        //UserSession不匹配，需要重新申请User Session
   JoyUserTokenExpired = 401000001,        //UserToken过期，需要重新登录
   JoyAccessTokenExpired = 403000002,        //AccessToken过期，需要重启申请AccessToken
   JoyUnNetwork = -1,                     //无网络连接
};

typedef void (^IDBLOCK)(id obj);
typedef void (^DICTBLOCK)(NSDictionary *dict);
typedef void (^ERRORBLOCK)(NSError *error);
typedef void (^LISTBLOCK)(NSArray *list);
typedef void (^BOOLBLOCK)(BOOL boolValue);
typedef void (^INTBLOCK)(int intValue);
typedef void (^FLOATBLOCK)(float floatValue);
typedef void (^STRINGBLOCK)(NSString *str);
typedef void (^VOIDBLOCK)(void);

#endif /* Joy_NetHeader_h */
