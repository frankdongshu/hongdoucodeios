//
//  MultipleImgCell.m
//  hongdou
//
//  Created by 李龙 on 2020/3/10.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "MultipleImgCell.h"
#import "MultipleCollectionCell.h"
#import "TZImagePickerController.h" // 图库
#import "TZImagePreviewController.h"

@interface MultipleImgCell ()<UICollectionViewDelegate, UICollectionViewDataSource, TZImagePickerControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;

@end

@implementation MultipleImgCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self configCollectionView];
        
    }
    return self;
}

- (void)setPictures:(NSArray *)pictures {
    _pictures = pictures;
    
    _selectedPhotos = [NSMutableArray arrayWithArray:pictures];
    
}

- (void)configCollectionView {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.itemSize = CGSizeMake(90, 90);
    layout.minimumInteritemSpacing = 20; //item列与列之间的最小间距
    layout.minimumLineSpacing = 20; //行与行的最小间距
    layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
    
    
    // 设置头视图的大小
//    layout.headerReferenceSize = CGSizeMake(50, 50);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 380) collectionViewLayout:layout];
    _collectionView.scrollEnabled = NO;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [self addSubview:_collectionView];
    
    [_collectionView registerClass:[MultipleCollectionCell class] forCellWithReuseIdentifier:@"MultipleCollectionCell"];
    
    [_collectionView registerClass:[UICollectionReusableView class]  forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    
    if (self.picType == OnlyShow) {
        return CGSizeMake(0, 0);
    }
    
    return CGSizeMake(50, 50);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableview = nil;
 
    if (kind == UICollectionElementKindSectionHeader){
 
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        if (headerView.subviews.count != 1) {
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, headerView.frame.origin.y, headerView.frame.size.width-30, headerView.frame.size.height)];
            lab.numberOfLines = 0;
            lab.text = @"相关证书上传(录取通知、学生证、教师资格证、各类考级证书)";
            lab.font = kFontSize(14);
            lab.textColor = [UIColor darkGrayColor];
            
            [headerView addSubview:lab];
        }
        
        reusableview = headerView;
 
    }
 
    return reusableview;
 
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.picType == OnlyShow) {
        return _selectedPhotos.count;
    }
    
    return _selectedPhotos.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MultipleCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MultipleCollectionCell" forIndexPath:indexPath];
    cell.videoImageView.hidden = YES;
    if (indexPath.item == _selectedPhotos.count) {
        cell.imageView.image = [UIImage imageNamed:@"add_photo"];
        cell.deleteBtn.hidden = YES;
        cell.gifLable.hidden = YES;
    } else {
        id photo = _selectedPhotos[indexPath.item][@"pic"];
        if ([photo isKindOfClass:[UIImage class]]) {
            cell.imageView.image = photo;
        } else if ([photo isKindOfClass:[NSString class]]) {
            [self configImageView:cell.imageView URL:[NSURL URLWithString:photo] completion:nil];
            
        } else if ([photo isKindOfClass:[PHAsset class]]) {
            [[TZImageManager manager] getPhotoWithAsset:photo photoWidth:100 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                cell.imageView.image = photo;
            }];
        }
        cell.asset = _selectedPhotos[indexPath.item][@"pic"];
        cell.gifLable.hidden = YES;
        
        if (self.picType == WriteRead) {
            cell.deleteBtn.hidden = NO;
        } else {
            cell.deleteBtn.hidden = YES;
        }
        
    }
    cell.deleteBtn.tag = indexPath.item;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark - Click Event

- (void)deleteBtnClik:(UIButton *)sender {
    
    if ([self collectionView:self.collectionView numberOfItemsInSection:0] <= _selectedPhotos.count) {
        [_selectedPhotos removeObjectAtIndex:sender.tag];
        [self.collectionView reloadData];
        return;
    }
    
    // 删除证件照图片
    [self updateDeleteImageWithPhotoId:self.selectedPhotos[sender.tag][@"id"]];
    
    [_selectedPhotos removeObjectAtIndex:sender.tag];
    [self.collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [self.collectionView reloadData];
    }];
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == _selectedPhotos.count) { // 选择
        TZImagePickerController *imagePickerVc = [self createTZImagePickerController];
        imagePickerVc.maxImagesCount = 9-self.selectedPhotos.count;
        imagePickerVc.isSelectOriginalPhoto = NO;
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            
            
            // 上传图片
            [self uploadPhotosWithPhotos:photos];
            
            for (UIImage *image in photos) {
                NSDictionary *dic = @{@"pic":image};
                [self.selectedPhotos addObject:dic];
            }
            
            [self.collectionView reloadData];
            
        }];
        self.block(imagePickerVc);
        
    } else { // 预览
        TZImagePickerController *imagePickerVc = [self createTZImagePickerController];
        imagePickerVc.maxImagesCount = 1;
        imagePickerVc.showSelectBtn = NO;
        [imagePickerVc setPhotoPreviewPageDidLayoutSubviewsBlock:^(UICollectionView *collectionView, UIView *naviBar, UIButton *backButton, UIButton *selectButton, UILabel *indexLabel, UIView *toolBar, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel) {
            if (numberLabel) {
                [numberLabel removeFromSuperview];
                numberLabel = nil;
            }
            if (numberImageView) {
                [numberImageView removeFromSuperview];
                numberImageView = nil;
            }
            if (doneButton) {
                [doneButton removeFromSuperview];
                doneButton = nil;
            }
        }];
        
        NSMutableArray *theArray = [NSMutableArray array];
        for (NSDictionary *dic in self.selectedPhotos) {
            [theArray addObject:[NSURL URLWithString:dic[@"pic"]]];
        }
        
        TZImagePreviewController *previewVc = [[TZImagePreviewController alloc] initWithPhotos:theArray currentIndex:indexPath.row tzImagePickerVc:imagePickerVc];
        
        previewVc.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [previewVc setBackButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
            
            NSLog(@"预览页 返回 isSelectOriginalPhoto:%d", isSelectOriginalPhoto);
        }];
        [previewVc setSetImageWithURLBlock:^(NSURL *URL, UIImageView *imageView, void (^completion)(void)) {
            [self configImageView:imageView URL:URL completion:completion];
        }];
        [previewVc setDoneButtonClickBlock:^(NSArray *photos, BOOL isSelectOriginalPhoto) {
            
            self.selectedPhotos = [NSMutableArray arrayWithArray:photos]; // 执行不到, 用到DoneButton需要改该句
            NSLog(@"预览页 完成 isSelectOriginalPhoto:%d photos.count:%zd", isSelectOriginalPhoto, photos.count);
            [self.collectionView reloadData];
        }];
        
        self.block(previewVc);
    }
}

- (void)configImageView:(UIImageView *)imageView URL:(NSURL *)URL completion:(void (^)(void))completion{
    if ([URL.absoluteString.lowercaseString hasSuffix:@"gif"]) {
        
    } else {
        [imageView sd_setImageWithURL:URL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (completion) {
                completion();
            }
        }];
    }
}

#pragma mark - TZImagePickerController

- (TZImagePickerController *)createTZImagePickerController {
    [TZImageManager manager].isPreviewNetworkImage = YES;
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self pushPhotoPickerVc:NO];
    
#pragma mark - 个性化设置，这些参数都可以不传，此时会走默认设置
    

    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    // imagePickerVc.navigationBar.translucent = NO;
    imagePickerVc.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.showSelectedIndex = YES;
    imagePickerVc.showPhotoCannotSelectLayer = YES;
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;

    // imagePickerVc.minImagesCount = 3;
    // imagePickerVc.alwaysEnableDoneBtn = YES;

    imagePickerVc.showSelectBtn = NO;
    //imagePickerVc.allowPreview = NO;
    // imagePickerVc.preferredLanguage = @"zh-Hans";

#pragma mark - 到这里为止
    
    return imagePickerVc;
}

#pragma mark - 图片上传
- (void)uploadPhotosWithPhotos:(NSArray *)imgArray {
    [self showLoading];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置时间格式
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
    
    [HTTPSessionManger postDataWithNSString:HLUPLoad_AlbumImages withDictionary:@{} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [imgArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UIImage *image = obj;
            NSData *imageData = UIImageJPEGRepresentation(image,0.5);
            [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"image[%d]",idx] fileName:fileName mimeType:@"image/jpeg"];
            
        }];
        
    } success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"%@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {

            NSMutableArray *imgArray = [NSMutableArray array];
            
            for (NSDictionary *dic in dictionary[@"data"]) {
                [imgArray addObject:dic[@"var"]];
            }
            
            [self uploadDoctorAddImageWithURLArray:imgArray];

        } else {
            [self showErrorWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        if (error.code == NSURLErrorBadServerResponse) {
            [self showErrorWithMessage:@"上传失败，请稍后再试！"];
        } else {
            [self showErrorWithMessage:@"上传失败，请检查网络！"];
        }
    }];
    
}

#pragma mark - 上传证件照
- (void)uploadDoctorAddImageWithURLArray:(NSMutableArray *)urlArray {
    
    NSDictionary *dic = @{
        @"token":[MyLogin getCurrentLoginUser].token,
        @"uid":[MyLogin getCurrentLoginUser].userid,
        @"pics":urlArray
    };
    
    [HTTPSessionManger postDataWithNSString:@"/coach/add_pic" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            // 添加新图后, 移除现有数组, 修改图片(添加), 没有返回图片id
            [self.selectedPhotos removeAllObjects];
            // 重新请求详情, 获取图片数组
            [self requestData];
            
        } else {
            [self showErrorWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self showErrorWithMessage:@"请求失败"];
    }];
    
}

// 获取用户信息(为了得到图片id)
- (void)requestData {
    
    NSDictionary *parmas = @{
        @"uid":[MyLogin getCurrentLoginUser].userid,
        @"token":[MyLogin getCurrentLoginUser].token
    };

    [HTTPSessionManger postDataWithNSString:@"/coach/get_coach" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            [self hideLoading];
            
            self.selectedPhotos = dictionary[@"data"][@"papers"];
            
            MyLogin *u = [MyLogin getCurrentLoginUser];
            u.papers = self.selectedPhotos;
            [MyLogin updateUser:u];
            
            [self.collectionView reloadData];
            
            
        } else {
            [self showErrorWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [self showErrorWithMessage:@"请求失败"];
    }];
}

#pragma mark - 删除证件照
- (void)updateDeleteImageWithPhotoId:(NSString *)imageId {
    [self showLoading];
    
    NSDictionary *dic = @{
        @"token":[MyLogin getCurrentLoginUser].token,
        @"uid":[MyLogin getCurrentLoginUser].userid,
        @"picid":imageId
    };
    
    [HTTPSessionManger postDataWithNSString:@"/coach/del_pic" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"=%@",dictionary);
        
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
            [self hideLoading];
            
            MyLogin *u = [MyLogin getCurrentLoginUser];
            u.papers = self.selectedPhotos;
            [MyLogin updateUser:u];
            
        } else {
            [self showErrorWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self showErrorWithMessage:@"请求失败"];
    }];
    
}

@end
