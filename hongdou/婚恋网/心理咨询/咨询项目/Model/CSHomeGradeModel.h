//
//  CSHomeGradeModel.h
//  hongdou
//
//  Created by 李龙 on 2020/3/11.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSHomeGradeDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSHomeGradeModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSMutableArray <CSHomeGradeDetailModel*> *lists;

@end

NS_ASSUME_NONNULL_END
