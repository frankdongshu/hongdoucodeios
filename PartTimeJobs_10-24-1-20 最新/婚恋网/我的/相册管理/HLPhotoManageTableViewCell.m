//
//  HLPhotoManageTableViewCell.m
//  hongdou
//
//  Created by iMac on 2019/9/26.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLPhotoManageTableViewCell.h"

@implementation HLPhotoManageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.collectionButtn setImage:[UIImage imageNamed:@"unlike"] forState:UIControlStateNormal];
    [self.collectionButtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateSelected];
    [self.collectionButtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [self.collectionButtn setTitleColor:self.likeNumLable.textColor forState:UIControlStateNormal];
    
    self.contenView.userInteractionEnabled = YES;
    self.btnArray = [NSMutableArray array];
    [self creatPhotoImageView];
}

- (void)setAlbumModel:(HLAlbumDetails *)albumModel{
    _albumModel = albumModel;
    self.titleLable.text = albumModel.content;
    [self.collectionButtn setSelected:albumModel.islikes];
    [self.collectionButtn setTitle:albumModel.likes forState:UIControlStateNormal];
    
    [self.contenView removeAllSubviews];
    if (albumModel.photoArray.count>0) {
        CGFloat width= (kScreenWidth - 60) / 4;
        
        if (albumModel.photoArray.count == 4 || albumModel.photoArray.count == 8) {
            [self.contenView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo((albumModel.photoArray.count/4) * width +10);
            }];
        } else {
            [self.contenView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo((albumModel.photoArray.count/4+1) * width +10);
            }];
        }
        [_albumModel.photoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            HLPhotoModel *model = obj;
            UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(idx%4*((kScreenWidth - 60)/4.f + 10), idx/4 * (10 + width), width, width)];
            photoImageView.hidden = NO;
            photoImageView.userInteractionEnabled = YES;
            [photoImageView sd_setImageWithURL:[NSURL URLWithString:model.url] placeholderImage:[UIImage imageNamed:@"tupianzhanwei"]];
            photoImageView.contentMode = UIViewContentModeScaleAspectFill;
            photoImageView.layer.cornerRadius = 3.f;
            photoImageView.layer.masksToBounds = YES;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonAction:)];
            [photoImageView addGestureRecognizer:tap];
            [self.btnArray addObject:photoImageView];
            [self.contenView addSubview:photoImageView];
        }];
    }else{
        [self.contenView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
    [self layoutIfNeeded];
}

- (void)creatPhotoImageView{
    for (int i=0; i<12; i++) {
        CGFloat width= (kScreenWidth - 60) / 4 ;
        NSInteger indexX = i % 4 * (10 + width);

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(indexX, i / 4 * (10 + width), width, width)];
        imageView.tag = i;
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.userInteractionEnabled = YES;
        imageView.image = [UIImage imageNamed:@"tupianzhanwei"];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonAction:)];
        [imageView addGestureRecognizer:tap];
//        [self.contenView addSubview:imageView];
        [self.btnArray addObject:imageView];

    }
}
- (void)buttonAction:(UITapGestureRecognizer *)tap{
    // 获取当前点击的位置
    CGPoint selectPoint = [tap locationInView:self];
    [self.btnArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         UIImageView *photoImageView = self.btnArray[idx];
         // 某个图片区域位置
        CGRect rect = [self convertRect:photoImageView.frame fromView:self.contenView];
        // 判断点击点是否在某个课件内
        if (CGRectContainsPoint(rect, selectPoint)) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(photoButtonClick:withIndexPath:andIsLike:)]) {
                [self.delegate photoButtonClick:idx withIndexPath:self.indexPath andIsLike:self.collectionButtn.selected];
            }
            *stop = YES;
        }
    }];
    
    
}

- (IBAction)deleteClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteButtonClickIndexPath:)]) {
        [self.delegate deleteButtonClickIndexPath:self.indexPath];
    }
}
- (IBAction)colletionClick:(id)sender {
    
    if (self.collectionButtn.selected) {
        [self requestCollectionUrl:HLAlbum_DeleteLike];
    }else{
        [self requestCollectionUrl:HLAlbum_Like];
    }
   
}

- (void)requestCollectionUrl:(NSString *)url{
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"aid":self.albumModel.albumId
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:url withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            self.collectionButtn.selected = !self.collectionButtn.selected;
            
            if ([url isEqualToString:HLAlbum_DeleteLike]) {
                
                [weakSelf.collectionButtn setTitle:[NSString stringWithFormat:@"%d",[self.collectionButtn.titleLabel.text intValue]-1] forState:UIControlStateNormal];
                
            } else {
                
                [weakSelf.collectionButtn setTitle:[NSString stringWithFormat:@"%d",[self.collectionButtn.titleLabel.text intValue]+1] forState:UIControlStateNormal];
            }
            
            self.albumModel.islikes = self.collectionButtn.selected;
            self.albumModel.likes = self.collectionButtn.titleLabel.text;
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(colletionButtonClick:)]) {
                [weakSelf.delegate colletionButtonClick:self.collectionButtn.selected];
            }
            
            
        } else {
            [[UIApplication sharedApplication].keyWindow showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [[UIApplication sharedApplication].keyWindow showTostWithMessage:@"操作失败，请重试！"];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
