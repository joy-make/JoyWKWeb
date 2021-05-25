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

-(void)registOCMethods:(NSSet *)methods{
    for (NSString *method in methods) {
        [self.userContentController addScriptMessageHandler:self name:method];
    }
}

- (void)removeOCMethods:(NSSet *)methods{
    for (NSString *method in methods) {
        [self.userContentController removeScriptMessageHandlerForName:method];
    }
}

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
