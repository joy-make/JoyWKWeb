//
//  WebVC.m
//  WKWebDemo
//
//  Created by Joymake on 2019/8/14.
//  Copyright © 2019 IB. All rights reserved.
//

#import "WebVC.h"
#import "UrlRedirectionProtocol.h"
#import "WebVC+JSNative.h"
#import "JHUD.h"

const BOOL JS_Call_Method_IsBuild = true;

@interface WebVC()<WKUIDelegate,WKScriptMessageHandler,WKNavigationDelegate>
@property (nonatomic,strong)WKWebView *wkWebView;
@property (nonatomic,strong)WKWebViewConfiguration *configuration;
@property (nonatomic,strong)WKPreferences *preferences;
@property (nonatomic,strong)WKUserContentController *userContentController ;
@property (nonatomic,copy)NSMutableSet<NSString *> *calledByJSMethodSet;
@property (nonatomic)UIBarButtonItem* backItem;         //返回按钮
@property (nonatomic)UIBarButtonItem* closeButtonItem;  //关闭当前页按钮
@property (nonatomic)UIBarButtonItem* rightButtonItem;  //右刷新按钮
@property (nonatomic,assign)KURLType urlType;           //url类型
@property (nonatomic,copy)NSString *url;                //url
@property (nonatomic,copy)JHUD *hud;                //url

@end

@implementation WebVC
-(WKUserContentController *)userContentController{
    return _userContentController = _userContentController?:[WKUserContentController new];
}

-(WKWebViewConfiguration *)configuration{
    if (!_configuration) {
        _configuration = [WKWebViewConfiguration new];
        _configuration.userContentController = self.userContentController;
        _configuration.preferences = self.preferences;
    }
    return _configuration;
}

-(WKPreferences *)preferences{
    if (!_preferences) {
        _preferences = [WKPreferences new];
        _preferences.javaScriptCanOpenWindowsAutomatically = YES;
    }
    return _preferences;
}
    
static void *WkwebBrowserContext = &WkwebBrowserContext;
-(WKWebView *)wkWebView{
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc]initWithFrame:self.view.bounds configuration:self.configuration];
        //开启手势触摸
        _wkWebView.allowsBackForwardNavigationGestures = YES;
        [_wkWebView sizeToFit];
        [_wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:WkwebBrowserContext];
        _wkWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    }
    return _wkWebView;
}
- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        if (_isNavHidden == YES) {
            _progressView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 3);
        }else{
            CGFloat navigationBarBottom = self.navigationController.navigationBar.bounds.size.height+self.navigationController.navigationBar.frame.origin.y;
            _progressView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 3);
        }
        // 设置进度条的色彩
        [_progressView setTrackTintColor:[UIColor whiteColor]];
        _progressView.progressTintColor = [UIColor orangeColor];
    }
    return _progressView;
}

-(JHUD *)hud{
    if (!_hud) {
        _hud = [[JHUD alloc]initWithFrame:self.wkWebView.bounds];
//        _hud.indicatorBackGroundColor = [UIColor colorWithWhite:1 alpha:1];
        _hud.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    }
    return _hud;
}

-(UIBarButtonItem*)backItem{
    return _backItem = _backItem?: [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(customBackItemClicked)];
}

-(UIBarButtonItem*)closeButtonItem{
    return _closeButtonItem = _closeButtonItem?:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeItemClicked)];
}

-(UIBarButtonItem*)rightButtonItem{
    return _rightButtonItem = _rightButtonItem?:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(roadLoadClicked)];
}

-(NSMutableSet<NSString *> *)calledByJSMethodSet{
    return _calledByJSMethodSet = _calledByJSMethodSet?:[NSMutableSet setWithArray:@[@"jsShare",@"jsSelectPhoto",@"jsGetAppEnv",@"jsBottomClick",@"jsHideTabBar",@"jsShowTabBar",@"jsCallPhone",@"jsSystemVersion",@"jsUserInfo",@"jsClearCache",@"jsCallSms",@"jsSaveToken",@"jsGetToken",@"jsEnableOrDisableAlert",@"jsSaveToCacheWithKeyValue",@"jsGetCacheForKey",@"jsClearCacheForKey",@"jsClearCache"]];
}

-(void)dealloc{
    [self.wkWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeOCMethods:self.calledByJSMethodSet];
    [self.wkWebView setNavigationDelegate:nil];
    [self.wkWebView setUIDelegate:nil];
    [NSURLProtocol unregisterClass:[UrlRedirectionProtocol class]];
}

-(void)viewWillAppear:(BOOL)animated{
    if(self.isNativeInterceptorActivate)//如果开启url拦截
    [NSURLProtocol registerClass:[UrlRedirectionProtocol class]];
    [self.wkWebView setNavigationDelegate:self];
    self.isNativeAlertActivate?[self.wkWebView setUIDelegate:self]:nil;
    [self registOCMethods:self.calledByJSMethodSet];
}

-(instancetype)initWithType:(KURLType)urlType url:(NSString *)url{
    if (self = [super init]) {
        self.urlType = urlType;
        self.url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.wkWebView];
    [self setNavItems];
    [self.hud showAtView:self.wkWebView hudType:JHUDLoadingTypeCircleJoin];
    //是否拦截http的url
    self.isNativeInterceptorActivate?[self filtHTTP]:nil;
    self.urlType == KURLTypeCache?[self loadLocalHTML]:[self loadHTML];
}

- (void)setNavItems{
    //原生导航是否启用
    if(!self.isNavHidden){
        self.navigationItem.rightBarButtonItem = self.rightButtonItem;
//        self.navigationItem.leftBarButtonItem = self.backItem;
        [self.view addSubview:self.progressView];
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = false;
    }
}

#pragma mark 加载本地H5
- (void)loadLocalHTML{
    //本地资源
    NSString *fileURL = [NSString stringWithContentsOfFile:self.url encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = self.url?[NSURL fileURLWithPath:self.url]:nil;
    if (fileURL && baseURL) {
        [self.wkWebView loadHTMLString:fileURL baseURL:baseURL];
    }
}

#pragma mark 加载远程H5
- (void)loadHTML {
    //    [self clearBrowserCache];
    __weak __typeof(&*self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        NSURL *url=[NSURL URLWithString:self.url];
        NSURLCache *urlCache = [NSURLCache sharedURLCache];
        [urlCache setMemoryCapacity:1*1024*1024];
        NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:self.cachePolicy timeoutInterval:20.0];
        [strongSelf.wkWebView loadRequest: request];
    });
}
    
-(void)addJsCallNativeMethods:(NSSet *)methods{
    [self.calledByJSMethodSet setByAddingObjectsFromSet:methods];
}

//统一注册所有的js方法
-(void)registOCMethods:(NSSet *)methods{
    for (NSString *method in methods) {
        [self.userContentController addScriptMessageHandler:self name:method];
    }
}

//统一移除所有的js方法
- (void)removeOCMethods:(NSSet *)methods{
    for (NSString *method in methods) {
        [self.userContentController removeScriptMessageHandlerForName:method];
    }
}

-(void)customBackItemClicked{
    self.wkWebView.canGoBack?self.wkWebView.goBack:[self.navigationController popViewControllerAnimated:YES];
}

-(void)closeItemClicked{
    if (self.navigationController.viewControllers.count>1){
        [self.navigationController popViewControllerAnimated:YES];
    }else if (self.wkWebView.canGoBack){
        [self.wkWebView goToBackForwardListItem:self.wkWebView.backForwardList.backList.firstObject];
    }
}

- (void)roadLoadClicked{
    [self.wkWebView reload];
}

-(void)updateNavigationItems{
    if (self.wkWebView.canGoBack) {
        [self.navigationItem setLeftBarButtonItems:@[self.backItem,self.closeButtonItem] animated:NO];
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        [self.navigationItem setLeftBarButtonItems:nil];
    }
}

- (void)clearBrowserCache {
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        }];
    });
}

#pragma mark WKNavigationDelegate
//这个是网页加载完成，导航的变化
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
 /*主意：这个方法是当网页的内容全部显示（网页内的所有图片必须都正常显示）的时候调用(不是出现的时候就调用)否则不显示，或则部分显示时这个方法就不调用。*/
    // 获取加载网页的标题
//    if (self.wkWebView.title.length) {
//        self.title = self.wkWebView.title;
//    }
    [self.hud hide];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateNavigationItems];
    NSString *doc = @"document.body.outerHTML";
    [webView evaluateJavaScript:doc
              completionHandler:^(id _Nullable htmlStr, NSError * _Nullable error) {
        if (error) {
          NSLog(@"JSError:%@",error);
        }
        NSLog(@"html:%@",htmlStr);
    }] ;
}

#pragma mark 开始加载
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    //开始加载的时候，让加载进度条显示
    self.progressView.hidden = NO;
    [self.hud showAtView:webView hudType:JHUDLoadingTypeCircleJoin];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

#pragma mark 内容返回时调用
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    [self.hud hide];
}

#pragma mark 服务器请求跳转的时候调用
-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
}

#pragma mark 服务器开始请求的时候调用,根据navigationAction里的信息确定是否允许
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    [self updateNavigationItems];
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark 内容加载失败时候调用
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"页面加载超时");
    [self.hud hide];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark 跳转失败的时候调用
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [self.hud hide];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark 进度条
-(void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
}

#pragma mark - WKUIDelegate
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

#pragma mark 交互。可输入的文本。
-(void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        sleep(3);
//        completionHandler(@"fefewwwwg");
//    });
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:prompt message:defaultText preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor redColor];
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

#pragma mark KVO监听进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.wkWebView) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.wkWebView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.wkWebView.estimatedProgress animated:animated];
        // Once complete, fade out UIProgressView
        if(self.wkWebView.estimatedProgress >= 1.0f) {
            __weak __typeof(&*self)weakSelf =self;
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                __strong __typeof(&*weakSelf)strongSelf =weakSelf;
                [strongSelf.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                __strong __typeof(&*weakSelf)strongSelf =weakSelf;
                [strongSelf.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -- WKScriptMessageHandler
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    SEL selector = NSSelectorFromString([message.name stringByAppendingString:@":"]);
    IMP imp = [self methodForSelector:selector];
    void (*func)(id, SEL,id) = (void *)imp;
    BOOL result = NO;
    if ([self respondsToSelector:selector]) {
        func(self, selector,message.body);
        result = YES;
    }
//    self.hud.messageLabel.text = [NSString stringWithFormat:@"函数名:%@\n参数:%@\n结果:%s",message.name,message.body,result?"":"方法未找到"];
//    [self.hud showAtView:self.wkWebView hudType:JHUDLoadingTypeFailure];
//    [self.hud hideAfterDelay:2];
}

@end
