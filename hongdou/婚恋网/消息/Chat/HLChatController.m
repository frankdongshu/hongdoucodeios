//
//  HLChatController.m
//  hongdou
//
//  Created by 维康1 on 2021/7/29.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLChatController.h"
#import "ZPHMessageTableViewCellLayout.h"
#import "ZPHMessageTableViewCell.h"
#import "ZPHMessageTableViewCellText.h"
#import "ZPHMessageTableViewCellImage.h"
#import "ZPHMessageTableViewCellVoice.h"
#import "ZPHMessageTableViewCellHtml.h"
#import "ZPHMessageTableViewCellCard.h"
#import "ZPHChatManager.h"
#import "HLOpenMemberViewController.h"
#import "HLFrienderDetailViewController.h"
#import "TZImagePickerController.h"
#import "JCHATFileManager.h" // 删除本地文件

#import "HLOpenMemberViewController.h" // 购买会员

#import <RPSDK/RPSDK.h>

#import "HDPreviewPhotoController.h"
#import "HLChatGifPopView.h"
#import "HLGoVipView.h"

@interface HLChatController ()<UITableViewDelegate,UITableViewDataSource,ZPHMessageTableViewCellDelegate,XBZChatKeyBoardViewDelegate,TZImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,showRecvMsgDelegate> {
    
    NSDictionary *_isSend; // 能否发送
    int _page; // 聊天记录分页
}

// 输入法
@property (nonatomic, strong) XBZChatKeyBoardView *keyBoardView;

// 打招呼图标
@property (nonatomic, strong) UIImageView *heartImgV;

// 消息列表
@property (nonatomic,strong)UITableView *messageTableView;

// 消息数组
@property (nonatomic,strong)NSMutableArray *messageArray;

// 服务端发来的Json串需要拼接
@property (nonatomic, strong) NSMutableString *messageString;

// 记录上一条消息时间
@property (nonatomic, strong) NSString *onTimeStr;

@end

@implementation HLChatController

- (void)viewWillAppear:(BOOL)animated {
    
    XMUserManager *userManager = [XMUserManager sharedInstance];
    userManager.showRecvMsgDelegate = self;
    [userManager setAppAccount:[LoginManager defaultManager].account];
    [userManager userLogin];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSString *name = kISNullObject(self.chatDic[@"cname"])?@"未知用户":self.chatDic[@"cname"];
    self.sc_navigationBar.title = name;
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.view.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0];
    
    //消息列表
    _messageTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight-kNavBarHeight -64) style:UITableViewStylePlain];
    _messageTableView.backgroundColor = [UIColor clearColor];
    _messageTableView.dataSource = self;
    _messageTableView.delegate = self;
    _messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_messageTableView];
    _messageTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    //添加列表点击
    UITapGestureRecognizer *tableViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    tableViewTap.cancelsTouchesInView = NO;
    [_messageTableView addGestureRecognizer:tableViewTap];


    
    self.keyBoardView =  [[XBZChatKeyBoardView alloc] initWithNavigationBarTranslucent:NO];
    self.keyBoardView.delegate = self;
    self.keyBoardView.isChating = YES;
    self.keyBoardView.isSending = YES;
    [self.view addSubview:self.keyBoardView];
    
    
    self.heartImgV = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth/2-40, self.keyBoardView.origin.y-80, 80, 80)];
    [self.view addSubview:self.heartImgV];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topViewTap:)];
    self.heartImgV.userInteractionEnabled = YES;
    [self.heartImgV addGestureRecognizer:tap];
    
    
    //注册cell
    [_messageTableView registerClass:[ZPHMessageTableViewCellText class] forCellReuseIdentifier:@"OwnerOther_text"];
    [_messageTableView registerClass:[ZPHMessageTableViewCellImage class] forCellReuseIdentifier:@"OwnerOther_image"];
    [_messageTableView registerClass:[ZPHMessageTableViewCellVoice class] forCellReuseIdentifier:@"OwnerOther_voice"];
    [_messageTableView registerClass:[ZPHMessageTableViewCellCard class] forCellReuseIdentifier:@"OwnerOther_card"];
    [_messageTableView registerClass:[ZPHMessageTableViewCellHtml class] forCellReuseIdentifier:@"OwnerOther_html"];
    
    [_messageTableView registerClass:[ZPHMessageTableViewCellText class] forCellReuseIdentifier:@"OwnerSelf_text"];
    [_messageTableView registerClass:[ZPHMessageTableViewCellImage class] forCellReuseIdentifier:@"OwnerSelf_image"];
    [_messageTableView registerClass:[ZPHMessageTableViewCellVoice class] forCellReuseIdentifier:@"OwnerSelf_voice"];
    [_messageTableView registerClass:[ZPHMessageTableViewCellCard class] forCellReuseIdentifier:@"OwnerSelf_card"];
    [_messageTableView registerClass:[ZPHMessageTableViewCellHtml class] forCellReuseIdentifier:@"OwnerSelf_html"];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    header.automaticallyChangeAlpha = YES;
    
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    
    _messageTableView.mj_header = header;
    
    _page = 1;
    
    
    // 获取聊天记录
    [self requestChatRecordsWithHeaderRef:NO];
    
    // 客服发的超链接, 进行跳转
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushLinkVC:) name:@"NEW_USER_LINK" object:nil];
    
    // 查看图片
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkImgClick:) name:@"CHECK_IMG" object:nil];
    
    
    // 获取Gif动图
    [self requestHeartImg];
    
    // 发送消息
    [self isSendMessage];
    
}

- (void)topViewTap:(UITapGestureRecognizer *)tap {
    
    HLChatGifPopView *pView = [[HLChatGifPopView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    pView.SelectBlock = ^(NSString *uid) {
        
        // 图片消息体
        NSDictionary *params = @{
            @"uid":[LoginManager defaultManager].userid,
            @"mobile":self.chatDic[@"cmobile"],
            @"chead":[LoginManager defaultManager].avatar,
            @"uhead":self.chatDic[@"chead"],
            @"text":uid,
            @"facility":@"iOS",
            @"cut":@"pic",
            @"time":[self currentTime],
            @"ontime":self.onTimeStr
        };

        self.onTimeStr = params[@"time"];

        // 发送信息至服务器
        [self uploadFriendsDialogueWithMessage:params];

        // 发送信息更新界面
        [self addMessageWithDictionary:params];
        
    };
    
    [pView showSelf];
    
}

// 获取Gif动图
- (void)requestHeartImg {
    
    NSDictionary *dic = @{
        @"sign":@"IMhi"
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/index/notice" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/index/notice %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [self.heartImgV sd_setImageWithURL:[NSURL URLWithString:dictionary[@"data"][@"val"]]];
            
        } else {
            
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

// 收到消息
- (void)showRecvMsg:(MIMCMessage *)packet user:(MCUser *)user {
    
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:[packet getPayload] options:NSJSONReadingMutableLeaves error:nil];
    
    // 防止和多个人聊天, 同时进入聊天页面显示
    if (![[responseJSON[@"uid"] stringValue] isEqualToString:[self.chatDic[@"cid"] stringValue]]) {
        return;
    }
    
    // 发送信息更新界面
    [self addMessageWithDictionary:responseJSON];
    
    // 设置已读
    [self requsetRead];
    
}

// 收到服务端发送过来的消息
- (void)SRWebSocketDidReceiveMsg:(NSNotification *)note {
    
    NSString * message = note.object;
    NSLog(@"收到数据: %@",message);
    
    if (kISNullObject(message)) {
        return;
    }
    
    
    [self.messageString appendString:message];
    
    
    if ([message containsString:@"</json>"]) {
        
        [self.messageString deleteCharactersInRange:NSMakeRange(0, 6)];
        [self.messageString deleteCharactersInRange:NSMakeRange(self.messageString.length-7, 7)];
        
        
        NSDictionary *dic = [self dictionaryWithJsonString:self.messageString];
        
        NSLog(@"收到的数据: %@",dic);
        
        
        // 防止和多个人聊天, 同时进入聊天页面显示
        if (![[dic[@"uid"] stringValue] isEqualToString:[self.chatDic[@"cid"] stringValue]]) {
            return;
        }
        
        NSDictionary *params = @{
            @"uid":dic[@"uid"],
            @"cid":dic[@"cid"],
            @"data":@"",
            @"facility":@"iOS",
            @"text":dic[@"text"],
            @"type":dic[@"type"],
            @"uhead":dic[@"user"][@"head"],
            @"time":dic[@"time"],
            @"ontime":self.onTimeStr
        };
        
        self.onTimeStr = dic[@"time"];
        
        [self addMessageWithDictionary:params];
        
        // 设置为已读
        [self requsetRead];
        
        self.messageString = [NSMutableString stringWithString:@""];
    }
    
}

// json转字典
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if (err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    
    return dic;
}

// 查看图片
- (void)checkImgClick:(NSNotification *)notifi {
    
    NSString *url = notifi.object;
    
    NSInteger idx = 0;
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    for (int i=0; i<self.messageArray.count; i++) {
        
        ZPHMessageTableViewCellLayout *layout = self.messageArray[i];
        
        if (layout.model.category == 1) {
            
            [arr addObject:layout.model.text];
        }
        
    }
    
    for (int j=0; j<arr.count; j++) {
        if ([arr[j] isEqualToString:url]) {
            idx = j;
        }
    }
    
    HDPreviewPhotoController *previewVC = [[HDPreviewPhotoController alloc] init];
    previewVC.hidesBottomBarWhenPushed = YES;
    previewVC.picArray = arr;
    previewVC.selectIdx = idx;
    [self.navigationController pushViewController:previewVC animated:YES];
    
}

// 客服发来的超链接富文本跳转页面
- (void)pushLinkVC:(NSNotification *)notifi {
    
    NSArray *checkArr = notifi.object;
    
    if (checkArr.count == 1) { // 只有一个连接, 直接跳转
        
        NSString *linkStr = [checkArr[0] URL].absoluteString;
        
        if ([linkStr isEqualToString:@"paraches://rzym"]) { // 去认证
            // 头像认证
            [self settingClick];
        } else if ([linkStr isEqualToString:@"paraches://gmym"]) { // 去购买
            HLGoVipViewController *vc = [[HLGoVipViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
        } else {
            [self.view showError:@"未知超链接"];
        }
        
        return;
    }
    
    
                
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    for (NSTextCheckingResult *result in checkArr) {
        NSString *urlStr = result.URL.absoluteString;
        
        NSString *str = [urlStr isEqualToString:@"paraches://rzym"]?@"去认证":[urlStr isEqualToString:@"paraches://gmym"]?@"去购买":@"未知超链接";
        
        [alertController addAction:[UIAlertAction actionWithTitle:str style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if ([urlStr isEqualToString:@"paraches://rzym"]) { // 去认证
                
                // 头像认证
                [self settingClick];
                
            } else if ([urlStr isEqualToString:@"paraches://gmym"]) { // 去购买
                HLGoVipViewController *vc = [[HLGoVipViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
                
            } else {
                
                [self.view showError:@"未知链接"];
            }
            
        }]];
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
    
}

// 获取聊天记录
- (void)requestChatRecordsWithHeaderRef:(BOOL)isRef {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"cid":self.chatDic[@"cid"],
        @"page":@(_page)
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/im/history" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/im/history: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            NSArray *arr = dictionary[@"data"];
            
            if (arr.count == 0) { // 没有消息了
                [self.messageTableView.mj_header endRefreshing];
                
                return;
            }
            
            
            if (isRef) { // 上拉刷新
                
                NSInteger oldCnt = [self.messageArray count];
                
                for (NSDictionary *dict in [arr reverseObjectEnumerator]) {
                    
                    [dict setValue:self.onTimeStr forKey:@"ontime"];
                    
                    ZPHMessageTableViewCellLayout *layout = [[ZPHMessageTableViewCellLayout alloc] initWithDictionary:dict];
                    //保存到数组
                    [self.messageArray insertObject:layout atIndex:0];
                    
                    
                    self.onTimeStr = dict[@"time"];
                    
                }
                
                [self.messageTableView reloadData];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageArray.count - oldCnt inSection:0];
                [self.messageTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                
            }
            else {
                
                // 记录不为0, 走这个
                [self requsetRead]; // 设置已读
                
                for (NSDictionary *dict in arr) {
                    
                    [dict setValue:self.onTimeStr forKey:@"ontime"];
                    
                    ZPHMessageTableViewCellLayout *layout = [[ZPHMessageTableViewCellLayout alloc] initWithDictionary:dict];
                    //保存到数组
                    [self.messageArray addObject:layout];
                    
                    
                    self.onTimeStr = dict[@"time"];
                }
                
                [self.messageTableView reloadData];
                
            }
            
            
            [self.messageTableView.mj_header endRefreshing];
            

            
            
            if (!isRef) { // 针对刚进页面
                // 回到底部
                if (self.messageArray.count != 0) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [UIView animateWithDuration:0.15 animations:^{
                            [self.messageTableView setFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight-64-kSafeAreaBottom-kNavBarHeight)];
                            NSIndexPath * lastIndex = [NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0];
                            [self tableviewScrollToRowWithIndex:lastIndex];
                            
                        } completion:nil];
                    });
                }
            }
            
            
        } else {
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}


// 防止没注销监听退出该界面还走监听方法
//- (void)viewDidDisappear:(BOOL)animated {
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

- (void)dealloc {
    
    NSLog(@"控制器已销毁,注销监听");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

// 下拉更多聊天记录
- (void)loadNewData {
    
    _page++;
    
    [self requestChatRecordsWithHeaderRef:YES];
    
}

// 列表点击事件
- (void)hideKeyboard {
    [self.keyBoardView hideBottomView];
}

// 列表将要拖动
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [self.keyBoardView hideBottomView];
//}

#pragma mark --UITableViewDataSoure
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZPHMessageTableViewCellLayout *layout = self.messageArray[indexPath.row];
    
    NSString *ownerKey; NSString *typeKey;
    
    
    if ([[NSString stringWithFormat:@"%@",layout.model.uid] isEqualToString:[LoginManager defaultManager].userid]) {
        ownerKey = @"OwnerSelf";
    } else {
        ownerKey = @"OwnerOther";
    }
    
    switch (layout.model.category) {
        case 0: typeKey = @"text"; break;
        case 1: typeKey = @"image"; break;
        case 2: typeKey = @"voice"; break;
        case 3: typeKey = @"card"; break;
        case 4: typeKey = @"html"; break;
    }
    
    
    NSString *identifier = [NSString stringWithFormat:@"%@_%@",ownerKey,typeKey];
    ZPHMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    
    if (indexPath.row < self.messageArray.count) {
        cell.layout = layout;
    }
    
    return cell;
}

#pragma mark - ZPHMessageTableViewCellDelegate

// 点击头像判断自己是否是发送方
- (void)requestReceived:(BOOL)isReceived {
    
    if (isReceived) { // 自己
        
        HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
        
        HLUser *userInfo = [[HLUser alloc] init];
        userInfo.username = [LoginManager defaultManager].account;
        detailVC.userInfo = userInfo;
        detailVC.userId = [LoginManager defaultManager].userid;
        
        [self.navigationController pushViewController:detailVC animated:YES];
        
    } else { // 对方
        
        HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
        
        HLUser *userInfo = [[HLUser alloc] init];
        userInfo.username = self.chatDic[@"cmobile"];
        detailVC.userInfo = userInfo;
        detailVC.isChatting = YES;
        detailVC.refreshBlock  = ^{
            
        };
        detailVC.removeBlock = ^{
            
        };
        
        [self.navigationController pushViewController:detailVC animated:YES];
        
    }
    
}

#pragma mark --UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.messageArray.count) {
        ZPHMessageTableViewCellLayout *layout = self.messageArray[indexPath.row];
        return layout.rowHeight;
    }else {
        return 0;
    }
}

- (void)addMessageWithDictionary:(NSDictionary *)messageDictionary {
    
    NSLog(@"发送的消息体: %@",messageDictionary);
    
    //转模型
    ZPHMessageTableViewCellLayout *layout = [[ZPHMessageTableViewCellLayout alloc] initWithDictionary:messageDictionary];
    
    //保存到数组
    [self.messageArray addObject:layout];
    
    //更新ui
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSIndexPath* insertion = [NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0];
        [self.messageTableView reloadData];
        [self tableviewScrollToRowWithIndex:insertion];
    });
}

#pragma mark - XBZChatKeyBoardViewDelegate

//发送文本，考虑到表情（🙂&[微笑]）上传时需要将原文传给服务器，展示的时候才是显示转换后的文字
- (void)chatKeyBoardViewSendTextMessage:(NSMutableAttributedString *)text originText:(NSString *)originText {
    
    if (kISNullObject(originText)) {
        return;
    }
    
    // 自定义消息体
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"mobile":self.chatDic[@"cmobile"],
        @"chead":[LoginManager defaultManager].avatar,
        @"uhead":self.chatDic[@"chead"],
        @"text":originText,
        @"facility":@"iOS",
        @"cut":@"text",
        @"time":[self currentTime],
        @"ontime":self.onTimeStr
    };
    
    self.onTimeStr = params[@"time"];
    
    // 发送信息至服务器
    [self uploadFriendsDialogueWithMessage:params];

    // 发送信息更新界面
    [self addMessageWithDictionary:params];
    
    
//    [ZPHChatManager sendChatMessageWithContent:message answerBlock:^(id data) { // 机器人回答
//
//        NSLog(@"请求到的data = %@",data);
//        NSDictionary *dataDictionary = data;
//        NSArray *results = dataDictionary[@"results"];
//        for (NSDictionary *resultDict in results) {
//            NSDictionary *valuesDict = resultDict[@"values"];
//            [self addMessageWithDictionary:@{@"category":@0,@"content":valuesDict[@"text"]} isSelf:NO];
//
//        }
//    }];
    
    
}

// 发送语音
- (void)chatKeyBoardViewSendVoiceMessage:(nonnull NSDictionary *)voicePath {
  
    NSString *voiceDuration = [voicePath objectForKey:@"duration"];
    NSString *voicePathStr  = [voicePath objectForKey:@"path"];
    
    if ([voiceDuration integerValue]<0.5) {
        return;
    }
    
    // 上传音频文件
    [self uploadAudioWithLocUrl:voicePathStr locUrlDur:[NSString stringWithFormat:@"%d",[voiceDuration intValue]]];
    
}

// 点击更多
- (void)chatKeyBoardViewSelectMoreImteTitle:(NSString *)title index:(NSInteger)index {
    
    if (index == 0) {
        // 照片
        [self photoClick];
        
    }
    if (index == 1) {
        // 相机
        [self cameraClick];
    }
    
}

// 调取相册
- (void)photoClick {
    [self pushTZImagePickerController];
}

// 调取相机
- (void)cameraClick {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSString *requiredMediaType = (NSString *)kUTTypeImage;
        NSArray *arrMediaTypes=[NSArray arrayWithObjects:requiredMediaType,nil];
        [picker setMediaTypes:arrMediaTypes];
        picker.showsCameraControls = YES;
        picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        picker.editing = YES;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark - TZImagePickerController

- (void)pushTZImagePickerController {
   
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    // imagePickerVc.barItemTextColor = [UIColor redColor];
    // imagePickerVc.naviBgColor = [UIColor whiteColor];
    // imagePickerVc.navigationBar.translucent = NO;
    
#pragma mark - 五类个性化设置，这些参数都可以不传，此时会走默认设置
    
    [imagePickerVc setUiImagePickerControllerSettingBlock:^(UIImagePickerController *imagePickerController) {
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    }];

    imagePickerVc.iconThemeColor = [UIColor colorWithHex:0x5d57ed];
    
    
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.allowPickingGif = NO;
//    imagePickerVc.allowPickingMultipleVideo = YES; // 是否可以多选视频
    imagePickerVc.alwaysEnableDoneBtn = YES;
    
    // 设置是否显示图片序号
    imagePickerVc.showSelectedIndex = YES;
    
    imagePickerVc.showPhotoCannotSelectLayer = YES;
    
    /// 5. 单选模式,maxImagesCount为1时才生效
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = NO;
    imagePickerVc.needCircleCrop = NO;
    // 设置竖屏下的裁剪尺寸
    NSInteger left = 30;
    NSInteger widthHeight = kScreenWidth - 2 * left;
    NSInteger top = (kScreenHeight  - widthHeight) / 2;
    imagePickerVc.cropRect = CGRectMake(left, top, widthHeight, widthHeight);
    imagePickerVc.scaleAspectFillCrop = YES;
   
    
#pragma mark - 到这里为止
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
    }];
    
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
//    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
//    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    
    // 上传图片
    [self uploadPhoto:photos assets:assets];
    
//    [self.keyBoardView hideBottomView];
    
}

// 相机,相册Finish的代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.movie"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.view showTostWithMessage:@"不支持视频发送"];
        return;
    }
    UIImage *image;
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // 上传图片
    [self uploadPhoto:@[image] assets:@[]];
    [self.keyBoardView hideBottomView];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//发送大表情图片
- (void)chatKeyBoardViewSendPhotoMessage:(nonnull NSString *)photo {
    NSLog(@"photoMessage:%@", photo);
    
    UIImage *img = [UIImage imageNamed:photo];
    
    // 上传图片
    [self uploadPhoto:@[img] assets:@[]];
    
}

// 上传图片
- (void)uploadPhoto:(NSArray *)imags assets:(NSArray *)assets {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // 设置时间格式
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
    
    
    [self.view showLoadMessageAtCenter:@"请稍后.."];
    
    [HLHTTPSessionManager postDataWithNSString:HLUPLoad_AlbumImages withDictionary:@{@"uid":[LoginManager defaultManager].userid} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if (assets.count == 0) {
            // 上传图片
            [imags enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                UIImage *img = obj;
                NSData *imageData = UIImageJPEGRepresentation(img,0.5);
                [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"image[%d]",idx] fileName:fileName mimeType:@"image/jpeg"];
                
            }];
            
            return;
        }
        
        PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
        
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.synchronous = YES;
        
        [assets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAsset *aset = obj;
            
            [imageManager requestImageDataForAsset:aset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                
                if ([dataUTI isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                    // 上传GIF
                    [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"image[%d]",idx] fileName:fileName mimeType:@"image/gif"];
                    
                } else {
                    // 上传图片
                    NSData *imageData = UIImageJPEGRepresentation(imags[idx],0.5);
                    [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"image[%d]",idx] fileName:fileName mimeType:@"image/jpeg"];
                }
                
            }];
            
        }];
        
    } success:^(NSDictionary *dictionary) {
        
        HDLog(@"聊天界面上传图片: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",dictionary[@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [self.view hide];
            
            NSArray *imgUrlArr = dictionary[@"data"];
            
            for (NSDictionary *dic in imgUrlArr) {
                // 图片消息体
                NSDictionary *params = @{
                    @"uid":[LoginManager defaultManager].userid,
                    @"mobile":self.chatDic[@"cmobile"],
                    @"chead":[LoginManager defaultManager].avatar,
                    @"uhead":self.chatDic[@"chead"],
                    @"text":[dic[@"var"] stringValue],
                    @"facility":@"iOS",
                    @"cut":@"pic",
                    @"time":[self currentTime],
                    @"ontime":self.onTimeStr
                };

                self.onTimeStr = params[@"time"];

                // 发送信息至服务器
                [self uploadFriendsDialogueWithMessage:params];

                // 发送信息更新界面
                [self addMessageWithDictionary:params];
                
            }
            
        } else {
            [self.view showTitle:dictionary[@"msg"]];
        }
        
    } failure:^(NSError *error) {
        [self.view showError:@"上传图片失败"];
    }];
    
}

// 上传音频文件
- (void)uploadAudioWithLocUrl:(NSString *)locUrl locUrlDur:(NSString *)dur {
    
    [self.view showLoadMessageAtCenter:@"请稍后.."];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.mp3",str];
    
    [HLHTTPSessionManager postDataWithNSString:HLUPLoad_HeaderImage withDictionary:@{@"uid":[LoginManager defaultManager].userid} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSError *error;
        BOOL success = [formData appendPartWithFileURL:[NSURL fileURLWithPath:locUrl] name:@"image" fileName:fileName mimeType:@"audio/mpeg" error:&error];
        if (!success) {
            NSLog(@"appendPartWithFileURL error: %@", error);
        }
        
    } success:^(NSDictionary *dictionary) {
        NSLog(@"上传音频成功: %@",dictionary);
        
        // 删除本地音频
        if ([JCHATFileManager deleteFile:locUrl]) {
            NSLog(@"已删除本地音频!");
        } else {
            NSLog(@"删除本地音频失败!");
        }
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [self.view hide];
            
            // 语音消息体
            NSDictionary *params = @{
                @"uid":[LoginManager defaultManager].userid,
                @"mobile":self.chatDic[@"cmobile"],
                @"chead":[LoginManager defaultManager].avatar,
                @"uhead":self.chatDic[@"chead"],
                @"text":[NSString stringWithFormat:@"%@#%@",dictionary[@"data"][@"url"],dur],
                @"facility":@"iOS",
                @"cut":@"voi",
                @"time":[self currentTime],
                @"ontime":self.onTimeStr
            };
            
            self.onTimeStr = params[@"time"];

            // 发送信息至服务器
            [self uploadFriendsDialogueWithMessage:params];

            // 发送信息更新界面
            [self addMessageWithDictionary:params];
            
            
            
        } else {
            [self.view showError:dictionary[@"msg"]];
        }
        
    } failure:^(NSError *error) {
        
        [self.view showError:[error localizedDescription]];
    }];
    
}

// 不能发送提示购买会员
- (void)openBuyVipViewWithMessage {
    
//    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:self->_isSend[@"err"] preferredStyle:UIAlertControllerStyleAlert];
//
//    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"购买会员(低至1.5元/月)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//        //开通会员
//        HLOpenMemberViewController *openVC = [[HLOpenMemberViewController alloc] init];
//        openVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:openVC animated:YES];
//
//    }];
//
//    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"头像认证(赠送永久VIP)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//        // 是否认证过
//        [self settingClick];
//
//    }];
//    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//    }];
//
//    [action1 setValue:REDColor forKey:@"titleTextColor"];
//    [action2 setValue:REDColor forKey:@"titleTextColor"];
//
//    [alertC addAction:action1];
//    [alertC addAction:action2];
//    [alertC addAction:action3];
//
//    [self presentViewController:alertC animated:YES completion:nil];
    
    
    HLGoVipView *gView = [[HLGoVipView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    gView.SelectBlock = ^{
      
        //开通会员
        HLGoVipViewController *openVC = [[HLGoVipViewController alloc] init];
        openVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:openVC animated:YES];
        
    };
    
    [gView showSelf];
    
}

// 是否认证
- (void)settingClick {
    
    [MBProgressHUD showLoading];
    
    // 是否人脸认证
    [HLHTTPSessionManager postDataWithNSString:@"/user/certification" withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"certification: %@",dictionary);
        
        [MBProgressHUD hideLoading];
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            if (![[dictionary[@"data"][@"VerifyStatus"] stringValue] isEqualToString:@"1"]) { // 未认证
                
                [self authFace];
                
            } else { // 已认证
                
                [MBProgressHUD showMessage:@"已认证" view:nil];
            }
            
        } else if ([[dictionary[@"code"] stringValue] isEqualToString:@"202"]) {
            // code 202 尚未认证
            [self authFace];
            
        } else {
            
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
        [MBProgressHUD showMessage:@"判断人脸是否认证失败" view:nil];
        
    }];
    
}

// 去人脸认证
- (void)authFace {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"pic":[LoginManager defaultManager].avatar
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/getAlibabaToken" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        [MBProgressHUD hideLoading];
        
        NSLog(@"getAlibabaToken: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            [MBProgressHUD hideLoading];
            
            [RPSDK startWithVerifyToken:dictionary[@"data"][@"VerifyToken"]
                         viewController:self
                             completion:^(RPResult * _Nonnull result) {
                // 建议接入方调用实人认证服务端接口 DescribeVerifyResult，
                // 来获取最终的认证状态，并以此为准进行业务上的判断和处理。
                NSLog(@"真人头像认证结果：%@", result);
                switch (result.state) {
                    case RPStatePass:
                        // 认证通过。
                        NSLog(@"真人头像认证成功");
                        break;
                    case RPStateFail:
                        // 认证不通过。
                        break;
                    case RPStateNotVerify:
                        // 未认证。
                        // 通常是用户主动退出或者姓名身份证号实名校验不匹配等原因导致。
                        // 具体原因可通过 result.errorCode 和 result.message 来区分（详见错误码说明）。
                        break;
                }
            }];
            
        } else {
            [MBProgressHUD showMessage:@"获取Token失败" view:nil];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

// 获取当前时间戳
- (NSString *)currentTime{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0]; //获取当前时间0秒后的时间
    NSTimeInterval time = [date timeIntervalSince1970]; // *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

// 设置已读
- (void)requsetRead {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"mobile":self.chatDic[@"cmobile"]
    };
    
    NSLog(@"inRead: %@",params);
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:@"/friends/inRead" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"inRead: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
        } else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"touchesbegan");
    
}

- (void)chatBarFrameDidChangeFrame:(CGRect)frame {
    __weak HLChatController *weakSelf = self;
    
    if (frame.origin.y == _messageTableView.frame.size.height) {
        return;
    }
    
    if (self.messageArray.count != 0) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.15 animations:^{
                [weakSelf.messageTableView setFrame:CGRectMake(0, kNavBarHeight, self.view.frame.size.width, frame.origin.y-kNavBarHeight)];
                NSIndexPath * lastIndex = [NSIndexPath indexPathForRow:weakSelf.messageArray.count-1 inSection:0];
                [weakSelf tableviewScrollToRowWithIndex:lastIndex];
                
                weakSelf.heartImgV.frame = CGRectMake(kScreenWidth/2-40, self.keyBoardView.origin.y-80, 80, 80);
                
            } completion:nil];
        });
    }
}

// 上传聊天
- (void)uploadFriendsDialogueWithMessage:(NSDictionary *)dic {
    
    NSLog(@"消息体: %@",dic);
   
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:@"/friends/dialogue" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"上传聊天记录: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            NSString *jsonString = [self convertToJsonData:dic];
            
            [[[XMUserManager sharedInstance] getUser] sendMessage:dic[@"mobile"] payload:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
            
        } else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

- (NSString *)convertToJsonData:(NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    
    if (!jsonData) {
        NSLog(@"%@",error);
    } else {
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

    //去掉字符串中的反斜杠
    NSRange range3 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\\" withString:@"" options:NSLiteralSearch range:range3];
    
    return mutStr;
}

//滑动
-(void)tableviewScrollToRowWithIndex:(NSIndexPath *)lastIndex {
    
    dispatch_queue_t queue = dispatch_queue_create("MessageArray", DISPATCH_QUEUE_SERIAL);//串行队列
    
    dispatch_async(queue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.messageTableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        });
    });
}

#pragma mark --lazy loading
// 消息数组
-(NSMutableArray *)messageArray {
    
    if (!_messageArray) {
        _messageArray = [[NSMutableArray alloc]init];
    }
    return _messageArray;
}

// 拼接服务器返来的json串
- (NSMutableString *)messageString {
    if (!_messageString) {
        _messageString = [[NSMutableString alloc] init];
    }
    return _messageString;;
}

// 记录上一条消息时间
- (NSString *)onTimeStr {
    if (!_onTimeStr) {
        _onTimeStr = [NSString string];
    }
    return _onTimeStr;
}

#pragma mark -- 是否可以发送消息
- (void)isSendMessage {
    
//    if (self.isVip) {
//        self.keyBoardView.isSending = YES;
//    }else{
//
//        self.keyBoardView.isSending = NO;
//    }
//
//
//    return;
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid,
        @"mobile":self.chatDic[@"cmobile"]
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:@"/friends/in_linkup" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"in_linkup: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        
        [self.view hideLoading];
        if ([code isEqualToString:@"200"] ) {
            
            self.keyBoardView.isSending = YES;
            
        } else {
            
            self.keyBoardView.isSending = NO;

            self->_isSend = @{
                @"err":dictionary[@"msg"]
            };
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:error.localizedDescription];
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
