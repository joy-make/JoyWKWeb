//
//  Joy_FileRequest.h
//  JoyRequest
//
//  Created by Joymake on 2019/6/18.
//

#import "Joy_NetManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface Joy_FileRequest : Joy_NetManager
@property (nonatomic, copy) JoyProgressBlock progressBlock;             //进度回调

//上传文件
- (void)startUploadWithFilePath:(NSString*)filePath;

- (void)startUploadWithFilePath:(NSString*)filePath progress:(JoyProgressBlock)progress success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure;

- (void)startUploadWithData:(NSData*)data;

- (void)startUploadWithData:(NSData*)data progress:(JoyProgressBlock)progress success:(JoySuccessBlock)success failure:(JoyFailureBlock)failure;

//下载文件
- (void)startDownLoadFile:(JoyProgressBlock)progress completion:(JoyDownLoadCompleteBlock)complete;

//下载进度处理
- (void)handleUploadProgress:(NSProgress*)progress;

@end

NS_ASSUME_NONNULL_END
