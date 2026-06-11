//
//  Setup.h
//  婚恋网
//
//  Created by iMac on 2019/3/1.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#ifndef Setup_h
#define Setup_h

#define APP_CHANNEL @"app_store_hongdou"

//是否支持微信登录  (如果不支持，请注释掉下面一行）
#define WeiXinLogin @"weixin"

#define WeiXinAppID  @"wx2ae7a59cf7d5401f"

#define WeiXinAppSecret  @"34f0bbd592a76526bcd37b3a909bc342"

// 百度地图key
#define BMAPPKEY @"oV7jSUikwwyb2NGuPA7Ni3xODkBjw9FE"

//是否支持微博登录  (如果不支持，请注释掉下面一行）
#define WeiboLogin @"weibo"

#define WeiboAppKey @"101556799"

#define WeiboRedirectURI @"https://api.weibo.com/oauth2/default.html"

//是否支持QQ登录  (如果不支持，请注释掉下面一行）
#define QQLogin @"qq"

#define QQAppKey @"1108707754" //

//友盟统计appkey
#define APPKEY @"5ca459e361f564a18100035b"

// 微信
#define WXAppId @"wxa8c21353997d6f01"
#define WXSecret @"f446a3d6b251d9d6a895e7ea84491156"

// QQ
#define QQAppId @"101869261"
#define QQKEY @"9ac1d8f09a4fdcdb448fa35675d4b3b3"

// 微博
#define SinaKey @"1304327934"
#define SinaSecret @"ecd126afb0663e984637314626a8bc16"

// 极光
#define JPushAPPKEY @"d044c9f34e3d60f3e60e37b4"
#define JPushSeccret @"0417b94308321ea0cba13da0"

//关于程序跳转的参数--必须和plist文件中的一致！
#define My_Scheme @"hongdou-marriage"
//是否是测试环境（如果要切换到正式环境，请注释掉下面一行）
#define EPLATFORM_SERVICE 1
#ifdef EPLATFORM_SERVICE
//测试环境
//#define BaseUrl @"http://39.97.187.95/index.php/api"

#define BaseUrl @"http://www.jiajiao211.net/index.php/api"
#else
//正式环境域名
//#define BaseUrl @"http://39.97.187.95/index.php/api"
#define BaseUrl @"http://www.jiajiao211.net/index.php/api"
#endif

//Tabbar标题
#define TabBarItemTitle1 @"首页"
#define TabBarItemTitle2 @"发现"
#define TabBarItemTitle3 @"消息"
#define TabBarItemTitle4 @"我的"

//默认主题
#define Default_Theme HXThemeWhite


/*
 沙盒测试
 账号:hongdoutest2@163.com
 密码:Hongdou123
 */
#endif /* Setup_h */
