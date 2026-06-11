//
//  CSCityDetailModel.h
//  CSPartTimeJobs
//
//  Created by 这是一个笑脸 on 2019/7/19.
//  Copyright © 2019 FangPursuit. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface CSCityDetailModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSMutableArray *lists;

@end

NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN

@interface CSCityInfoModel : NSObject
@property (nonatomic, copy) NSString *city;
@property (nonatomic, assign) NSInteger ID;

@end

NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN

// 筛选
@interface CSCityChooseModel : NSObject
@property (nonatomic, copy) NSString *habitation; // 城市
@property (nonatomic, copy) NSString *cou; // 个数

@end

NS_ASSUME_NONNULL_END

