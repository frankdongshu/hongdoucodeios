//
//  XBZChatKeyBoardManager.m
//  XBZKeyBoard
//
//  Created by BigKing on 2018/10/19.
//  Copyright © 2018年 BigKing. All rights reserved.
//

#import "XBZChatKeyBoardManager.h"
#import "XBZKeyBoardDefine.h"

@implementation XBZChatKeyBoardManager

static XBZChatKeyBoardManager *_manager = nil;
static dispatch_once_t onceToken;

- (instancetype)init {
    if (self = [super init]) {
        [self confgiChatKeyBoardData];
    }
    return self;
}

+ (instancetype)sharedManager {
    
    dispatch_once(&onceToken, ^{
        if (!_manager) {
            _manager = [[self alloc] init];
        }
    });
    return _manager;
}

- (void)tearDown {
    
    _manager = nil;
    
    onceToken = 0l;
}

//设置默认的表情包及更多功能
- (void)confgiChatKeyBoardData {
    // group 两种表情风格可选
    XBZGroupEmojiModel *group1 = [XBZGroupEmojiModel initEmojiWithPlist:@"chatEmojis.plist" image:@"icon_emoji_group1"];
//    XBZGroupEmojiModel *group1 = [XBZGroupEmojiModel initEmojiWithPlist:@"emotion_icons.plist" fileName:@"Expression_" image:@"icon_emoji_group1"];

    XBZGroupEmojiModel *group2 = [XBZGroupEmojiModel initFaceWithFileName:@"panda" count:25 image:@"icon_emoji_group2"];

    
    [self configEmojisData:@[group1,group2]];
    

    XBZChatMoreItem *item1 = [XBZChatMoreItem initWithNormalImage:@"aio_icons_activity" highlightedImage:nil title:@"图片" font:15];
    XBZChatMoreItem *item2 = [XBZChatMoreItem initWithNormalImage:@"aio_icons_pacamera" highlightedImage:nil title:@"相机" font:15];
    
//    XBZChatMoreItem *item3 = [XBZChatMoreItem initWithNormalImage:@"aio_icons_location" highlightedImage:nil title:@"定位" font:15];

    
//    [self configMoreItems:@[item1, item2, item3]];
    
    [self configMoreItems:@[item1, item2]];
}

- (void)configEmojisData:(NSArray *)emojis {
    self->_groupEmojis = emojis;
}

- (void)configMoreItems:(NSArray<XBZChatMoreItem *> *)moreItems {
    self->_moreItems = moreItems;
}

- (void)dealloc {
    NSLog(@"XBZChatKeyBoardManager单例销毁了~~~~~~~");
}

@end
