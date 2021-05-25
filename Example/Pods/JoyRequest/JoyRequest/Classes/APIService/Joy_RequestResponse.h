//
//  ApiResponse.h
//  Lejiayuan
//
//  Created by CaoQuan on 16/6/28.
//  Copyright © 2016年 Lejiayuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Joy_RequestResponse : NSObject
@property (nonatomic, strong) id responseObject;                //响应数据
@property (nonatomic, strong) NSHTTPURLResponse* response;      //响应信息，可以用于获取响应header等信息
@property (nonatomic, readonly) NSInteger resultCode;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, assign) BOOL isCache;

+ (instancetype)responseWithObject:(id)responseObject;

- (instancetype)initWithData:(id)responseObject;
@end
