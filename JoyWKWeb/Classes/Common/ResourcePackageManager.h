//
//  ResourcePackageManager.h
//  DSAppb
//
//  Created by Joymake on 2019/9/16.
//  Copyright © 2019 IB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JoyRequest/Joy_Request.h>

NS_ASSUME_NONNULL_BEGIN

@interface ResourcePackageManager : NSObject
    
@property (nonatomic,strong)NSDictionary *configDict;
+ (instancetype)shareInstance;
-(void)downLoadConfigSuccess:(VOIDBLOCK)success failure:(ERRORBLOCK)failure;
    @end

NS_ASSUME_NONNULL_END
