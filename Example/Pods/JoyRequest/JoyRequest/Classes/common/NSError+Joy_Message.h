//
//  NSError+Message.h
//  smartSDK
//
//  Created by Joymake on 2018/8/18.
//

#import <Foundation/Foundation.h>

@interface NSError (Joy_Message)
@property (nonatomic, copy) NSString *message;                                //错误信息

@property (nonatomic,assign)long statusCode;

@property (nonatomic,strong)NSDictionary *responseDict;

@end
