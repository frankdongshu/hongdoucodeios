//
//  HLReleaseViewController.m
//  hongdou
//
//  Created by iMac on 2019/9/26.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLReleaseViewController.h"
#import <Photos/Photos.h>
#import "LxGridViewFlowLayout.h"
#import "TZImageManager.h"
#import "TZTestCell.h"
#import "TZImagePickerController.h"
#import "TZPhotoPreviewController.h"
#import "TZLocationManager.h"
#import "TZImageUploadOperation.h"
#import "HLPhotoModel.h"
#import <VODUpload/VODUploadClient.h>

#import "HLAddressController.h" // 邮寄地址界面

#import "HPGrowingTextView.h"

#define IsEquallString(_Str1,_Str2)  [_Str1 isEqualToString:_Str2]

@interface HLReleaseViewController ()<TZImagePickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate,HPGrowingTextViewDelegate>
{
    NSMutableArray *_selectedPhotos; // 存放图片数组
    NSMutableArray *_selectedAssets;
    NSMutableArray *_uplodaPicArr; // 存放url地址图片数组

    BOOL _isSelectOriginalPhoto;
    
    CGFloat _itemWH;
    CGFloat _margin;
}

// 话题
@property (nonatomic,strong) HPGrowingTextView *growingTextView;

@property (nonatomic, strong) UILabel *showNumLabel;

@property (nonatomic, strong) HXBarButtonItem *leftBarItem;
@property (nonatomic, strong) HXBarButtonItem *rightBarItem;

@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (strong, nonatomic) LxGridViewFlowLayout *layout;
@property (strong, nonatomic) CLLocation *location;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@property (nonatomic, strong) HLAlbumUploadModel *model;

@property (nonatomic, strong) NSString *outputPath;

@property (nonatomic, strong) VODUploadClient *uploader;
@property (nonatomic, strong) NSString *UploadAuth;
@property (nonatomic, strong) NSString *UploadAddress;
@property (nonatomic, strong) NSString *VideoId;

@end

@implementation HLReleaseViewController

-(void)loadView
{
    [super loadView];
    @weakify(self);
    self.leftBarItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    self.rightBarItem = [[HXBarButtonItem alloc] initWithTitle:@"发布" withColor:[UIColor colorWithHex:0xFF5C79] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self uploadVideoOrPicture];
        
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    self.sc_navigationBar.title = self.isYanPin?@"发布商业信息":@"发布动态";
    self.sc_navigationBar.leftBarButtonItem = self.leftBarItem;
    self.sc_navigationBar.rightBarButtonItem = self.rightBarItem;
    _selectedPhotos = [NSMutableArray array];
    _selectedAssets = [NSMutableArray array];
    [self creatUITextView];
    [self configCollectionView];
    
    
    [self initVODUpload];
    
}

#pragma mark --初始化
- (void)initVODUpload {
        
    // create VODUploadClient object
    self.uploader = [VODUploadClient new];
    // weakself
    __weak typeof(self) weakSelf = self;
    // setup callback
    OnUploadFinishedListener FinishCallbackFunc = ^(UploadFileInfo* fileInfo, VodUploadResult* result){
        NSLog(@"upload finished callback videoid:%@, imageurl:%@", result.videoId, result.imageUrl);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //主线程执行
            [weakSelf uplodaPublicationTrendsWithVideoId:weakSelf.VideoId];
        });
        
    };
    OnUploadFailedListener FailedCallbackFunc = ^(UploadFileInfo* fileInfo, NSString *code, NSString* message){
        NSLog(@"upload failed callback code = %@, error message = %@", code, message);
    };
    OnUploadProgressListener ProgressCallbackFunc = ^(UploadFileInfo* fileInfo, long uploadedSize, long totalSize) {
            
        NSLog(@"upload progress callback uploadedSize : %li, totalSize : %li", uploadedSize, totalSize);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *videoSize = [NSString stringWithFormat:@"%.2fM",(CGFloat)totalSize/(1024*1024)];
            NSLog(@"视频大小: %@",videoSize);
            
            // 不可能超过30M的, 基本不会执行到
            if ([videoSize doubleValue] > 30) {
                [weakSelf.view showTostWithMessage:@"小视频大小限制在30M及以内"];
                [weakSelf.uploader clearFiles];
                return;
            }
            
//            [weakSelf.view showLoading];
            if (uploadedSize == totalSize) {
//                [weakSelf.view hideLoading];
            }
            
        });
                           
    };
    OnUploadTokenExpiredListener TokenExpiredCallbackFunc = ^{
        NSLog(@"upload token expired callback.");
        // token过期，设置新的上传凭证，继续上传
        // 在该回调方法中，我们可以向AppServer重新请求新的上传凭证或STS
        [self resumeWithVideoAuth];
    };
    OnUploadRertyListener RetryCallbackFunc = ^{
        NSLog(@"upload retry begin callback.");
    };
    OnUploadRertyResumeListener RetryResumeCallbackFunc = ^{
        NSLog(@"upload retry end callback.");
    };
    OnUploadStartedListener UploadStartedCallbackFunc = ^(UploadFileInfo* fileInfo) {
        NSLog(@"upload upload started callback.");
        // 设置上传地址 和 上传凭证
        [weakSelf.uploader setUploadAuthAndAddress:fileInfo uploadAuth:self.UploadAuth uploadAddress:self.UploadAddress];
    };
    VODUploadListener *listener = [[VODUploadListener alloc] init];
    listener.finish = FinishCallbackFunc;
    listener.failure = FailedCallbackFunc;
    listener.progress = ProgressCallbackFunc;
    listener.expire = TokenExpiredCallbackFunc;
    listener.retry = RetryCallbackFunc;
    listener.retryResume = RetryResumeCallbackFunc;
    listener.started = UploadStartedCallbackFunc;
    // init with upload address and upload auth
    [self.uploader init:listener];
}

// 刷新视频上传地址和凭证
- (void)resumeWithVideoAuth {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"vid":self.VideoId
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/album/get_vid" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/album/get_vid: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [self.view hideLoading];
            
            self.UploadAddress = dictionary[@"data"][@"json"][@"UploadAddress"];
            self.UploadAuth = dictionary[@"data"][@"json"][@"UploadAuth"];
            self.VideoId = dictionary[@"data"][@"json"][@"VideoId"];
            
            // 并调用以下方法继续上传
            [self.uploader resumeWithAuth:self.UploadAuth];
            
            
        }else {
            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.view showErrorWithMessage:error.localizedDescription];
    }];
    
}

- (void)creatUITextView{
//    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, 180)];
//    self.textView.backgroundColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.0];
//    self.textView.textColor = [UIColor blackColor];
//    self.textView.font = [UIFont systemFontOfSize:16];
//    self.textView.delegate = self;
//    [self.view addSubview:self.textView];
//
//    self.placeHolderlabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 6 , kScreenWidth , 21)];
//    self.placeHolderlabel.font = [UIFont systemFontOfSize:16];
//    self.placeHolderlabel.textColor = [UIColor colorWithRed:157/255.0 green:164/255.0 blue:174/255.0 alpha:1.0];
//    self.placeHolderlabel.text = @"这一刻您想说点什么…";
//    [self.textView addSubview:self.placeHolderlabel];
    
    
    
    self.growingTextView = [[HPGrowingTextView alloc]initWithFrame:CGRectMake(0,kNavigationBarHeight, kScreenWidth, 200)];
    self.growingTextView.minHeight = 200;
    self.growingTextView.delegate = self;
    self.growingTextView.textColor = [UIColor blackColor];
    self.growingTextView.font = [UIFont systemFontOfSize:16];
    self.growingTextView.minNumberOfLines = 1;
    self.growingTextView.maxNumberOfLines = 10;
    self.growingTextView.animateHeightChange = NO;
    self.growingTextView.placeholder = self.isYanPin?@"填写信息内容…":@"这一刻您想说点什么…";
    self.growingTextView.placeholderColor = [UIColor colorWithRed:157/255.0 green:164/255.0 blue:174/255.0 alpha:1.0];
    self.growingTextView.returnKeyType = UIReturnKeyDone;
    self.growingTextView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    self.growingTextView.enablesReturnKeyAutomatically = YES;
    self.growingTextView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.growingTextView];
    
    
    self.showNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight + 210, kScreenWidth - 15, 20)];
    self.showNumLabel.textAlignment = NSTextAlignmentRight;
    self.showNumLabel.font = [UIFont systemFontOfSize:14];
    self.showNumLabel.textColor = [UIColor colorWithRed:157/255.0 green:164/255.0 blue:174/255.0 alpha:1.0];
    self.showNumLabel.text = @"0/200";
    [self.view addSubview:self.showNumLabel];
    
    
    if (!kISNullObject(self.fabuId)) {
        
        [self.growingTextView.internalTextView unmarkText];
        NSInteger index = self.growingTextView.text.length;
        UITextView *textView = self.growingTextView.internalTextView;
        NSString *insertString = [NSString stringWithFormat:@"%@ ",self.fabuString];
        NSMutableString *string = [NSMutableString stringWithString:textView.text];
        [string insertString:insertString atIndex:index];
        self.growingTextView.text = string;
//        [self.growingTextView becomeFirstResponder];
        textView.selectedRange = NSMakeRange(index + insertString.length, 0);
        
        
        
//        self.textView.text = self.fabuString;
//        [self.placeHolderlabel setHidden:YES];
    }
}

- (void)configCollectionView {
    // 如不需要长按排序效果，将LxGridViewFlowLayout类改成UICollectionViewFlowLayout即可
    _layout = [[LxGridViewFlowLayout alloc] init];
    _margin = 4;
    
    _itemWH = (kScreenWidth - 8 * _margin) / 4 ;
    _layout.itemSize = CGSizeMake(_itemWH, _itemWH);
    _layout.minimumInteritemSpacing = _margin;
    _layout.minimumLineSpacing = _margin;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight + 230, kScreenWidth, kScreenHeight - kNavigationBarHeight - 230) collectionViewLayout:_layout];
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.contentInset = UIEdgeInsetsMake(4, 4, 4, 4);
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [_collectionView addGestureRecognizer:tapGr];
    
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[TZTestCell class] forCellWithReuseIdentifier:@"TZTestCell"];
}

-(void)viewTapped:(UITapGestureRecognizer*)tapGr {
    
    if (self.growingTextView.isFirstResponder) {
        [self.growingTextView resignFirstResponder];
        
    }
}

// 上传图片或视频
- (void)uploadVideoOrPicture {
    
    if (self.growingTextView.isFirstResponder) {
        [self.growingTextView resignFirstResponder];
    }
    if (self.growingTextView.text.length ==0) {
        [self.view showTostWithMessage:self.isYanPin?@"填写信息内容…":@"这一刻您想说点什么…"];
        return;
    }
    
    if (_selectedAssets.count > 0) {
        PHAsset *p = [_selectedAssets firstObject];
        
        if (p.mediaType == 2) { // 上传的视频
            
            [self uploadPictureWithOutputPath:self.outputPath];
            
        } else { // 上传的图片
            
            [self uplodaPhotos];
            
        }
        
    } else { // 图片非必须
//        [self.view showTostWithMessage:@"请选择图片"];
        
        NSMutableArray *arr = [NSMutableArray array];
        
        [self uplodaPublicationTrendsWithDataArray:arr];
    }
    
}


- (void)uplodaPhotos{
    
    [self.view showLoading];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置时间格式
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
 
    [HLHTTPSessionManager postDataWithNSString:HLUPLoad_AlbumImages withDictionary:@{@"uid":[LoginManager defaultManager].userid} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //
        [self->_selectedPhotos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIImage *image = obj;
            NSData *imageData = UIImageJPEGRepresentation(image,1);
            [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"image[%d]",idx] fileName:fileName mimeType:@"image/jpeg"];
        }];
        
        
    } success:^(NSDictionary *dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
//            self->_uplodaPicArr = [HLAlbumUploadModel mj_objectArrayWithKeyValuesArray:dictionary[@"data"]];
            [self uplodaPublicationTrendsWithDataArray:dictionary[@"data"]];
        } else {
            
            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError *error) {
        if (error.code == NSURLErrorBadServerResponse) {
            [self.view showErrorWithMessage:@"上传失败，请稍后再试！"];
        }else
        {
            [self.view showErrorWithMessage:@"上传失败，请检查网络！"];
        }
    }];
    
}
- (void)uplodaPublicationTrendsWithDataArray:(NSMutableArray *)array {
    
    // 针对话题模块
    if (!kISNullObject(self.fabuId)) {
        
        // 设置了地址, 可继续进行发布
        [self requestShowAddressWithArray:array];
        
        return;
    }
    
    // 调用接口发布动态
    [self uploadPublishWithArray:array];
    
}

// 调用接口发布动态
- (void)uploadPublishWithArray:(NSMutableArray *)array {
    
    NSString *theURL = [NSString string];
    
    if (self.isYanPin) { // 发布颜品动态的url
        
        theURL = @"/album/abadd";
        
    } else{ // 普通动态url
        theURL = HLPublic_Trends;
    }
    
    WeakSelf(weakSelf);
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[LoginManager defaultManager].userid forKey:@"uid"];
    [dic setObject:self.growingTextView.text forKey:@"content"];
    
    if (!kISNullObject(self.fabuId) && [self.growingTextView.text containsString:self.fabuString]) {
        [dic setObject:self.fabuId forKey:@"tid"];// 话题id
    }

    for (int i = 0; i<array.count; i++) {
        
        NSDictionary * dicTemp =array[i];
        if ([[dicTemp allKeys] containsObject:@"var"]) {
            [dic setObject:dicTemp[@"var"] forKey:[NSString stringWithFormat:@"pics[%d]",i]];
        }
//        [dic setObject:dicTemp[@"var"] forKey:[NSString stringWithFormat:@"pics[%d]",i]];
    }
    
    [HLHTTPSessionManager postDataWithNSString:theURL withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"%@: %@",theURL,dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"] ) {
            
            // 发布话题用
            if (!kISNullObject(self.fabuId) && [self.growingTextView.text containsString:self.fabuString]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HUA_TI_REFRESH_ADD" object:nil];
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPhotoManage" object:nil];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:error.localizedDescription];
    }];
    
}

/// 展示邮寄地址
- (void)requestShowAddressWithArray:(NSMutableArray *)array {
    
    
    // 必须有地址才让发布的需求用这个
//    NSDictionary *params = @{
//        @"uid":[LoginManager defaultManager].userid
//    };
//
//    [MBProgressHUD showLoading];
//    [HLHTTPSessionManager postDataWithNSString:@"/user/get_address" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
//        [MBProgressHUD hideLoading];
//
//        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
//
//            // 调用接口发布动态
//            [self uploadPublishWithArray:array];
//
//        } else { // 202 没有设置邮寄地址
//
//            [self pushAlertVc];
//
//        }
//
//    } failure:^(NSError * _Nonnull error) {
//        [MBProgressHUD showMessage:error.localizedDescription view:nil];
//    }];
    
    
    // 调用接口发布动态
    [self uploadPublishWithArray:array];
    
}

// 询问是否进入添加邮寄地址界面
- (void)pushAlertVc {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请设置好奖品接收地址,在进行发布!" preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *cencel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    UIAlertAction *act = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        HLAddressController *vc = [[HLAddressController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }];
    
    [alertVC addAction:cencel];
    [alertVC addAction:act];
    
    [self presentViewController:alertVC animated:YES completion:nil];
    
}

// 上传视频, 提交接口, 后台字段不同意, 图片:var, 视频url
- (void)uplodaPublicationTrendsWithVideoId:(NSString *)vid {
    WeakSelf(weakSelf);
    
    
    NSString *theURL = [NSString string];
    
    if (self.isYanPin) { // 发布颜品动态的url
        
        theURL = @"/album/abadd";
        
    } else{ // 普通动态url
        theURL = HLPublic_Trends;
    }

    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"content":self.growingTextView.text,
//        @"pics[0]":dic[@"url"],
        @"vid":vid
    };
    
    NSMutableDictionary *parDic = [NSMutableDictionary dictionaryWithDictionary:params];
    
    
    if (!kISNullObject(self.fabuId) && [self.growingTextView.text containsString:self.fabuString]) {
        [parDic setObject:self.fabuId forKey:@"tid"];// 话题id
    }
    
    [HLHTTPSessionManager postDataWithNSString:theURL withDictionary:parDic success:^(NSDictionary * _Nonnull dictionary) {
        
        
        NSLog(@"~1~1~1~1~: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [self.view hideLoading];
            
            // 发布话题用
            if (!kISNullObject(self.fabuId) && [self.growingTextView.text containsString:self.fabuString]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HUA_TI_REFRESH_ADD" object:nil];
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPhotoManage" object:nil];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:error.localizedDescription];
    }];
}

#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (_selectedAssets) {
        PHAsset *p = [_selectedAssets firstObject];
        
        if (p.mediaType == 2) {
            return _selectedPhotos.count;
        } else {
            return _selectedPhotos.count + 1;
        }
    }
   
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TZTestCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TZTestCell" forIndexPath:indexPath];
    cell.videoImageView.hidden = YES;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    if (indexPath.item == _selectedPhotos.count) {
        cell.imageView.image = [UIImage imageNamed:@"add_photo"];
        cell.deleteBtn.hidden = YES;
        cell.gifLable.hidden = YES;
    } else {
        cell.imageView.image = _selectedPhotos[indexPath.item];
        cell.asset = _selectedAssets[indexPath.item];
        cell.deleteBtn.hidden = NO;
    }
    cell.gifLable.hidden = YES;

    cell.deleteBtn.tag = indexPath.item;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == _selectedPhotos.count) {
        [self pushTZImagePickerController];

    } else { // preview photos or video / 预览照片
    
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:_selectedAssets selectedPhotos:_selectedPhotos index:indexPath.item];
        imagePickerVc.maxImagesCount = 4;
        imagePickerVc.allowPickingGif = NO;
        imagePickerVc.allowPickingOriginalPhoto = NO;
        imagePickerVc.allowPickingMultipleVideo = YES;
        imagePickerVc.showSelectedIndex = YES;
        imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
        imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            self->_selectedPhotos = [NSMutableArray arrayWithArray:photos];
            self->_selectedAssets = [NSMutableArray arrayWithArray:assets];
            self->_isSelectOriginalPhoto = isSelectOriginalPhoto;
            [self->_collectionView reloadData];
            self->_collectionView.contentSize = CGSizeMake(0, ((self->_selectedPhotos.count + 2) / 3 ) * (self->_margin + self->_itemWH));
        }];
        [self presentViewController:imagePickerVc animated:YES completion:nil];
    }
}
#pragma mark - LxGridViewDataSource

/// 以下三个方法为长按排序相关代码
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.item < _selectedPhotos.count;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath canMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    return (sourceIndexPath.item < _selectedPhotos.count && destinationIndexPath.item < _selectedPhotos.count);
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath didMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    UIImage *image = _selectedPhotos[sourceIndexPath.item];
    [_selectedPhotos removeObjectAtIndex:sourceIndexPath.item];
    [_selectedPhotos insertObject:image atIndex:destinationIndexPath.item];
    
    id asset = _selectedAssets[sourceIndexPath.item];
    [_selectedAssets removeObjectAtIndex:sourceIndexPath.item];
    [_selectedAssets insertObject:asset atIndex:destinationIndexPath.item];
    
    [_collectionView reloadData];
}



#pragma mark - Click Event

- (void)deleteBtnClik:(UIButton *)sender {
    if ([self collectionView:self.collectionView numberOfItemsInSection:0] <= _selectedPhotos.count) {
        [_selectedPhotos removeObjectAtIndex:sender.tag];
        [_selectedAssets removeObjectAtIndex:sender.tag];
        [self.collectionView reloadData];
        return;
    }
    
    [_selectedPhotos removeObjectAtIndex:sender.tag];
    [_selectedAssets removeObjectAtIndex:sender.tag];
    [_collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        [self->_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [self->_collectionView reloadData];
    }];
}



#pragma mark - TZImagePickerController

- (void)pushTZImagePickerController {
   
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    // imagePickerVc.barItemTextColor = [UIColor redColor];
    // imagePickerVc.naviBgColor = [UIColor whiteColor];
    // imagePickerVc.navigationBar.translucent = NO;
    
#pragma mark - 五类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    
    imagePickerVc.selectedAssets = _selectedAssets; // 目前已经选中的图片数组
    imagePickerVc.videoMaximumDuration = 15; // 视频最大拍摄时间
    
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
//        self->_selectedPhotos = photos;
//        [_collectionView reloadData];
    }];
    
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

/*
 // 设置了navLeftBarButtonSettingBlock后，需打开这个方法，让系统的侧滑返回生效
 - (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
 
 navigationController.interactivePopGestureRecognizer.enabled = YES;
 if (viewController != navigationController.viewControllers[0]) {
 navigationController.interactivePopGestureRecognizer.delegate = nil; // 支持侧滑
 }
 }
 */

#pragma mark - UIImagePickerController

- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        // 无相机权限 做一个友好的提示
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self takePhoto];
                });
            }
        }];
        // 拍照之前还需要检查相册权限
    } else if ([PHPhotoLibrary authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else if ([PHPhotoLibrary authorizationStatus] == 0) { // 未请求过相册权限
        [[TZImageManager manager] requestAuthorizationWithCompletion:^{
            [self takePhoto];
        }];
    } else {
        [self pushImagePickerController];
    }
}

// 调用相机
- (void)pushImagePickerController {
    // 提前定位
    __weak typeof(self) weakSelf = self;
    [[TZLocationManager manager] startLocationWithSuccessBlock:^(NSArray<CLLocation *> *locations) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.location = [locations firstObject];
    } failureBlock:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.location = nil;
    }];
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVc.sourceType = sourceType;
        NSMutableArray *mediaTypes = [NSMutableArray array];
        [mediaTypes addObject:(NSString *)kUTTypeImage];

        if (mediaTypes.count) {
            _imagePickerVc.mediaTypes = mediaTypes;
        }
        [self presentViewController:_imagePickerVc animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    tzImagePickerVc.sortAscendingByModificationDate = YES;
    [tzImagePickerVc showProgressHUD];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSDictionary *meta = [info objectForKey:UIImagePickerControllerMediaMetadata];
        // save photo and get asset / 保存图片，获取到asset
        [[TZImageManager manager] savePhotoWithImage:image meta:meta location:self.location completion:^(PHAsset *asset, NSError *error){
            [tzImagePickerVc hideProgressHUD];
            if (error) {
                NSLog(@"图片保存失败 %@",error);
            } else {
                TZAssetModel *assetModel = [[TZImageManager manager] createModelWithAsset:asset];
                [self refreshCollectionViewWithAddedAsset:assetModel.asset image:image];

            }
        }];
    } else if ([type isEqualToString:@"public.movie"]) {
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        if (videoUrl) {
            [[TZImageManager manager] saveVideoWithUrl:videoUrl location:self.location completion:^(PHAsset *asset, NSError *error) {
                [tzImagePickerVc hideProgressHUD];
                if (!error) {
                    TZAssetModel *assetModel = [[TZImageManager manager] createModelWithAsset:asset];
                    [[TZImageManager manager] getPhotoWithAsset:assetModel.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                        if (!isDegraded && photo) {
                            [self refreshCollectionViewWithAddedAsset:assetModel.asset image:photo];
                        }
                    }];
                }
            }];
        }
    }
}

- (void)refreshCollectionViewWithAddedAsset:(PHAsset *)asset image:(UIImage *)image {
    [_selectedAssets addObject:asset];
    [_selectedPhotos addObject:image];
    [_collectionView reloadData];
    
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = asset;
        NSLog(@"location:%@",phAsset.location);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - TZImagePickerControllerDelegate

/// User click cancel button
/// 用户点击了取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    // NSLog(@"cancel");
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    [_collectionView reloadData];

    // 1.打印图片名字
//    [self printAssetsName:assets];
    // 2.图片位置信息
//    for (PHAsset *phAsset in assets) {
//        NSLog(@"location:%@",phAsset.location);
//    }
    
    // 3. 获取原图的示例，用队列限制最大并发为1，避免内存暴增
//    self.operationQueue = [[NSOperationQueue alloc] init];
//    self.operationQueue.maxConcurrentOperationCount = 1;
//    for (NSInteger i = 0; i < assets.count; i++) {
//        PHAsset *asset = assets[i];
//        // 图片上传operation，上传代码请写到operation内的start方法里，内有注释
//        TZImageUploadOperation *operation = [[TZImageUploadOperation alloc] initWithAsset:asset completion:^(UIImage * photo, NSDictionary *info, BOOL isDegraded) {
//            if (isDegraded) return;
//            NSLog(@"图片获取&上传完成");
//        } progressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
//            NSLog(@"获取原图进度 %f", progress);
//        }];
//        [self.operationQueue addOperation:operation];
//    }
}

// 选择视频的回调
-(void)imagePickerController:(TZImagePickerController *)picker
       didFinishPickingVideo:(UIImage *)coverImage
                sourceAssets:(PHAsset *)asset{
    [self.view showLoading];
    // 时间限制
//    if (asset.duration > 15.99) {
//        [self.view showTostWithMessage:@"小视频时长限制在15s及以内"];
//        return;
//    }
    
//    PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
//    long long size = [[resource valueForKey:@"fileSize"] longLongValue];
//    NSString *videoSize = [NSString stringWithFormat:@"%.2fM",(CGFloat)size/(1024*1024)];
//
//    NSLog(@"视频大小: %@",videoSize);
//
//    if ([videoSize doubleValue] > 25) {
//        [self.view showTostWithMessage:@"小视频大小限制在25M及以内"];
//        return;
//    }
    
    
    _selectedPhotos = [NSMutableArray arrayWithArray:@[coverImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    // open this code to send video / 打开这段代码发送视频
    [[TZImageManager manager] getVideoOutputPathWithAsset:asset presetName:AVAssetExportPresetHighestQuality success:^(NSString *outputPath) {
        [self.view hideLoading];
        NSData *data = [NSData dataWithContentsOfFile:outputPath];
        
        
        NSLog(@"~~~ %.2f",(CGFloat)data.length/(1024*1024));
        
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
        // Export completed, send video here, send by outputPath or NSData
        // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
        self.outputPath = outputPath;
        
    } failure:^(NSString *errorMessage, NSError *error) {
        [self.view hideLoading];
        NSLog(@"视频导出失败:%@,error:%@",errorMessage, error);
    }];
    [_collectionView reloadData];
    
}

- (void)uploadPictureWithOutputPath:(NSString *)outputPath {
    
    [self.uploader addFile:self.outputPath vodInfo:nil];
    
    [self.view showLoading];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat   = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.mp4", str];
    
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"filePath":fileName,
        @"title":@"12345"
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/album/get_vid" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        
        NSLog(@"~~~~~~: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            
            self.UploadAddress = dictionary[@"data"][@"json"][@"UploadAddress"];
            self.UploadAuth = dictionary[@"data"][@"json"][@"UploadAuth"];
            self.VideoId = dictionary[@"data"][@"json"][@"VideoId"];

            //开始上传
            [self.uploader start];
            
            
        }else {
            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.view showErrorWithMessage:error.localizedDescription];
    }];
    
    
    
//    [HLHTTPSessionManager postDataWithNSString:HLUPLoad_HeaderImage withDictionary:@{@"uid":[LoginManager defaultManager].userid} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//
//        NSError *error;
//        BOOL success = [formData appendPartWithFileURL:[NSURL fileURLWithPath:outputPath] name:@"image" fileName:fileName mimeType:@"video/mpeg4" error:&error];
//        if (!success) {
//
//            NSLog(@"appendPartWithFileURL error: %@", error);
//        }
//
//    } success:^(NSDictionary *dictionary) {
//        NSLog(@"~~~~~%@",dictionary);
//
//        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
//        if ([code isEqualToString:@"200"] ) {
//
//            [self uplodaPublicationTrendsWithDic:dictionary[@"data"]];
//
//        } else {
//
//            [self.view showErrorWithMessage:dictionary[@"msg"]];
//        }
//
//    } failure:^(NSError *error) {
//
//        [self.view showErrorWithMessage:[error localizedDescription]];
//
//    }];
    
}


// If user picking a gif image and allowPickingMultipleVideo is NO, this callback will be called.
// If allowPickingMultipleVideo is YES, will call imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
// 如果用户选择了一个gif图片且allowPickingMultipleVideo是NO，下面的代理方法会被执行
// 如果allowPickingMultipleVideo是YES，将会调用imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(PHAsset *)asset {
    _selectedPhotos = [NSMutableArray arrayWithArray:@[animatedImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    [_collectionView reloadData];
}

// Decide album show or not't
// 决定相册显示与否
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(PHFetchResult *)result {
  
    return YES;
}

// Decide asset show or not't
// 决定asset显示与否
- (BOOL)isAssetCanSelect:(PHAsset *)asset {

    return YES;
}

#pragma mark - Private

/// 打印图片名字
- (void)printAssetsName:(NSArray *)assets {
    NSString *fileName;
    for (PHAsset *asset in assets) {
        fileName = [asset valueForKey:@"filename"];
         NSLog(@"图片名字:%@",fileName);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.growingTextView.isFirstResponder) {
        [self.growingTextView resignFirstResponder];
        
    }
}

#pragma mark - UITextViewDelegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height{
    if (height <= 114) {
        height = 114;
    }
    //更新growingTextView的高度
}
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    [self.growingTextView resignFirstResponder];
    return YES;
}
- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@""])
    {
        //删除表情
        if(_growingTextView.text&&_growingTextView.text.length) {
            NSString *lastStr = [_growingTextView.text substringFromIndex:_growingTextView.text.length-1];
            if (IsEquallString(lastStr, @"]") && _growingTextView.text.length > 2) {
                NSInteger index = - 1;
                for (NSInteger i = _growingTextView.text.length - 1; i >= 0; i--) {
                    NSString *str = [_growingTextView.text substringWithRange:NSMakeRange(i, 1)];
                    if (IsEquallString(str, @"[")) {
                        index = i;
                        break;
                    }
                }
                if (index >= 0) {
                    _growingTextView.text = [_growingTextView.text substringToIndex:index];
                } else {
                    _growingTextView.text = [_growingTextView.text substringToIndex:_growingTextView.text.length-1];
                }
                return NO;
            }
            
        }
        //删除@
        NSRange selectRange = growingTextView.selectedRange;
        if (selectRange.length > 0)
        {
            //用户长按选择文本时不处理
            return YES;
        }
        // 判断删除的是一个@中间的字符就整体删除
        NSMutableString *string = [NSMutableString stringWithString:growingTextView.text];
        NSArray *matches = [self atAll];
        
        BOOL inAt = NO;
        NSInteger index = range.location;
        for (NSTextCheckingResult *match in matches)
        {
            NSRange newRange = NSMakeRange(match.range.location + 1, match.range.length - 1);
            if (NSLocationInRange(range.location, newRange))
            {
                
//                for (int i=0; i<self.AtArray.count; i++) {
//                    NSDictionary *dict = self.AtArray[i];
//                    if (IsEquallString(dict[@"name"], [string substringWithRange:match.range])) {
//                        [self.AtArray removeObjectAtIndex:i];
//                        break;
//                    }
//                }
                
                //删除本地保存的@对象或者话题对象
                
                inAt = YES;
                index = match.range.location;
                [string replaceCharactersInRange:match.range withString:@""];
                break;
            }
        }
        
        if (inAt)
        {
            growingTextView.text = string;
            growingTextView.selectedRange = NSMakeRange(index, 0);
            return NO;
        }
        
        NSArray *matches1 = [self topicAll];
        
        BOOL inTopic = NO;
        NSInteger index1 = range.location;
        for (NSTextCheckingResult *match1 in matches1)
        {
            NSRange newRange1 = NSMakeRange(match1.range.location +1, match1.range.length-1);
            if (NSLocationInRange(range.location, newRange1))
            {
//                NSLog(@"-%@-",[string substringWithRange:match1.range]);
//                for (int i=0; i<self.topicArray.count; i++) {
//                    NSDictionary *dict = self.topicArray[i];
//                    if (IsEquallString(dict[@"name"], [string substringWithRange:match1.range])) {
//                        [self.topicArray removeObjectAtIndex:i];
//                        break;
//                    }
//                }
//
//                NSLog(@"%@",self.topicArray);
                inTopic = YES;
                index1 = match1.range.location;
                [string replaceCharactersInRange:match1.range withString:@""];
                break;
            }
        }
        
        if (inTopic)
        {
            growingTextView.text = string;
            growingTextView.selectedRange = NSMakeRange(index1, 0);
            return NO;
        }
        
    }
    
    // 如果复制的字数加上原本的字数超过200, 不添加到textView上/ 后期在做超过200字的截取
    if (text.length + growingTextView.text.length > 200) {
        return NO;
    }
    
    //控制文本输入内容
    if (range.location>=200){
        //控制输入文本的长度
        return  NO;
    }
    
    
    
    //判断是回车键就发送出去
    if ([text isEqualToString:@"\n"])
    {
        [self.view endEditing:YES];
        return NO;
    }
    return YES;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    
    UITextRange *selectedRange = growingTextView.internalTextView.markedTextRange;
    NSString *newText = [growingTextView.internalTextView textInRange:selectedRange];
    if (newText.length < 1)
    {
        // 高亮输入框中的@
        UITextView *textView = self.growingTextView.internalTextView;
        NSRange range = textView.selectedRange;

        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:textView.text];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, string.string.length)];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5;// 字体的行间距
        [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, string.string.length)];
        [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, string.string.length)];
        NSArray *matches = [self atAll];

        for (NSTextCheckingResult *match in matches)
        {
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:0xF96781] range:NSMakeRange(match.range.location, match.range.length-1)];
        }

        NSArray *matches1 = [self topicAll];
        for (NSTextCheckingResult *match1 in matches1)
        {
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:0xF96781] range:NSMakeRange(match1.range.location, match1.range.length-1)];
        }

        textView.attributedText = string;
        textView.selectedRange = range;
    }
    if (growingTextView.text.length<=0) {
        growingTextView.textColor = [UIColor blackColor];
    }
    
    
    self.showNumLabel.text = [NSString stringWithFormat:@"%ld/200",growingTextView.text.length ];
}

- (void)growingTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView
{
    // 光标不能点落在@词中间
    NSRange range = growingTextView.selectedRange;
    if (range.length > 0)
    {
        // 选择文本时可以
        return;
    }
    NSArray *matches = [self atAll];
    for (NSTextCheckingResult *match in matches)
    {
        NSRange newRange = NSMakeRange(match.range.location + 1, match.range.length - 1);
        if (NSLocationInRange(range.location, newRange))
        {
            growingTextView.internalTextView.selectedRange = NSMakeRange(match.range.location + match.range.length, 0);
            break;
        }
    }

    NSArray *matches1 = [self topicAll];

    for (NSTextCheckingResult *match1 in matches1)
    {
        NSRange newRange1 = NSMakeRange(match1.range.location+1, match1.range.length-1);
        if (NSLocationInRange(range.location, newRange1))
        {
            growingTextView.internalTextView.selectedRange = NSMakeRange(match1.range.location + match1.range.length, 0);
            break;
        }
    }
}

- (NSArray<NSTextCheckingResult *> *)atAll
{
    // 找到文本中所有的@
//    NSString *string = self.growingTextView.text;
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(...)+ "  options:NSRegularExpressionCaseInsensitive error:nil];
//    NSArray *matches = [regex matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, [string length])];
//    return matches;
    
    // 找到文本中所有的@
    //
    NSString *string = self.growingTextView.text;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(.*?)+ "  options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, [string length])];
    return matches;
    
    
}

- (NSArray<NSTextCheckingResult *> *)topicAll
{
    // 找到文本中所有的@
    NSString *string = self.growingTextView.text;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(.*?)#+ " options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, [string length])];
    return matches;
}

/// 拼接
-(NSString *)jsonString:(NSArray *)dataArr{
    NSString *attring= [NSString string];
    if (dataArr.count>0) {
        NSMutableArray *atarr = [NSMutableArray array];
        for ( int i =0; i<dataArr.count; i++)
        {
            NSDictionary *dict = [dataArr objectAtIndex:i];
            [atarr addObject:dict[@"id"]];
            attring = [atarr componentsJoinedByString:@","];
        }
    }else{
        attring = @"";
    }
    return attring;
}

#pragma mark CKEmoticonInputViewDelegate
- (void)emoticonInputDidTapText:(NSString *)text {
    [self.growingTextView.internalTextView unmarkText];
    NSInteger index = self.growingTextView.text.length;
    index = self.growingTextView.selectedRange.location + self.growingTextView.selectedRange.length;
    UITextView *textView = self.growingTextView.internalTextView;
    NSString *insertString = text;
    NSMutableString *string = [NSMutableString stringWithString:textView.text];
    [string insertString:insertString atIndex:index];
    self.growingTextView.text = string;
    textView.selectedRange = NSMakeRange(index + insertString.length, 0);
//    [self growingTextViewDidChange:self.growingTextView];
//    [self.growingTextView scrollRangeToVisible:NSMakeRange(self.growingTextView.text.length, 1)];
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
