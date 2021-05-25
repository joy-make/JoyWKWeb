//
//  TabBarVC.m
//  WKWebDemo
//
//  Created by Joymake on 2019/8/30.
//  Copyright © 2019 IB. All rights reserved.
//

#import "TabBarVC.h"
#import "WebVC.h"
#import "ResourcePackageManager.h"
#import "UrlRedirectionProtocol.h"

@implementation TabBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.translucent = NO;
    [self configTabbarItem];
}
    
- (void)configTabbarItem{
    NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"appConfig" ofType:@"json"]];

    NSDictionary *localConfigDict = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];

    NSDictionary *configDict = [ResourcePackageManager shareInstance].configDict?:localConfigDict?:nil;
    
    for (NSDictionary *dict in [configDict objectForKey:@"items"]) {
        NSString *title = [dict objectForKey:@"title"];
        NSString *icon = [dict objectForKey:@"icon"];
        NSString *h5Path = [dict objectForKey:@"h5Path"];
        NSString *module = [dict objectForKey:@"module"];
        NSString *htmlPath = [[UrlRedirectionProtocol getCachePath] stringByAppendingString:h5Path];
        
        NSString *h5Type = [dict objectForKey:@"type"];
        WebVC *vc;
        if ([h5Type isEqualToString:@"remote"]) {
            vc = [[WebVC alloc]initWithType:KURLTypeURL url:h5Path];
        }else if([h5Type isEqualToString:@"zip"]){
            vc = [[WebVC alloc]initWithType:KURLTypeCache url:htmlPath];
        }else if([h5Type isEqualToString:@"resource"]){
            NSString *url = [[NSBundle mainBundle]pathForResource:@"home" ofType:@"html"];
            vc = [[WebVC alloc]initWithType:KURLTypeCache url:url];
        }
        else if([h5Type isEqualToString:@"native"]){
            Class NativeClass = NSClassFromString(module);
            vc = [[NativeClass alloc]init];
        }
        if ([vc isKindOfClass:WebVC.class]) {
            vc.isNativeInterceptorActivate = true;
            vc.isNativeAlertActivate = true;
        }
        
        if(vc){
        //    增加自己要拦截的域名
        //    [[UrlFiltManager shareInstance]configUrlFilt:@[@"http://127.0.0.1:8000/",@"http://www.joy.com/"]];
        vc.tabBarItem = [[UITabBarItem alloc]initWithTitle:title image:[UIImage imageNamed:icon] tag:0];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
        nav.navigationBar.translucent = false;
        [self addChildViewController:vc];
        }
    }
}

+ (UIImage *)barItemImage:(NSString *)imageUrl{
    NSArray *stringArr = [imageUrl componentsSeparatedByString:@"/"];
    NSString *imageName = stringArr.lastObject;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    UIImage *image = [UIImage imageWithData:data];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
    // 判断文件是否已存在，存在，删除原文件
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    // 将image写入沙盒
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    return [UIImage imageWithContentsOfFile:filePath];
}

@end
