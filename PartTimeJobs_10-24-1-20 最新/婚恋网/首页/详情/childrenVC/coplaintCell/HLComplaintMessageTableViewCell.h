//
//  HLComplaintMessageTableViewCell.h
//  hongdou
//
//  Created by iMac on 2019/10/22.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLComplaintMessageTableViewCell : HXBaseTableViewCell<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UILabel *planceLabel;

@end

NS_ASSUME_NONNULL_END
