//
//  HLNearbyModel.m
//  婚恋网
//
//  Created by iMac on 2019/6/28.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLNearbyModel.h"

@implementation HLNearbyModel

/*
 1千-4千 4千-1万 1万-2万 2万-3万 3万-5万 5万以上
 */
- (void)mj_keyValuesDidFinishConvertingToObject{
    switch (self.income_level) {
        case 1:
            self.income = @"1千-4千";
            break;
        case 2:
            self.income = @"4千-1万";
            break;
        case 3:
            self.income = @"1万-2万";
            break;
        case 4:
            self.income = @"2万-3万";
            break;
        case 5:
            self.income = @"3万-5万";
            break;
        case 6:
            self.income = @"5万以上";
            break;
        default:
            break;
    }
}

@end
