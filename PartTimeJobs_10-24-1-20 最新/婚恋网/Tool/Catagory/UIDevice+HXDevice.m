//
//  UIDevice+HXDevice.m
//  eplatform-edu
//
//  Created by iMac on 2017/7/19.
//  Copyright © 2017年 华夏大地教育网. All rights reserved.
//

#import "UIDevice+HXDevice.h"
#import <sys/utsname.h>

@implementation UIDevice (HXDevice)


- (NSString*)deviceModelName
{
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //iPhone 系列
    if ([deviceModel isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    
    if ([deviceModel isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    
    if ([deviceModel isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    
    if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    
    if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    
    if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    
    if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    
    if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    
    if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    
    if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    
    if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    
    if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    
    if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    
    if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    
    if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    
    if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    
    if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    
    if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    
    if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    
    if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    
    if ([deviceModel isEqualToString:@"iPhone10,1"])    return @"iPhone 8";
    
    if ([deviceModel isEqualToString:@"iPhone10,4"])    return @"iPhone 8";
    
    if ([deviceModel isEqualToString:@"iPhone10,2"])    return @"iPhone 8 Plus";
    
    if ([deviceModel isEqualToString:@"iPhone10,5"])    return @"iPhone 8 Plus";
    
    if ([deviceModel isEqualToString:@"iPhone10,3"])    return @"iPhone X";
    
    if ([deviceModel isEqualToString:@"iPhone10,6"])    return @"iPhone X";
    
    if ([deviceModel isEqualToString:@"iPhone11,8"])   return @"iPhone_XR";
    
    if ([deviceModel isEqualToString:@"iPhone11,2"])   return @"iPhone_XS";
    
    if ([deviceModel isEqualToString:@"iPhone11,4"])   return @"iPhone_XS_MAX";
    
    if ([deviceModel isEqualToString:@"iPhone11,6"])   return @"iPhone_XS_MAX";
    
    
    //iPod 系列
    
    if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    
    if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    
    if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    
    if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    
    if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    
    if ([deviceModel isEqualToString:@"iPod7,1"])      return @"iPod Touch 6G";
    
    //iPad 系列
    
    if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
    
    if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    
    if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    
    if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    
    if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2 (32nm)";
    
    if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPad mini (WiFi)";
    
    if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPad mini (GSM)";
    
    if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPad mini (CDMA)";
    
    if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3(WiFi)";
    
    if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3(CDMA)";
    
    if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3(4G)";
    
    if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    
    if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4 (4G)";
    
    if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
    
    if ([deviceModel isEqualToString:@"iPad4,1"]
        ||[deviceModel isEqualToString:@"iPad4,2"]
        ||[deviceModel isEqualToString:@"iPad4,3"])    return @"iPad Air";
    
    if ([deviceModel isEqualToString:@"iPad5,3"]
        ||[deviceModel isEqualToString:@"iPad5,4"])    return @"iPad Air 2";
    
    if ([deviceModel isEqualToString:@"iPad6,11"]
        ||[deviceModel isEqualToString:@"iPad6,12"])   return @"iPad 5";
    
    if ([deviceModel isEqualToString:@"i386"])         return @"Simulator";
    
    if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";
    
    if ([deviceModel isEqualToString:@"iPad4,4"]
        ||[deviceModel isEqualToString:@"iPad4,5"]
        ||[deviceModel isEqualToString:@"iPad4,6"])    return @"iPad mini 2";
    
    if ([deviceModel isEqualToString:@"iPad4,7"]
        ||[deviceModel isEqualToString:@"iPad4,8"]
        ||[deviceModel isEqualToString:@"iPad4,9"])    return @"iPad mini 3";
    
    if ([deviceModel isEqualToString:@"iPad5,1"]
        ||[deviceModel isEqualToString:@"iPad5,2"])    return @"iPad mini 4";
    
    if ([deviceModel isEqualToString:@"iPad6,7"]
        ||[deviceModel isEqualToString:@"iPad6,8"]
        ||[deviceModel isEqualToString:@"iPad7,1"]
        ||[deviceModel isEqualToString:@"iPad7,2"])    return @"iPad Pro 12_9 Inch";
    
    if ([deviceModel isEqualToString:@"iPad7,3"]
        ||[deviceModel isEqualToString:@"iPad7,4"])    return @"iPad Pro 10_5 Inch";
    
    if ([deviceModel isEqualToString:@"iPad6,3"]
        ||[deviceModel isEqualToString:@"iPad6,4"])    return @"iPad Pro 9_7 Inch";
    
    return deviceModel;
}

@end
