//
//  HLNewHomeController.m
//  hongdou
//
//  Created by 李龙 on 2020/7/2.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLNewHomeController.h"
#import <AVFoundation/AVFoundation.h>
#import "HLHomeConstellationCell.h" // 星座
#import "HLVisitorCell.h" // 访客
#import "HLNewVipCell.h" // 最新会员
#import "HLFuQiXiangCell.h" // 夫妻相
#import "HLQingRenCell.h" // 梦中情人
#import "HLGaoYanZhiCell.h" // 高颜值
#import "HLYiQiWanCell.h" // 一起玩
#import "UITableView+FDTemplateLayoutCell.h"
#import "HLPlayPopView.h" // 一起玩弹出视图
#import "HLOpenMemberViewController.h"
#import "HLPiPeiDuView.h" // 答题弹框
#import "HLNewsSeenViewController.h" // 谁看过我
#import "HLFrienderDetailViewController.h" // 用户详情
#import "HLNickNameCell.h" // 昵称
#import "HLDreamLoverDesView.h" // 梦中情人简介
#import "HLHomeImgCell.h"

@interface HLNewHomeController ()<HLYiQiWanCellDelegate,HLGaoYanZhiCellDelegate,HLNewVipCellDelegate,HLFuQiXiangCellDelegate,HLQingRenCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    NSDictionary *_qrImgDic; // 梦中情人
    
    NSString *_imgUrl;
}

@property (nonatomic, strong) NSDictionary *theNewDic;
@property (nonatomic, strong) NSArray *togetherArray; // 一起玩

@end

@implementation HLNewHomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(requestData) name:DismissLoginView object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tableViewForTopClick) name:@"squareReloadList" object:nil];
    
    self.tableView.backgroundColor = kRGBA(244, 244, 249, 1);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-kNavigationBarHeight-kTabBarHeight);
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.tableView.estimatedRowHeight = 200;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuse"];
    [self.tableView registerNib:[UINib nibWithNibName:@"HLHomeConstellationCell" bundle:nil] forCellReuseIdentifier:@"HLHomeConstellationCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"HLHomeImgCell" bundle:nil] forCellReuseIdentifier:@"HLHomeImgCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"HLVisitorCell" bundle:nil] forCellReuseIdentifier:@"HLVisitorCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"HLNewVipCell" bundle:nil] forCellReuseIdentifier:@"HLNewVipCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"HLFuQiXiangCell" bundle:nil] forCellReuseIdentifier:@"HLFuQiXiangCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"HLQingRenCell" bundle:nil] forCellReuseIdentifier:@"HLQingRenCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"HLGaoYanZhiCell" bundle:nil] forCellReuseIdentifier:@"HLGaoYanZhiCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"HLYiQiWanCell" bundle:nil] forCellReuseIdentifier:@"HLYiQiWanCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"HLNickNameCell" bundle:nil] forCellReuseIdentifier:@"HLNickNameCell"];
    
    self.theNewDic = [[NSDictionary alloc] init];
    self.togetherArray = [[NSArray alloc] init];
    _qrImgDic = @{
        @"imgObj":[UIImage imageNamed:@"qingren_moren"],
        @"isSelect":@0,
        @"imgData":[NSNull null]
    };
    
    
    
    [self loadNewData];
    
    // 是否弹出答题框
//    [self getCount];
    
}

// 退出登录首页表格回到顶部
- (void)tableViewForTopClick {
    
    // 防止取不到钻石会员图片Cell
    [self.tableView scrollToTop];
    
}

// 为了退出登录换号时, 答题框和数据同时刷新
- (void)requestData {
    
    self.theNewDic = @{};
    self.togetherArray = @[];
    
    [self.tableView reloadData];
    
    _qrImgDic = @{
        @"imgObj":[UIImage imageNamed:@"qingren_moren"],
        @"isSelect":@0,
        @"imgData":[NSNull null]
    };
    
    [self loadNewData];
//    [self getCount];
}

// 钻石会员图片
- (void)requestVVipImage {
    
    NSDictionary *dic = @{
        @"sign":@"buyVIPios"
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:@"/index/notice" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"-@@@- %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            self->_imgUrl = dictionary[@"data"][@"val"];
            
            HLHomeImgCell *cell = self.tableView.visibleCells[2];
            
            [cell.imgView sd_setImageWithURL:[NSURL URLWithString:self->_imgUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                cell.imageHeight.constant = image.size.height/image.size.width*(kScreenWidth-32);
                
            }];
            
            [self.tableView reloadData];
            
        } else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:error.localizedDescription];
    }];
    
}

// 答题统计
- (void)getCount {
    
    if (!self.isLogin || ![[LoginManager defaultManager] avatar]) {
        return;
    }
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:@"/subject/get_count" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"-- %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            if ([dictionary[@"data"][@"today"] intValue] < 3) {
                
                HLPiPeiDuView *pView = [[HLPiPeiDuView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
                
                [pView showSelf];
            }
            
            
        } else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:error.localizedDescription];
    }];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 7) {
        
        return [tableView fd_heightForCellWithIdentifier:@"HLYiQiWanCell" configuration:^(id cell) {
           
            [self configCell:cell indexpath:indexPath];
        }];
        
    } else {
        return UITableViewAutomaticDimension;
    }
    
}

- (void)configCell:(HLYiQiWanCell *)cell indexpath:(NSIndexPath *)indexpath
{
    [cell.tagView removeAllTags];
    cell.tagView.preferredMaxLayoutWidth = kScreenWidth-30;
    cell.tagView.padding = UIEdgeInsetsMake(20, 20, 20, 20);
    cell.tagView.lineSpacing = 15;
    cell.tagView.interitemSpacing = 15;
    cell.tagView.singleLine = NO;
    // 给出两个字段，如果给的是0，那么就是变化的,如果给的不是0，那么就是固定的
//        cell.tagView.regularWidth = 80;
        cell.tagView.regularHeight = 30;
    
    NSArray *arr = self.togetherArray;
    
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        SKTag *tag = [[SKTag alloc] initWithText:arr[idx]];
        
        tag.font = [UIFont systemFontOfSize:12];
        tag.textColor = kRGBA(63, 70, 88, 1);
        tag.bgColor = kRGBA(249, 246, 249, 1);
        tag.cornerRadius = 15;
        tag.enable = YES;
        tag.padding = UIEdgeInsetsMake(5, 10, 5, 10);
        [cell.tagView addTag:tag];
    }];
    
    cell.tagView.didTapTagAtIndex = ^(NSUInteger index, UIButton *btn)
    {
        NSLog(@"点击了%ld",index);
        
        HLPlayPopView *pView = [[HLPlayPopView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) andTitle:arr[index]];
        
        pView.SelectBlock = ^(NSString *uid) {
            
            HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
            detailVC.hidesBottomBarWhenPushed = YES;
            
            detailVC.userId = [NSString stringWithFormat:@"%@",uid];
            
            [self.navigationController pushViewController:detailVC animated:YES];
            
        };
        
        [pView showSelf];
    };
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        HLNickNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLNickNameCell"];
        cell.selectionStyle = 0;
        cell.backgroundColor = [UIColor clearColor];
        
        NSString *str = kISNullObject(self.theNewDic[@"nickname"])?@"":self.theNewDic[@"nickname"];
        
        cell.nickNameLab.text = [NSString stringWithFormat:@"%@",str];
        
        return cell;
    }
    if (indexPath.row == 1) {
        HLHomeConstellationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLHomeConstellationCell"];
        cell.selectionStyle = 0;
        cell.backgroundColor = [UIColor clearColor];
        cell.dic = self.theNewDic;
        
        return cell;
    }
    if (indexPath.row == 2) {
        HLHomeImgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLHomeImgCell"];
        cell.selectionStyle = 0;
        cell.backgroundColor = [UIColor clearColor];
//        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:self->_imgUrl]];
        
        return cell;
    }
    if (indexPath.row == 3) { // 访客
        HLVisitorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLVisitorCell"];
        cell.selectionStyle = 0;
        cell.backgroundColor = [UIColor clearColor];
        
        for (UIView *view in cell.containerView.subviews) {
            [view removeFromSuperview];
        }
        
        cell.dic = self.theNewDic;
        
        return cell;
    }
    if (indexPath.row == 4) { // 会员
        HLNewVipCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLNewVipCell"];
        cell.selectionStyle = 0;
        cell.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
        cell.dic = self.theNewDic;
        
        return cell;
    }
//    if (indexPath.row == 4) { // 夫妻相
//        HLFuQiXiangCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLFuQiXiangCell"];
//        cell.selectionStyle = 0;
//        cell.backgroundColor = [UIColor clearColor];
//        cell.delegate = self;
//        cell.dic = self.theNewDic;
//
//        return cell;
//    }
    if (indexPath.row == 5) { // 梦中情人
        HLQingRenCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLQingRenCell"];
        cell.selectionStyle = 0;
        cell.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
        
        cell.dic = self->_qrImgDic;
        
        return cell;
    }
    if (indexPath.row == 6) { // 高颜值
        HLGaoYanZhiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLGaoYanZhiCell"];
        cell.selectionStyle = 0;
        cell.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
        cell.dic = self.theNewDic;
        
        return cell;
    }
    if (indexPath.row == 7) {
        HLYiQiWanCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLYiQiWanCell"];
        cell.selectionStyle = 0;
        cell.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
        
        [self configCell:cell indexpath:indexPath];
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 2) {
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectDiamond" object:nil];
        
        HLGoVipViewController *vc = [[HLGoVipViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    if (indexPath.row == 3) {
        HLNewsSeenViewController *seenVC = [[HLNewsSeenViewController alloc] init];
        seenVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:seenVC animated:YES];
    }
}

// 一起玩标签刷新
- (void)reloadYiQiPlayWithDataDic:(NSDictionary *)dic {
    
    self.togetherArray = dic[@"find"];
    
    [self.tableView reloadData];
}

// 跳转开通vip界面
- (void)pushVip {
    
    HLGoVipViewController *openVC = [[HLGoVipViewController alloc] init];
    openVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:openVC animated:YES];
}

- (void)pushBuyVipClick {
    
    HLGoVipViewController *openVC = [[HLGoVipViewController alloc] init];
    openVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:openVC animated:YES];
}

- (void)pushVipClick {
    
    HLGoVipViewController *openVC = [[HLGoVipViewController alloc] init];
    openVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:openVC animated:YES];
    
}

- (void)pushYiQiWanVipClick {
    
    HLGoVipViewController *openVC = [[HLGoVipViewController alloc] init];
    openVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:openVC animated:YES];
    
}

// vip 跳转详情
- (void)pushVipDetailWithId:(NSString *)uid {
    
    HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
    detailVC.hidesBottomBarWhenPushed = YES;
    
    detailVC.userId = [NSString stringWithFormat:@"%@",uid];
    
    [self.navigationController pushViewController:detailVC animated:YES];
    
}

// 高颜值跳转详情
- (void)pushGaoYanZhiDetailWithId:(NSString *)uid {
    
    HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
    detailVC.hidesBottomBarWhenPushed = YES;
    
    detailVC.userId = [NSString stringWithFormat:@"%@",uid];
    
    [self.navigationController pushViewController:detailVC animated:YES];
    
}

// 跳转详情页(夫妻相)
- (void)pushFuQiXiangDetail {
    
    HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
    detailVC.hidesBottomBarWhenPushed = YES;
    
    detailVC.userId = [NSString stringWithFormat:@"%@",self.theNewDic[@"qjd"][@"id"]];
    
    [self.navigationController pushViewController:detailVC animated:YES];
    
}

// 梦中情人
- (void)addPhotoMengZhongQingRen {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"uid":kIsEmptyObject([LoginManager defaultManager].userid)?@"":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/tx_dl" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [MBProgressHUD hideLoading];
            
            if ([dictionary[@"data"][@"no"] intValue] > 9) {
                [self indexPathRowModifyUserIcon];
            }
            else if ([dictionary[@"data"][@"no"] intValue] == 0) {
                
                HLDreamLoverDesView *dView = [[HLDreamLoverDesView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) andMessage:dictionary[@"data"][@"tips"]];
                
                dView.SelectBlock = ^{
                    
                    HLGoVipViewController *openVC = [[HLGoVipViewController alloc] init];
                    openVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:openVC animated:YES];
                    
                };
                
                dView.CloseBlock = ^{
                    
                };
                
                [dView showSelf];
                
            }
            else {
                
                HLDreamLoverDesView *dView = [[HLDreamLoverDesView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) andMessage:dictionary[@"data"][@"tips"]];
                
                dView.SelectBlock = ^{
                    
                    HLGoVipViewController *openVC = [[HLGoVipViewController alloc] init];
                    openVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:openVC animated:YES];
                    
                };
                
                dView.CloseBlock = ^{
                    
                    [self indexPathRowModifyUserIcon];
                    
                };
                
                [dView showSelf];
                
            }
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

// 梦中情人问号
- (void)wenhaoClickAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    
    HLDreamLoverDesView *dView = [[HLDreamLoverDesView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) andMessage:message];
    
    dView.SelectBlock = ^{
        
        HLGoVipViewController *openVC = [[HLGoVipViewController alloc] init];
        openVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:openVC animated:YES];
        
    };
    
    dView.CloseBlock = ^{
        
    };
    
    [dView showSelf];
    
}

// 跳转情人详情页
- (void)pushQingRenDetailWithId:(NSString *)uid {
    
    HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
    detailVC.hidesBottomBarWhenPushed = YES;
    
    detailVC.userId = [NSString stringWithFormat:@"%@",uid];
    
    [self.navigationController pushViewController:detailVC animated:YES];
    
}



- (void)loadNewData {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"uid":kIsEmptyObject([LoginManager defaultManager].userid)?@"":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/newIndex" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [MBProgressHUD hideLoading];
            
            self.theNewDic = dictionary[@"data"];
            self.togetherArray = dictionary[@"data"][@"find"];
            
            [self.tableView reloadData];
            
        } else if ([code isEqualToString:@"203"] ) {
            [MBProgressHUD hideLoading];
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
        
        // 钻石会员图片
        [self requestVVipImage];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:[NSString stringWithFormat:@"%@下拉再次刷新",error.localizedDescription] view:nil];
    }];
    
    
    [self.tableView.mj_header endRefreshing];
    
}

- (void)indexPathRowModifyUserIcon{
    
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"添加照片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    alertViewController.modalInPopover = YES;
    alertViewController.modalPresentationStyle = UIModalPresentationPopover;
    
    __weak typeof(self) weakSelf = self;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    imagePickerController.modalPresentationStyle = 0;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            [self.view showTostWithMessage:@"应用相机权限受限，请在设置中启用"];
            return;
        }else{
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            [weakSelf presentViewController:imagePickerController animated:YES completion:nil];
        }
    }];
    [cameraAction setValue:[UIColor colorWithHex:0x8C49FF] forKey:@"titleTextColor"];
    UIAlertAction *photoesAlbum = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            [self.view showTostWithMessage:@"应用相册权限受限，请在设置中启用"];
            return;
        }else{
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [weakSelf presentViewController:imagePickerController animated:YES completion:nil];
        }
    }];
    [photoesAlbum setValue:[UIColor colorWithHex:0x8C49FF] forKey:@"titleTextColor"];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [cancle setValue:kCellTitleColor forKey:@"titleTextColor"];
    
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alertViewController addAction:cameraAction];
    }
    [alertViewController addAction:photoesAlbum];
    [alertViewController addAction:cancle];
    alertViewController.popoverPresentationController.sourceView = self.view;
    alertViewController.popoverPresentationController.sourceRect = self.view.frame;
    alertViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    [self presentViewController:alertViewController animated:YES completion:^{
        [alertViewController tapGesAlert];
    }];
    
}

#pragma mark - ImagePiker delegate
/**
 *  UIImagePickerController图片选择的方法
 *
 *  @param picker 图片选择的容器
 *  @param info   选择图片的内容
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = nil;
        if (picker.allowsEditing) {
            image = [info objectForKey:UIImagePickerControllerEditedImage];
        }else{
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        NSData *imageData = UIImageJPEGRepresentation(image,0.5);
        
        self->_qrImgDic = @{
            @"imgObj":image,
            @"isSelect":@1,
            @"imgData":imageData
        };
        
        [self.tableView reloadData];
        
        
//        [self uploadUserHeaderImage];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
    
}

#pragma mark - JXCategoryListContentViewDelegate

- (UIView *)listView {
    return self.view;
}

- (UIScrollView *)listScrollView {
    return self.tableView;
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
