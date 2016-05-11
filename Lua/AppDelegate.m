//
//  AppDelegate.m
//  Lua
//
//  Created by Dakezuo on 16/5/9.
//  Copyright © 2016年 dianhun. All rights reserved.
//

#import "AppDelegate.h"
#import "lauxlib.h"
#import "wax.h"
#import "ZipArchive.h"
#import "ViewController.h"

#define WAX_PATCH_URL @"https://raw.githubusercontent.com/dakezuo/LUATest/master/patch/patch.zip"

@interface AppDelegate ()<NSURLConnectionDelegate>
/** 进度条属性*/
@property (nonatomic, strong) UIProgressView *progressView;
/** 文件总大小 */
@property (nonatomic, assign) NSUInteger totalLength;
/** 文件当前大小 */
@property (nonatomic, assign) NSUInteger currentLength;

@property (nonatomic, strong) UIView *alertView;

@property (nonatomic, strong) NSMutableData *data;

@end

@implementation AppDelegate
@synthesize window = _window;

- (id)init {
    if(self = [super init]) {
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *dir = [doc stringByAppendingPathComponent:@"lua"];
        [[NSFileManager defaultManager] removeItemAtPath:dir error:NULL];
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
        
        NSString *pp = [[NSString alloc ] initWithFormat:@"%@/?.lua;%@/?/init.lua;", dir, dir];
        setenv(LUA_PATH, [pp UTF8String], 1);
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ViewController *myView = [story instantiateViewControllerWithIdentifier:@"ViewController"];
    self.window.rootViewController = myView;
    [self.window makeKeyAndVisible];
    
     [[[UIAlertView alloc] initWithTitle:nil message:@"有新的内容,点击立即更新" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"确定"]) {
        NSLog(@"111");
        // you probably want to change this url before run
        NSURL *patchUrl = [NSURL URLWithString:WAX_PATCH_URL];
        //2、创建请求对象
        NSURLRequest *request = [NSURLRequest requestWithURL:patchUrl];
        //3、代理请求
        /*
         第一个参数:请求对象
         第二个参数:谁成为代理
         第三个参数:startImmediately :是否立即开始发送网络请求
         */
        NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:NO];
        [connection start];
        
        
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressView.frame = CGRectMake(15, 30, 200, 30);
        self.progressView.progressTintColor = [UIColor orangeColor];
        self.progressView.progress = 0.01;
       
        self.alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 230, 60)];
        self.alertView.center = self.window.center;
        self.alertView.layer.cornerRadius = 6.0f;
        self.alertView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 230, 30)];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.text = @"正在更新,请稍候";
        lable.textColor = [UIColor whiteColor];
        [self.alertView addSubview:lable];
        [self.alertView addSubview:self.progressView];
        [self.window.rootViewController.view addSubview:self.alertView];
        
        /*
        NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:patchUrl] returningResponse:NULL error:NULL];
        if(data) {
            NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString *patchZip = [doc stringByAppendingPathComponent:@"patch.zip"];
            [data writeToFile:patchZip atomically:YES];
            
            NSString *dir = [doc stringByAppendingPathComponent:@"lua"];
            [[NSFileManager defaultManager] removeItemAtPath:dir error:NULL];
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
            
            ZipArchive *zip = [[ZipArchive alloc] init];
            [zip UnzipOpenFile:patchZip];
            [zip UnzipFileTo:dir overWrite:YES];
            
            NSString *pp = [[NSString alloc ] initWithFormat:@"%@/?.lua;%@/?/init.lua;", dir, dir];
            setenv(LUA_PATH, [pp UTF8String], 1);
            wax_start("patch", nil);
            
            // reinit MainViewController again
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            ViewController *myView = [story instantiateViewControllerWithIdentifier:@"ViewController"];
            self.window.rootViewController = myView;
            [self.window makeKeyAndVisible];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"更新失败 "] delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil] show];
        }
        */
    }
}

//1.当接受到服务器响应的时候会调用:response(响应头)
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"接受到响应");
    
    //1、在响应头中有一个预估的文件大小expectedContentLength
    self.totalLength = response.expectedContentLength;
    //这里你们可以打印看看   然后在网页的请求头也可以去对比一下，看是否为一样
    //    NSLog(@"totalLength = %lld", response.expectedContentLength);
    self.data = [[NSMutableData alloc] init];
}
//2.当接受到服务器返回数据的时候调用(会调用多次)
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData: data];
    // 1、计算当前接收到得数据的总数  这里就是记录每一次写入数据的多少
    self.currentLength += data.length;
    // 2、计算下载比例
    //self.progressView.progress = 1.0 * self.currentLength/self.totalLength;
    float progress = (float)self.currentLength/self.totalLength;
    NSNumber* progressNumber = [NSNumber numberWithFloat:progress];
    [self.progressView setProgress:[progressNumber floatValue] animated:NO];
    /*
    dispatch_async(dispatch_get_main_queue(),^{
        NSLog(@"131");
       [self.progressView setProgress:[progressNumber floatValue] animated:YES];
        if ([progressNumber floatValue] == 1) {
             //[self.alertView removeFromSuperview];
        }
    });
     */
}
//3.当请求失败的时候调用
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"请求失败");
    [self.alertView removeFromSuperview];
    [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"更新失败 "] delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil] show];
}
//4.当请求结束(成功|失败)的时候调用
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"请求结束");
   //[self.alertView removeFromSuperview];
    if(self.data) {
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *patchZip = [doc stringByAppendingPathComponent:@"patch.zip"];
        [self.data writeToFile:patchZip atomically:YES];
        
        NSString *dir = [doc stringByAppendingPathComponent:@"lua"];
        [[NSFileManager defaultManager] removeItemAtPath:dir error:NULL];
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
        
        ZipArchive *zip = [[ZipArchive alloc] init];
        [zip UnzipOpenFile:patchZip];
        [zip UnzipFileTo:dir overWrite:YES];
        
        NSString *pp = [[NSString alloc ] initWithFormat:@"%@/?.lua;%@/?/init.lua;", dir, dir];
        setenv(LUA_PATH, [pp UTF8String], 1);
        wax_start("patch", nil);
        
        // reinit MainViewController again
        [self performSelector:@selector(hide) withObject:nil afterDelay:1];
//        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//        ViewController *myView = [story instantiateViewControllerWithIdentifier:@"ViewController"];
//        self.window.rootViewController = myView;
//        [self.window makeKeyAndVisible];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"更新失败 "] delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil] show];
    }
}

- (void)hide
{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ViewController *myView = [story instantiateViewControllerWithIdentifier:@"ViewController"];
    self.window.rootViewController = myView;
    [self.window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
