//
//  HLGaoYanZhiCell.m
//  hongdou
//
//  Created by 李龙 on 2020/7/5.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLGaoYanZhiCell.h"
#import "HLGaoYanZhiCollectionCell.h"

@interface HLGaoYanZhiCell ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@end

@implementation HLGaoYanZhiCell

- (IBAction)huanClick:(UIButton *)sender {
    
    if (![LoginManager defaultManager].isVip) {
        [self.delegate pushVipClick];
        return;
    }
    
    [MBProgressHUD showLoading];
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/rh_looking" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [MBProgressHUD hideLoading];
            
            self.dic = dictionary[@"data"];
            
            [self.collectionView reloadData];
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

- (void)setDic:(NSDictionary *)dic {
    _dic = dic;
    
    [self.collectionView reloadData];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [_collectionView registerNib:[UINib nibWithNibName:@"HLGaoYanZhiCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"HLGaoYanZhiCollectionCell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ((NSArray *)self.dic[@"looking"]).count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HLGaoYanZhiCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HLGaoYanZhiCollectionCell" forIndexPath:indexPath];
    
    NSArray *arr = self.dic[@"looking"];
    
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:arr[indexPath.item][@"head"]] placeholderImage:[UIImage imageNamed:@"icon_head"]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *arr = self.dic[@"looking"];
    
    [self.delegate pushGaoYanZhiDetailWithId:arr[indexPath.item][@"id"]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
