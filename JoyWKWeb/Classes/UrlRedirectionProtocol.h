//
//  BaseOnRedirectRequestURLProtocol.h
//  WKWebDemo
//
//  Created by Joymake on 2019/7/12.
//  Copyright © 2019 IB. All rights reserved.
//  url重定向

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UrlRedirectionProtocol : NSURLProtocol
//获取缓存路径
+(NSString *)getCachePath;

@end

@interface UrlFiltManager : NSObject

+ (instancetype)shareInstance;

@property (nonatomic,readonly)NSMutableSet *urlFiltSet;

//配置拦截的域名或地址
- (void)configUrlFilt:(NSArray *)urlFitArray;

@end

NS_ASSUME_NONNULL_END
