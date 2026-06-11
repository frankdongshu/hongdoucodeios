//
//  HLNewVipCell.m
//  hongdou
//
//  Created by 李龙 on 2020/7/4.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLNewVipCell.h"
#import "HLNewVipCollectionCell.h"
#import "HLNewVipModel.h"

@interface HLNewVipCell ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) HLNewVipModel *model;

@end

@implementation HLNewVipCell

- (IBAction)pushVipClick:(UIButton *)sender {
    
    [self.delegate pushVip];
}

// /user/rh_vip
- (IBAction)huanClick:(UIButton *)sender {
    
    if (![LoginManager defaultManager].isVip) {
        [self.delegate pushVip];
        return;
    }
    
    [MBProgressHUD showLoading];
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/rh_vip" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [MBProgressHUD hideLoading];
            
            self.model = [HLNewVipModel mj_objectWithKeyValues:dictionary[@"data"]];
            
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
    
    self.model = [HLNewVipModel mj_objectWithKeyValues:dic];
    
    [self.collectionView reloadData];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [_collectionView registerNib:[UINib nibWithNibName:@"HLNewVipCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"HLNewVipCollectionCell"];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.model.vipArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HLNewVipCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HLNewVipCollectionCell" forIndexPath:indexPath];
    
    HLNewVipPerModel *mod = self.model.vipArr[indexPath.item];
    
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:mod.head]];
    
    cell.nameLab.text = mod.nickname;
    
    NSString *ageStr = kISNullObject(mod.age)?@"":mod.age;
    NSString *heightStr = kISNullObject(mod.height)?@"":mod.height;
    
    cell.infoLab.text = [NSString stringWithFormat:@"%@岁 %@",ageStr,heightStr];
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HLNewVipPerModel *mod = self.model.vipArr[indexPath.item];
    
    [self.delegate pushVipDetailWithId:mod.uid];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
