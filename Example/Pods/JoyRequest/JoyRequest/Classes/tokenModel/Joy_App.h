//
//  SCBusinessApp.h
//  Property_pro
//
//  Created by wyy on 2018/3/28.
//  Copyright © 2018年 YH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Joy_NetManager.h"

@interface Joy_App : NSObject<NSCoding>

@property (nonatomic,assign)JoyAppRequestType appType;
@property (nonatomic, copy)  NSString          *access_token;

/**
 * 缓存登录信息
 */
+ (void)saveAppListInfo:(NSArray *)appList;

/**
 * 取缓存
 */
+ (NSArray *)getAppListCacheInfo;

+ (Joy_App *)getAppWithType:(JoyAppRequestType)appType;

/**
 * 清除用户app缓存缓存
 */
+ (void)clearAppListInfo;

/**
 缓存用户XUserTokentoken
 */
+ (void)cacheXUserToken:(NSString *)xuserToken;

/**
 获取用户XUserTokentoken
 */
+ (NSString *)getCacheXUserToken;

/**
 清除用户XUserTokentoken
 */
+ (void)cleanCacheXUserToken;

@end
