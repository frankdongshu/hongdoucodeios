//
//  HLFriendsInfoTableViewCell.m
//  hongdou
//
//  Created by iMac on 2019/10/17.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLFriendsInfoTableViewCell.h"

@interface HLFriendsInfoTableViewCell ()<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;



@end

@implementation HLFriendsInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backGroundView.layer.cornerRadius = 6.f;
    self.backGroundView.layer.masksToBounds = YES;

    [self setupUI];
}

-(void)setupUI{
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.backGroundView.bounds collectionViewLayout:flow];
    self.collectionView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    self.collectionView.backgroundColor = [UIColor clearColor];

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.backGroundView addSubview:self.collectionView];
}

- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    
    NSLog(@"%@",dataArray);
    
    if (dataArray.count>=10) { // 4行的高度
//        NSLog(@"4行的高度~~~~");
        [self.backGroundView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(17);
            make.right.equalTo(self.mas_right).offset(-17);
            make.top.equalTo(self.mas_top).offset(10);
            make.height.mas_equalTo((self.dataArray.count/4+1) * 40 + 10);
            make.bottom.equalTo(self.mas_bottom).offset(-10);
        }];
    }
    else if (dataArray.count<10 && dataArray.count>6) { // 3行的高度
//        NSLog(@"3行的高度~~~~");
        [self.backGroundView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(17);
            make.right.equalTo(self.mas_right).offset(-17);
            make.top.equalTo(self.mas_top).offset(10);
            make.height.mas_equalTo((self.dataArray.count/5+1) * 40 + 20);
            make.bottom.equalTo(self.mas_bottom).offset(-10);
        }];
    }
    else { // 两行的高度
//        NSLog(@"2行的高度~~~~");
        [self.backGroundView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(17);
            make.right.equalTo(self.mas_right).offset(-17);
            make.top.equalTo(self.mas_top).offset(10);
            make.height.mas_equalTo((self.dataArray.count/4+1) * 30 + 10);
            make.bottom.equalTo(self.mas_bottom).offset(-10);
        }];
    }
    
     
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.backGroundView).offset(5);
        make.right.bottom.equalTo(self.backGroundView).offset(-5);
    }];
    [self.collectionView reloadData];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
}


#pragma mark --UICollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    //在创建collectionView的时候注册cell（一个分区）
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    UILabel *label = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
    label.text = self.dataArray[indexPath.item];
    label.textColor = [UIColor colorWithHex:0x545E78];
    label.font = [UIFont systemFontOfSize:15];
    label.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:label];

    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((kScreenWidth - 74)/3, 20);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
