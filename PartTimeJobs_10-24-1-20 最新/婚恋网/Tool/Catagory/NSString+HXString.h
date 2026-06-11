//
//  NSString+HXString.h
//  eplatform-edu
//
//  Created by iMac on 16/8/16.
//  Copyright © 2016年 华夏大地教育网. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HXString)

-(NSMutableAttributedString*)attriStringWithFirstString:(NSString*)string1 withTwoString:(NSString*)string2 withThreeString:(NSString*)string3 color:(UIColor*)colors;

//验证电话号码
+(BOOL)isValidateTelNumber:(NSString *)number;

//验证email
+(BOOL)isValidateEmail:(NSString *)email;

//是否是有效的正则表达式
+(BOOL)isValidateRegularExpression:(NSString *)strDestination byExpression:(NSString *)strExpression;

+(NSMutableAttributedString*)highlightedString:(NSString*)string isClassic:(BOOL)isClassic isVote:(BOOL)isVote;

+(BOOL)isImageFileName:(NSString *)name;

+(BOOL)isAudioFileName:(NSString *)name;

+(BOOL)isVideoFileName:(NSString *)name;

+ (NSString *) responseceObjectCode:(id)code;

//身份证验证
+ (BOOL)cly_verifyIDCardString:(NSString *)idCardString;
@end
