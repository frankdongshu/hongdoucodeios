//
//  HLPhotoModel.h
//  hongdou
//
//  Created by iMac on 2019/9/26.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 照片信息
@interface HLPhotoModel : NSObject

@property (nonatomic, copy) NSString *photoID;
@property (nonatomic, copy) NSString *aid;
@property (nonatomic, copy) NSString *url; // 图片地址
@property (nonatomic, copy) NSString *fm; // 视频封面
@property (nonatomic, copy) NSString *examine;


@end

// 相册详情
@interface HLAlbumDetails : NSObject

@property (nonatomic, copy) NSString *uid; // 当前用户ID
@property (nonatomic, copy) NSString *albumId; // 详情id
@property (nonatomic, copy) NSString *content; //内容描述
@property (nonatomic, copy) NSString *date; // 日期
@property (nonatomic, copy) NSString *likes; // 喜欢人数
@property (nonatomic, strong) NSArray *photoArray; //图片数组 pics
@property (nonatomic, assign) BOOL islikes; // 是否喜欢

@property (nonatomic, copy) NSString *nickname; //昵称
@property (nonatomic, copy) NSString *head; // 头像
@property (nonatomic, copy) NSString *member; // 喜欢人数
@property (nonatomic, copy) NSString *gender; // 性别

@property (nonatomic, assign) CGFloat cellHight; // cell 高度


// 有奖话题
@property (nonatomic, copy) NSString *vote;// 得票数
@property (nonatomic, assign) BOOL isvote; // 是否投票


// 动态显示倒计时
@property (nonatomic, copy) NSString *datetime;
// 是否是颜品VIP
@property (nonatomic, assign) BOOL isvip;
// webUrl
@property (nonatomic, copy) NSString *url;

// 观看次数
@property (nonatomic, copy) NSString *looked;

@end

// 相册
@interface HLAlbumModel : NSObject

@property (nonatomic, copy) NSString *key; // 相册标题
@property (nonatomic, strong) NSArray *albumArray; //相册详情数组


@end


@interface HLAlbumUploadModel : NSObject

@property (nonatomic, copy) NSString *state; // 上传转态是否成功
@property (nonatomic, copy) NSString *var; // 地址url


@end

NS_ASSUME_NONNULL_END
