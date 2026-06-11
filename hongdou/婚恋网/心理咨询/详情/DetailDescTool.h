//
//  DetailDescTool.h
//  hongdou
//
//  Created by 李龙 on 2020/3/15.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailDescTool : NSObject

+ (NSArray *)getLinesArrayOfStringInLabel:(UILabel *)label;

+ (NSAttributedString *)theRichText:(NSString *)string theRange:(NSUInteger)theRange changeRange:(NSInteger)changeRange color:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
