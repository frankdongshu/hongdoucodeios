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

//分享的key
#define WXAppId @"wx2ae7a59cf7d5401f"

#define WXSecret @"3ae65aed5853d6837c8f14c4e9229190"

#define QQAppId @"1110198272" //

#define QQKEY @"d4e2978f7cf804ceb3bbc5ae62c1f800" //

#define SinaKey @"1304327934"

#define SinaSecret @"ecd126afb0663e984637314626a8bc16"

// 极光
#define JPushAPPKEY @"15d46aff2e4fde91acd4172c"
#define JPushSeccret @"abc8d3790cb83766598aa877"

//关于程序跳转的参数--必须和plist文件中的一致！
#define My_Scheme @"hongdou-marriage"
//是否是测试环境（如果要切换到正式环境，请注释掉下面一行）
#define EPLATFORM_SERVICE 1
#ifdef EPLATFORM_SERVICE
//测试环境
#define BaseUrl @"http://db.hongdou.art/index.php/api"
#else
//正式环境域名
#define BaseUrl @"http://www.hongdou.art/index.php/api"
#endif

//Tabbar标题
#define TabBarItemTitle1 NSLocalizedString(@"首页", nil)
#define TabBarItemTitle2 NSLocalizedString(@"发现", nil)
#define TabBarItemTitle3 NSLocalizedString(@"消息", nil)
#define TabBarItemTitle4 NSLocalizedString(@"我的", nil)

//默认主题
#define Default_Theme HXThemeWhite


// 完整的输出
#define CLog(format, ...)  NSLog(format, ## __VA_ARGS__)

#define HDLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);


/*
 沙盒测试
 账号:hongdoutest2@163.com
 密码:Hongdou123
 */
#endif /* Setup_h */
