//
//  ZPHMessageTableViewCellLayoutImage.m
//  ZHChatBar
//
//  Created by zph on 27/03/2018.
//  Copyright © 2018 zph. All rights reserved.
//

#import "ZPHMessageTableViewCellLayoutImage.h"

@implementation ZPHMessageTableViewCellLayoutImage

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
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.text]];
    
    UIImage *image = [self imageCompressForWidth:[UIImage imageWithData:data] targetWidth:kScreenWidth/3];
    
    self.contentFrame = CGRectMake(CGRectGetMaxX(self.headPictureFrame) +10, CGRectGetMinY(self.headPictureFrame), image.size.width, image.size.height);
    
    //背景
    self.messageBackViewFrame = CGRectMake(CGRectGetMinX(self.contentFrame), CGRectGetMinY(self.contentFrame), self.contentFrame.size.width, self.contentFrame.size.height +11);
    
    if (self.messageBackViewFrame.size.height >self.headPictureFrame.size.height) {
        self.rowHeight = CGRectGetMaxY(self.messageBackViewFrame);
    }
    
}

//右
-(void)setRightLayoutWithModel:(ZPHMessage *)model {
    
    [super setRightLayoutWithModel:model];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.text]];
    
    UIImage *image = [self imageCompressForWidth:[UIImage imageWithData:data] targetWidth:kScreenWidth/3];
    
    self.contentFrame = CGRectMake(kScreenWidth - self.headPictureFrame.size.width -20 - image.size.width, CGRectGetMinY(self.headPictureFrame), image.size.width, image.size.height);
    
    //背景
    self.messageBackViewFrame = CGRectMake(CGRectGetMinX(self.contentFrame), CGRectGetMinY(self.contentFrame), self.contentFrame.size.width, self.contentFrame.size.height +11);
    
    if (self.messageBackViewFrame.size.height >self.headPictureFrame.size.height) {
        self.rowHeight = CGRectGetMaxY(self.messageBackViewFrame);
    }
    
}

//指定宽度按比例缩放
-(UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    if (targetHeight>0) {
        
    }else{
        targetHeight = targetWidth;
    }
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    return newImage;
}


@end
