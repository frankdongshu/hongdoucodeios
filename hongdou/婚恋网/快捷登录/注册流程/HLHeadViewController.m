//
//  HLHeadViewController.m
//  hongdou
//
//  Created by 李龙 on 2021/5/7.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLHeadViewController.h"
#import "HLSexViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface HLHeadViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    NSData *_imgeData;
}
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;

@end

@implementation HLHeadViewController

- (IBAction)nextClick:(id)sender {
    
    [self uploadUserHeaderImage];
    
}

- (IBAction)selectClick:(id)sender {
    
    [self indexPathRowModifyUserIcon];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self.view showTostWithMessage:@"未设置头像"];
    }];
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"退出" withColor:[UIColor blackColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        [self logOut];
        
    }];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(logOut)];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    self.headImgV.layer.cornerRadius = 36;
    self.headImgV.layer.masksToBounds = YES;
    self.headImgV.layer.borderColor=[[UIColor systemBlueColor] CGColor];
    self.headImgV.layer.borderWidth = 2;
    
}

- (void)logOut {
    
    [[LoginManager defaultManager] doLogout];
    [MyLogin logOut];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
    
    [JVERIFICATIONService dismissLoginControllerAnimated:YES completion:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)back:(id)sender {
    [self.view showTostWithMessage:@"未设置头像"];
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
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self presentViewController:alertViewController animated:YES completion:^{
            [alertViewController tapGesAlert];
        }];
        
    });
    
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
        _imgeData = imageData;
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        
        self.headImgV.image = [UIImage imageWithData:imageData];
        
    }
    
    
}
// 上传头像
- (void)uploadUserHeaderImage{
    
    [self.view showLoadingWithMessage:@"上传中..."];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置时间格式
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
    
    NSData* imageData = _imgeData;
    if (!_imgeData) {
        [self.view showTostWithMessage:@"请选择头头像"];
    }else{
        
        [HLHTTPSessionManager postDataWithNSString:HLUPLoad_HeaderImage withDictionary:@{@"uid":[LoginManager defaultManager].userid} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            [formData appendPartWithFileData:imageData name:@"image" fileName:fileName mimeType:@"image/jpeg"];
            
        } success:^(NSDictionary *dictionary) {
            
            NSLog(@"/user/upload %@",dictionary);

            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            if ([code isEqualToString:@"200"] ) {
                [self uploadUserInfoVaule:[dictionary objectForKey:@"data"][@"url"]];
            }
            else {
                [self.view showErrorWithMessage:dictionary[@"msg"]];
            }
            
        } failure:^(NSError *error) {
            [self.view showTostWithMessage:[error localizedDescription]];
        }];
    }
    
}

// 上传用户基本信息
- (void)uploadUserInfoVaule:(NSString *)vaule{
    
    [self.view showLoadingWithMessage:@"正在设置..."];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"type":@"head",
        @"val":vaule
    };
    
    [HLHTTPSessionManager postDataWithNSString:HLEdit_UserModify withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/user/modify: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [self.view hideLoading];
            
            [[LoginManager defaultManager] setAvatar:vaule];
            
            HLSexViewController *vc = [[HLSexViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else {
            
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:[error localizedDescription]];
    }];
    
}

/**
 *  UIImagePickerController选择完成后调用的方法
 *
 *  @param picker 图片选择的容器
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
