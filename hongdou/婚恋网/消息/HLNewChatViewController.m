//
//  HLNewChatViewController.m
//  hongdou
//
//  Created by iMac on 2019/11/5.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLNewChatViewController.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "JCHATFileManager.h"
#import "JCHATShowTimeCell.h"

#import "UIImage+ResizeMagick.h"


#import <MobileCoreServices/UTCoreTypes.h>
#import <JMessage/JMSGConversation.h>
#import "JCHATStringUtils.h"
#import <UIKit/UIPrintInfo.h>
#import "JCHATLoadMessageTableViewCell.h"
#import "JCHATSendMsgManager.h"


#import <AssetsLibrary/AssetsLibrary.h>
#import "JCHATAudioPlayerHelper.h"
#import "FKGPopOption.h"
#import "HLComplaintViewController.h"
#import "HLFrienderDetailViewController.h"
#import "HLBuyChattingViewController.h"

#import "JCAddMapViewController.h"

#import "HLOpenMemberViewController.h" // 开通会员

#import "CSCoachDetailViewController.h" // 咨询师详情

#import "LLStatementController.h" // 语句设置界面

#import "TZImagePickerController.h"

#define interval 60*2 //static =const
#define navigationRightButtonRect CGRectMake(0, 0, 14, 17)
#define messageTableColor [UIColor colorWithRed:236/255.0 green:237/255.0 blue:240/255.0 alpha:1]

static NSInteger const messagePageNumbers = 25;
static NSInteger const messagefristPageNumbers = 20;


@interface HLNewChatViewController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PictureDelegate,playVoiceDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate,JMessageDelegate,JMSGEventDelegate,UIScrollViewDelegate,JCHATPhotoPickerViewControllerDelegate,UITextViewDelegate,XBZChatKeyBoardViewDelegate,TZImagePickerControllerDelegate>
{
@private
    BOOL isNoOtherMessage;
    NSInteger messageOffset;
    NSMutableArray *_imgDataArr;
    //    JMSGConversation *_conversation;//
    NSMutableDictionary *_allMessageDic; //缓存所有的message model
    NSMutableArray *_allmessageIdArr; //按序缓存后有的messageId， 于allMessage 一起使用
    NSMutableArray *_userArr;//
    NSMutableDictionary *_refreshAvatarUsersDic;
    BOOL isChatting; // 是否畅聊
    BOOL isVip; // 是否会员
    BOOL isRenLian; // 是否人脸头像
    NSDictionary *isSend; // 能否发送
}
@property (strong, nonatomic) JCHATMessageTableView *messageTableView;


@property(assign, nonatomic) BOOL barBottomFlag;
@property(nonatomic, strong, readwrite) XHVoiceRecordHUD *voiceRecordHUD;
@property(strong, nonatomic) NSString *targetName;
@property(assign, nonatomic) BOOL isConversationChange;



/**
 *  管理录音工具对象
 */
@property(nonatomic, strong) XHVoiceRecordHelper *voiceRecordHelper;

/**
 *  记录旧的textView contentSize Heigth
 */
@property(nonatomic, assign) CGFloat previousTextViewContentHeight;


@property (nonatomic, strong) UIView *openChatView;

@property (nonatomic, strong) XBZChatKeyBoardView *keyBoardView;


@end


@implementation HLNewChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_more"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        if (self.isXinLiVC) {
            [self showPopMaster];
        } else {
            [self showPopSelector];
        }
        
    }];
    
    _refreshAvatarUsersDic = [NSMutableDictionary dictionary];
    _allMessageDic = [NSMutableDictionary dictionary];
    _allmessageIdArr = [NSMutableArray array];
    _imgDataArr = [NSMutableArray array];
    
    self.sc_navigationBar.title = self.conversation.title;
    isChatting = NO;
    isVip = NO;
    [self setupComponentView];
    
    if (!self.isXinLiVC) {
        
        // 是不是人脸头像
        [self isRenLianTouXiang];
        
        // 是否可以发送
        [self isSendMessage];
    } else {
        
        self->isRenLian = YES;
        self.keyBoardView.isSending = YES;
        
    }
    
    [self addNotification];
    [self addDelegate];
    [self getPageMessage];
    

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 禁用 iOS7 返回手势
//    HXNavigationController * navigationController = (HXNavigationController *)self.navigationController;
//    navigationController.enableInnerInactiveGesture = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_conversation clearUnreadCount];
    [[JCHATAudioPlayerHelper shareInstance] stopAudio];
    [[JCHATAudioPlayerHelper shareInstance] setDelegate:nil];
    //开启全局滑动手势
//    HXNavigationController * navigationController = (HXNavigationController *)self.navigationController;
//    navigationController.enableInnerInactiveGesture = YES;
}


- (void)setupComponentView {

    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.openChatView = [[UIView alloc] init];
    
    self.openChatView.frame = CGRectMake(0,kNavigationBarHeight,kScreenWidth,50);
    [self.openChatView az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0xFFAE9D],[UIColor colorWithHex:0xFF7098]] locations:@[@(0.0),@(0.5),@(0.75),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    [self.view addSubview:self.openChatView];
    
    
    UILabel *biaoYuLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth-100, 50)];
    biaoYuLab.text = @"开通会员即可享受自由沟通，成功率增加300%，会员费仅为3元";
    biaoYuLab.textColor = [UIColor whiteColor];
    biaoYuLab.textAlignment = NSTextAlignmentLeft;
    biaoYuLab.numberOfLines = 0;
    biaoYuLab.font = [UIFont systemFontOfSize:13.f];
    [self.openChatView addSubview:biaoYuLab];
    
    
    
    
    
//    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(biaoYuLab.frame), 200, 44)];
//    titleLable.text = @"单人畅聊\t\t\t¥1/人";
//    titleLable.textColor = [UIColor whiteColor];
//    titleLable.font = [UIFont systemFontOfSize:13.f];
//    [self.openChatView addSubview:titleLable];
//
//    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 120, CGRectGetMaxY(biaoYuLab.frame)+4, 100, 36)];
//    btn.backgroundColor = [UIColor colorWithHex:0xFFCA10];
//    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [btn setTitle:@"开通畅聊" forState:UIControlStateNormal];
//    btn.titleLabel.font = [UIFont systemFontOfSize:13.f];
//    btn.layer.cornerRadius = 4.f;
//    btn.layer.masksToBounds = YES;
//    [btn addTarget:self action:@selector(openChatting) forControlEvents:UIControlEventTouchUpInside];
//    [self.openChatView addSubview:btn];
//
//
//    // 分割线
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(titleLable.frame), kScreenWidth-40, 0.3)];
//    lineView.backgroundColor = [UIColor whiteColor];
//
//    [self.openChatView addSubview:lineView];
    
    
//    UILabel *titleLable1 = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(lineView.frame), 200, 44)];
//    titleLable1.text = @"VIP不限人数\t\t¥3/月";
//    titleLable1.textColor = [UIColor whiteColor];
//    titleLable1.font = [UIFont systemFontOfSize:13.f];
//    [self.openChatView addSubview:titleLable1];
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 100, 0, 100, 50)];
//    btn1.backgroundColor = [UIColor colorWithHex:0xFFCA10];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn1 setTitle:@"开通会员>>" forState:UIControlStateNormal];
    btn1.titleLabel.font = [UIFont systemFontOfSize:13.f];
    btn1.layer.cornerRadius = 4.f;
    btn1.layer.masksToBounds = YES;
    [btn1 addTarget:self action:@selector(openVip) forControlEvents:UIControlEventTouchUpInside];
    [self.openChatView addSubview:btn1];
    
    self.openChatView.hidden = YES;
    
    _messageTableView  = [[JCHATMessageTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _messageTableView.userInteractionEnabled = YES;
    _messageTableView.showsVerticalScrollIndicator = NO;
    _messageTableView.scrollsToTop = NO;
    _messageTableView.contentInsetTop = 0;
    if (@available(iOS 9.0, *)) {
        _messageTableView.cellLayoutMarginsFollowReadableWidth = NO;
    } else {
        // Fallback on earlier versions
    }
    _messageTableView.delegate = self;
    _messageTableView.dataSource = self;
    _messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _messageTableView.backgroundColor = [UIColor colorWithRed:0.961 green:0.969 blue:1.000 alpha:1.000];
    [_messageTableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];

    [self.view addSubview:_messageTableView];
    
    // 设置成分组表格, 解决UITableViewHeaderFooterContentView分割线问题
    _messageTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _messageTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    
    
    self.keyBoardView =  [[XBZChatKeyBoardView alloc] initWithNavigationBarTranslucent:NO];
    self.keyBoardView.delegate = self;
//    self.keyBoardView.isChating = self.isXinLiVC?YES:NO;
    self.keyBoardView.isChating = YES;
    [self.view addSubview:self.keyBoardView];

    [_messageTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(kNavigationBarHeight);
        make.bottom.mas_equalTo(self.keyBoardView.mas_top);
    }];
    
     [self.messageTableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
}


- (void)openVip {
    
    //开通会员
    HLOpenMemberViewController *openVC = [[HLOpenMemberViewController alloc] init];
    openVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:openVC animated:YES];
    
}

/**
*  监听按钮状态改变的方法
*
*  @param keyPath tableView改变的属性
*  @param object  tableView
*  @param change  改变后的数据
*  @param context 注册监听时context传递过来的值
*/

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
//        CGSize size = [change[NSKeyValueChangeNewKey] CGSizeValue];
//        if (size.height > self.messageTableView.height) {
//            [self.messageTableView scrollToBottomAnimated:YES];
//        }
        
        int tableViewHeight = SCREEN_Height-kNavigationBarHeight-kHomeIndecatorHeight-kToolBarHeight-50;
        
        if (tableViewHeight > self.messageTableView.height && tableViewHeight != self.messageTableView.height) {
            
            [self.messageTableView scrollToBottomAnimated:YES];
        }
    }
}

- (void)tap:(UITapGestureRecognizer *)tap {
    [self.keyBoardView hideBottomView];
}

// 请求是否是畅聊
- (void)requestChatting{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLIS_Chatting withDictionary:@{@"uid":[LoginManager defaultManager].userid,@"mobile":self.userName} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"是否是畅聊: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            self->isChatting = [[dictionary[@"data"] objectForKey:@"is"] boolValue]; // 是否和我是畅聊
            self->isVip = [[dictionary[@"data"] objectForKey:@"vip"] boolValue];
            
            if (self->isVip) {
                
//                weakSelf.openChatView.hidden = YES;
                weakSelf.keyBoardView.isChating = YES;
//                [weakSelf.messageTableView mas_updateConstraints:^(MASConstraintMaker *make) {
//                    make.top.equalTo(self.view.mas_top).offset(kNavigationBarHeight);
//                }];
                
                
                self.openChatView.hidden = YES;
                [self.messageTableView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.view.mas_top).offset(kNavigationBarHeight);
                }];
                
            }
            else if (self->isChatting) {
                
                NSString *string = [NSString stringWithFormat:@"%@",self.conversation.title];
                NSString *string1 = @" 已开通畅聊";
                NSString *string2 = [NSString stringWithFormat:@"%@%@",string,string1];
                NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string2];
                [text addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:[string2 rangeOfString:string1]];
                [text addAttribute:NSFontAttributeName value:kScaleFont(14) range:[string2 rangeOfString:string1]];
                
                self.sc_navigationBar.titleLabel.attributedText = text;
                
//                weakSelf.openChatView.hidden = YES;
                weakSelf.keyBoardView.isChating = YES;
//                [weakSelf.messageTableView mas_updateConstraints:^(MASConstraintMaker *make) {
//                    make.top.equalTo(self.view.mas_top).offset(kNavigationBarHeight);
//                }];
                
            }
            else {
//                weakSelf.openChatView.hidden = NO;
                weakSelf.keyBoardView.isChating = NO;
//                [weakSelf.messageTableView mas_updateConstraints:^(MASConstraintMaker *make) {
//                    make.top.equalTo(self.view.mas_top).offset(kNavigationBarHeight +50);
//                }];
            }
            
        } else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
        
    }];
}

#pragma mark --add Delegate
- (void)addDelegate {
    [JMessage addDelegate:self withConversation:self.conversation];
}


#pragma mark --加载通知
- (void)addNotification{
    
    // 添加开通会员通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestChatting) name:@"openChatiing" object:nil];
    
    // 开通会员后再次更新能否发送状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestChatting) name:@"OpenSending" object:nil];
    
    // 注销监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeJianTingClick) name:@"MESSAGE_JianTing" object:nil];
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cleanMessageCache)
                                                 name:kDeleteAllMessage
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(AlertToSendImage:)
                                                 name:kAlertToSendImage
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deleteMessage:)
                                                 name:kDeleteMessage
                                               object:nil];
    
 
}


#pragma mark ----发送文本消息
- (void)prepareTextMessage:(NSString *)text {
    
    if ([text isEqualToString:@""] || text == nil) {
        return;
    }
    [[JCHATSendMsgManager ins] updateConversation:_conversation withDraft:@""];
    JMSGMessage *message = nil;
    JMSGTextContent *textContent = [[JMSGTextContent alloc] initWithText:text];
    JCHATChatModel *model = [[JCHATChatModel alloc] init];
    
    message = [_conversation createMessageWithContent:textContent];//!
    
    JMSGOptionalContent *option = [[JMSGOptionalContent alloc] init];
    option.needReadReceipt = YES;//是否需要对方发送已读回执
    [_conversation sendMessage:message optionalContent:option];
    
    [self addmessageShowTimeData:message.timestamp];
    [model setChatModelWith:message conversationType:_conversation];
    [self addMessage:model];
}

#pragma mark -- 刷新对应的
- (void)addCellToTabel {
    NSIndexPath *path = [NSIndexPath indexPathForRow:[_allmessageIdArr count]-1 inSection:0];
    [_messageTableView beginUpdates];
    [_messageTableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    [_messageTableView endUpdates];
    [self scrollToEnd];
}

#pragma mark ---比较和上一条消息时间超过5分钟之内增加时间model
- (void)addmessageShowTimeData:(NSNumber *)timeNumber{
    NSString *messageId = [_allmessageIdArr lastObject];
    JCHATChatModel *lastModel = _allMessageDic[messageId];
    NSTimeInterval timeInterVal = [timeNumber longLongValue];
    
    if ([_allmessageIdArr count] > 0 && lastModel.isTime == NO) {
        
        NSDate* lastdate = [NSDate dateWithTimeIntervalSince1970:[lastModel.messageTime longLongValue]/1000];
        NSDate* currentDate = [NSDate dateWithTimeIntervalSince1970:timeInterVal/1000];
        NSTimeInterval timeBetween = [currentDate timeIntervalSinceDate:lastdate];
        if (fabs(timeBetween) > interval) {
            [self addTimeData:timeInterVal];
        }
    } else if ([_allmessageIdArr count] == 0) {//首条消息显示时间
        [self addTimeData:timeInterVal];
    } else {
        NSLog(@"不用显示时间");
    }
}

#pragma mark ---比较和上一条消息时间超过5分钟之内增加时间model
- (void)dataMessageShowTime:(NSNumber *)timeNumber{
    NSString *messageId = [_allmessageIdArr lastObject];
    JCHATChatModel *lastModel = _allMessageDic[messageId];
    NSTimeInterval timeInterVal = [timeNumber longLongValue];
    
    if ([_allmessageIdArr count]>0 && lastModel.isTime == NO) {
        NSDate* lastdate = [NSDate dateWithTimeIntervalSince1970:[lastModel.messageTime longLongValue]/1000];
        NSDate* currentDate = [NSDate dateWithTimeIntervalSince1970:timeInterVal/1000];
        NSTimeInterval timeBetween = [currentDate timeIntervalSinceDate:lastdate];
        if (fabs(timeBetween) > interval) {
            JCHATChatModel *timeModel =[[JCHATChatModel alloc] init];
            timeModel.timeId = [self getTimeId];
            timeModel.isTime = YES;
            timeModel.messageTime = @(timeInterVal);
            timeModel.contentHeight = [timeModel getTextHeight];//!
            [_allMessageDic setObject:timeModel forKey:timeModel.timeId];
            [_allmessageIdArr addObject:timeModel.timeId];
        }
    } else if ([_allmessageIdArr count] ==0) {//首条消息显示时间
        JCHATChatModel *timeModel =[[JCHATChatModel alloc] init];
        timeModel.timeId = [self getTimeId];
        timeModel.isTime = YES;
        timeModel.messageTime = @(timeInterVal);
        timeModel.contentHeight = [timeModel getTextHeight];//!
        [_allMessageDic setObject:timeModel forKey:timeModel.timeId];
        [_allmessageIdArr addObject:timeModel.timeId];
    } else {
        NSLog(@"不用显示时间");
    }
}

- (void)dataMessageShowTimeToTop:(NSNumber *)timeNumber{
    NSString *messageId = [_allmessageIdArr lastObject];
    JCHATChatModel *lastModel = _allMessageDic[messageId];
    NSTimeInterval timeInterVal = [timeNumber longLongValue];
    if ([_allmessageIdArr count]>0 && lastModel.isTime == NO) {
        NSDate* lastdate = [NSDate dateWithTimeIntervalSince1970:[lastModel.messageTime doubleValue]];
        NSDate* currentDate = [NSDate dateWithTimeIntervalSince1970:timeInterVal];
        NSTimeInterval timeBetween = [currentDate timeIntervalSinceDate:lastdate];
        if (fabs(timeBetween) > interval) {
            JCHATChatModel *timeModel =[[JCHATChatModel alloc] init];
            timeModel.timeId = [self getTimeId];
            timeModel.isTime = YES;
            timeModel.messageTime = @(timeInterVal);
            timeModel.contentHeight = [timeModel getTextHeight];
            [_allMessageDic setObject:timeModel forKey:timeModel.timeId];
            [_allmessageIdArr insertObject:timeModel.timeId atIndex: isNoOtherMessage?0:1];
        }
    } else if ([_allmessageIdArr count] ==0) {//首条消息显示时间
        JCHATChatModel *timeModel =[[JCHATChatModel alloc] init];
        timeModel.timeId = [self getTimeId];
        timeModel.isTime = YES;
        timeModel.messageTime = @(timeInterVal);
        timeModel.contentHeight = [timeModel getTextHeight];
        [_allMessageDic setObject:timeModel forKey:timeModel.timeId];
        [_allmessageIdArr insertObject:timeModel.timeId atIndex: isNoOtherMessage?0:1];
    } else {
        NSLog(@"不用显示时间");
    }
}

- (void)addTimeData:(NSTimeInterval)timeInterVal {
    JCHATChatModel *timeModel =[[JCHATChatModel alloc] init];
    timeModel.timeId = [self getTimeId];
    timeModel.isTime = YES;
    timeModel.messageTime = @(timeInterVal);
    timeModel.contentHeight = [timeModel getTextHeight];//!
    [self addMessage:timeModel];
}

- (NSString *)getTimeId {
    NSString *timeId = [NSString stringWithFormat:@"%d",arc4random()%1000000];
    return timeId;
}

#pragma mark --滑动至尾端
- (void)scrollToEnd {
    if ([_allmessageIdArr count] != 0) {
        [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_allmessageIdArr count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

// 控制滚动到底部
- (void)scrollToBottomAnimated:(BOOL)animated {
    if (![self shouldAllowScroll]) return;
    
    NSInteger rows = [self.messageTableView numberOfRowsInSection:0];
    
    if (rows > 0) {
        [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_allmessageIdArr count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}
#pragma mark - Previte Method

- (BOOL)shouldAllowScroll {
    return YES;
}


#pragma mark - tableView datasoce
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!isNoOtherMessage) {
        if (indexPath.row == 0) { //这个是第 0 行 用于刷新
            return 40;
        }
    }
    
    if (indexPath.row >= _allmessageIdArr.count) {
        return 40;
    }
    NSString *messageId = _allmessageIdArr[indexPath.row];
    JCHATChatModel *model = _allMessageDic[messageId];
    if (model.isTime == YES) {
        return 31;
    }
    
    if (model.message.contentType == kJMSGContentTypeEventNotification) {
        return model.contentHeight + 17;
    }
    
    if (model.message.contentType == kJMSGContentTypeText) {
        return model.contentHeight + 17;
    } else if (model.message.contentType == kJMSGContentTypeImage ||
               model.message.contentType == kJMSGContentTypeFile ||
               model.message.contentType == kJMSGContentTypeLocation) {
        if (model.imageSize.height == 0) {
            [model setupImageSize];
        }
        return model.imageSize.height < 44?59:model.imageSize.height + 14;
        
    } else if (model.message.contentType == kJMSGContentTypeVoice) {
        return 69;
    }  else {
        return 49;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_allmessageIdArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!isNoOtherMessage) {
        if (indexPath.row == 0) {
            static NSString *cellLoadIdentifier = @"loadCell"; //name
            JCHATLoadMessageTableViewCell *cell = (JCHATLoadMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellLoadIdentifier];
            
            if (cell == nil) {
                cell = [[JCHATLoadMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellLoadIdentifier];
            }
            [cell startLoading];
            [self flashToLoadMessage];
            //          [self performSelector:@selector(flashToLoadMessage) withObject:nil afterDelay:0];
            return cell;
        }
    }
    if (indexPath.row >= _allmessageIdArr.count) {
        //        NSLog(@"2.index %ld beyond bounds %ld",indexPath.row,_allmessageIdArr.count);
        return nil;
    }
    NSString *messageId = _allmessageIdArr[indexPath.row];
    if (!messageId) {
        //        NSLog(@"messageId is nil%@",messageId);
        return nil;
    }
    
    JCHATChatModel *model = _allMessageDic[messageId];
    if (!model) {
        //        NSLog(@"JCHATChatModel is nil%@", messageId);
        return nil;
    }
    
    if (model.isTime == YES || model.message.contentType == kJMSGContentTypeEventNotification || model.isErrorMessage) {
        static NSString *cellIdentifier = @"timeCell";
        JCHATShowTimeCell *cell = (JCHATShowTimeCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"JCHATShowTimeCell" owner:nil options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (model.isErrorMessage) {
            cell.messageTimeLabel.text = @"";
            //            [NSString stringWithFormat:@"%@ 错误码:%ld",st_receiveErrorMessageDes,model.messageError.code];
            return cell;
        }
        
        if (model.message.contentType == kJMSGContentTypeEventNotification) {
            cell.messageTimeLabel.text = [((JMSGEventContent *)model.message.content) showEventNotification];
        } else {
            cell.messageTimeLabel.text = [JCHATStringUtils getFriendlyDateString:[model.messageTime longLongValue]];
        }
        return cell;
        
    } else {
        static NSString *cellIdentifier = @"MessageCell";
        JCHATMessageTableViewCell *cell = (JCHATMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[JCHATMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.conversation = _conversation;
        }
        
        [cell setCellData:model delegate:self indexPath:indexPath];
        
        cell.messageTableViewCellRefreshMediaMessage = ^(JCHATChatModel *cellModel,BOOL isShouldRefresh){
            if (isShouldRefresh) {
                [self refreshCellMessageMediaWithChatModel:cellModel];
            }
        };
        
        return cell;
    }
}

#pragma mark - 检查并刷新消息图片图片
- (void)refreshCellMessageMediaWithChatModel:(JCHATChatModel *)model {
    //    NSLog(@"Action - refreshCellMessageMediaWithChatModel:");
    
    if (!model) {
        return ;
    }
    if (!model.message || ![self.conversation isMessageForThisConversation:model.message]) {
        return ;
    }
    NSString *msgId = model.message.msgId;
    JMSGMessage *db_message = [self.conversation messageWithMessageId:msgId];
    if (!db_message || !db_message.msgId) {
        return ;
    }
    
    model.message = db_message;
    [_allMessageDic setObject:model forKey:model.message.msgId];
    //[_allmessageIdArr addObject:model.message.msgId];msgId 不会变化所以不用去修改
    
    // 1.method
    //    [self.messageTableView reloadData];
    
    // 2.method
    //    NSArray *cellArray = [_messageTableView visibleCells];
    //    for (id temp in cellArray) {
    //        if ([temp isKindOfClass:[JCHATMessageTableViewCell class]]) {
    //            JCHATMessageTableViewCell *cell = (JCHATMessageTableViewCell *)temp;
    //            if ([cell.model.message.msgId isEqualToString:msgId]) {
    //                cell.model = model;
    //                [cell layoutAllView];
    //            }
    //        }
    //    }
    // 3.在cell 里面刷新
}
#pragma mark - 检查并刷新头像
- (void)chcekReceiveMessageAvatarWithReceiveNewMessage:(JMSGMessage *)message {
    NSLog(@"chcekReceiveMessageAvatarWithReceiveNewMessage:%@",message.serverMessageId);
    if (!message || !message.fromUser) {
        return ;
    }
    
    JMSGMessage *lastMessage = message;
    JMSGUser *fromUser = lastMessage.fromUser;
    [fromUser thumbAvatarData:^(NSData *data, NSString *objectId, NSError *error) {
        if (error == nil && [objectId isEqualToString:fromUser.username]) {
            if (data != nil) {
                NSUInteger lenght = data.length;
                [self refreshVisibleRowsAvatarWithNewMessage:lastMessage avatarDataLength:lenght];
            }
        }
    }];
   
}

- (void)refreshVisibleRowsAvatarWithNewMessage:(JMSGMessage *)message avatarDataLength:(NSUInteger)length {
    
    //    NSLog(@"refreshVisibleRowsAvatarWithNewMessage::%@",message.serverMessageId);
    
    NSString *username_appkey = [NSString stringWithFormat:@"%@_%@",message.fromUser.username,message.fromUser.appKey];
    NSString *msgId = message.msgId;
    
    NSArray *indexPaths = [[_messageTableView indexPathsForVisibleRows] mutableCopy];
    NSMutableArray *reloadIndexPaths = [NSMutableArray array];
    for (int i = 0; i < indexPaths.count; i++) {
        NSIndexPath *indexPath = indexPaths[i];
        JCHATMessageTableViewCell *cell = [_messageTableView cellForRowAtIndexPath:indexPath];
        JCHATChatModel *cellModel = cell.model;
        JMSGUser *cellUser = cell.model.message.fromUser;
        NSString *key = [NSString stringWithFormat:@"%@_%@",cellUser.username,cellUser.appKey];
        
        if (![username_appkey isEqualToString:key]) {
            continue ;
        }
        if (cellModel.avatarDataLength != length) {
            JMSGMessage *dbMessage = [self.conversation messageWithMessageId:msgId];
            JCHATChatModel *model = [_allMessageDic objectForKey:msgId];
            model.message = dbMessage;
            [_allMessageDic setObject:model forKey:msgId];
            [reloadIndexPaths addObject:indexPath];
        }
    }
    
    if (reloadIndexPaths.count > 0) {
        [_messageTableView reloadRowsAtIndexPaths:reloadIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)reloadAllCellAvatarImage {
    //    NSLog(@"Action -reloadAllCellAvatarImage");
    
    for (int i = 0; i < _allmessageIdArr.count; i++) {
        NSString *msgid = [_allmessageIdArr objectAtIndex:i];
        JCHATChatModel *model = [_allMessageDic objectForKey:msgid];
        if (model.message.isReceived && !model.message.fromUser.avatar) {
            JMSGMessage *message = [self.conversation messageWithMessageId:msgid];
            model.message = message;
            [_allMessageDic setObject:model forKey:msgid];
        }
    }
    
    NSArray *cellArray = [_messageTableView visibleCells];
    for (id temp in cellArray) {
        if ([temp isKindOfClass:[JCHATMessageTableViewCell class]]) {
            JCHATMessageTableViewCell *cell = (JCHATMessageTableViewCell *)temp;
            if (cell.model.message.isReceived) {
                [cell reloadAvatarImage];
            }
        }
    }
}

#pragma mark -PlayVoiceDelegate

- (void)successionalPlayVoice:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    JCHATMessageTableViewCell *tempCell = (JCHATMessageTableViewCell *) cell;
    JCHATChatModel *model = tempCell.model;
    
    if (model.message.contentType == kJMSGContentTypeVoice && model.message.flag) {
        JCHATMessageTableViewCell *voiceCell =(JCHATMessageTableViewCell *)[self.messageTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        [voiceCell playVoice];
    }
}

- (void)setMessageIDWithMessage:(JMSGMessage *)message chatModel:(JCHATChatModel * __strong *)chatModel index:(NSInteger)index {
    [_allMessageDic removeObjectForKey:(*chatModel).message.msgId];
    [_allMessageDic setObject:*chatModel forKey:message.msgId];
    
    if ([_allmessageIdArr count] > index) {
        [_allmessageIdArr removeObjectAtIndex:index];
        [_allmessageIdArr insertObject:message.msgId atIndex:index];
    }
}

#pragma mark --点击头像查看用户信息
- (void)selectHeadView:(JCHATChatModel *)model {
    if ([model.message isReceived]) {
//        [self.view showTostWithMessage:@"查看用户资料朋友"];
        NSLog(@"___%@ ___%lld",model.message.fromUser.username,model.message.fromUser.uid);
        
        if ([model.message.fromUser.username containsString:@"mind"]) {
            [self requestUserDetailWithModel:model.message.fromUser.username];
            return;
        }
        
        HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
        
        HLUser *userInfo = [[HLUser alloc] init];
        userInfo.username = model.message.fromUser.username;
        userInfo.nickname = model.message.fromUser.nickname;
        detailVC.userInfo = userInfo;
        detailVC.isChatting = YES;
        detailVC.refreshBlock  = ^{
            //            [self.navigationController popViewControllerAnimated:YES];
        };
        detailVC.removeBlock = ^{
            
        };
        
        if (![userInfo.username isEqualToString:@"hongdoukefu"]) {
            [self.navigationController pushViewController:detailVC animated:YES];
        }
        
        
    } else { // 查看自己
        
        if (self.isXinLiVC) {
            [self requestUserDetailWithModel:model.message.fromUser.username];
            return;
        }
        
        HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
        
        HLUser *userInfo = [[HLUser alloc] init];
        userInfo.username = model.message.fromUser.username;
        userInfo.nickname = model.message.fromUser.nickname;
        detailVC.userInfo = userInfo;
        detailVC.userId = [LoginManager defaultManager].userid;
        
        [self.navigationController pushViewController:detailVC animated:YES];
    }

}

- (void)requestUserDetailWithModel:(NSString *)mobile {
    [self.view showLoading];
    
    NSDictionary *parmas = @{
        @"mobile":mobile
    };
    
    [HTTPSessionManger postDataWithNSString:@"/customer/details" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [self.view hideLoading];
            
            CSCoachDetailViewController *vc = [[CSCoachDetailViewController alloc] init];
            vc.model = [CSCoachDetailModel mj_objectWithKeyValues:dictionary[@"data"]];
            vc.isApp = XinLiApp;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:[error localizedDescription]];
    }];
    
    
}

#pragma mark -连续播放语音
- (void)getContinuePlay:(UITableViewCell *)cell
              indexPath:(NSIndexPath *)indexPath {
    JCHATMessageTableViewCell *tempCell = (JCHATMessageTableViewCell *) cell;
    JCHATChatModel *model = tempCell.model;
    if (model.message.contentType == kJMSGContentTypeVoice && [model.message.flag isEqualToNumber:@(0)] && [model.message isReceived]) {
        if ([[JCHATAudioPlayerHelper shareInstance] isPlaying]) {
            tempCell.continuePlayer = YES;
        }else {
            tempCell.continuePlayer = NO;
        }
    }
}

#pragma mark 预览图片 PictureDelegate
//PictureDelegate
- (void)tapPicture:(NSIndexPath *)index tapView:(UIImageView *)tapView tableViewCell:(UITableViewCell *)tableViewCell {
    JCHATMessageTableViewCell *cell =(JCHATMessageTableViewCell *)tableViewCell;
    NSInteger count = _imgDataArr.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        JCHATChatModel *messageObject = [_imgDataArr objectAtIndex:i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.message = messageObject;
        photo.srcImageView = tapView; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = [_imgDataArr indexOfObject:cell.model];
    //  browser.currentPhotoIndex = cell.model.photoIndex; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    browser.conversation =_conversation;
    [browser show];
}
#pragma mark 地址查看

- (void)tapLoction:(NSIndexPath *)index tapView:(UIImageView *)tapView tableViewCell:(UITableViewCell *)tableViewCell{
    JCHATMessageTableViewCell *cell =(JCHATMessageTableViewCell *)tableViewCell;
    
    JCHATChatModel *model = cell.model;
    JMSGLocationContent *locationContent = (JMSGLocationContent *)model.message.content;
    if (locationContent) {
        JCAddMapViewController *mapVC = [[JCAddMapViewController alloc] init];
        mapVC.isOnlyShowMap = YES;
        mapVC.lat = [locationContent.latitude doubleValue];
        mapVC.lon = [locationContent.longitude doubleValue];
        [self.navigationController pushViewController:mapVC animated:YES];
    }
    
}

#pragma mark --获取所有发送消息图片
- (NSArray *)getAllMessagePhotoImg {
    NSMutableArray *urlArr =[NSMutableArray array];
    for (NSInteger i=0; i<[_allmessageIdArr count]; i++) {
        NSString *messageId = _allmessageIdArr[i];
        JCHATChatModel *model = _allMessageDic[messageId];
        if (model.message.contentType == kJMSGContentTypeImage) {
            [urlArr addObject:((JMSGImageContent *)model.message.content)];
        }
    }
    return urlArr;
}

#pragma mark -- 判断对方是否人像
- (void)isRenLianTouXiang {
    
    NSDictionary *dic = @{
        @"uid":kIsEmptyObject([LoginManager defaultManager].userid)?@"":[LoginManager defaultManager].userid
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:@"/user/in_head" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"-- %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [self.view hideLoading];
            
            if ([[NSString stringWithFormat:@"%@",dictionary[@"data"][@"in_head"]] isEqualToString:@"0"]) {
                self->isRenLian = NO;
            } else {
                self->isRenLian = YES;
            }
            
        }else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:error.localizedDescription];
    }];
    
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
        @"mobile":self.userName
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:@"/friends/in_linkup" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"-2- %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        
        [self.view hideLoading];
        if ([code isEqualToString:@"200"] ) {
            
            self.keyBoardView.isSending = YES;
            
        } else {
            
            self.keyBoardView.isSending = NO;
            
            self->isSend = @{
                @"err":dictionary[@"msg"]
            };
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:error.localizedDescription];
    }];
    
}

#pragma mark --JMessageDelegate
- (void)onSendMessageResponse:(JMSGMessage *)message error:(NSError *)error {
    
    if (message != nil) {
        NSLog(@"发送的 Message:  %@",message);
    }
    [self relayoutTableCellWithMessage:message];
    
    if (error != nil) {
        NSLog(@"Send response error - %@", error);
        [_conversation clearUnreadCount];
        NSString *alert = [JCHATStringUtils errorAlert:error];
        if (alert == nil) {
            alert = [error description];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showMessage:error.code == 803008 ? @"您已被拉黑" : alert view:self.view];
        return;
    }
    
    NSDictionary *dic = [self dictionaryWithJsonString:message.content.toJsonString];
    
    
    if (!self.isXinLiVC) {
        // 上传聊天记录
        [self uploadFriendsDialogueWithMessage:dic[@"text"]];
    }
    
    JCHATChatModel *model = _allMessageDic[message.msgId];
    if (!model) {
        return;
    }
}

// json格式字符串转字典：
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

// 上传聊天记录
- (void)uploadFriendsDialogueWithMessage:(NSString *)message {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"text":@"发送了文字/图片/语音/定位",
        @"mobile":self.userName,
        @"facility":@"ios",
        @"chid":@""
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:@"/friends/dialogue" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"上传聊天记录: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
        } else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}


- (void)onReceiveMessageReceiptStatusChangeEvent:(JMSGMessageReceiptStatusChangeEvent *)receiptEvent{
    //receiptEvent.messages;   消息已读回执列表
    NSLog(@"消息已读");
}

#pragma mark --收到消息
- (void)onReceiveMessage:(JMSGMessage *)message error:(NSError *)error {
    
    if (message != nil) {
        [message setMessageHaveRead:^(id resultObject, NSError *error) {
            
        }];
    }
    if (error != nil) {
        JCHATChatModel *model = [[JCHATChatModel alloc] init];
        [model setErrorMessageChatModelWithError:error];
        [self addMessage:model];
        return;
    }
    
    if (![self.conversation isMessageForThisConversation:message]) {
        return;
    }
    
    if (message.contentType == kJMSGContentTypeCustom) {
        return;
    }
    
    WeakSelf(weakSelf);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!message) {
            
            return;
        }
        if (message.contentType == kJMSGContentTypeEventNotification) {
            if (((JMSGEventContent *)message.content).eventType == kJMSGEventNotificationRemoveGroupMembers
                && ![((JMSGGroup *)weakSelf.conversation.target) isMyselfGroupMember]) {
                //                [weakSelf setupNavigation];
                [weakSelf.conversation clearUnreadCount];
                
            }
        }
        
        if (weakSelf.conversation.conversationType == kJMSGConversationTypeSingle) {
        } else if (![((JMSGGroup *)weakSelf.conversation.target).gid isEqualToString:((JMSGGroup *)message.target).gid]){
            return;
        }
        
        JCHATChatModel *model = [self->_allMessageDic objectForKey:message.msgId];
        if (model) {// 说明已经加载，说明可能是同步下来的多媒体消息，下载完成，然后再次收到就去刷新
            model.message = message;
            [weakSelf refreshCellMessageMediaWithChatModel:model];
        }else{
            
            NSString *firstMsgId = [self->_allmessageIdArr firstObject];
            JCHATChatModel *firstModel = [self->_allMessageDic objectForKey:firstMsgId];
            if (message.timestamp < firstModel.message.timestamp) {
                // 比数组中最老的消息时间都小的，无需加入界面显示，下次翻页时会加载
                return ;
            }
            
            model = [[JCHATChatModel alloc] init];
            [model setChatModelWith:message conversationType:weakSelf.conversation];
            if (message.contentType == kJMSGContentTypeImage) {
                [self->_imgDataArr addObject:model];
            }
            model.photoIndex = [self->_imgDataArr count] -1;
            [weakSelf addmessageShowTimeData:message.timestamp];
            [weakSelf addMessage:model];
            
            BOOL isHaveCache = NO;
            NSString *key = [NSString stringWithFormat:@"%@_%@",message.fromUser.username,message.fromUser.appKey];
            NSMutableArray *messages = self->_refreshAvatarUsersDic[key];
            if (messages) {
                isHaveCache = YES;
                [messages addObject:message];
            }else{
                messages = [NSMutableArray array];
                [messages addObject:message];
            }
            if (messages.count > 10) {
                [messages removeObjectAtIndex:0];
            }
            [self->_refreshAvatarUsersDic setObject:messages forKey:key];
            
            [weakSelf chcekReceiveMessageAvatarWithReceiveNewMessage:message];
        }
    });
    
}

- (void)onReceiveMessageDownloadFailed:(JMSGMessage *)message {
    
    if (![self.conversation isMessageForThisConversation:message]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!message) {
            
            return;
        }
        if (self->_conversation.conversationType == kJMSGConversationTypeSingle) {
        } else if (![((JMSGGroup *)self->_conversation.target).gid isEqualToString:((JMSGGroup *)message.target).gid]){
            return;
        }
        
        JCHATChatModel *model = [self->_allMessageDic objectForKey:message.msgId];
        if (model) {// 说明已经加载，说明可能是同步下来的多媒体消息，下载完成，然后再次收到就去刷新
            model.message = message;
            [self refreshCellMessageMediaWithChatModel:model];
        }else{
            model = [[JCHATChatModel alloc] init];
            [model setChatModelWith:message conversationType:self->_conversation];
            if (message.contentType == kJMSGContentTypeImage) {
                [self->_imgDataArr addObject:model];
            }
            model.photoIndex = [self->_imgDataArr count] -1;
            [self addmessageShowTimeData:message.timestamp];
            [self addMessage:model];
        }
    });
    
}
- (void)onSyncOfflineMessageConversation:(JMSGConversation *)conversation
                         offlineMessages:(NSArray<__kindof JMSGMessage *> *)offlineMessages {
    NSLog(@"Action -- onSyncOfflineMessageConversation:offlineMessages:");
    
    if (conversation.conversationType != self.conversation.conversationType) {
        return ;
    }
    BOOL isThisConversation = NO;
    if (conversation.conversationType == kJMSGConversationTypeSingle) {
        JMSGUser *user1 = (JMSGUser *)conversation.target;
        JMSGUser *user2 = (JMSGUser *)self.conversation.target;
        if ([user1.username isEqualToString:user2.username] &&
            [user1.appKey isEqualToString:user2.appKey]) {
            isThisConversation = YES;
        }
    }else{
        JMSGGroup *group1 = (JMSGGroup *)conversation.target;
        JMSGGroup *group2 = (JMSGGroup *)conversation.target;
        if ([group1.gid isEqualToString:group2.gid]) {
            isThisConversation = YES;
        }
    }
    
    if (!isThisConversation) {
        return ;
    }
    
    NSMutableArray *pathsArray = [NSMutableArray array];
    NSMutableArray *allSyncMessages = [NSMutableArray arrayWithArray:offlineMessages];
    for (int i = 0; i< allSyncMessages.count; i++) {
        JMSGMessage *message = allSyncMessages[i];
        JCHATChatModel *model = [[JCHATChatModel alloc] init];
        [model setChatModelWith:message conversationType:_conversation];
        if (message.contentType == kJMSGContentTypeImage) {
            [_imgDataArr addObject:model];
        }
        model.photoIndex = [_imgDataArr count] -1;
        
        [_allMessageDic setObject:model forKey:model.message.msgId];
        [_allmessageIdArr addObject:model.message.msgId];
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:[_allmessageIdArr count]-1 inSection:0];
        [pathsArray addObject:path];
    }
    if (pathsArray.count) {
        [_messageTableView beginUpdates];
        [_messageTableView insertRowsAtIndexPaths:pathsArray withRowAnimation:UITableViewRowAnimationNone];
        [_messageTableView endUpdates];
        [self scrollToEnd];
    }
}

- (void)onSyncRoamingMessageConversation:(JMSGConversation *)conversation {
    
    if (conversation.conversationType != self.conversation.conversationType) {
        return ;
    }
    BOOL isThisConversation = NO;
    if (conversation.conversationType == kJMSGConversationTypeSingle) {
        JMSGUser *user1 = (JMSGUser *)conversation.target;
        JMSGUser *user2 = (JMSGUser *)self.conversation.target;
        if ([user1.username isEqualToString:user2.username] &&
            [user1.appKey isEqualToString:user2.appKey]) {
            isThisConversation = YES;
        }
    }else{
        JMSGGroup *group1 = (JMSGGroup *)conversation.target;
        JMSGGroup *group2 = (JMSGGroup *)conversation.target;
        if ([group1.gid isEqualToString:group2.gid]) {
            isThisConversation = YES;
        }
    }
    
    if (!isThisConversation) {
        return ;
    }
    
    isNoOtherMessage = NO;
    messageOffset = 0;
    [_imgDataArr removeAllObjects];
    [_userArr removeAllObjects];
    
    [_allMessageDic removeAllObjects];
    [_allmessageIdArr removeAllObjects];
    [_imgDataArr removeAllObjects];
    
    //    [self getGroupMemberListWithGetMessageFlag:YES];
}

//- (void)onGroupInfoChanged:(JMSGGroup *)group {
//    [self updateGroupConversationTittle:group];
//}

- (void)relayoutTableCellWithMessage:(JMSGMessage *) message{
    //    NSLog(@"relayoutTableCellWithMessage: msgid:%@",message.msgId);
    if ([message.msgId isEqualToString:@""]) {
        return;
    }
    
    JCHATChatModel *model = _allMessageDic[message.msgId];
    if (model) {
        model.message = message;
        [_allMessageDic setObject:model forKey:message.msgId];
    }
    
    NSInteger index = [_allmessageIdArr indexOfObject:message.msgId];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    JCHATMessageTableViewCell *tableviewcell = [_messageTableView cellForRowAtIndexPath:indexPath];
    tableviewcell.model = model;
    [tableviewcell layoutAllView];
    
    //    [_messageTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark --获取对应消息的索引
- (NSInteger )getIndexWithMessageId:(NSString *)messageID {
    for (NSInteger i=0; i< [_allmessageIdArr count]; i++) {
        NSString *getMessageID = _allmessageIdArr[i];
        if ([getMessageID isEqualToString:messageID]) {
            return i;
        }
    }
    return 0;
}

- (bool)checkDevice:(NSString *)name {
    NSString *deviceType = [UIDevice currentDevice].model;
    NSLog(@"deviceType = %@", deviceType);
    NSRange range = [deviceType rangeOfString:name];
    return range.location != NSNotFound;
}

#pragma mark -- 清空消息缓存
- (void)cleanMessageCache {
    [_allMessageDic removeAllObjects];
    [_allmessageIdArr removeAllObjects];
    [self.messageTableView reloadData];
}

#pragma mark --添加message
- (void)addMessage:(JCHATChatModel *)model {
    if (model.isTime) {
        [_allMessageDic setObject:model forKey:model.timeId];
        [_allmessageIdArr addObject:model.timeId];
        [self addCellToTabel];
        return;
    }
    [_allMessageDic setObject:model forKey:model.message.msgId];
    [_allmessageIdArr addObject:model.message.msgId];
    [self addCellToTabel];
}

NSInteger newSortMessageType(id object1,id object2,void *cha) {
    JMSGMessage *message1 = (JMSGMessage *)object1;
    JMSGMessage *message2 = (JMSGMessage *)object2;
    if([message1.timestamp integerValue] > [message2.timestamp integerValue]) {
        return NSOrderedDescending;
    } else if([message1.timestamp integerValue] < [message2.timestamp integerValue]) {
        return NSOrderedAscending;
    }
    return NSOrderedSame;
}

- (void)AlertToSendImage:(NSNotification *)notification {
    UIImage *img = notification.object;
    [self prepareImageMessage:img];
}

- (void)deleteMessage:(NSNotification *)notification {
    JMSGMessage *message = notification.object;
    [_conversation deleteMessageWithMessageId:message.msgId];
    [_allMessageDic removeObjectForKey:message.msgId];
    [_allmessageIdArr removeObject:message.msgId];
    [_messageTableView loadMoreMessage];
}

#pragma mark --排序conversation
- (NSMutableArray *)sortMessage:(NSMutableArray *)messageArr {
    NSArray *sortResultArr = [messageArr sortedArrayUsingFunction:newSortMessageType context:nil];
    return [NSMutableArray arrayWithArray:sortResultArr];
}

- (void)getPageMessage {
    NSLog(@"Action - getAllMessage");
    [self cleanMessageCache];
    NSMutableArray * arrList = [[NSMutableArray alloc] init];
    [_allmessageIdArr addObject:[[NSObject alloc] init]];
    
    messageOffset = messagefristPageNumbers;
    [arrList addObjectsFromArray:[[[_conversation messageArrayFromNewestWithOffset:@0 limit:@(messageOffset)] reverseObjectEnumerator] allObjects]];
    if ([arrList count] < messagefristPageNumbers) {
        isNoOtherMessage = YES;
        [_allmessageIdArr removeObjectAtIndex:0];
    }
    
    for (NSInteger i=0; i< [arrList count]; i++) {
        JMSGMessage *message = [arrList objectAtIndex:i];
        JCHATChatModel *model = [[JCHATChatModel alloc] init];
        [model setChatModelWith:message conversationType:_conversation];
        if (message.contentType == kJMSGContentTypeImage) {
            [_imgDataArr addObject:model];
            model.photoIndex = [_imgDataArr count] - 1;
        }
        
        [self dataMessageShowTime:message.timestamp];
        [_allMessageDic setObject:model forKey:model.message.msgId];
        [_allmessageIdArr addObject:model.message.msgId];
    }
    [_messageTableView reloadData];
    [self scrollToBottomAnimated:NO];
}

- (void)flashToLoadMessage {
    NSMutableArray * arrList = @[].mutableCopy;
    NSArray *newMessageArr = [_conversation messageArrayFromNewestWithOffset:@(messageOffset) limit:@(messagePageNumbers)];
    [arrList addObjectsFromArray:newMessageArr];
    if ([arrList count] < messagePageNumbers) {// 判断还有没有新数据
        isNoOtherMessage = YES;
        [_allmessageIdArr removeObjectAtIndex:0];
    }
    
    messageOffset += messagePageNumbers;
    for (NSInteger i = 0; i < [arrList count]; i++) {
        JMSGMessage *message = arrList[i];
        JCHATChatModel *model = [[JCHATChatModel alloc] init];
        [model setChatModelWith:message conversationType:_conversation];
        
        if (message.contentType == kJMSGContentTypeImage) {
            [_imgDataArr insertObject:model atIndex:0];
            model.photoIndex = [_imgDataArr count] - 1;
        }
        
        [_allMessageDic setObject:model forKey:model.message.msgId];
        [_allmessageIdArr insertObject:model.message.msgId atIndex: isNoOtherMessage?0:1];
        [self dataMessageShowTimeToTop:message.timestamp];// FIXME:
    }
    
    [_messageTableView loadMoreMessage];
}

- (JMSGUser *)getAvatarWithTargetId:(NSString *)targetId {
    
    for (NSInteger i=0; i<[_userArr count]; i++) {
        JMSGUser *user = [_userArr objectAtIndex:i];
        if ([user.username isEqualToString:targetId]) {
            return user;
        }
    }
    return nil;
}

#pragma mark - RecorderPath Helper Method
- (NSString *)getRecorderPath {
    NSString *recorderPath = nil;
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yy-MMMM-dd";
    recorderPath = [[NSString alloc] initWithFormat:@"%@/Documents/", NSHomeDirectory()];
    dateFormatter.dateFormat = @"yyyy-MM-dd-hh-mm-ss";
    recorderPath = [recorderPath stringByAppendingFormat:@"%@-MySound.ilbc", [dateFormatter stringFromDate:now]];
    return recorderPath;
}


#pragma 键盘事件处理
// 滚动 先注销 键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.keyBoardView hideBottomView];
}

#pragma mark - 跳转到语句设置界面
- (void)pushYuJuVC {
    
    LLStatementController *vc = [[LLStatementController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - 跳转到开通会员界面
- (void)pushOpenVipVC {
    
    HLOpenMemberViewController *vc = [[HLOpenMemberViewController alloc] init];
    
    vc.isChat = YES;
    vc.chatVC = self.navigationController;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark XBZChatKeyBoardViewDelegate

- (void)openBuyVipViewWithMessage {
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:self->isSend[@"err"] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self openVip];
        
    }];
    [action setValue:REDColor forKey:@"titleTextColor"];
    
    [alertC addAction:action];
    
    [self presentViewController:alertC animated:YES completion:nil];
    
}

// 发送问候语
- (void)chatDidSelectGreetImteTitle:(NSString *)title index:(NSInteger)index{
    
    if (!self->isRenLian) {
        [self.view showTostWithMessage:@"您的头像审核未通过，请尽快更新头像"];
        return;
    }
    if (!self->isVip && !self->isChatting) {
        
        self.openChatView.hidden = NO;
        [self.messageTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(kNavigationBarHeight +50);
        }];
        
    } else {
        self.openChatView.hidden = YES;
        [self.messageTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(kNavigationBarHeight);
        }];
    }
    
    if ([title isEqualToString:@""] || title == nil) {
        return;
    }
    [[JCHATSendMsgManager ins] updateConversation:_conversation withDraft:@""];
    JMSGMessage *message = nil;
    JMSGTextContent *textContent = [[JMSGTextContent alloc] initWithText:title];
    JCHATChatModel *model = [[JCHATChatModel alloc] init];
    
    message = [_conversation createMessageWithContent:textContent];//!
    
    JMSGOptionalContent *option = [[JMSGOptionalContent alloc] init];
    option.needReadReceipt = YES;//设置这条消息的发送是否需要对方发送已读回执，NO，默认值
    [_conversation sendMessage:message optionalContent:option];
    
    [self addmessageShowTimeData:message.timestamp];
    [model setChatModelWith:message conversationType:_conversation];
    [self addMessage:model];
}

// 发送语音
- (void)chatKeyBoardViewSendVoiceMessage:(nonnull NSDictionary *)voicePath {
    
    if (!self->isRenLian) {
        [self.view showTostWithMessage:@"您的头像审核未通过，请尽快更新头像"];
        return;
    }
  
    NSString *voiceDuration = [voicePath objectForKey:@"duration"];
    NSString *voicePathStr  = [voicePath objectForKey:@"path"];
    if ([voiceDuration integerValue]<0.5) {
        return;
    }
    
    JMSGMessage *voiceMessage = nil;
    JCHATChatModel *model =[[JCHATChatModel alloc] init];
    JMSGVoiceContent *voiceContent = [[JMSGVoiceContent alloc] initWithVoiceData:[NSData dataWithContentsOfFile:voicePathStr] voiceDuration:[NSNumber numberWithInteger:[voiceDuration integerValue]]];
    
    voiceMessage = [_conversation createMessageWithContent:voiceContent];
    [_conversation sendMessage:voiceMessage];
    [model setChatModelWith:voiceMessage conversationType:_conversation];
    [JCHATFileManager deleteFile:voicePathStr];
    [self addMessage:model];
}

//发送大表情图片
- (void)chatKeyBoardViewSendPhotoMessage:(nonnull NSString *)photo {
    NSLog(@"photoMessage:%@", photo);
    
    if (!self->isRenLian) {
        [self.view showTostWithMessage:@"您的头像审核未通过，请尽快更新头像"];
        return;
    }

    [self prepareEmojiImageMessage:[UIImage imageNamed:photo]];
}

//发送文本，考虑到表情（🙂&[微笑]）上传时需要将原文传给服务器，展示的时候才是显示转换后的文字
- (void)chatKeyBoardViewSendTextMessage:(nonnull NSMutableAttributedString *)text originText:(nonnull NSString *)originText {
    
    if (!self->isRenLian) {
        [self.view showTostWithMessage:@"您的头像审核未通过，请尽快更新头像"];
        return;
    }
    
    if ([originText isEqualToString:@""] || originText == nil) {
        return;
    }
    [[JCHATSendMsgManager ins] updateConversation:_conversation withDraft:@""];
    JMSGMessage *message = nil;
    JMSGTextContent *textContent = [[JMSGTextContent alloc] initWithText:originText];
    JCHATChatModel *model = [[JCHATChatModel alloc] init];
    
    message = [_conversation createMessageWithContent:textContent];//!
    
    [_conversation sendMessage:message];
    
    [self addmessageShowTimeData:message.timestamp];
    [model setChatModelWith:message conversationType:_conversation];
    [self addMessage:model];
    
}

//点击更多
- (void)chatKeyBoardViewSelectMoreImteTitle:(NSString *)title index:(NSInteger)index {
    
    if (!self->isRenLian) {
        [self.view showTostWithMessage:@"您的头像审核未通过，请尽快更新头像"];
        return;
    }
    
    if (index == 0) {
        // 照片
        [self photoClick];
    }else if (index == 1){
        // 相机
        [self cameraClick];
    }else{
        //地理位置
        JCAddMapViewController *mapVC = [[JCAddMapViewController alloc] init];
        mapVC.addressBlock = ^(NSDictionary *dic) {
            [self prensentMapLoaction:dic];
        };
        [self.navigationController pushViewController:mapVC animated:YES];
    }
}


#pragma mark -调用相册
- (void)photoClick {
    [self pushTZImagePickerController];
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
    
    
    for (UIImage *image in photos) {
        [self prepareImageMessage:image];
    }
    
//    [self.keyBoardView hideBottomView];
    
}

#pragma mark --调用相机
- (void)cameraClick {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSString *requiredMediaType = ( NSString *)kUTTypeImage;
        NSArray *arrMediaTypes=[NSArray arrayWithObjects:requiredMediaType,nil];
        [picker setMediaTypes:arrMediaTypes];
        picker.showsCameraControls = YES;
        picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        picker.editing = YES;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark - ZYQAssetPickerController Delegate
//-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
//  for (int i=0; i<assets.count; i++) {
//    ALAsset *asset=assets[i];
//    UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
//    [self prepareImageMessage:tempImg];
//    [self dropToolBarNoAnimate];
//  }
//}
#pragma mark - HMPhotoPickerViewController Delegate
- (void)JCHATPhotoPickerViewController:(JCHATPhotoSelectViewController *)PhotoPickerVC selectedPhotoArray:(NSArray *)selected_photo_array {
    for (UIImage *image in selected_photo_array) {
        [self prepareImageMessage:image];
    }
    [self.keyBoardView hideBottomView];
}
#pragma mark - UIImagePickerController Delegate
//相机,相册Finish的代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.movie"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.view showTostWithMessage:@"不支持视频发送"];
        return;
    }
    UIImage *image;
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self prepareImageMessage:image];
    [self.keyBoardView hideBottomView];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- 发送表情图片

- (void)prepareEmojiImageMessage:(UIImage *)img {
    img = [img resizedImageByWidth:240];
    
    JMSGMessage* message = nil;
    JCHATChatModel *model = [[JCHATChatModel alloc] init];
    JMSGImageContent *imageContent = [[JMSGImageContent alloc] initWithImageData:UIImagePNGRepresentation(img)];
    if (imageContent) {
        message = [_conversation createMessageWithContent:imageContent];
        [[JCHATSendMsgManager ins] addMessage:message withConversation:_conversation];
        [self addmessageShowTimeData:message.timestamp];
        [model setChatModelWith:message conversationType:_conversation];
        [_imgDataArr addObject:model];
        model.photoIndex = [_imgDataArr count] - 1;
        [model setupImageSize];
        [self addMessage:model];
    }
}

#pragma mark --发送图片
- (void)prepareImageMessage:(UIImage *)img {
    img = [img resizedImageByWidth:720];
    
    JMSGMessage* message = nil;
    JCHATChatModel *model = [[JCHATChatModel alloc] init];
    JMSGImageContent *imageContent = [[JMSGImageContent alloc] initWithImageData:UIImagePNGRepresentation(img)];
    if (imageContent) {
        message = [_conversation createMessageWithContent:imageContent];
        [[JCHATSendMsgManager ins] addMessage:message withConversation:_conversation];
        [self addmessageShowTimeData:message.timestamp];
        [model setChatModelWith:message conversationType:_conversation];
        [_imgDataArr addObject:model];
        model.photoIndex = [_imgDataArr count] - 1;
        [model setupImageSize];
        [self addMessage:model];
    }
}
#pragma mark --发送地址

- (void)prensentMapLoaction:(NSDictionary *)dic{
    
    JMSGMessage* message = nil;
    JCHATChatModel *model = [[JCHATChatModel alloc] init];

    NSNumber *numberLat = [[NSNumber alloc] initWithDouble:[dic[@"lat"] doubleValue]];
    NSNumber *numberLon = [[NSNumber alloc] initWithDouble:[dic[@"lon"] doubleValue]];

    JMSGLocationContent *locationContent = [[JMSGLocationContent alloc] initWithLatitude:numberLat longitude:numberLon scale:@1 address:dic[@"address"]];
    
    if (locationContent) {
        message = [_conversation createMessageWithContent:locationContent];
        [[JCHATSendMsgManager ins] addMessage:message withConversation:_conversation];
        [_conversation sendMessage:message];

        [self addmessageShowTimeData:message.timestamp];
        [model setChatModelWith:message conversationType:_conversation];
        [self addMessage:model];
        [self.keyBoardView hideBottomView];

    }
    
    
}

#pragma mark --
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}






#pragma mark 更多更难按钮
// 咨询师端
- (void)showPopMaster {
    CGRect frame = CGRectMake(kScreenWidth - 20 , kStatusBarHeight+22, 20, 20);
    
    FKGPopOption *s = [[FKGPopOption alloc] initWithFrame:self.view.bounds];
    
    NSString *ext = [self.conversation getExtraValueForKey:@"ext"];
    
    s.option_optionContents = @[[ext isEqualToString:@"1"]?@"取消置顶":@"聊天置顶",@"清空聊天记录",@"拉黑"];
    
    [[s option_setupPopOption:^(NSInteger index, NSString *content) {
        
        if (index == 0) {
            
            if ([ext isEqualToString:@"1"]) {
                [self.conversation setExtraValue:@"0" forKey:@"ext"];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self.conversation setExtraValue:@"1" forKey:@"ext"];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        } else if (index == 1) {
            [self clearAllMessage];
            [self.conversation deleteAllMessages];
        } else {
            [self pushBlackRedUser];
        }
        
        
    } whichFrame:frame animate:YES] option_show];
    
}

// 拉黑红豆用户
- (void)pushBlackRedUser {
    
    NSDictionary *parmas = @{
        @"uid":[MyLogin getCurrentLoginUser].userid,
        @"token":[MyLogin getCurrentLoginUser].token,
        @"mobile":((JMSGUser *)self.conversation.target).username
    };

    [HTTPSessionManger postDataWithNSString:@"/customer/blacklist" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"~ %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [kAppDelegate.window showSuccessWithMessage:dictionary[@"msg"]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveRedUser" object:parmas[@"mobile"]];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        } else {
            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showErrorWithMessage:[error localizedDescription]];
    }];
    
}

// 右侧按钮
- (void)showPopSelector{
    
    
    CGRect frame = CGRectMake(kScreenWidth - 20 , kStatusBarHeight+22, 20, 20);
    
    FKGPopOption *s = [[FKGPopOption alloc] initWithFrame:self.view.bounds];
    
    NSString *ext = [self.conversation getExtraValueForKey:@"ext"];
    
    s.option_optionContents = @[[ext isEqualToString:@"1"]?@"取消置顶":@"聊天置顶",@"清空聊天记录", @"拉黑并举报", @"拉黑"];
    
    [[s option_setupPopOption:^(NSInteger index, NSString *content) {
        
        if (index == 0){
            
            if ([ext isEqualToString:@"1"]) {
                [self.conversation setExtraValue:@"0" forKey:@"ext"];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self.conversation setExtraValue:@"1" forKey:@"ext"];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        } else if (index == 1) {
            [self clearAllMessage];
            [self.conversation deleteAllMessages];
        } else if (index == 2) {
            [self goComplaint];
        } else {
            [self pushBlack];
        }
        
    } whichFrame:frame animate:YES] option_show];
}
//修改昵称
- (void)alterNikname{
    
}
//置顶
- (void)messageTop{
    
}
//清空消息
- (void)clearAllMessage{
    [self cleanMessageCache];
}
//拉黑
- (void)pushBlack{
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
//        @"bid":@"",
        @"mobile":((JMSGUser *)self.conversation.target).username
    };
    
    
    [HLHTTPSessionManager postDataWithNSString:HLPull_Black withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        
        if ([code isEqualToString:@"200"] ) {
            [kAppDelegate.window showSuccessWithMessage:dictionary[@"msg"]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RemovePerson" object:params[@"mobile"]];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        } else {
            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showErrorWithMessage:[error localizedDescription]];
    }];
    
}


// 拉黑并举报
- (void)goComplaint{
    
    HLComplaintViewController *comPlaintVC = [[HLComplaintViewController alloc] init];
    comPlaintVC.userMobile = ((JMSGUser *)self.conversation.target).username;
    if ([comPlaintVC.userMobile containsString:@"mind"]) {
        comPlaintVC.pertEnum = ZiXunShi;
    }
    
    [self.navigationController pushViewController:comPlaintVC animated:YES];
    
}

- (void)openChatting{
    HLBuyChattingViewController *buyChatVC = [[HLBuyChattingViewController alloc] init];
    buyChatVC.userName = self.userName;
    buyChatVC.nickName = self.conversation.title;
    HXNavigationController *nvc = [[HXNavigationController alloc] initWithRootViewController:buyChatVC];
    [self presentViewController:nvc animated:NO completion:^{
        
    }];
    //    [self.navigationController pushViewController:buyChatVC animated:YES];
}

// 移除监听
- (void)removeJianTingClick {
    NSLog(@"Action -- dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //remove delegate
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAlertToSendImage object:self];
    [JMessage removeDelegate:self withConversation:_conversation];
}


#pragma mark --释放内存
- (void)dealloc {
    NSLog(@"Action -- dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //remove delegate
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAlertToSendImage object:self];
    [JMessage removeDelegate:self withConversation:_conversation];
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
