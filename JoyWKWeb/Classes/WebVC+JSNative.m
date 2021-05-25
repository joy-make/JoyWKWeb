//
//  WebVC+JSNative.m
//  WKWebDemo
//
//  Created by Joymake on 2019/8/14.
//  Copyright © 2019 IB. All rights reserved.
//

#import "WebVC+JSNative.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import <JoyRequest/Joy_NetCacheTool.h>

#ifdef RELEASE
#define ENVSTR @"2"
#elif UAT
#define ENVSTR @"1"
#elif SIT
#define ENVSTR @"0"
#endif

extern const BOOL JS_Call_Method_IsBuild;
@interface WebVC() <MFMessageComposeViewControllerDelegate>

@end

@implementation WebVC (JSNative)

#pragma 获取app运行环境
- (void)jsGetAppEnv:(NSString *)env{
    NSDictionary *jsDict = @{
        @"status":@"0",
        @"description":@"app运行环境",
        @"body":@{
                @"value":@"Debug"}
    };

    NSString *JSResult = JS_Call_Method_IsBuild?[self transferToJsBridgeJSonWithObject:jsDict methodName:@"jsGetAppEnv"]:[NSString stringWithFormat:@"jsGetAppEnvResult(%@)",@"Debug"];
    //OC调用JS
    [self.wkWebView evaluateJavaScript:JSResult completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}

- (void)jsClearCache:(id)obj{
    if ([[[UIDevice currentDevice]systemVersion]intValue ] >= 9.0) {
           NSArray * types =@[WKWebsiteDataTypeMemoryCache,WKWebsiteDataTypeDiskCache]; // 9.0之后才有的
           NSSet *websiteDataTypes = [NSSet setWithArray:types];
           NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
           [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
           }];
       }else{
           NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES) objectAtIndex:0];
           NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
           NSLog(@"%@", cookiesFolderPath);
           NSError *errors;
           [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
       }
}

#pragma 调用app分享
//- (void)jsShare:(NSDictionary *)dic{
//    if (![dic isKindOfClass:[NSDictionary class]]) {return;}
//    //OC反馈给JS分享结果
//    NSString *JSResult = [self transferToJSObjectWithDict:dic methodName:@"jsShareResult"];
//    [self.wkWebView evaluateJavaScript:JSResult completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//        NSLog(@"%@", error);
//    }];
//}

- (void)jsShare:(NSString *)json{
    NSDictionary *jsonDict = (NSDictionary*)[self convertjsonStringToObj:json];
    NSString *JSResult = JS_Call_Method_IsBuild?[self transferToJsBridgeJSonWithObject:jsonDict methodName:@"jsShare"]:[self transferToJSonWithDict:jsonDict methodName:@"jsShareResult"];
    [self.wkWebView evaluateJavaScript:JSResult completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}

#pragma 打电话
- (void)jsCallPhone:(NSString *)phone{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phone]];
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma 发短信
- (void)jsCallSms:(NSDictionary *)sms{
    MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
    // 设置短信内容
    vc.body = [sms objectForKey:@"content"];
    vc.messageComposeDelegate = self;
    [[[[vc viewControllers] lastObject] navigationItem] setTitle:[sms objectForKey:@"title"]?:@"短信"];//修改短信界面标题
    [[[[vc viewControllers] lastObject] navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancleAction)]];
    if(vc){
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)cancleAction{
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if (self.navigationController){
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

//短信发送成功后的回调
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    // 关闭短信界面
    [controller dismissViewControllerAnimated:YES completion:nil];
    if(result == MessageComposeResultCancelled) {
        NSLog(@"取消发送");
    } else if(result == MessageComposeResultSent) {
        NSLog(@"已经发出");
    } else {
        NSLog(@"发送失败");
    }
}

#pragma mark alert是否开启
-(void)jsEnableOrDisableAlert:(NSString *)alert{
    [self.wkWebView setUIDelegate: [alert isEqualToString:@"1"]?self:nil];
}

#pragma 模拟bottom点击
- (void)jsBottomClick:(NSString *)index{
    UITabBarController *tabBar = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if ([tabBar isKindOfClass:UITabBarController.class]) {
        tabBar.selectedIndex = [index integerValue];
    }
}

#pragma 隐藏tabbar
- (void)jsHideTabBar:(NSString *)str{
    self.tabBarController.tabBar.hidden = true;
    self.navigationController.navigationBarHidden = true;
    self.wkWebView.frame = [UIScreen mainScreen].bounds;
}

#pragma 展示tabbar
- (void)jsShowTabBar:(NSString *)str{
    self.tabBarController.tabBar.hidden = false;
    self.navigationController.navigationBarHidden = false;
    self.wkWebView.frame =self.view.bounds;
}

#pragma 获取手机系统版本
- (void)jsSystemVersion:(id)obj{
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    NSDictionary *jsDict = @{
        @"status":@"0",
        @"description":@"手机系统版本",
        @"body":@{
                @"value":phoneVersion}
    };

    NSString *JSResult = JS_Call_Method_IsBuild?[self transferToJsBridgeJSonWithObject:jsDict methodName:@"jsSystemVersion"]:[NSString stringWithFormat:@"jsSystemVersionResult('%@')",phoneVersion];
    [self.wkWebView evaluateJavaScript:JSResult completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}

#pragma 清理缓存
-(void)jsClearCache{
    
}

#pragma mark 存json
- (void)jsSaveToCacheWithKeyValue:(NSString *)json{
    NSDictionary *dict = (NSDictionary *)[self convertjsonStringToObj:json];
    if ([dict isKindOfClass:NSDictionary.class]) {
        if (dict.count) {
            [Joy_NetCacheTool scbuCacheString:json forKey:dict.allKeys.firstObject];
        }
    }
}

- (void)jsGetCacheForKey:(NSString *)key{
    NSString *json = [Joy_NetCacheTool scbuStringCacheForKey:key];
    NSString *JSResult = JS_Call_Method_IsBuild?[self transferToJsBridgeJSonWithObject:json methodName:@"jsGetCacheForKey"]:[NSString stringWithFormat:@"jsGetCacheResult('%@')",json];
    [self.wkWebView evaluateJavaScript:JSResult completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}

- (void)jsClearCacheForKey:(NSString *)key{
    [Joy_NetCacheTool scbuRemoveCacheForKey:key];
}

@end

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

@implementation WebVC (FiltUrl)

-(void)filtHTTP{
    Class cls = NSClassFromString(@"WKBrowsingContextController");
    SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
    if ([(id)cls respondsToSelector:sel]) {
        [(id)cls performSelector:sel withObject:@"http"];
        [(id)cls performSelector:sel withObject:@"https"];
    }
}

@end
