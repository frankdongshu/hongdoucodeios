//
//  AppDelegate.m
//  婚恋网
//
//  Created by iMac on 2019/2/28.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "AppDelegate.h"
#import <MOBFoundation/MobSDK+Privacy.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>

#import <XHLaunchAd.h>
#import <UserNotifications/UserNotifications.h>
#import "GDTSplashAd.h"

#import "GDTSDKConfig.h"
#import "AvoidCrash.h"
@interface AppDelegate ()<JPUSHRegisterDelegate,GDTSplashAdDelegate>
@property (nonatomic, strong) GDTSplashAd *splashAd;
@property (retain, nonatomic) UIView *bottomView;
@end

@implementation AppDelegate
/**
 *  开屏广告成功展示
 */
- (void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd {
    NSLog(@"~~开屏广告成功展示");
}

/**
 *  开屏广告素材加载成功
 */
- (void)splashAdDidLoad:(GDTSplashAd *)splashAd {
    NSLog(@"~~开屏广告素材加载成功");
    
    [self.splashAd showAdInWindow:self.window withBottomView:self.bottomView skipView:nil];
    
}

/**
 *  开屏广告展示失败
 */
- (void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error {
    NSLog(@"~!@!~开屏广告展示失败:%@",error);
    
    if (error.code == 5004) {
        [splashAd loadAd];
    }
    
}
/**
 *  开屏广告曝光回调
 */
- (void)splashAdExposured:(GDTSplashAd *)splashAd {
    NSLog(@"~~开屏广告曝光回调");
}

/**
 *  开屏广告点击回调
 */
- (void)splashAdClicked:(GDTSplashAd *)splashAd {
    NSLog(@"~~开屏广告点击回调");
}

/**
 *  开屏广告将要关闭回调
 */
- (void)splashAdWillClosed:(GDTSplashAd *)splashAd {
    NSLog(@"~~开屏广告将要关闭回调");
}

/**
 *  开屏广告关闭回调
 */
- (void)splashAdClosed:(GDTSplashAd *)splashAd {
    NSLog(@"~~开屏广告关闭回调");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WELCOME_iMG" object:nil];
}

/**
 *  开屏广告点击以后即将弹出全屏广告页
 */
- (void)splashAdWillPresentFullScreenModal:(GDTSplashAd *)splashAd {
    NSLog(@"~~开屏广告点击以后即将弹出全屏广告页");
}

/**
 *  开屏广告点击以后弹出全屏广告页
 */
- (void)splashAdDidPresentFullScreenModal:(GDTSplashAd *)splashAd {
    NSLog(@"~~开屏广告点击以后弹出全屏广告页");
}

/**
 *  点击以后全屏广告页将要关闭
 */
- (void)splashAdWillDismissFullScreenModal:(GDTSplashAd *)splashAd {
    NSLog(@"~~点击以后全屏广告页将要关闭");
}

/**
 *  点击以后全屏广告页已经关闭
 */
- (void)splashAdDidDismissFullScreenModal:(GDTSplashAd *)splashAd {
    NSLog(@"~~点击以后全屏广告页已经关闭");
}

/**
 * 开屏广告剩余时间回调
 */
- (void)splashAdLifeTime:(NSUInteger)time {
    NSLog(@"~~开屏广告剩余时间回调");
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //添加防崩溃代码
    [AvoidCrash makeAllEffective];
    NSArray *noneSelClassStrings = @[
                             @"NSNull",
                             @"NSNumber",
                             @"NSString",
                             @"NSDictionary",
                             @"NSArray"
                             ];
       [AvoidCrash setupNoneSelClassStringsArr:noneSelClassStrings];
    // 拉取广告页
    [self requestSplashAd];
    //开启网络监控
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    [self registShareSDK];
    
    
    [MobSDK uploadPrivacyPermissionStatus:NO onResult:^(BOOL success) {

    }];
    
    
    // 极光推送
    [self setJPUSHServiceWithOptions:launchOptions];
    // 极光IM
//    [self setJMessageWithOptions:launchOptions];
    
    
    // BaiduMap 配置
    [self setBaiduMapComplant];
    
    
    
    
    // 解决iOS12.1 tarbar 图标及文字出现位置偏移
    [UITabBar appearance].translucent = NO;
    
    
    if (@available(iOS 11.0, *)) {
        UITableView.appearance.estimatedRowHeight = 0;
        UITableView.appearance.estimatedSectionFooterHeight = 0;
        UITableView.appearance.estimatedSectionHeaderHeight = 0;
    }
    
    // 广告页
//    [self requestLaunch];
    
    return YES;
}
// 拉取广告页
- (void)requestSplashAd {
    
    BOOL result = [GDTSDKConfig registerAppId:@"1209178442"];
    
    if (result) {
        NSLog(@"注册成功!");
    }
    
    self.splashAd = [[GDTSplashAd alloc] initWithPlacementId:@"6183628777074128"];
    
    self.splashAd.delegate = self;
    self.splashAd.fetchDelay = 5;
    UIImage *splashImage = [UIImage imageNamed:@"SplashNormal"];
    if (isIPhoneXSeries()) {
        splashImage = [UIImage imageNamed:@"SplashX"];
    } else if ([UIScreen mainScreen].bounds.size.height == 480) {
        splashImage = [UIImage imageNamed:@"SplashSmall"];
    }
    
    self.splashAd.backgroundImage = splashImage;
    
    [self.splashAd loadAd];
    
   
}
// ShareSDK
- (void)registShareSDK {
    
    [ShareSDK registPlatforms:^(SSDKRegister *platformsRegister) {
        
        // QQ
        [platformsRegister setupQQWithAppId:QQAppId appkey:QQKEY enableUniversalLink:YES universalLink:@"https://syvjn.share2dlink.com/qq_conn/101869261"];
        
        // 微信
        [platformsRegister setupWeChatWithAppId:WXAppId appSecret:WXSecret universalLink:@"https://syvjn.share2dlink.com/"];
        
    }];
    
}



// 极光IM初始化
- (void)setJMessageWithOptions:(NSDictionary *)launchOptions{
    

#ifdef EPLATFORM_SERVICE
    //测试环境
    [JMessage setDebugMode];
#else
    //正式环境
    [JMessage setLogOFF];
#endif
    
    // Required - 启动 JMessage SDK
    [JMessage setupJMessage:launchOptions appKey:JPushAPPKEY channel:My_Scheme apsForProduction:NO category:nil messageRoaming:YES];
    
    
    // Required - 注册 APNs 通知
    // 可以添加自定义categories
    [JMessage registerForRemoteNotificationTypes:(UNAuthorizationOptionBadge |
                                                  UNAuthorizationOptionSound |
                                                  UNAuthorizationOptionAlert)
                                      categories:nil];
    
    
    [self registerJPushStatusNotification];
    

}

// 极光推送SDK初始化
- (void)setJPUSHServiceWithOptions:(NSDictionary *)launchOptions {
    // 添加初始化 APNs 代码
    //Required
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    if (@available(iOS 12.0, *)) {
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionProvidesAppNotificationSettings;
    } else {
        // Fallback on earlier versions
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
      // 可以添加自定义 categories
      // NSSet<UNNotificationCategory *> *categories for iOS10 or later
      // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    // 添加初始化 JPush 代码
    // Required
    // init Push
    // notice: 2.1.5 版本的 SDK 新增的注册方法，改成可上报 IDFA，如果没有使用 IDFA 直接传 nil
    [JPUSHService setupWithOption:launchOptions appKey:JPushAPPKEY
                          channel:My_Scheme
                 apsForProduction:NO
            advertisingIdentifier:nil];
    
}

#pragma mark- JPUSHRegisterDelegate

// iOS10+ 点击推送调用
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
  // Required
  NSDictionary * userInfo = notification.request.content.userInfo;
  if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    [JPUSHService handleRemoteNotification:userInfo];
  }
  completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
}

// iOS10+ App前台 收到推送调用
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
  // Required
  NSDictionary * userInfo = response.notification.request.content.userInfo;
  if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
      [JPUSHService handleRemoteNotification:userInfo];
      NSLog(@"推送内容: %@",userInfo);
      
  }
  completionHandler();  // 系统要求执行这个方法
}

// 配置百度地图
- (void)setBaiduMapComplant{
    // 要使用百度地图，请先启动BaiduMapManager
    BMKMapManager *mapManager = [[BMKMapManager alloc] init];
    [BMKMapManager setCoordinateTypeUsedInBaiduMapSDK: BMK_COORDTYPE_BD09LL];
    // 如果要关注网络及授权验证事件，请设定generalDelegate参数
    BOOL ret = [mapManager start:BMAPPKEY  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
}

// 设置广告页
- (void)requestLaunch {
    
    [XHLaunchAd setLaunchSourceType:SourceTypeLaunchScreen];
    [XHLaunchAd setWaitDataDuration:3];
    
    [HLHTTPSessionManager postDataWithNSString:HLNotice withDictionary:@{@"sign":@"backdrop"} success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            
            NSString *image = [NSString stringWithFormat:@"%@",dictionary[@"data"][@"val"]];
            
            //1.使用默认配置初始化
            XHLaunchImageAdConfiguration *imageAdconfiguration = [XHLaunchImageAdConfiguration defaultConfiguration];
            //广告图片URLString/或本地图片名(.jpg/.gif请带上后缀)
            imageAdconfiguration.imageNameOrURLString = image;
            //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
//            imageAdconfiguration.openModel = @"http://www.it7090.com";
            //显示图片开屏广告
            [XHLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];
            
            
        } else {
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}


- (void)registerJPushStatusNotification {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidSetup:)
                          name:kJMSGNetworkDidSetupNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkIsConnecting:)
                          name:kJMSGNetworkIsConnectingNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidClose:)
                          name:kJMSGNetworkDidCloseNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidRegister:)
                          name:kJMSGNetworkDidRegisterNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidLogin:)
                          name:kJMSGNetworkDidLoginNotification
                        object:nil];

    [defaultCenter addObserver:self
                      selector:@selector(receivePushMessage:)
                          name:kJMSGNetworkDidReceiveMessageNotification
                        object:nil];

}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    [JMessage resetBadge];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0]; // 清除本地角标
    [JPUSHService resetBadge]; // 清除服务器角标
    [[UIApplication sharedApplication] cancelAllLocalNotifications]; // 取消全部通知标识
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    if ([MyLogin userHadLogin]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"enterForeground" object:nil];
    }

    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [JMessage resetBadge];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Required - 注册token
    [JMessage registerDeviceToken:deviceToken];
    // Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
    
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"___"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}


- (void)networkDidSetup:(NSNotification *)notification {
    NSLog(@"Event - 建立连接");
}

- (void)networkIsConnecting:(NSNotification *)notification {
    NSLog(@"Event - 正在连接中");
}

- (void)networkDidClose:(NSNotification *)notification {
    NSLog(@"Event - 关闭连接");
}

- (void)networkDidRegister:(NSNotification *)notification {
    NSLog(@"Event - 注册成功");
}

- (void)networkDidLogin:(NSNotification *)notification {
    NSLog(@"Event - 连接成功");
}

- (void)receivePushMessage:(NSNotification *)notification {
    NSLog(@"Event - 收到消息");

    NSDictionary *info = notification.userInfo;
    if (info) {
        NSLog(@"The message - %@", info);
    } else {
        NSLog(@"Unexpected - no user info in jpush mesasge");
    }
}


@end
