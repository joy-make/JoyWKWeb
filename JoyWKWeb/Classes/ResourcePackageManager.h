//
//  ResourcePackageManager.h
//  DSAppb
//
//  Created by Joymake on 2019/9/16.
//  Copyright © 2019 IB. All rights reserved.
//  用于管理H5配置文件以及H5对应的资源包

#import <Foundation/Foundation.h>
#import <JoyRequest/Joy_Request.h>

NS_ASSUME_NONNULL_BEGIN

@interface ResourcePackageManager : NSObject
    
@property (nonatomic,strong)NSDictionary *configDict;

+ (instancetype)shareInstance;

//下载json配置文件
-(void)downLoadConfig:(NSString*)url Success:(VOIDBLOCK)success failure:(ERRORBLOCK)failure;
    
@end

NS_ASSUME_NONNULL_END
