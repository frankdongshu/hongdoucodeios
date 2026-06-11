//
//  HXUserDetailTableViewCell.h
//  婚恋网
//
//  Created by iMac on 2019/3/29.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXUserDetailTableViewCell : HXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *promptLable;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

- (void)setCellTitle:(NSString *)title withprompt:(NSString *)prompt withContent:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
