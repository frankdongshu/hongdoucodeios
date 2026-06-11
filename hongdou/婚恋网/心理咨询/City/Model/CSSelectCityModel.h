//
//  CSSelectCityModel.h
//  CSPartTimeJobs
//
//  Created by 这是一个笑脸 on 2019/7/19.
//  Copyright © 2019 FangPursuit. All rights reserved.
//

#import "CSCityDetailModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface CSSelectCityModel : NSObject
@property (nonatomic, strong) CSCityDetailModel *major;

@property (nonatomic, strong) NSMutableArray <CSCityDetailModel*>*all;

@end

NS_ASSUME_NONNULL_END
