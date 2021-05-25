//
//  ApiResponse.m
//  Lejiayuan
//
//  Created by CaoQuan on 16/6/28.
//  Copyright © 2016年 Lejiayuan. All rights reserved.
//

#import "Joy_RequestResponse.h"

@implementation Joy_RequestResponse
+ (instancetype)responseWithObject:(id)responseObject {
	return [[self alloc] initWithData:responseObject];;
}

- (instancetype)initWithData:(id)responseObject {
	self = [super init];
	if (self) {
		self.responseObject = responseObject;
        //存储GID
	}
	
	return self;
}
@end
