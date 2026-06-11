//
//  HLMoreQingRenView.m
//  hongdou
//
//  Created by 李龙 on 2020/7/9.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLMoreQingRenView.h"

#import "HLTogetherPlayCollectionCell.h"

@interface HLMoreQingRenView ()<UIGestureRecognizerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation HLMoreQingRenView

- (instancetype)initWithFrame:(CGRect)frame andArray:(NSArray *)array {
    if ([super initWithFrame:frame]) {
        
        [self addSubview:self.collectionView];
        [self addSubview:self.headerView];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.collectionView.frame = CGRectMake(0, kScreenHeight-130, kScreenWidth, 130);
            
            self.headerView.frame = CGRectMake(0, kScreenHeight-160, kScreenWidth, 40);
        }];
        
        self.dataArray = [[NSMutableArray alloc] initWithArray:array];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeSelf)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isDescendantOfView:self.collectionView] || [touch.view isDescendantOfView:self.headerView]) {
        return NO;
    }
    return YES;
}

-(void)showSelf{
    UIWindow *windew = [UIApplication sharedApplication].keyWindow;
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    [windew addSubview:self];
}

-(void)removeSelf{
    [self removeFromSuperview];
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(-kScreenWidth, kScreenHeight-160, kScreenWidth, 40)];
        _headerView.backgroundColor = [UIColor whiteColor];
        
        _headerView.layer.cornerRadius = 5;
        _headerView.layer.masksToBounds = YES;
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        lab.text = @"颜值超高啊,程序员小哥哥真的尽力了！";
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:14];
        lab.textColor = kRGBA(63, 70, 88, 1);
        
        [_headerView addSubview:lab];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(kScreenWidth-50, 0, 40, 40);
        [btn setImage:[UIImage imageNamed:@"home_cha"] forState:UIControlStateNormal];
        
        btn.contentMode = UIViewContentModeCenter;
        [btn addTarget:self action:@selector(removeSelf) forControlEvents:UIControlEventTouchUpInside];
        
        [_headerView addSubview:btn];
        
    }
    return _headerView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.estimatedItemSize = CGSizeMake(100, 100);
        
        layout.minimumLineSpacing = 20;
        layout.minimumInteritemSpacing = 20;
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        
        
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-kScreenWidth, kScreenHeight-130, kScreenWidth, 130) collectionViewLayout:layout];
        
        _collectionView.backgroundColor = [UIColor whiteColor];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerNib:[UINib nibWithNibName:@"HLTogetherPlayCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"HLTogetherPlayCollectionCell"];
    }
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HLTogetherPlayCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HLTogetherPlayCollectionCell" forIndexPath:indexPath];
    
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:self.dataArray[indexPath.item][@"head"]]];
    cell.nameLab.text = self.dataArray[indexPath.item][@"nickname"];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self removeSelf];
    
    self.SelectBlock(self.dataArray[indexPath.item][@"id"]);
    
}

- (void)requestDataWithTitle:(NSString *)title {
    
    [self showLoading];
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid,
        @"label":title
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/find" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"321~: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [self hideLoading];
            
            self.dataArray = dictionary[@"data"];
            
            [self.collectionView reloadData];
            
        }else {
            [self showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [self showTostWithMessage:error.localizedDescription];
    }];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
