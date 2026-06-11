//
//  ZPHMessageTableViewCellLayoutHtml.m
//  hongdou
//
//  Created by 维康1 on 2021/9/2.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "ZPHMessageTableViewCellLayoutHtml.h"

@implementation ZPHMessageTableViewCellLayoutHtml

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    if (self = [super init]) {
        
        ZPHMessage *messageModel = [ZPHMessage messageWithDic:dictionary];
        
        if ([[NSString stringWithFormat:@"%@",messageModel.uid] isEqualToString:[LoginManager defaultManager].userid]) {
            [self setRightLayoutWithModel:messageModel];
        }else {
            [self setLeftLayoutWithModel:messageModel];
        }
    }
    
    return self;
}
//左
-(void)setLeftLayoutWithModel:(ZPHMessage *)model {
    
    [super setLeftLayoutWithModel:model];
    
    
    CGFloat kviewWidth = [UIScreen mainScreen].bounds.size.width;
    
    //内容文字
    NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc]init];
    [contentAttributedString appendAttributedString:[self getContentHtml:model.text]];
    NSRange rang = NSMakeRange(0, contentAttributedString.length);
    [contentAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:rang];
    [contentAttributedString addAttribute:NSKernAttributeName value:@1 range:rang];
    NSMutableAttributedString *attri = [self expressionAttributedStringWithString:contentAttributedString];
    CGSize contentSize = [self sizeWithAttributedString:attri proSize:CGSizeMake(kviewWidth -self.headPictureFrame.size.width -80, MAXFLOAT)];
    self.contentFrame = CGRectMake(CGRectGetMaxX(self.headPictureFrame) +20, CGRectGetMidY(self.headPictureFrame) -10, contentSize.width, contentSize.height);
    self.layoutAttributedString = attri;
    
    //背景
    self.messageBackViewFrame = CGRectMake(CGRectGetMinX(self.contentFrame) -18, CGRectGetMinY(self.contentFrame) -12, self.contentFrame.size.width +35, self.contentFrame.size.height +35);
    
    if (self.messageBackViewFrame.size.height > self.headPictureFrame.size.height) {
        self.rowHeight = CGRectGetMaxY(self.messageBackViewFrame);
    }
    
}

//右
-(void)setRightLayoutWithModel:(ZPHMessage *)model {
    
    [super setRightLayoutWithModel:model];
    
    CGFloat kviewWidth = [UIScreen mainScreen].bounds.size.width;
    
    //内容文字
    NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc]init];
    [contentAttributedString appendAttributedString:[self getContentHtml:model.text]];
    NSRange rang = NSMakeRange(0, contentAttributedString.length);
    [contentAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:rang];
    [contentAttributedString addAttribute:NSKernAttributeName value:@1 range:rang];
    NSMutableAttributedString *attri = [self expressionAttributedStringWithString:contentAttributedString];
    CGSize contentSize = [self sizeWithAttributedString:attri proSize:CGSizeMake(kviewWidth -self.headPictureFrame.size.width -80, MAXFLOAT)];
    self.contentFrame = CGRectMake(kviewWidth - self.headPictureFrame.size.width -30 -contentSize.width, CGRectGetMidY(self.headPictureFrame) -10, contentSize.width, contentSize.height);
    
    self.layoutAttributedString = attri;
    
    //背景
    self.messageBackViewFrame = CGRectMake(CGRectGetMinX(self.contentFrame) -18, CGRectGetMinY(self.contentFrame) -12, self.contentFrame.size.width +35, self.contentFrame.size.height +35);
    
    if (self.messageBackViewFrame.size.height >self.headPictureFrame.size.height) {
        self.rowHeight = CGRectGetMaxY(self.messageBackViewFrame);
    }
    
}

-(NSMutableAttributedString *)expressionAttributedStringWithString:(id)string {
    
    NSAssert([string isKindOfClass:[NSString class]]||[string isKindOfClass:[NSAttributedString class]], @"string非字符串. %@",string);
    
    NSAttributedString *attributedString = nil;
    if ([string isKindOfClass:[NSString class]]) {
        attributedString = [[NSAttributedString alloc]initWithString:string];
    }else{
        attributedString = string;
    }
    if (attributedString.length <=0) {
        return [attributedString mutableCopy];
    }
    
    NSMutableAttributedString *resultAttributedString = [NSMutableAttributedString new];
    NSError *error;
    NSString *regexString =@"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";//正则表达式
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:&error];//创建一个正则表达式对象,存储匹配规则
    if (regex != nil) {
        NSArray *results = [regex matchesInString:attributedString.string options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [attributedString length])];
        
        //遍历表情,找到对应图像名称
        NSUInteger location = 0;
        for (NSTextCheckingResult *result in results) {
            
            NSRange range = result.range;
            NSAttributedString *subAttrStr = [attributedString attributedSubstringFromRange:NSMakeRange(location, range.location -location)];
            //先把非表情的部分加上去
            [resultAttributedString appendAttributedString:subAttrStr];
            //下次循环从表情的下一个位置开始
            location = NSMaxRange(range);
            NSAttributedString *expressionAttrStr = [attributedString attributedSubstringFromRange:range];//表情名称
            NSString *imageName = expressionAttrStr.string;
            
            if (imageName.length >0) {
                NSTextAttachment *attchImage = [[NSTextAttachment alloc]init];
                attchImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"emotion.bundle/%@",imageName]];//添加表情
                [resultAttributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attchImage]];
            }
        }
        
        if (location < [attributedString length]) {
            //到这说明最后面还有非表情字符串
            NSRange range = NSMakeRange(location, [attributedString length] - location);
            NSAttributedString *subAttrStr = [attributedString attributedSubstringFromRange:range];
            [resultAttributedString appendAttributedString:subAttrStr];
        }
    }
    
    return resultAttributedString;
}

- (NSMutableAttributedString *)getContentHtml:(NSString *)content {
    
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType,
                              NSCharacterEncodingDocumentAttribute : @(NSUTF8StringEncoding)};
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithData:data options:options documentAttributes:nil error:nil];
    
    // 设置段落格式
    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    para.lineSpacing = 2;
    para.paragraphSpacing = 5;
    [attStr addAttribute:NSParagraphStyleAttributeName value:para range:NSMakeRange(0, attStr.length)];
    
    // 设置文本的Font
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, attStr.length)];
    
    return attStr;
}


@end
