//
//  HLExchangeReusableView.h
//  hongdou
//
//  Created by 维康1 on 2019/12/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HLExchangeReusableDeleagte <NSObject>

- (void)refreshTableView;

@end

@interface HLExchangeReusableView : UICollectionReusableView

@property (nonatomic,assign) id <HLExchangeReusableDeleagte>delegate;

@property (nonatomic, strong) UISwitch *theSwitch;

@property (nonatomic, assign) BOOL statu;

/**
 *  声明相应的数据模型属性,进行赋值操作,获取头视图或尾视图需要的数据.或者提供一个方法获取需要的数据.
 */
 
- (void)getSHCollectionReusableViewHearderButton:(UIButton *)button;


@end

NS_ASSUME_NONNULL_END
