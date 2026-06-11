//
//  HLHTTPSessionManager.h
//  婚恋网
//
//  Created by iMac on 2019/4/8.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "AFHTTPSessionManager.h"

#pragma mark 登录模块接口
//登录
#define HLLOGIN @"/index/logon"
//三方登录
#define HLThird_QQLOGIN @"/index/QQLogin"
#define HLThird_WXLOGIN @"/index/wechatLogin"
#define HLThird_IOS_LOGIN @"/index/iOSLogin"

//注销
#define HLlogout @"/index/logout"

//发送短信验证码
#define HLSEND_CODE @"/index/sms"
// 查看验证码
#define HLSEE_CODE @"/sms/getCaptcha"
// 注册
#define HLREGISTER @"/index/register"
// 找回密码
#define HLRERSETPWD @"/index/reset"
// 绑定手机号
#define HLBINDIN_PHONE @"/index/binding"


#pragma mark 用户信息模块接口
// 是否已经完善信息
#define HLISPerfect @"/user/imperfect"  //true 已经完善 false 未完善
//获取用户信息
#define HLGET_UserINFO @"/user/get"
//获取好友用户资料
#define HLGET_FriendsINFO @"/ulist/getwhole"

//获取交友条件信息
#define HLGet_FriendsINFO @"/friends/get"

//获取目标交友条件信息
#define HLNewGet_FriendsINFO @"/ulist/getfriends"

// 偶遇点击事件所调接口
#define HLGET_OU_YU @"/ulist/random_see"

// 获取用户余额
#define NLUser_Balance @"/user/balance"


// 上传头像
#define HLUPLoad_HeaderImage @"/user/upload"
// 完善用户资料
#define HLEdit_UserEVPI @"/user/EVPI"
// 修改用户信息
#define HLEdit_UserModify @"/user/modify"
// 修改名片
#define HLEdit_UserCard @"/user/card"
// 修改交友信息
#define HLEdit_FriendsModify @"/friends/modify"

// 获取相册信息
#define HLAlbum_Info @"/album/get"
// 查看他人相册
#define HLFriendsAlbum_Info @"/ulist/get_album"
// 相册点赞
#define HLAlbum_Like @"/album/likes"
// 相册删除一条状态
#define HLAlbum_Del @"/album/del"

// 相册取消点赞
 #define HLAlbum_DeleteLike @"/album/delLikes"
// 上传相册图片 获取url地址
#define HLUPLoad_AlbumImages @"/album/upload"
// 发表动态
#define HLPublic_Trends @"/album/add"
// 兑换产品
#define HLExchange_Shopping @"/product/exchange"


#pragma 列表系列接口
#define HLCity_list @"/index/city"
// 学历列表
#define HLEducation_List @"/index/education_list"
// 身高列表
#define HLHeight_List @"/index/height_list"
//月收入列表
#define HLIncome_List @"/index/income_list"
//住房类型列表
#define HLHousing_List @"/index/housing_list"
//民族列表
#define HLNation_List @"/index/nation_list"
//子女状况列表
#define HLChildren_List @"/index/children_list"
//婚姻状况列表
#define HLMarital_List @"/index/marital_list"
//血型列表
#define HLBlood_List @"/index/blood_list"
//年龄列表
#define HLAge_List @"/index/age_list"
//行业列表
#define HLIndustry_List @"/index/industry_list"
//职位列表
#define HLPosition_List @"/index/position_list"
// 产品列表
#define HLShopping_List @"/product/get"
// 兑换记录
#define HLRecord_List @"/product/record"
// 好友印象
#define HLFriends_YinXiang @"/user/effect"
// 删除印象
#define HLFriends_Delete_YinXiang @"/user/deleff"


//句式列表  固定发生消息的句式的数据列表
#define HLSyntax_list @"/index/syntax_list"
//举报类型列表
#define HLComplaint_List @"/index/complaint_list"
//图片举报类型列表
#define HLPiccomplaint_list @"/index/pic_complaint_list"

#pragma mark 设置接口

// 用户资料状态
#define HLISClose @"/user/isClose"

// 用户资料开关
#define HLSWITCH @"/user/close"
// 获取公告
#define HLNotice @"/index/notice" // sign==disclaimer时是《免责声明》 Sign==concerning时是《关于我们》 sign==security时是《安全手册》 sige == Aversion 请求版本号
// 获取通知
#define HLGET_Notifiction @"/index/get_set"
// 通知设置
#define HLNitifiction_Set @"/index/set"
//手机实名认证
#define HLVerity_PhoneNnber @"/user/attestation"
//手机实名认证状态
#define HLVerity_Statue @"/user/isAtt"
//留言
#define HLLeave_Message @"/index/message"

#pragma mark 隐私管理
//关注我的用户
#define HLFollow_Shields @"/friends/followMy"
//我关注的用户
#define HLMyFollow_Shields @"/friends/myFollow"
//关注用户
#define HLGoFollow_Shields @"/friends/follow"
//取消关注用户
 #define HLCancelFollow_Shields @"/friends/delFollow"

//看过我的用户
#define HLSeenMy_Shields @"/friends/seenMy"
//我查看过的用户
#define HLMySeen_Shields @"/friends/mySeen"

// 被我点赞的用户
#define HLMyLike @"/album/myLikes"
// 给我点赞的用户
#define HLLikeMe @"/album/likesMy"

//我屏蔽的用户
#define HLPrivacy_Shield @"/friends/myShield"
//屏蔽用户
#define HLGoPrivacy_Shield @"/friends/shield"
//移除屏蔽用户
#define HLDelegatePrivacy_Shield @"/friends/delShield"

// 我的黑名单列表
#define HLPrivacy_PullBlack @"/friends/myBlacklist"
// 拉黑用户
#define HLPull_Black @"/friends/blacklist"
//移除拉黑用户
#define HLDelegate_PullBlack @"/friends/delBlacklist"

// 打招呼
#define HLFriends_Call @"/friends/myCall"
// 畅聊
#define HLFriends_Chatting @"/friends/myChatting"

// 系统消息
#define HLFriends_System @"/friends/mySystem"

// 举报
#define HLFriends_Complaint @"/friends/complaint"


#pragma mark 首页接口
// 推荐列表
#define HLTuijian_friends @"/ulist/newindex"
// 更新推荐列表
#define HLUpdate_friends @"/ulist/change"
// 附近
#define HLNearby_friends @"/ulist/distance"
// 智能体
#define HLAgent_list @"/agent/list"
// 豆选
#define HLDouxuan_friends @"/ulist/random"
// 用户资料详情 
#define HLUser_Detailed @"/ulist/detailed"

// 筛选
#define HLUser_Screen @"/ulist/screen"

// 用户上传定位
#define HLUser_Location @"/ulist/location"

#pragma mark 发现页接口
// 广场
#define HLAlbum_Square @"/album/square"
// 关注
#define HLAlbum_Follow @"/album/follow"
// 举报图片
#define HLAlbum_Complaint @"/album/complaint"

// 聊天前审核
#define HLUser_ExamineType @"/user/examineType"
// 获取活动状态
#define HLActiv @"/user/in_activities"
// 活动开关
#define HLSwitch @"/user/as_on_off"
// 获取自我介绍语句
#define HLPerson_im @"/user/get_im"

// 获取兑换状态
#define HLDui_Huan_Activ @"/user/in_exchange"

// 获取活动信息
#define HLActivity @"/product/get_activity"

// 开奖记录
#define HLLottery_Record @"/product/get_history"


// 邀请信息
#define HLInviten_Reward @"/user/invite"
// 邀请码
#define HLInviten_Code @"/user/referralCode"
// 输入对方邀请码
#define HLInviten_UplodeCode @"/user/recommend"
/*
 邀请奖励  /user/invite    uid token
 邀请码  /user/referralCode
 */
#pragma 消息页数据



#pragma mark 会员相关
//用户是否是会员
#define HLIS_VIPMember @"/translate/clear"
// vip套餐 价格表
#define HLVip_PriceList @"/index/member_list"

//用户是否与我畅聊
#define HLIS_Chatting @"/friends/isChatting"


NS_ASSUME_NONNULL_BEGIN

@interface HLHTTPSessionManager : AFHTTPSessionManager


/**
 @return VKHTTPSessionManager
 */
+ (instancetype)sharedClient;
/**
 普通GET请求
 */
+ (void)getDataWithNSString : (NSString *)actionUrlStr
             withDictionary : (NSDictionary *) nsDic
                    success : (void (^)(NSDictionary* dictionary))success
                    failure : (void (^)(NSError *error))failure;

/**
 普通POST请求
 */
+ (void)postDataWithNSString : (NSString *)actionUrlStr
              withDictionary : (NSDictionary *) nsDic
                     success : (void (^)(NSDictionary* dictionary))success
                     failure : (void (^)(NSError *error))failure;



//上传附件
+ (void)postDataWithNSString : (NSString *)actionUrlStr
              withDictionary : (NSDictionary *) nsDic
    constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                     success : (void (^)(NSDictionary* dictionary))success
                     failure : (void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
