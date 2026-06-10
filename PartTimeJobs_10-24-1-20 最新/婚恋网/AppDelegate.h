//
//  AppDelegate.h
//  婚恋网
//
//  Created by iMac on 2019/2/28.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

