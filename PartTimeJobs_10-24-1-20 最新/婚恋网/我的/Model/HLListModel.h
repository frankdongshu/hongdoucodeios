//
//  HLListModel.h
//  hongdou
//
//  Created by iMac on 2019/9/21.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLListModel : NSObject

@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) BOOL isSelect;

@end

@interface HLAllCityModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray *cityArray;

@end

@interface HLCityModel : NSObject

@property (nonatomic, copy) NSString *cityID;
@property (nonatomic, copy) NSString *cityName;

@end


NS_ASSUME_NONNULL_END

