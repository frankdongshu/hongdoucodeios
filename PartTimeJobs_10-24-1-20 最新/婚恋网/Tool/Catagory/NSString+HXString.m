//
//  NSString+HXString.m
//  eplatform-edu
//
//  Created by iMac on 16/8/16.
//  Copyright © 2016年 华夏大地教育网. All rights reserved.
//

#import "NSString+HXString.h"

@implementation NSString (HXString)

-(NSMutableAttributedString*)attriStringWithFirstString:(NSString*)string1 withTwoString:(NSString*)string2 withThreeString:(NSString*)string3 color:(UIColor*)colors{
    NSMutableAttributedString * mutableAttriStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@",string1,string2,string3]];
    NSDictionary * attris = @{NSForegroundColorAttributeName:colors,NSFontAttributeName:[UIFont systemFontOfSize:17]};
    [mutableAttriStr setAttributes:attris range:NSMakeRange(0,string1.length)];
    [mutableAttriStr setAttributes:attris range:NSMakeRange(mutableAttriStr.length - string3.length,string3.length)];

    return mutableAttriStr;
}


//是否是有效的正则表达式
+(BOOL)isValidateRegularExpression:(NSString *)strDestination byExpression:(NSString *)strExpression
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strExpression];
    
    return [predicate evaluateWithObject:strDestination];
    
}

//验证email
+(BOOL)isValidateEmail:(NSString *)email {
    
    NSString *strRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,5}";
    
    BOOL rt = [self isValidateRegularExpression:email byExpression:strRegex];
    
    return rt;
    
}

//验证电话号码
+(BOOL)isValidateTelNumber:(NSString *)number {
    
    NSString *strRegex = @"^1[0-9][0-9]{9}$";
    
    BOOL rt = [self isValidateRegularExpression:number byExpression:strRegex];
    
    return rt;
    
}

+(BOOL)isImageFileName:(NSString *)name
{
    NSString * havePic = [name lowercaseString];
    if ([havePic hasSuffix:@"gif"]||[havePic hasSuffix:@"png"]||[havePic hasSuffix:@"jpg"]||[havePic hasSuffix:@"jpeg"])
    {
        return YES;
    }
    return NO;
}

+ (NSMutableAttributedString*)highlightedString:(NSString*)string isClassic:(BOOL)isClassic isVote:(BOOL)isVote
{
    NSMutableString * titleText = [NSMutableString stringWithString:string];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]init];
    
    if (isClassic && !isVote) {
        
        //精选图片
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = [UIImage imageNamed:@"jing"];
        NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [attr appendAttributedString:imageStr];
        
    }
    
    if (isVote) {
        
        //投票图片
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = [[UIImage imageNamed:@"tou"] imageWithTintColor:kNavigationBarColor];
        NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [attr appendAttributedString:imageStr];
    }
    
    //正则表达式匹配
    NSString*parten = @"<span class='ui-highlight'>.*?</span>";
    NSError* error = NULL;
    
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:parten options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray* match = [reg matchesInString:titleText options:NSMatchingReportCompletion range:NSMakeRange(0, titleText.length)];
    
    if (match.count != 0)
    {
        //颜色
        UIColor *color = [UIColor colorWithRed:1.000 green:0.600 blue:0.000 alpha:1.000];
        NSDictionary *attrsDic = @{NSForegroundColorAttributeName:color};
        //开头文字
        NSRange frRange = ((NSTextCheckingResult*)[match objectAtIndex:0]).range;
        NSAttributedString * head = [[NSAttributedString alloc]initWithString:[titleText substringWithRange:NSMakeRange(0, frRange.location)] attributes:nil];
        [attr appendAttributedString:head];
        
        for (int i = 0; i<match.count;i++) {
            
            NSTextCheckingResult *matc = [match objectAtIndex:i];
            
            NSRange range = [matc range];
            NSLog(@"%lu,%lu,%@",(unsigned long)range.location,(unsigned long)range.length,[titleText substringWithRange:range]);
            NSString * subtext = [titleText substringWithRange:range];
            NSString * text = [subtext substringWithRange:NSMakeRange(27, subtext.length-34)];
            NSAttributedString * foot = [[NSAttributedString alloc]initWithString:text attributes:attrsDic];
            [attr appendAttributedString:foot];
            
            if (i<match.count-1) {
                
                NSTextCheckingResult *nextMatc = [match objectAtIndex:i+1];
                NSRange nextRange = [nextMatc range];
                NSRange newRange = NSMakeRange(NSMaxRange(range), nextRange.location-NSMaxRange(range));
                NSString * text = [titleText substringWithRange:newRange];
                NSAttributedString * next = [[NSAttributedString alloc]initWithString:text attributes:nil];
                [attr appendAttributedString:next];
                
            }else
            {
                //结尾文字
                NSRange foRange = ((NSTextCheckingResult*)[match lastObject]).range;
                NSAttributedString * foot = [[NSAttributedString alloc]initWithString:[titleText substringWithRange:NSMakeRange(foRange.location+foRange.length, titleText.length-foRange.location-foRange.length)] attributes:nil];
                [attr appendAttributedString:foot];
            }
        }
        
    }else
    {
        //title
        NSAttributedString * title = [[NSAttributedString alloc]initWithString:titleText attributes:nil];
        [attr appendAttributedString:title];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:5];
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attr.length)];
    
    return attr;
}

+(BOOL)isAudioFileName:(NSString *)name
{
    NSString * havePic = [name lowercaseString];
    if ([havePic hasSuffix:@"mp3"])
    {
        return YES;
    }
    return NO;
}

+(BOOL)isVideoFileName:(NSString *)name
{
    NSString * havePic = [name lowercaseString];
    if ([havePic hasSuffix:@"mp4"])
    {
        return YES;
    }
    return NO;
}
+ (NSString *) responseceObjectCode:(id)code{
    NSString *str1 = [NSString stringWithFormat:@"%@",code];
    return str1;
}


/**
 校验身份证号码是否正确 返回BOOL值
 
 @param idCardString 身份证号码
 @return 返回BOOL值 YES or NO
 */
+ (BOOL)cly_verifyIDCardString:(NSString *)idCardString {
    NSString *regex = @"^[1-9]\\d{5}(18|19|([23]\\d))\\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\\d{3}[0-9Xx]$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL isRe = [predicate evaluateWithObject:idCardString];
    if (!isRe) {
        //身份证号码格式不对
        return NO;
    }
    //加权因子 7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2
    NSArray *weightingArray = @[@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2"];
    //校验码 1, 0, 10, 9, 8, 7, 6, 5, 4, 3, 2
    NSArray *verificationArray = @[@"1", @"0", @"10", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2"];
    
    NSInteger sum = 0;//保存前17位各自乖以加权因子后的总和
    for (int i = 0; i < weightingArray.count; i++) {//将前17位数字和加权因子相乘的结果相加
        NSString *subStr = [idCardString substringWithRange:NSMakeRange(i, 1)];
        sum += [subStr integerValue] * [weightingArray[i] integerValue];
    }
    
    NSInteger modNum = sum % 11;//总和除以11取余
    NSString *idCardMod = verificationArray[modNum]; //根据余数取出校验码
    NSString *idCardLast = [idCardString.uppercaseString substringFromIndex:17]; //获取身份证最后一位
    
    if (modNum == 2) {//等于2时 idCardMod为10  身份证最后一位用X表示10
        idCardMod = @"X";
    }
    if ([idCardLast isEqualToString:idCardMod]) { //身份证号码验证成功
        return YES;
    } else { //身份证号码验证失败
        return NO;
    }
}

@end
