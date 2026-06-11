//
//  HLWishTopCell.m
//  hongdou
//
//  Created by 李龙 on 2021/12/19.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLWishTopCell.h"
#import "HLTogetherPlayCollectionCell.h"

@interface HLWishTopCell ()<UICollectionViewDelegate,UICollectionViewDataSource>

@end

@implementation HLWishTopCell


- (IBAction)exchangeClick:(id)sender {
    
    [self.delegate goExchangeVC];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.imgView.layer.cornerRadius = 7;
    self.imgView.layer.masksToBounds = YES;
    
    self.imgView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.imgView.layer.borderWidth = 1;
    
    self.btn.layer.cornerRadius = self.btn.height/2;
    self.btn.layer.masksToBounds = YES;
    
    [self.btn az_setGradientBackgroundWithColors:@[kRGB(255, 174, 157),kRGB(255, 112, 152)] locations:@[@(0),@(.8),@(0),@(0)] startPoint:CGPointMake(0, 1) endPoint:CGPointMake(1, 1)];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.estimatedItemSize = CGSizeMake(80, 80);
    
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    
//    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    
    _collectionView.collectionViewLayout = layout;
    
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [_collectionView registerNib:[UINib nibWithNibName:@"HLTogetherPlayCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"HLTogetherPlayCollectionCell"];
    
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSArray *arr = self.dataDic[@"hpl"];
    return arr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HLTogetherPlayCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HLTogetherPlayCollectionCell" forIndexPath:indexPath];
    
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:self.dataDic[@"hpl"][indexPath.item][@"head"]]];
    
//    cell.nameLab.text = _dataDic[@"hpl"][indexPath.item][@"nickname"];
    
    cell.nameLab.hidden = YES;
    
    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDataDic:(NSDictionary *)dataDic {
    _dataDic = dataDic;
    
    
    NSString *string = [NSString stringWithFormat:@"已有%@人帮我助力",_dataDic[@"hpc"]];
    NSString *string1 = [NSString stringWithFormat:@"%@人",_dataDic[@"hpc"]];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
    [text addAttribute:NSForegroundColorAttributeName value:kRGBA(255, 92, 120, 1) range:[string rangeOfString:string1]];
    
    self.peopleNumLab.attributedText = text;
    
    
    int i = [_dataDic[@"price"] intValue]- [_dataDic[@"sy"] intValue];
    
    NSString *stringNum = [NSString stringWithFormat:@"%d/%@红豆",i,_dataDic[@"price"]];
    NSString *stringNum1 = [NSString stringWithFormat:@"%d/",i];
    
    
    NSMutableAttributedString *text1 = [[NSMutableAttributedString alloc] initWithString:stringNum];
    
    [text1 addAttribute:NSForegroundColorAttributeName value:kRGBA(255, 92, 120, 1) range:[stringNum rangeOfString:stringNum1]];
    
    
    self.numberLab.attributedText = text1;
    
    
    
    [self.collectionView reloadData];
}


- (IBAction)bugClick:(id)sender {
}

- (IBAction)addressClick:(id)sender {
    
    [self.delegate goAddressVC];
}


- (IBAction)btnClick:(id)sender {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"puid":self.dataDic[@"id"]
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/product/helpwish" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            [self.delegate refeshData];
            
        } else {
            
            [MBProgressHUD showMessage:dictionary[@"msg"] view:self];
            
        }
        

    } failure:^(NSError * _Nonnull error) {

    }];
    
}

@end
