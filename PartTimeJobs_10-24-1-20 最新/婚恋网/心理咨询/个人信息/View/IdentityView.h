//
//  IdentityView.h
//  PartTimeJobs
//
//  Created by 维康1 on 2020/4/28.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    IdentityDefalut,
    IdentityFaBu,
} IdentityType;

typedef void(^SureBlock)(void);
typedef void(^IdenBlock)(NSString *string);

@interface IdentityView : UIView

- (instancetype)initWithFrame:(CGRect)frame andSelectString:(NSString *)select;


@property (nonatomic, assign) IdentityType identityType;

@property (nonatomic, copy) SureBlock sureBlock;

@property (nonatomic, copy) IdenBlock idenBlock;

-(void)showSelf;
-(void)removeSelf;

@end

NS_ASSUME_NONNULL_END
