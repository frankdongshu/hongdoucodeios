//
//  ZPHMessage.m
//  ZHChatBar
//
//  Created by zph on 27/03/2018.
//  Copyright © 2018 zph. All rights reserved.
//

#import "ZPHMessage.h"

@implementation ZPHMessage

/**
 *  重写init方法
 */
-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self == [super init]) {
        [self setValuesForKeysWithDictionary:dic];
        
        if (!kISNullObject(dic[@"type"])) {
            
            if ([dic[@"type"] isEqualToString:@"text"]) {
                self.category = 0;
            } else if ([dic[@"type"] isEqualToString:@"pic"]) {
                self.category = 1;
            } else if ([dic[@"type"] isEqualToString:@"voi"]) {
                self.category = 2;
            } else if ([dic[@"type"] isEqualToString:@"card"]) { // 名片
                self.category = 3;
            } else { // html
                self.category = 4;
            }
            
        } else if (!kISNullObject(dic[@"cut"])) {
            
            if ([dic[@"cut"] isEqualToString:@"text"]) {
                self.category = 0;
            } else if ([dic[@"cut"] isEqualToString:@"pic"]) {
                self.category = 1;
            } else if ([dic[@"cut"] isEqualToString:@"voi"]) {
                self.category = 2;
            } else if ([dic[@"type"] isEqualToString:@"card"]) { // 名片
                self.category = 3;
            } else {
                self.category = 4;
            }
            
        } else {
            self.category = 0;
        }
        
        
        
    }
    return self;
}

+(instancetype)messageWithDic:(NSDictionary *)dic{
    return [[self alloc]initWithDic:dic];
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end
