//
//  CSHomeGradeDetailModel.h
//  CSPartTimeJobs
//
//  Created by 这是一个笑脸 on 2019/7/18.
//  Copyright © 2019 FangPursuit. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@interface CSHomeGradeDetailModel : NSObject
@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger parentGradeID;
@end

NS_ASSUME_NONNULL_END
