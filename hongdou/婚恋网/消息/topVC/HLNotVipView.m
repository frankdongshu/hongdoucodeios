//
//  HLNotVipView.m
//  hongdou
//
//  Created by user on 2022/4/14.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import "HLNotVipView.h"
#import "HLChatGifCollectionViewCell.h"

@interface HLNotVipView ()<UIGestureRecognizerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSString *titleStr;

@end

@implementation HLNotVipView

- (instancetype)initWithFrame:(CGRect)frame andDataArray:(NSMutableArray *)array andTitle:(NSString *)title {
    
    if ([super initWithFrame:frame]) {
        
        self.dataArray = array;
        self.titleStr = title;
        
        [self addSubview:self.collectionView];
        [self.collectionView addSubview:self.headerView];
       
        
        [self bottomView];
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeSelf)];
//        tap.delegate = self;
//        [self addGestureRecognizer:tap];
        
    }
    return self;
}

- (void)bottomView {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.collectionView.frame), kScreenWidth, kScreenHeight-CGRectGetMaxY(self.collectionView.frame))];
    
    view.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:view];
    
        
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, kScreenWidth, 50)];
    lab.font = [UIFont systemFontOfSize:18];
    lab.textAlignment = NSTextAlignmentCenter;
    
    NSString *dataStr = [NSString stringWithFormat:@"%ld名异性",self.dataArray.count];
    
    NSString *string = [NSString stringWithFormat:@"有%@%@",dataStr,self.titleStr];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
    
    [text addAttribute:NSForegroundColorAttributeName value:kRGB(241, 136, 124) range:[string rangeOfString:dataStr]];
    [text addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:[string rangeOfString:dataStr]];
    
    lab.attributedText = text;
    
    
    [view addSubview:lab];
    
    
    UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, kScreenWidth, 50)];
    lab1.font = [UIFont systemFontOfSize:18];
    lab1.textAlignment = NSTextAlignmentCenter;
    lab1.textColor = kRGB(241, 136, 124);
    lab1.text = @"✓开通会员查看所有用户";
    
    [view addSubview:lab1];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = kRGB(241, 136, 124);
    btn.layer.cornerRadius = 25;
    btn.layer.masksToBounds = YES;
    [btn setTitle:@"立即开通认识TA们" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(30, CGRectGetMaxY(lab1.frame)+20, kScreenWidth-60, 50);
    
    [view addSubview:btn];
}

- (void)btnClick {
    
    // 跳转会员界面
    self.SelectBlock(self);
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isDescendantOfView:self.collectionView] || [touch.view isDescendantOfView:self.headerView]) {
        return NO;
    }
    
    return YES;
}

-(void)showSelf{
    UIWindow *windew = [UIApplication sharedApplication].keyWindow;
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0];
    [windew addSubview:self];
}

-(void)removeSelf{
    [self removeFromSuperview];
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth-30, .3)];
        _headerView.backgroundColor = [UIColor lightGrayColor];
        
    }
    return _headerView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//        layout.estimatedItemSize = CGSizeMake(100, 100);
        layout.itemSize = CGSizeMake(kScreenWidth/4, kScreenWidth/4);
        
//        layout.minimumLineSpacing = 20;
//        layout.minimumInteritemSpacing = 20;
        layout.sectionInset = UIEdgeInsetsMake(10, 20, 0, 20);
        
        
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 75, kScreenWidth, kScreenWidth/4*3+40) collectionViewLayout:layout];
        
        _collectionView.backgroundColor = [UIColor whiteColor];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerNib:[UINib nibWithNibName:@"HLChatGifCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HLChatGifCollectionViewCell"];
    }
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.dataArray.count>9) {
        return 9;
    }
    
    return self.dataArray.count-1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HLChatGifCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HLChatGifCollectionViewCell" forIndexPath:indexPath];
    
    
    HLFriendUserModel *model = self.dataArray[indexPath.item+1];
    
    cell.imgView.layer.cornerRadius = kScreenWidth/4/2;
    cell.imgView.layer.masksToBounds = YES;
    cell.imgView.contentMode = UIViewContentModeScaleAspectFill;
    
    UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.head]]];
    
    UIImage *blurImg = [img imageByBlurSoft];
    
    cell.imgView.image = blurImg;
    
    cell.vipImgView.hidden = YES;
    
    
    if (indexPath.item+1 == 9) {
        cell.imgView.layer.borderColor = [[UIColor redColor] CGColor];
        cell.imgView.layer.borderWidth = 1;
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/4, kScreenWidth/4)];
        lab.text = [NSString stringWithFormat:@"%ld",self.dataArray.count-1];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = [UIColor whiteColor];
        lab.font = [UIFont systemFontOfSize:30 weight:.1];
        [cell addSubview:lab];
        
    }
    
    return cell;
}

- (void)extracted:(NSDictionary * _Nonnull)dictionary {
    [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
