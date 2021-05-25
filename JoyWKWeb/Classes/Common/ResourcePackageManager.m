//
//  ResourcePackageManager.m
//  DSAppb
//
//  Created by Joymake on 2019/9/16.
//  Copyright © 2019 IB. All rights reserved.
//

#import "ResourcePackageManager.h"
#import "SSZipArchive.h"
#import "AFNetworking.h"
#import "UrlRedirectionProtocol.h"
#import <JoyRequest/Joy_NetCacheTool.h>

@interface ResourcePackageManager (){
    NSURLSessionDownloadTask *_downloadTask;
}
@end

@implementation ResourcePackageManager
    
    static ResourcePackageManager *instance = nil;
    static  NSString  *const Kpakage_CacheKey = @"Kpakage_CacheKey";
    
+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self.class new];
    });
    return instance;
}
    
-(void)downLoadConfigSuccess:(VOIDBLOCK)success failure:(ERRORBLOCK)failure{
    [Joy_Request getJsonWithUrl:@"http://127.0.0.1:8000/appConfig.json" param:nil Success:^(Joy_RequestResponse *response) {
        [self checkNeedUpdatePackageConfig:response.responseObject :success failure:failure];
    } failure:failure app:JoyAppRequestTypeLogin];
}
    
    //对比包版本
- (void)checkNeedUpdatePackageConfig:(NSDictionary *)config :(VOIDBLOCK)success failure:(ERRORBLOCK)failure{
    NSDictionary *cacheConfigDict= [[Joy_NetCacheTool scbuDictCacheForKey:Kpakage_CacheKey] objectForKey:@"packageVersion"];
    __block BOOL hasError = false;
    dispatch_group_t group = dispatch_group_create();
    for (NSDictionary *model in [config objectForKey:@"items"]) {
        NSString *newVersion = [model objectForKey:@"version"];
        NSString *moduleName = [model objectForKey:@"module"];
        NSString *zipUrlStr = [model objectForKey:@"url"];
        NSString *type = [model objectForKey:@"type"];

        NSString *oldVersion = [cacheConfigDict objectForKey:moduleName];
        if ((newVersion.intValue >oldVersion.intValue || (oldVersion == nil))&&(![type isEqualToString:@"zipResource"])) {
            dispatch_group_enter(group);
            dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self downLoadModule:moduleName url:zipUrlStr success:^{
                    dispatch_group_leave(group);
                } failure:^(NSError *error) {
                    hasError = true;
                    dispatch_group_leave(group);
                }];
            });
        }
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        self.configDict = config;
        success?success():nil;
        //没有解压异常才缓存
        if (hasError == false) {
            [Joy_NetCacheTool scbuCacheDict:config forKey:Kpakage_CacheKey];
        }
    });
}
    
#pragma mark 下载并解压H5资源
- (void)downLoadModule:(NSString *)module url:(NSString *)url success:(VOIDBLOCK)success failure:(ERRORBLOCK)failure{
    //自己要缓存的地址
    NSString *cachePath = [UrlRedirectionProtocol getCachePath];
    //远程地址
    NSURL *URL = [NSURL URLWithString:url];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    _downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //self.progressView.progress = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //- block的返回值, 要求返回一个URL, 返回的这个URL就是文件的位置的路径
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        BOOL unzipSuccess = [SSZipArchive unzipFileAtPath:filePath.path toDestination:cachePath];
        if (unzipSuccess) {
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath.path]){
                [[NSFileManager defaultManager] removeItemAtPath:filePath.path error:nil];
            }
            success?success():nil;
        }else{
            failure?failure(nil):nil;
        }
    }];
    [_downloadTask resume];
    
}
    @end
