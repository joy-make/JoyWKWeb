//
//  SCBusinessApp.m
//  Property_pro
//
//  Created by wyy on 2018/3/28.
//  Copyright © 2018年 YH. All rights reserved.
//

#import "Joy_App.h"
#import "Joy_NetCacheTool.h"

static NSString *KSCAPPListCacheKey = @"KSCAPPListCacheKey";
static NSString *SC_XUserToken = @"SC_XUserToken";
static Joy_App *instance = nil;

@implementation Joy_App

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.appType = [aDecoder decodeIntegerForKey:@"appType"];
        self.access_token = [aDecoder decodeObjectForKey:@"access_token"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInteger:self.appType forKey:@"appType"];
    [aCoder encodeObject:self.access_token forKey:@"access_token"];
}

- (instancetype)init{
    if (self = [super init]) { }
    return self;
}

#define APP_LIST_PATH [NSHomeDirectory() stringByAppendingString:@"/Documents/applist"]
+ (void)saveAppListInfo:(NSArray *)appList{
    NSMutableData*data = [[NSMutableData alloc]init];
    NSKeyedArchiver*archive = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archive encodeObject:appList forKey:APP_LIST_PATH];
    [archive finishEncoding];
    [data writeToFile:APP_LIST_PATH atomically:YES];
}

+ (NSArray *)getAppListCacheInfo{
    NSData*data2 = [NSData dataWithContentsOfFile:APP_LIST_PATH];
    NSKeyedUnarchiver*unarchive = [[NSKeyedUnarchiver alloc]initForReadingWithData:data2];
    NSArray*apps = [unarchive decodeObjectForKey:APP_LIST_PATH];
    [unarchive finishDecoding];
    return apps;
}

+ (Joy_App *)getAppWithType:(JoyAppRequestType)appType{
    if (appType == JoyAppRequestTypeUser) {
        Joy_App *app = [Joy_App new];
        app.appType = JoyAppRequestTypeUser;
        app.access_token = [self getCacheXUserToken];
        return app;
    }
    NSArray *apps = [Joy_App getAppListCacheInfo];
    for (Joy_App *app in apps) {
        if (app.appType ==appType) {
            return app;
        }
    }
    return nil;
}

+ (void)clearAppListInfo{
    [[NSFileManager defaultManager] removeItemAtPath:APP_LIST_PATH error:nil];
}

/**
 缓存用户XUserTokentoken
 */

+ (void)cacheXUserToken:(NSString *)xuserToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:xuserToken forKey:SC_XUserToken];
    [defaults synchronize];
}

/**
 获取用户XUserTokentoken
 */
+ (NSString *)getCacheXUserToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:SC_XUserToken];
}

/**
 清除用户XUserTokentoken
 */
+ (void)cleanCacheXUserToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:SC_XUserToken];
    [defaults synchronize];
}


@end
