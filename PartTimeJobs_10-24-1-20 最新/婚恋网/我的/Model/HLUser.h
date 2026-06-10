//
//  HLUser.h
//  婚恋网
//
//  Created by jxzhang on 2019/4/14.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLUser : NSObject

@property (nonatomic , copy) NSString *userid;  //用户id
@property (nonatomic , copy) NSString *head;  //头像
@property (nonatomic , copy) NSString *nickname;  //昵称
@property (nonatomic , copy) NSString *username; //用户名
@property (nonatomic , copy) NSString *password; //密码

@property (nonatomic , copy) NSString *gender;  //性别
@property (nonatomic , copy) NSString *birthday; // 生日
@property (nonatomic , copy) NSString *age;  //年龄
@property (nonatomic , copy) NSString * height; // 身高
@property (nonatomic , copy) NSString * weight; //体重


@property (nonatomic , copy) NSString *habitation; // 用户居住地
@property (nonatomic , copy) NSString *education; //学历
@property (nonatomic , copy) NSString *earns; // 收入
@property (nonatomic , copy) NSString *industry; // 行业
@property (nonatomic , copy) NSString *housing; //住房情况
@property (nonatomic , copy) NSString *car; //购车情况
@property (nonatomic , copy) NSString *certification; //认证状况
@property (nonatomic , copy) NSString *registered; // 用户户口
@property (nonatomic , copy) NSString * native; // 用户籍贯
@property (nonatomic , copy) NSString * nation; //民族
@property (nonatomic , copy) NSString * school; //毕业院校
@property (nonatomic , copy) NSString * company; //所在单位
@property (nonatomic , copy) NSString * position; //职位
@property (nonatomic , copy) NSString * marital; //婚姻状况
@property (nonatomic , copy) NSString * children; //子女状况
@property (nonatomic , copy) NSString * blood; //血型
@property (nonatomic , copy) NSString * itemCount; //未填项数量
@property (nonatomic , copy) NSString * proper_bad; // 评价数量
@property (nonatomic , copy) NSString * proper_like; // 喜欢数量
@property (nonatomic , copy) NSString * proper_no; // 不喜欢数量
@property (nonatomic , copy) NSArray * effect; // 好友印象

@property (nonatomic , copy) NSString * pic_one; //照片1
@property (nonatomic , copy) NSString * pic_two; //照片2
@property (nonatomic , copy) NSString * pic_three; //照片3
@property (nonatomic, copy)  NSArray  * picArray; // 照片数组

@property (nonatomic , copy) NSString * listen; //倾听我心
@property (nonatomic , copy) NSString *constellation; //星座
@property (nonatomic , copy) NSString *animals; //属相


@property (nonatomic , copy) NSString *follow; //关注
@property (nonatomic , copy) NSString *fans; //粉丝
@property (nonatomic , copy) NSString *balance; //余额


@property (nonatomic , copy) NSString * member; //是否是会员
@property (nonatomic , copy) NSString * memberdata; // 会员天数
@property (nonatomic , copy) NSString * attestation; // 

@property (nonatomic , assign) NSInteger isqq;//是否是QQ
@property (nonatomic , assign) NSInteger iswx; //是否是微信

@property (nonatomic , copy) NSString *distance; //距离

@property (nonatomic , assign) BOOL in_follow; //是否关注


@property (nonatomic, strong)NSArray *album; //相册
@property (nonatomic, strong)NSArray *data; //用户资料标签

@property (nonatomic , copy) NSString *friends; //交友条件
@property (nonatomic, strong)NSArray *label; //标签

#pragma mark 新添加  筛选条件
@property (nonatomic, copy)NSString *album_s; // 相册描述
@property (nonatomic, copy)NSString *recommend; // 推荐理由

@end



@interface HLFriendModel : NSObject

@property (nonatomic , copy) NSString *userid;  //用户id
@property (nonatomic , copy) NSString *f_age;  //年龄
@property (nonatomic , copy) NSString *f_habitation;  //居住地
@property (nonatomic , copy) NSString *f_income;  //月收入
@property (nonatomic , copy) NSString *f_height;  //身高
@property (nonatomic , copy) NSString *f_weight;  //体重
@property (nonatomic , copy) NSString *f_education;//学历
@property (nonatomic , copy) NSString *f_registered; //户口所在地


@end

@interface HLSoundModel : NSObject

@property (nonatomic , copy) NSString *sound; // 用户音频

@end

@interface HLFriendUserModel : NSObject

@property (nonatomic , copy) NSString *userid;  //用户id
@property (nonatomic , copy) NSString *nickname;  //昵称
@property (nonatomic , copy) NSString *age;  //年龄
@property (nonatomic , copy) NSString *height;  //身高
@property (nonatomic , copy) NSString *head;  //头像
@property (nonatomic , copy) NSString *member;  



@end

