//
//  HLThirdAndFourthCell.h
//  hongdou
//
//  Created by 李龙 on 2020/6/26.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLThirdAndFourthCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;

- (void)setContentDic:(NSDictionary *)dic indexpath:(NSIndexPath *)indexpath;

@end

NS_ASSUME_NONNULL_END
