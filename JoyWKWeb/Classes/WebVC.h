//
//  WebVC.h
//  WKWebDemo
//
//  Created by Joymake on 2019/8/14.
//  Copyright © 2019 IB. All rights reserved.
//  Web控制器,可以独立使用，也可以通过category的方式扩展js方法（调用addJsCallNativeMethods：methods注册js、并在category实现对应的method,基类会自动寻找category的js对应的实现method）

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,KURLType) {
    KURLTypeURL,        //远程url
    KURLTypeCache,      //本地缓存或本地资源
};

@interface WebVC : UIViewController
@property (nonatomic,strong,readonly)WKWebView *wkWebView;
@property (nonatomic,strong,readonly)WKUserContentController *userContentController ;
@property (nonatomic,assign) BOOL isNavHidden;                      //是否隐藏导航,默认隐藏
@property (nonatomic,assign) BOOL isNativeAlertActivate;            //是否开启原生alert
@property (nonatomic,assign) BOOL isNativeInterceptorActivate;      //是否开启url拦截
@property (nonatomic,strong)UIProgressView *progressView;           //进度条
@property (nonatomic,assign)NSURLRequestCachePolicy cachePolicy;    //缓存策略
@property (nonatomic,strong)UIButton *closeBtn;                     //暴露关闭按钮，可以自行配置🔘的图片、图片颜色、隐藏与否、点击事件等

//初始化
@property(nonatomic,readonly)WebVC  *(^initWebVC)(KURLType urlType,NSString *url);
//隐藏导航
@property(nonatomic,readonly)WebVC  *(^hiddenNav)(BOOL hiddenNav);
//配置缓存策略
@property(nonatomic,readonly)WebVC  *(^configCachePolicy)(NSURLRequestCachePolicy cachePolicy);
//是否开启url拦截功能
@property(nonatomic,readonly)WebVC  *(^InterceptorActivate)(BOOL interceptorActivate);
//添加js方法
@property(nonatomic,readonly)WebVC  *(^addJsCallNativeMethods)(NSArray *methods);
//配置关闭按钮颜色、图片
@property(nonatomic,readonly)WebVC  *(^configCloseBtn)(UIColor *color,UIImage *image);

//初始化 
- (instancetype)initWithType:(KURLType)urlType url:(NSString *)url;
    
//添加oc方法(js调用)
- (void)addJsCallNativeMethods:(NSArray *)methods;

/*注册H5按钮监听事件*/
-(void)registH5BtnObserverByElementId:(NSString *)elementId registFunction:(NSString *)func;

//设置关闭按钮的颜色
-(void)setCloseBtnColor:(UIColor *)color image:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
