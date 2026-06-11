//
//  HLDefines.h
//  婚恋网
//
//  Created by iMac on 2019/3/1.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#ifndef HLDefines_h
#define HLDefines_h

#define SHOWLOGIN @"showLoginVC"
#define NeedBindAccount @"needBindAccount"
#define NativeLogin @"nativeLogin"
#define VisitorLogin @"visitorLogin"
#define DismissLoginView @"dismissloginview"
#define UpdateImageOrNickname @"UpdateImageOrNickname"
#define ShowDetailInfoView @"ShowDetailInfoView"

#define HLALIPAYRESULT @"hlAlipayResult"

#define HLWEIXINPAYRESULT @"hlWeiXinpayResult"
#define LoginNeedBindPhoneNoti @"LoginNeedBindPhoneNoti"

#define kAlertToSendImage @"AlertToSendImage"

#define kDeleteMessage @"DeleteMessage"
#define kDeleteAllMessage  @"deleteAllMessage"
#define Login_USER @"loginUser" // 家教登录持久化

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "BRStringPickerView.h"
#define MAXRECORDTIME 180
#define MINRECORDTIME 1

#define IsIOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IsIOS9 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define IS_iPhoneX (CGSizeEqualToSize(CGSizeMake(1125,2436), [[UIScreen mainScreen]currentMode].size)) || (CGSizeEqualToSize(CGSizeMake(828,1792), [[UIScreen mainScreen]currentMode].size)) || (CGSizeEqualToSize(CGSizeMake(1242,2688), [[UIScreen mainScreen]currentMode].size))

#define WeakSelf(weakSelf) __weak typeof (&*self) weakSelf = self

#define CY_WeakSelf __weak __typeof(&*self)weakSelf = self;

#pragma mark color
/**
 *  RGB颜色取值
 */
#define kHYLColor(r,g,b,al) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(al)]

/// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//字符串是否为空
#define kISNullString(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO )
//数组是否为空
#define kISNullArray(array) (array == nil || [array isKindOfClass:[NSNull class]] || array.count == 0 ||[array isEqual:[NSNull null]])
//字典是否为空
#define kISNullDict(dic) (dic == nil || [dic isKindOfClass:[NSNull class]] || dic.allKeys == 0 || [dic isEqual:[NSNull null]])
//是否是空对象
#define kISNullObject(_object) (_object == nil \
|| [_object isKindOfClass:[NSNull class]] \
|| ([_object respondsToSelector:@selector(length)] && [(NSData *)_object length] == 0) \
|| ([_object respondsToSelector:@selector(count)] && [(NSArray *)_object count] == 0))
//判断对象是否为空,为空则返回默认值
#define kGetNullDefaultObj(_value,_default) ([_value isKindOfClass:[NSNull class]] || !_value || _value == nil || [_value isEqualToString:@"(null)"] || [_value isEqualToString:@"<null>"] || [_value isEqualToString:@""] || [_value length] == 0)?_default:_value

#define kISiPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kScreenMaxLength (MAX(kScreenWidth, kScreenHeight))
#define kScreenMinLength (MIN(kScreenWidth, kScreenHeight))
#define kISiPhone5 (kISiPhone && kScreenMaxLength == 568.0)
#define kISiPhone6 (kISiPhone && kScreenMaxLength == 667.0)
#define kISiPhone6P (kISiPhone && kScreenMaxLength == 736.0)
#define kISiPhoneX (kISiPhone && kScreenMaxLength == 812.0)
#define kISiPhoneXr (kISiPhone && kScreenMaxLength == 896.0)
#define kISiPhoneXX (kISiPhone && kScreenMaxLength > 811.0)
#define IOS8 ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0)


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight  [UIScreen mainScreen].bounds.size.height

//6为标准适配的,如果需要其他标准可以修改
#define kScale_W(w) ((kScreenWidth)/375) * (w)
#define kScale_H(h) (kScreenHeight/667) * (h)
//字体适配
#define kScaleFont(fontSize) [UIFont systemFontOfSize: fontSize*kScreenWidth/375]
//状态栏高度
#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
//状态栏高度
#define StatusBarHeight (kISiPhoneXX?44:20)
//标签栏高度
#define kTabBarHeight (StatusBarHeight > 20 ? 83 : 49)
//导航栏高度
#define kNavBarHeight (StatusBarHeight + 44)
//安全区高度
#define kSafeAreaBottom (kISiPhoneXX ? 34 : 0)

/** 获取APP名称 */
#define APP_NAME ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"])
/** 程序版本号 */
#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
/** 获取APP build版本 */
#define APP_BUILD ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"])


/// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


#define systemFontSize(x) [UIFont systemFontOfSize:(x)]

#define kFontNavigationTitle systemFontSize(18)
#define kFontNavigationItem systemFontSize(16)

#define kFontTitleLarge systemFontSize(15)
#define kFontTitleMiddle systemFontSize(14)
#define kFontTitleSmall systemFontSize(13)
#define kFontTitleSmallnext systemFontSize(12)
#define kFontTitleSmallest systemFontSize(11)

/// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#import "FTYColor.h"
#define HEXColor(colorString)  [FTYColor getColor:colorString andAlpha:1]
#define CCPNavColor HEXColor(@"2e55a6")
#define REDColor HEXColor(@"e46151")

#endif /* HLDefines_h */
