# JoyWKWeb

[![CI Status](https://img.shields.io/travis/joy/JoyWKWeb.svg?style=flat)](https://travis-ci.org/joy/JoyWKWeb)
[![Version](https://img.shields.io/cocoapods/v/JoyWKWeb.svg?style=flat)](https://cocoapods.org/pods/JoyWKWeb)
[![License](https://img.shields.io/cocoapods/l/JoyWKWeb.svg?style=flat)](https://cocoapods.org/pods/JoyWKWeb)
[![Platform](https://img.shields.io/cocoapods/p/JoyWKWeb.svg?style=flat)](https://cocoapods.org/pods/JoyWKWeb)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

JoyWKWeb is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JoyWKWeb'
```

## Author
joy, wangguopeng.zh

## Description
JoyWKWeb 是基于WKWebView开发的一个的组件、提供功能如下

###### 1.快速的js注入方法,便于H5和OC进行交互、不需要实现WKWebView的代理
###### 2.二级页面自动带导航返回、关闭、刷新功能、回退到一级页面后自动隐藏
###### 3.页面悬浮关闭按钮(可自定义按钮图片和图片颜色)
###### 4.通过category可以扩展和H5交互的方法、只需要两步1.实现注册的js方法2.通过WebVC暴露的方法注册js函数即可(不需要通过wkwebview的代理去判断message name和body,WebVC已做了方法的反射)
###### 5.支持OC回调H5，提供了转换H5可执行的js转换方法，只需要传入methodName和parameter即可转换成H5可识别的标准json串.
###### 6.支持远程url、本地H5资源、远程H5的压缩包资源(自动解压加载)
###### 7.提供远程下载H5资源包的功能、以及资源包自动解压加载功能
###### 8.提供远程配置文件下载缓存功能，可以远程配置资源包下载地址、资源包版本、本地加载时会根据版本判断是否需要下载新资源包还是直接使用缓存资源包
###### 9.支持远程配置App的TabBar的各个模块、模块名、模块图片、可以远程压缩包、本地H5资源、远程H5地址、OC原生ViewController的混合加载(如本地tabbar4个tab、tab1:远程url tab2:远程下载的压缩包中的vue编译H5资源、tab3:本地项目中的html资源 tab4:原生控制器PersonalInfoViewController)
###### 10.支持HTTP、HTTPS、url重定向功能(如:设置过滤http://www.joy.com后,可以重定向此域名下访问的资源到本地资源)
###### 11.集成了一些可以被H5调用的基本的功能，如打电话、发短信、获取手机系统版本、缓存数据、获取缓存数据、清理缓存、展示/隐藏tabbar、页面回退功能

## JoyWKWeb结构
#### 1.WebVC 主要功能类可独立使用
#### 2.WebVC+JSNative.h 扩展WebVC的功能、提供一些常用的系统方法封装以及便于原生对象转换H5可执行json的函数，可独立使用
#### 3.UrlRedirectionProtocol 基于NSURLProtocol、用于配制需要拦截的域名以及拦截后相应资源的重定向
#### 4.ResourcePackageManager.h 资源配置管理器:下载url对应的app的配置文件(或手动配制configDict对象)、并根据配制文件下载对应版本的H5压缩包、H5资源包的解压
#### 5.TabBarVC 可配置的Tabbar控制器，需要配合ResourcePackageManager资源管理器远程配制tabbar上的菜单以及各菜单对应的H5URL、缓存资源、原生页面等。


## 具体使用方法，待补充
```
  WebVC *vc; //WebVC 初始化类型 KURLTypeURL/KURLTypeCache
  vc = [[WebVC alloc]initWithType:KURLTypeURL url:h5Path];     //加载远程url
  vc = [[WebVC alloc]initWithType:KURLTypeCache url:htmlPath]; //加载缓存地址
  [vc addJsCallNativeMethods:[NSSet setWithArray:@[@"jsGetUserInfo",@"jsGetToken",@"jsSystemVersion",@"jsCallPhone"]]]; //注册和H5协定的js函数
  [vc setCloseBtnColor:[UIColor orangeColor] image:nil];   //设置悬浮关闭按钮图片及图片的颜色
  [self.navigationController pushViewController:vc animated:true];
```

### 实注册的js方法
```
extern const BOOL JS_Call_Method_IsBuild;

@interface WebVC (JSNative)

@end

@implementation WebVC (JSNative)
#pragma 打电话
- (void)jsCallPhone:(NSString *)phone{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phone]];
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:url]];
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

    //methodName:jsSystemVersion为H5中监听的js函数
    NSString *JSResult = JS_Call_Method_IsBuild?[self transferToJsBridgeJSonWithObject:jsDict methodName:@"jsSystemVersion"]:[NSString stringWithFormat:@"jsSystemVersionResult('%@')",phoneVersion];
    [self.wkWebView evaluateJavaScript:JSResult completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}
```

### H5中的js函数
```
//唤起电话
function jsCallPhone(){
    //android
    if  (checkIsAndroidType()){
        window.MainJsInterface.jsCallPhone("18666666666");
    }else {
    //ios
        window.webkit.messageHandlers.jsCallPhone.postMessage("18666666666");
    }
}

//获取系统版本
function jsSystemVersion(){
    if(checkIsAndroidType()){
        window.MainJsInterface.jsSystemVersion();
    }else {
        window.webkit.messageHandlers.jsSystemVersion.postMessage(null);
    }
}

//监听原生获取系统版本回调函数
document.addEventListener("jsSystemVersion", function(evt) {
    var content = "系统版本" + evt.detail["body"]["value"];
	alert(content);
});

//检查app系统
function checkIsAndroidType(){
    var u = navigator.userAgent;
    var isAndroid = u.indexOf('Android') > -1 || u.indexOf('Adr') > -1; //android终端
    var isiOS = !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/); //ios终端
    if    (isAndroid == true){
        return true
    }else if(isiOS == true){
        return false
    }
}
```


## License

JoyWKWeb is available under the MIT license. See the LICENSE file for more info.
