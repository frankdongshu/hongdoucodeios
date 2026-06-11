//
//  HLFengCaiXiuViewController.m
//  hongdou
//
//  Created by user on 2022/8/3.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import "HLFengCaiXiuViewController.h"
#import "HLShowTopCell.h"
#import "HLFengCaiXiuCell.h"
#import "FengCaiShowDetailController.h"
#import "HLShowAddPhotoView.h"
#import "HLShowPreviousView.h"
#import <AVFoundation/AVFoundation.h>

@interface HLFengCaiXiuViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,HLShowAddPhotoViewDelegate,HLShowPreviousViewDelegate,HLFengCaiXiuCellDelegate> {
    NSString *_bannerUrl;
}

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) HLShowAddPhotoView *pView;

/**缓存图片高度*/
@property (nonatomic,strong)NSMutableDictionary *imageHeightArray;

@end

@implementation HLFengCaiXiuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = [NSMutableArray array];
    self.imageHeightArray = [NSMutableDictionary dictionary];
    
    [self initTableView];
    [self.tableView.mj_header beginRefreshing];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.tableView.bottom, kScreenWidth, 72)];
    
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"往期活动" forState:UIControlStateNormal];
    btn.frame = CGRectMake(16, 12, 135, 48);
    [btn setTitleColor:kRGBA(34, 34, 34, 1) forState:UIControlStateNormal];
    btn.layer.cornerRadius = 24;
    btn.layer.masksToBounds = YES;
    btn.layer.borderColor = [kRGB(221, 221, 221) CGColor];
    btn.layer.borderWidth = 1;
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:btn];
    
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.backgroundColor = kRGBA(255, 89, 130, 1);
    [btn1 setTitle:@"上传照片" forState:UIControlStateNormal];
    btn1.frame = CGRectMake(CGRectGetMaxX(btn.frame)+12, 12, kScreenWidth-btn.width-32-12, 48);
    btn1.layer.cornerRadius = 24;
    btn1.layer.masksToBounds = YES;
    btn1.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn1 addTarget:self action:@selector(isUploadPicture) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:btn1];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNewData) name:@"SHOW_ZAN" object:nil];
}

// 往期活动
- (void)btnClick {
    
    HLShowPreviousView *view = [[HLShowPreviousView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    view.delegate = self;
    
    [view showSelf];
}

- (void)previousListWithId:(NSString *)aid {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"pid":aid
    };
    
    [self requestRecommendWithUrl:@"/album/activityhistorylist" params:params];
}

// 上传照片
- (void)isUploadPicture {
    
    [HLHTTPSessionManager postDataWithNSString:@"/album/ifactivityadd" withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        
        HDLog(@"/album/ifactivityadd: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [self.view hide];
            [self uploadPicClick];
        } else {
            [self.view showTitle:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showError:error.localizedDescription];
    }];
    
}

- (void)uploadPicClick {
    
    self.pView = [[HLShowAddPhotoView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    self.pView.delegate = self;
    
    [self.pView showSelf];
}

// 添加图片
- (void)addPhotoClick {
    [self indexPathRowModifyUserIcon];
}

//创建tabbleview视图
-(void)initTableView
{
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight-kTabBarHeight-72);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 120.f;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.backgroundColor = kRGBA(242, 242, 242, 1);
    [self.tableView registerNib:[UINib nibWithNibName:@"HLShowTopCell" bundle:nil] forCellReuseIdentifier:@"HLShowTopCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"HLFengCaiXiuCell" bundle:nil] forCellReuseIdentifier:@"HLFengCaiXiuCell"];
    
}

- (void)loadNewData {
    
    [self.imageHeightArray removeAllObjects];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [self requestRecommendWithUrl:@"/album/activitylist" params:params];
}

- (void)requestRecommendWithUrl:(NSString *)url params:(NSDictionary *)params {
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:url withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        HDLog(@"/album/activitylist: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [self.view hide];
            
            self.dataSource = dictionary[@"data"][@"list"];
            self->_bannerUrl = dictionary[@"data"][@"banner"];
            
        } else {
            [self.view showTitle:dictionary[@"msg"]];
        }
        
        [self.tableView.mj_header endRefreshing];
        
        [self setRequestFiledView];
        [weakSelf.tableView reloadData];
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showError:error.localizedDescription];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    
}

- (void)setRequestFiledView {
    if (self.dataSource.count == 0) {
        UILabel *warnMsg = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
        warnMsg.text = @"暂无内容";
        warnMsg.textColor = [UIColor colorWithWhite:0.5 alpha:1.000];
        warnMsg.font = [UIFont systemFontOfSize:16];
        warnMsg.textAlignment = NSTextAlignmentCenter;
        self.tableView.tableFooterView = warnMsg;
    } else {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        view.backgroundColor = [UIColor clearColor];
        self.tableView.tableFooterView = view;
    }
}

#pragma mark - table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        HLShowTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLShowTopCell"];
        cell.selectionStyle = 0;
        cell.backgroundColor = [UIColor clearColor];
        
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:self->_bannerUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image.size.height>0) {
                CGFloat scaleHeight = image.size.height/image.size.width*(kScreenWidth-30);
                cell.imgViewHeight.constant = scaleHeight;
                
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
        }];
        
        
        
        return cell;
        
    } else {
        
        HLFengCaiXiuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLFengCaiXiuCell"];
        cell.selectionStyle = 0;
        cell.delegate = self;
        cell.backgroundColor = [UIColor clearColor];
        
        if (indexPath.row == 1) {
            cell.imgViewBg.image = [UIImage imageNamed:@"show_pink_bg"];
            cell.nameLab.textColor = [UIColor whiteColor];
            cell.addLab.textColor = [UIColor whiteColor];
            cell.likeLab.textColor = [UIColor whiteColor];
            cell.rankImgV.hidden = NO;
        } else {
            cell.imgViewBg.image = [UIImage imageNamed:@"show_white_bg"];
            cell.nameLab.textColor = kRGBA(34, 34, 34, 1);
            cell.addLab.textColor = kRGBA(102, 102, 102, 1);
            cell.likeLab.textColor = kRGBA(34, 34, 34, 1);
            cell.rankImgV.hidden = YES;
        }
        
        cell.dic = self.dataSource[indexPath.row-1];
        
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:self.dataSource[indexPath.row-1][@"photo"]] placeholderImage:[UIImage imageNamed:@"tupianzhanwei"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image.size.height>0) {
                
                CGFloat scaleHeight = image.size.height/image.size.width*(kScreenWidth-30);
                
                if (![[self.imageHeightArray allKeys] containsObject:@(indexPath.row)]) {
                    [self.imageHeightArray setObject:@(scaleHeight) forKey:@(indexPath.row)];
                    [self.tableView beginUpdates];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                }
            }
        }];
        
        cell.imgHeight.constant = [[self.imageHeightArray objectForKey:@(indexPath.row)] floatValue];
        
        
        
        cell.nameLab.text = self.dataSource[indexPath.row-1][@"nickname"];
        
        cell.addLab.text = [NSString stringWithFormat:@"%@·%@岁",self.dataSource[indexPath.row-1][@"habitation"],self.dataSource[indexPath.row-1][@"age"]];
        
        cell.likeLab.text = [self.dataSource[indexPath.row-1][@"likes"] stringValue];
        
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return;
    }
    
    FengCaiShowDetailController *vc = [[FengCaiShowDetailController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.uid = self.dataSource[indexPath.row-1][@"id"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

/**
 *  头像修改选择的路径
 */
- (void)indexPathRowModifyUserIcon{
    
    
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"修改头像" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
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
//        UIImage *newImage = [self imageWithImageSimple:image scaledToSize:CGSizeMake(120, 120)];
        NSData *imageData = UIImageJPEGRepresentation(image,0.5);
        
//        newImage = [self circleImage:newImage witghParam:0];
        
        
        
        [self uploadUserHeaderImageWithData:imageData];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
    
}
// 上传图片
- (void)uploadUserHeaderImageWithData:(NSData *)imageData {
    
    [self.view showLoading];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置时间格式
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
    
    [HLHTTPSessionManager postDataWithNSString:HLUPLoad_HeaderImage withDictionary:@{@"uid":[LoginManager defaultManager].userid} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:imageData name:@"image" fileName:fileName mimeType:@"image/jpeg"];
        
    } success:^(NSDictionary *dictionary) {
        
        [self.view hideLoading];
        
        NSLog(@"/user/upload %@",dictionary);

        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            self.pView.url = [dictionary objectForKey:@"data"][@"url"];
            
            [self.pView.imgView sd_setImageWithURL:[NSURL URLWithString:[dictionary objectForKey:@"data"][@"url"]]];
            
            self.pView.addImg.hidden = YES;
            self.pView.lab1.hidden = YES;
            self.pView.lab2.hidden = YES;
            
            self.pView.delBtn.hidden = NO;
            
            self.pView.selbtn.hidden = YES;
            
        } else {
            
            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError *error) {
        [self.view showTostWithMessage:[error localizedDescription]];
    }];
    
}

- (void)updateList {
    [self loadNewData];
}

- (void)likeUpdateList {
    [self loadNewData];
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
