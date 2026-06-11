//
//  HDPreviewPhotoController.m
//  hongdou
//
//  Created by 维康1 on 2019/12/9.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HDPreviewPhotoController.h"
#import "HLPhotoCollectionViewCell.h"
#import "FKGPopOption.h"

@interface HDPreviewPhotoController ()<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout> {
    
    NSInteger _index;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *bottomView;

@property (strong, nonatomic) UIButton *collectionButtn;

@end

@implementation HDPreviewPhotoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back_white"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    
    self.sc_navigationBar.title = [NSString stringWithFormat:@"%ld/%ld",self.selectIdx+1,self.picArray.count];
    
    [self initSubViews];
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
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(kNavigationBarHeight, 0, 0, 0));
    }];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.selectIdx) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectIdx inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    });
    
}

#pragma mark - collectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.picArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HLPhotoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HLPhotoCollectionViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:self.picArray[indexPath.item]] placeholderImage:[UIImage imageNamed:@"tupianzhanwei"]];
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
    
    self.sc_navigationBar.title = [NSString stringWithFormat:@"%ld/%ld",_index+1,self.picArray.count];
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
