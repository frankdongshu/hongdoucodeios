//
//  NSString+HXString.h
//  eplatform-edu
//
//  Created by iMac on 16/8/16.
//  Copyright © 2016年 华夏大地教育网. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HXString)

- (NSMutableAttributedString*)attriStringWithFirstString:(NSString*)string1 withTwoString:(NSString*)string2 withThreeString:(NSString*)string3 color:(UIColor*)colors;

// 验证手机号
- (BOOL)isValidateTelNumber;

// 验证邮箱
- (BOOL)isValidateEmail;

// 验证url
- (BOOL)isTrueUrl;

// 字符串转码
- (NSString*)urlEncodeString;

// 反URL编码
- (NSString *)decodeFromPercentEscapeString;

+(NSMutableAttributedString*)highlightedString:(NSString*)string isClassic:(BOOL)isClassic isVote:(BOOL)isVote;

+(BOOL)isImageFileName:(NSString *)name;

+(BOOL)isAudioFileName:(NSString *)name;

+(BOOL)isVideoFileName:(NSString *)name;

//身份证验证
+ (BOOL)cly_verifyIDCardString:(NSString *)idCardString;

@end
