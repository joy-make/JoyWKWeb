//
//  Joy_FileRequest.m
//  JoyRequest
//
//  Created by Joymake on 2019/6/18.
//

#import "Joy_FileRequest.h"

@interface Joy_FileRequest ()
@property (nonatomic, strong) NSString *downloadDirectory;                //下载文件本地目录
@property (nonatomic, strong) NSString *downloadFileName;                //下载文件名

@end

@implementation Joy_FileRequest

/**
 * 上传 图片请求 通过URL来获取路径，进入沙盒或者系统相册等等
 */
- (void)startUploadWithFilePath:(NSString*)filePath {
    [self configSessionManagerHeader];
    NSURL *filePathUrl = [NSURL fileURLWithPath:filePath];
    self.task = [self.sessionManager POST:self.url parameters:self.param headers:@{} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileURL:filePathUrl name:@"resources" error:nil];
        NSLog(@"上传文件%@", filePathUrl);
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        [self handleUploadProgress:uploadProgress];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleSuccessTask:task response:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleFailureTask:task error:error];
    }];
}

- (void)startUploadWithFilePath:(NSString*)filePath progress:(JoyProgressBlock)progress success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure {
    self.successBlock = success;
    self.failureBlock = failure;
    self.progressBlock = progress;
    [self startUploadWithFilePath:filePath];
}

/**
 * 通过文件上传 直接以 key value 的形式向 formData 中追加二进制数据
 */
- (void)startUploadWithData:(NSData*)data {
    [self configSessionManagerHeader];
    self.task = [self.sessionManager POST:self.url parameters:self.param headers:@{} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFormData:data name:@"resources"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        [self handleUploadProgress:uploadProgress];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleSuccessTask:task response:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleFailureTask:task error:error];
    }];
}

- (void)startUploadWithData:(NSData*)data progress:(JoyProgressBlock)progress success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure {
    self.successBlock = success;
    self.failureBlock = failure;
    self.progressBlock = progress;
    [self startUploadWithData:data];
}

- (void)startDownLoadFile:(JoyProgressBlock)progress completion:(JoyDownLoadCompleteBlock)complete {
    self.progressBlock = progress;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    NSURLSessionDownloadTask *downTask = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        [self handleUploadProgress:downloadProgress];
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *fileName = self.downloadFileName.length ? self.downloadFileName : response.suggestedFilename;
        NSString *filePath = [self.downloadDirectory stringByAppendingPathComponent:fileName];
        return [NSURL fileURLWithPath:filePath isDirectory:NO];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (filePath) {//下载成功
            if (complete) {
                complete(filePath, error);
            }
        }
    }];
    
    [downTask resume];
}

//上传进度
- (void)handleUploadProgress:(NSProgress*)progress {
    self.progressBlock?self.progressBlock(progress):nil;
}
@end
