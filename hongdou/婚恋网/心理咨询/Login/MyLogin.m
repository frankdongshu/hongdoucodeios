//
//  MyLogin.m
//  hongdou
//
//  Created by 李龙 on 2020/3/5.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "MyLogin.h"

@implementation MyLogin

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"userid":@"id"};
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userid forKey:@"userid"];
    [aCoder encodeObject:self.mobile forKey:@"mobile"];
    [aCoder encodeObject:self.habitation forKey:@"habitation"];
    [aCoder encodeObject:self.identity forKey:@"identity"];
    [aCoder encodeObject:self.nickname forKey:@"nickname"];
    [aCoder encodeObject:self.sex forKey:@"sex"];
    [aCoder encodeObject:self.birthday forKey:@"birthday"];
    [aCoder encodeObject:self.token forKey:@"token"];
    [aCoder encodeObject:self.time forKey:@"time"];
    [aCoder encodeObject:self.pay_city forKey:@"pay_city"];
    [aCoder encodeObject:self.locking forKey:@"locking"];
    
    [aCoder encodeObject:self.intelligence forKey:@"intelligence"];
    [aCoder encodeObject:self.education forKey:@"education"];
    [aCoder encodeObject:self.school forKey:@"school"];
    [aCoder encodeObject:self.major forKey:@"major"];
    [aCoder encodeObject:self.descr forKey:@"descr"];
    [aCoder encodeObject:self.motto forKey:@"motto"];
    [aCoder encodeObject:self.head forKey:@"head"];
    [aCoder encodeObject:self.wx forKey:@"wx"];
    [aCoder encodeObject:self.qq forKey:@"qq"];
    [aCoder encodeObject:self.contact forKey:@"contact"];
    [aCoder encodeObject:self.pic forKey:@"pic"];
    [aCoder encodeObject:self.curriculum forKey:@"curriculum"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {

        self.userid = [aDecoder decodeObjectForKey:@"userid"];
        self.mobile = [aDecoder decodeObjectForKey:@"mobile"];
        self.habitation = [aDecoder decodeObjectForKey:@"habitation"];
        self.identity = [aDecoder decodeObjectForKey:@"identity"];
        self.nickname = [aDecoder decodeObjectForKey:@"nickname"];
        self.sex = [aDecoder decodeObjectForKey:@"sex"];
        self.birthday = [aDecoder decodeObjectForKey:@"birthday"];
        self.token = [aDecoder decodeObjectForKey:@"token"];
        self.time = [aDecoder decodeObjectForKey:@"time"];
        self.pay_city = [aDecoder decodeObjectForKey:@"pay_city"];
        self.locking = [aDecoder decodeObjectForKey:@"locking"];
        
        self.intelligence = [aDecoder decodeObjectForKey:@"intelligence"];
        self.education = [aDecoder decodeObjectForKey:@"education"];
        self.school = [aDecoder decodeObjectForKey:@"school"];
        self.major = [aDecoder decodeObjectForKey:@"major"];
        self.descr = [aDecoder decodeObjectForKey:@"descr"];
        self.motto = [aDecoder decodeObjectForKey:@"motto"];
        self.head = [aDecoder decodeObjectForKey:@"head"];
        self.wx = [aDecoder decodeObjectForKey:@"wx"];
        self.qq = [aDecoder decodeObjectForKey:@"qq"];
        self.contact = [aDecoder decodeObjectForKey:@"contact"];
        self.pic = [aDecoder decodeObjectForKey:@"pic"];
        self.curriculum = [aDecoder decodeObjectForKey:@"curriculum"];
  
    }
    
    return self;
}


// 退出登录
+ (void)logOut {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:Login_USER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)userHadLogin {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:Login_USER]) {
        return YES;
    }
    return NO;
}

+ (BOOL)updateUser:(MyLogin *)newUser{
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:newUser] forKey:Login_USER];
    
    return [[NSUserDefaults standardUserDefaults] synchronize];
    
}

// 当前登录人信息
+ (MyLogin *)getCurrentLoginUser {
    
    // 把持久化的登录人信息获取出来
    NSData *uData = [[NSUserDefaults standardUserDefaults] objectForKey:Login_USER];
    
    // 用反序列化类将二进制数据转化为User对象
    MyLogin *u = [NSKeyedUnarchiver unarchiveObjectWithData:uData];
    
    
    return u;
}

@end
