//
//  HXBaseTableViewCell.h
//  HXNavigationController
//
//  Created by iMac on 16/8/1.
//  Copyright © 2016年 TheLittleBoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXBaseTableViewCell : UITableViewCell

@property(nonatomic,assign)BOOL hiddenSelfSeparator; //隐藏分割线 默认是NO

@property(nonatomic,assign)BOOL fullScreenSeparator; //全屏分割线 默认是NO

@end
