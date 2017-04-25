//
//  ViewController.m
//  wkwebview
//
//  Created by 泛在吕俊衡 on 17/1/4.
//  Copyright © 2017年 anjohnlv. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "ViewController1.h"
@interface ViewController ()<WKScriptMessageHandler,WKNavigationDelegate,WKUIDelegate>
//webView
@property(nonatomic,strong)WKWebView *webView;
@property(nonatomic,strong)WKWebView *webView1;

@end

@implementation ViewController
-(void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"loading"];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatWebView];
}

//创建webView
-(void)creatWebView{
//    WKWebVIew是UIWebView的代替品，新的WebKit框架把原来的功能拆分成许多小类。本例中主要用到了WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler三个委托和配置类WKWebViewConfiguration去实现webView的request控制，界面控制，js交互，alert重写等功能。 使用WKWebView需要引入#import <WebKit/WebKit.h>
//    配置
    self.navigationController.navigationBar.translucent=NO;
    self.view.backgroundColor=[UIColor yellowColor];
    
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    
    config.preferences.minimumFontSize = 10;

    self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-364) configuration:config];
    
    NSURL *url=[NSURL URLWithString:@"http://www.jianshu.com"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:self.webView];
//    self.webView.navigationDelegate = self;
//    self.webView.UIDelegate = self;
    //允许手势，后退前进等操作
    self.webView.allowsBackForwardNavigationGestures = true;
    //监听是否可以前进后退，修改btn.enable属性

    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
     //监听加载进度
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    self.webView1 = [[WKWebView alloc]initWithFrame:CGRectMake(0, 340, self.view.bounds.size.width, 200) configuration:config];
    WKUserContentController *userCC = config.userContentController;
    //JS调用OC 添加处理脚本（注入JS脚本）
    [userCC addScriptMessageHandler:self name:@"showMobile"];
    [userCC addScriptMessageHandler:self name:@"showName"];
    [userCC addScriptMessageHandler:self name:@"showSendMsg"];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL *baseURL = [[NSBundle mainBundle] bundleURL];
    [self.webView1 loadHTMLString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] baseURL:baseURL];
    self.webView1.navigationDelegate=self;
    self.webView1.UIDelegate=self;
    [self.view addSubview:self.webView1];
   
    
    UIButton * btn=[[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.webView1.frame)+5, 100, 40)];
    btn.backgroundColor=[UIColor greenColor];
    [btn setTitle:@"OC调用JS" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
   [self.view addSubview:btn];
    
    
    
}
-(void)btnClick
{
//    [self.webView1 evaluateJavaScript:@"alertMobile()" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
////        TODO
//        NSLog(@"%@ %@",response,error);
//    }];
    [self.webView1 evaluateJavaScript:@"alertSendMsg('18870707070','周末爬山真是件愉快的事情')" completionHandler:nil];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"loading"]) {

    }
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSLog(@"estimatedProgress:%f",self.webView.estimatedProgress);
    }
}
#pragma mark - WKScriptMessageHandler
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
   //JS调用OC方法；
    if ([message.name isEqualToString:@"showMobile"]) {
        [self showMsg:@"我是下面的小红 手机号是:18870707070"];
    }
    
    if ([message.name isEqualToString:@"showName"]) {
        NSString *info = [NSString stringWithFormat:@"你好 %@, 很高兴见到你",message.body];
        [self showMsg:info];
    }
    
    if ([message.name isEqualToString:@"showSendMsg"]) {
        NSArray *array = message.body;
        NSString *info = [NSString stringWithFormat:@"这是我的手机号: %@, %@ !!",array.firstObject,array.lastObject];
        [self showMsg:info];
    }

}
- (void)showMsg:(NSString *)msg {
    [[[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
    
}
#pragma mark = WKNavigationDelegate
// 决定导航的动作，通常用于处理跨域的链接能否导航。WebKit对跨域进行了安全检查限制，不允许跨域，因此我们要对不能跨域的链接 单独处理。但是，对于Safari是允许跨域的，不用这么处理。
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{

//   重定向  1

    decisionHandler(WKNavigationActionPolicyAllow);

}

//在响应完成时，调用的方法。如果设置为不允许响应，web内容就不会传过来
-(void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    decisionHandler(WKNavigationResponsePolicyAllow);
     self.navigationItem.title=webView.title;
    //3
}

//接收到服务器跳转请求之后调用当main frame接收到服务重定向时，会回调此方法

-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    
}

//开始加载时调用当main frame的导航开始请求时，会调用此方法
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    //2
}


//当内容开始返回时调用当main frame的web内容开始到达时，会回调
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    //4
}

//页面加载完成之后调用
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
 
}
// 页面加载失败时调用当main frame开始加载数据失败时，会回调
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
{
    
}
//当main frame最后下载数据失败时，会回调
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    
}
//这与用于授权验证的API，与AFN、UIWebView的授权验证API是一样的
//-(void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
//{
//}
-(void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
//    iOS 9以后 WKNavigtionDelegate 新增了一个回调函数：
//    当 WKWebView 总体内存占用过大，页面即将白屏的时候，系统会调用上面的回调函数，我们在该函数里执行[webView reload](这个时候 webView.URL 取值尚不为 nil）解决白屏问题。在一些高内存消耗的页面可能会频繁刷新当前页面，H5侧也要做相应的适配操作。
//    并不是所有H5页面白屏的时候都会调用上面的回调函数，比如，最近遇到在一个高内存消耗的H5页面上 present 系统相机，拍照完毕后返回原来页面的时候出现白屏现象（拍照过程消耗了大量内存，导致内存紧张，WebContent Process 被系统挂起），但上面的回调函数并没有被调用。在WKWebView白屏的时候，另一种现象是 webView.titile 会被置空, 因此，可以在 viewWillAppear 的时候检测 webView.title 是否为空来 reload 页面。
}
#pragma mark WKUIDelegate
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    completionHandler();
    NSLog(@"%@",message);
    //1
//    UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
//    
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//
//    [alert addAction:cancelAction];
//    [alert addAction:okAction];
//    [self presentViewController:alert animated:YES completion:nil];

    //2
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"文本对话框" message:@"登录和密码对话框示例" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"登录";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"密码";
        textField.secureTextEntry = YES;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *login = alertController.textFields.firstObject;
        UITextField *password = alertController.textFields.lastObject;

    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    //3
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"保存或删除数据" message:@"删除数据将不可恢复" preferredStyle: UIAlertControllerStyleActionSheet];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:nil];
//    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:nil];
//    [alertController addAction:cancelAction];
//    [alertController addAction:deleteAction];
//    [alertController addAction:archiveAction];
//    [self presentViewController:alertController animated:YES completion:nil];
//    
    
//    UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"ios-alert"message:message delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
//    [alert show];
   
  
}
-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
   
  
//    UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"ios-alert"message:message delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
//    [alert show];
   
   
}
-(void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBack:(id)sender {
    NSLog(@"%@",self.webView.backForwardList);
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
}
- (IBAction)test:(id)sender {
    ViewController1* VC=[ViewController1 new];
    [self.navigationController pushViewController:VC animated:NO];
}

@end
