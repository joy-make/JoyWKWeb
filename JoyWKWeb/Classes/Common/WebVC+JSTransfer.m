//
//  WebVC+JSTransfer.m
//  DSAppb
//
//  Created by Joymake on 2019/9/27.
//  Copyright © 2019 IB. All rights reserved.
//

#import "WebVC+JSTransfer.h"

@implementation WebVC (JSTransfer)

//json转成js可执行字符串
- (NSString *)transferToJsBridgeStringWithJson:(NSString *)json methodName:(NSString *)methodName{
    NSString *JSResult = [NSString stringWithFormat:@"jsbridge('%@',%@)",methodName,json];
    return JSResult;
}

//转换对象为js可执行字符串
-(NSString *)transferToJsBridgeJSonWithObject:(NSObject *)obj methodName:(NSString *)methodName{
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:kNilOptions error:nil];// OC对象 -> JSON数据 [数据传输只能以进制流方式传输,所以传输给我们的是进制流,但是本质是JSON数据
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *JSResult = [self transferToJsBridgeStringWithJson:[NSString stringWithFormat:@"'%@'",jsonStr] methodName:methodName];
    return JSResult;
}

- (NSString *)transferToJSonWithDict:(NSObject *)obj methodName:(NSString *)methodName{
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&error];
    NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *replaceStr = [jsonStr stringByReplacingOccurrencesOfString:@"\\" withString:@"\\/"];
    replaceStr = [jsonStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *JSResult = [NSString stringWithFormat:@"%@('%@')",methodName,replaceStr];
    return JSResult;
}

-(NSString *)transferToJSObjectWithDict:(NSDictionary *)dict methodName:(NSString *)methodName{
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *replaceStr = [jsonStr stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];
    NSString *JSResult = [NSString stringWithFormat:@"%@(%@)",methodName,replaceStr];
    return JSResult;
}

- (NSObject *)convertjsonStringToObj:(NSString *)jsonString{
    NSObject *obj = nil;
    if ([jsonString isKindOfClass:[NSString class]]) {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        obj = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        return  obj;
    }else{
        return obj;
    }
}

- (NSString *)stringJSONString:(NSString *)string {
    NSMutableString *s = [NSMutableString stringWithString:string];
    [s replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}
@end
