//
//  ZPHMessage.h
//  ZHChatBar
//
//  Created by zph on 27/03/2018.
//  Copyright © 2018 zph. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZPHMessage : NSObject
/**
 对方id
 */
@property (nonatomic,copy)NSString *cid;
/**
 对方头像
 */
@property (nonatomic,copy)NSString *chead;
/**
 对方名字
 */
@property (nonatomic,copy)NSString *uname;
/**
 招呼语
 */
@property (nonatomic,copy)NSString *intro;
/**
 内容
 */
@property (nonatomic,copy)NSString *text;
/**
 类型
 */
@property (nonatomic,assign)int category;
/**
 自己id
 */
@property (nonatomic,copy) NSString *uid;
/**
 自己头像
 */
@property (nonatomic,copy)NSString *uhead;
/**
 时间字符串
 */
@property (nonatomic,copy)NSString *time;
/**
 上一条消息时间
 */
@property (nonatomic,copy)NSString *ontime;

//重写init方法
-(instancetype)initWithDic:(NSDictionary *)dic;
+(instancetype)messageWithDic:(NSDictionary *)dic;
@end
