//
//  WebVC+JSTransfer.h
//  DSAppb
//
//  Created by Joymake on 2019/9/27.
//  Copyright © 2019 IB. All rights reserved.
//


#import "WebVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebVC (JSTransfer)

//转换对象为js可执行字符串
-(NSString *)transferToJsBridgeJSonWithObject:(NSObject *)obj methodName:(NSString *)methodName;

//转换对象为js可执行对象
- (NSString *)transferToJSObjectWithDict:(NSDictionary *)dict methodName:(NSString *)methodName;

//转换对象为js json字符串
- (NSString *)transferToJSonWithDict:(NSObject *)obj methodName:(NSString *)methodName;

- (NSObject *)convertjsonStringToObj:(NSString *)jsonString;
@end

NS_ASSUME_NONNULL_END
