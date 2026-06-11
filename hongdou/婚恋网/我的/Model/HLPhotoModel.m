//
//  HLPhotoModel.m
//  hongdou
//
//  Created by iMac on 2019/9/26.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLPhotoModel.h"

@implementation HLPhotoModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"photoID":@"id"
             };
}

@end

@implementation HLAlbumDetails

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"albumId":@"id",
             @"photoArray":@"pics"
             };
}
+ (NSDictionary *)mj_objectClassInArray{
    return @{@"photoArray":@"HLPhotoModel"};
}

- (void)mj_keyValuesDidFinishConvertingToObject{
    CGFloat higth = 105;
    if (_photoArray.count>0) {
        CGFloat width= (kScreenWidth - 109) / 3.f ;
        higth += (_photoArray.count/3 + 1) * width;
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.content attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]}];
    
    CGRect rect = [string boundingRectWithSize:CGSizeMake(kScreenWidth - 89, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
    self.cellHight =  higth +rect.size.height +5;
}

@end

@implementation HLAlbumModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"albumArray":@"val"
             };
}
+ (NSDictionary *)mj_objectClassInArray{
    return @{@"albumArray":@"HLAlbumDetails"};
}
@end

@implementation HLAlbumUploadModel


@end
