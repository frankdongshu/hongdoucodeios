//
//  AccountGenderItemView.h
//  ShuShangShuo
//
//  Created by LCC on 2018/11/17.
//  Copyright © 2018年 lanmao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AccountGenderItemView;
@protocol GenderDelegate <NSObject>

- (void)updateGenderWithIndex:(NSInteger)sender;
- (void)updateStatusWithIndex:(NSInteger)sender withView:(AccountGenderItemView *)itemView;
@end

typedef enum : NSUInteger {
    LeftRightType,
    TopBottomType,
    CustomType,
} AccountGenderItemType;

@interface AccountGenderItemView : UIView

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIButton *manButton;
@property (nonatomic, weak) UIButton *womenButton;
@property (nonatomic, weak) UIButton *thirdButton;

@property (nonatomic, copy) NSString *gender;
@property (nonatomic, weak) id<GenderDelegate>genderDelegate;

@property (nonatomic, assign) AccountGenderItemType type;
@end
