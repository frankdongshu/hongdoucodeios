//
//  CSHomeTableViewCell.m
//  CSPartTimeJobs
//
//  Created by 这是一个笑脸 on 2019/7/18.
//  Copyright © 2019 FangPursuit. All rights reserved.
//

#import "CSHomeTableViewCell.h"
#import "CSHomeGradeDetailModel.h"
#import "CSCityDetailModel.h"
@interface CSHomeTableViewCell ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;

@end
@implementation CSHomeTableViewCell

-(void)setCellType:(CellType)cellType{
    _cellType = cellType;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.top.equalTo(self);
        }];
    }
    return self;
}

-(void)setDataMuArray:(NSMutableArray *)dataMuArray{
    _dataMuArray = dataMuArray;
    [self.collectionView reloadData];
}


#pragma mark - delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataMuArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CSHomeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CSHomeCollectionCell" forIndexPath:indexPath];
    if (_cellType == GradeType) {
        if ([self.seleArray containsObject:@(((CSHomeGradeDetailModel*)self.dataMuArray[indexPath.row]).ID)]) {
            [cell seleCell:YES];
        }else{
            [cell seleCell:NO];
        }
        cell.nameLabel.text = ((CSHomeGradeDetailModel*)self.dataMuArray[indexPath.row]).title;
    } else if (_cellType == ChosseType) {
        
        CSCityChooseModel *mod = self.dataMuArray[indexPath.row];
        if ([self.seleArray containsObject:mod.habitation]) {
            [cell seleCell:YES];
        }else{
            [cell seleCell:NO];
        }
        cell.nameLabel.text = [NSString stringWithFormat:@"%@(%@)",mod.habitation,mod.cou];
        
    } else{
        
        if ([self.seleArray containsObject:((CSCityInfoModel*)self.dataMuArray[indexPath.row]).city]) {
            [cell seleCell:YES];
        }else{
            [cell seleCell:NO];
        }
        cell.nameLabel.text = ((CSCityInfoModel*)self.dataMuArray[indexPath.row]).city;
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_cellType == GradeType) {
    
        self.seleBlock(((CSHomeGradeDetailModel*)self.dataMuArray[indexPath.row]).ID, ((CSHomeGradeDetailModel*)self.dataMuArray[indexPath.row]).title);
        
    }
    else if (_cellType == ChosseType) { // 筛选
        
        // 数字没用
        self.seleBlock(5, ((CSCityChooseModel*)self.dataMuArray[indexPath.row]).habitation);
        
    }
    else {
        
        self.seleBlock(((CSCityInfoModel*)self.dataMuArray[indexPath.row]).ID, ((CSCityInfoModel*)self.dataMuArray[indexPath.row]).city);

    }
}

#pragma mark - lazy
-(UICollectionView *)collectionView{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = CGSizeMake((kScreenWidth - 80) /3.0, 30);
        flowLayout.minimumLineSpacing = 20;
        flowLayout.minimumInteritemSpacing = 15;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [_collectionView registerClass:[CSHomeCollectionCell class] forCellWithReuseIdentifier:@"CSHomeCollectionCell"];
        _collectionView.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.scrollEnabled = NO;
    }
    return _collectionView;
}

@end


@interface CSHomeCollectionCell ()
@end
@implementation CSHomeCollectionCell
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.equalTo(self);
        }];
    }
    return self;
}

-(void)seleCell:(BOOL)sele{
    if (sele) {
        _nameLabel.backgroundColor = REDColor;
        _nameLabel.textColor = [UIColor whiteColor];
    }else{
        _nameLabel.backgroundColor = [UIColor whiteColor];
        _nameLabel.textColor = [UIColor blackColor];
    }
}

#pragma mark - lazy
-(UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = kScaleFont(12);
        _nameLabel.layer.cornerRadius = 15;
        _nameLabel.layer.borderColor = HEXColor(@"ececec").CGColor;
        _nameLabel.layer.borderWidth = 1;
        _nameLabel.layer.masksToBounds = YES;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

@end

