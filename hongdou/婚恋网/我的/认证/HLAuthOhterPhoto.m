//
//  HLAuthOhterPhoto.m
//  hongdou
//
//  Created by 维康1 on 2020/6/18.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLAuthOhterPhoto.h"
#import <AVFoundation/AVFoundation.h>

@interface HLAuthOhterPhoto ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    NSData *_imageData;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;

@end

@implementation HLAuthOhterPhoto

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"确认上传" withColor:[UIColor darkGrayColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self uploadAuthOhterImage];
        
    }];
    
    self.sc_navigationBar.title = [self.typeString isEqualToString:@"D"]?@"学历认证":[self.typeString isEqualToString:@"V"]?@"车辆认证":[self.typeString isEqualToString:@"P"]?@"职业认证":[self.typeString isEqualToString:@"R"]?@"房产认证":@"";
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self authOtherDetail];
}

// 选择图片
- (IBAction)selectClick:(UIButton *)sender {
    
    [self indexPathRowModifyUserIcon];
    
}

/**
 *  相片修改选择的路径
 */
- (void)indexPathRowModifyUserIcon{
    
//    UIView *view = [self.tableView cellForRowAtIndexPath:_currentIndexPath];
    
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"添加相片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
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
        
        _imageData = UIImageJPEGRepresentation(image,0.5);
        
        self.imgView.image = [UIImage imageWithData:_imageData];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
    
}

// 上传认证图片
- (void)uploadAuthOhterImage{
    
    [self.view showLoading];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置时间格式
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
    
    
    if (!_imageData) {
        [self.view showTostWithMessage:@"请选择图片"];
    } else {
        
        [HLHTTPSessionManager postDataWithNSString:HLUPLoad_HeaderImage withDictionary:@{@"uid":[LoginManager defaultManager].userid} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            [formData appendPartWithFileData:self->_imageData name:@"image" fileName:fileName mimeType:@"image/jpeg"];
            
        } success:^(NSDictionary *dictionary) {
            
            NSLog(@"上传图片: %@",dictionary);

            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            if ([code isEqualToString:@"200"] ) {
                
                [self isAuthWithPic:dictionary[@"data"][@"url"]];
                
            } else {
                
                [self.view showErrorWithMessage:dictionary[@"msg"]];
            }
            
        } failure:^(NSError *error) {
            [self.view showErrorWithMessage:error.localizedDescription];
        }];
    }
    
}

// 其他认证
- (void)isAuthWithPic:(NSString *)picUrl {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"type":self.typeString,
        @"pic":picUrl
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/DVPR" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"其他认证: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [self.view hideLoading];
            
            self.block();
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showErrorWithMessage:error.localizedDescription];
    }];
    
}

// 其他认证详情
- (void)authOtherDetail {
    [self.view showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"type":self.typeString
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/get_DVPR" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        [self.view hideLoading];
        NSLog(@"其他认证详情: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            [self.imgView sd_setImageWithURL:[NSURL URLWithString:dictionary[@"data"][@"pic"]]];
            self.selectBtn.hidden = YES;
            self.sc_navigationBar.rightBarButtonItem.enabled = NO;
            
        } else {
//            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showErrorWithMessage:error.localizedDescription];
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
