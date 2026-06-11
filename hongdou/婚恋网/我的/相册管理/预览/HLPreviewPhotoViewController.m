//
//  HLPreviewPhotoViewController.m
//  hongdou
//
//  Created by iMac on 2019/9/27.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLPreviewPhotoViewController.h"
#import "HLPhotoCollectionViewCell.h"
#import "FKGPopOption.h"

@interface HLPreviewPhotoViewController ()<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout> {
    
    NSInteger _index;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *bottomView;

@property (strong, nonatomic) UIButton *collectionButtn;

@end

@implementation HLPreviewPhotoViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back_white"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    
    self.sc_navigationBar.title = [NSString stringWithFormat:@"%ld/%ld",self.scrollIndexPath.item+1,self.albumModel.photoArray.count];
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_more"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        if (!self.isLogin) {
            [self.view showErrorWithMessage:@"请登录后在进行操作!"];
        } else {
            [self showPopSelector]; // pop
        }
        
        
        
    }];
    
    [self initSubViews];
}

// 举报图片
- (void)showPopSelector{
    
    [HLHTTPSessionManager postDataWithNSString:HLPiccomplaint_list withDictionary:@{} success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([dictionary[@"code"] integerValue] == 200) {
            
            NSMutableArray *array = [NSMutableArray array]; // 类型
            NSMutableArray *typeIdArray = [NSMutableArray array]; // 类型id
            
            for (NSDictionary *dic in dictionary[@"data"]) {
                [array addObject:dic[@"val"]];
                [typeIdArray addObject:dic[@"id"]];
            }
            
            
            CGRect frame = CGRectMake(kScreenWidth - 20 , kStatusBarHeight+22, 20, 20);
            
            FKGPopOption *s = [[FKGPopOption alloc] initWithFrame:self.view.bounds];
            
            s.option_optionContents = array;
               
            [[s option_setupPopOption:^(NSInteger index, NSString *content) {
            
                // 举报的类型id
                [self juBaoTypeWithTypeId:typeIdArray[index]];
                
            } whichFrame:frame animate:YES] option_show];
            
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
       
    } failure:^(NSError * _Nonnull error) {
              
    }];
    
}

// 举报图片类型
- (void)juBaoTypeWithTypeId:(NSString *)typeId {
    
    HLPhotoModel *model = self.albumModel.photoArray[_index];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"complaint":typeId,
        @"picid":model.photoID,
        @"album":model.aid
    };
    
    [HLHTTPSessionManager postDataWithNSString:HLAlbum_Complaint withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"%@",dictionary);
        
        if ([dictionary[@"code"] integerValue] == 200) {
            [self.view showSuccessWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}



- (void)setAlbumModel:(HLAlbumDetails *)albumModel{
    _albumModel = albumModel;
    [self.collectionView reloadData];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //禁用全局滑动手势
    self.sc_navigationBar.colorArray = @[[UIColor colorWithHex:0x3C3A55],[UIColor colorWithHex:0x3C3A55]];

    HXNavigationController * navigationController = (HXNavigationController *)self.navigationController;
    navigationController.enableInnerInactiveGesture = NO;
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //开启全局滑动手势
    HXNavigationController * navigationController = (HXNavigationController *)self.navigationController;
    navigationController.enableInnerInactiveGesture = YES;
}
- (void) initSubViews{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, kNavigationBarHeight-1, kScreenWidth, kScreenHeight - kTabBarHeight - kNavigationBarHeight+1) collectionViewLayout:layout];
    
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.scrollEnabled = YES;
    [self.collectionView registerNib:[UINib nibWithNibName:@"HLPhotoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HLPhotoCollectionViewCell"];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(kNavigationBarHeight, 0, kTabBarHeight, 0));
    }];
    
    
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithRed:59/255.0 green:56/255.0 blue:99/255.0 alpha:0.4];
    
    [self.view addSubview:view];
    
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.textColor = [UIColor whiteColor];
    [view addSubview:label];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.albumModel.content attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12],NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]}];
    
    CGRect rect = [string boundingRectWithSize:CGSizeMake(kScreenWidth - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
    
   
    label.attributedText = string;
    
    view.frame = CGRectMake(0, kScreenHeight - kTabBarHeight - rect.size.height -20, kScreenWidth, rect.size.height + 20);

    
    label.frame = CGRectMake(15, 10, kScreenWidth - 30, rect.size.height);
    
    self.bottomView = [[UIView alloc]init];
    [self.view addSubview:self.bottomView];
    self.bottomView.backgroundColor = [UIColor colorWithHex:0x3C3A55];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, kTabBarHeight));
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    self.collectionButtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 14, 21, 21)];
    
    [self.collectionButtn setImage:[UIImage imageNamed:@"unlike"] forState:UIControlStateNormal];
    [self.collectionButtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateSelected];
    
    [self.collectionButtn setSelected:self.isLike];

    [self.collectionButtn addTarget:self action:@selector(colletionClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.collectionButtn];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.scrollIndexPath) {
            [self.collectionView scrollToItemAtIndexPath:self.scrollIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    });
   
    
}

#pragma mark - collectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.albumModel.photoArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HLPhotoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HLPhotoCollectionViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    HLPhotoModel *model = self.albumModel.photoArray[indexPath.item];
    [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:model.url] placeholderImage:[UIImage imageNamed:@"tupianzhanwei"]];
    return cell;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(kScreenWidth, kScreenHeight - kTabBarHeight - kNavigationBarHeight);
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _index = scrollView.contentOffset.x/kScreenWidth;
    
    self.sc_navigationBar.title = [NSString stringWithFormat:@"%ld/%ld",_index+1,self.albumModel.photoArray.count];
}

- (void)colletionClick:(UIButton *)sender{
    
    if (!self.isLogin) {
        
        [self.view showErrorWithMessage:@"请登录后在进行操作!"];
        return;
    }
    
    if (self.collectionButtn.selected) {
        [self requestCollectionUrl:HLAlbum_DeleteLike];
    }else{
        [self requestCollectionUrl:HLAlbum_Like];
    }
    
}

- (void)requestCollectionUrl:(NSString *)url{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:url withDictionary:@{@"uid":[LoginManager defaultManager].userid,@"aid":self.albumModel.albumId} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            weakSelf.collectionButtn.selected = !self.collectionButtn.selected;
            
            if ([self.isTag isEqualToString:@"广场"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Red_Heart" object:[NSNumber numberWithBool:self.collectionButtn.selected]];
            }
            if ([self.isTag isEqualToString:@"关注"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Follow_Heart" object:[NSNumber numberWithBool:self.collectionButtn.selected]];
            }
            if ([self.isTag isEqualToString:@"动态"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Dong_Tai_Heart" object:[NSNumber numberWithBool:self.collectionButtn.selected]];
            }
            if ([self.isTag isEqualToString:@"动态管理"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DT_Guan_Li_Heart" object:[NSNumber numberWithBool:self.collectionButtn.selected]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPhotoManage" object:nil];
            }
            
            
            
        }else {
            [self.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:@"操作失败，请重试！"];
    }];
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
