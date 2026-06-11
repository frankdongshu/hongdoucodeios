//
//  HLPictruesBroweViewController.m
//  hongdou
//
//  Created by iMac on 2019/10/21.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLPictruesBroweViewController.h"
#import "HLPhotoManageTableViewCell.h"
#import "HLPreviewPhotoViewController.h"

#import "LLPhotoManageCell.h"

@interface HLPictruesBroweViewController ()<UITableViewDelegate,UITableViewDataSource,LLPhotoManageCellDeleagte>
{
    UIAlertView * alert;
    NSIndexPath * currentIndex;
    NSInteger theRowInt;
    
}
@property(nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *albumArray;
@property (nonatomic, strong) HLAlbumModel *albumModel;

@end

@implementation HLPictruesBroweViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self requestAlbumInfo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = @"动态";
    self.albumArray = [NSMutableArray array];
    [self creatTableView];
//    [self requestAlbumInfo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redHeartClick:) name:@"Dong_Tai_Heart" object:nil];
}


- (void)redHeartClick:(NSNotification *)notifi {
    
    BOOL likeIs = [notifi.object boolValue];
    
    NSArray *arr = [self.tableView indexPathsForVisibleRows];
    
    for (NSIndexPath *indexPath in arr) {
        
        if (indexPath.row == theRowInt) {
            HLPhotoManageTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            [cell.collectionButtn setSelected:likeIs];
            
            if (likeIs) {
                cell.likeNumLable.text = [NSString stringWithFormat:@"%d",[cell.likeNumLable.text intValue]+1];
            } else {
                cell.likeNumLable.text = [NSString stringWithFormat:@"%d",[cell.likeNumLable.text intValue]-1];
            }
            
            cell.albumModel.islikes = cell.collectionButtn.selected;
            cell.albumModel.likes = cell.likeNumLable.text;
        }
        
    }
    
}


- (void)creatTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight-kNavigationBarHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    //    _tableView.allowsSelection = NO;
    _tableView.scrollsToTop = NO;
    _tableView.contentInsetTop = 0;
    _tableView.estimatedRowHeight = 120.f;
    _tableView.tableFooterView=[[UIView alloc] init];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [_tableView registerNib:[UINib nibWithNibName:@"HLPhotoManageTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLPhotoManageTableViewCell"];
    
    [_tableView registerClass:[LLPhotoManageCell class] forCellReuseIdentifier:@"LLPhotoManageCell"];
    
    [self.view addSubview:_tableView];
}

// 请求相册信息
- (void)requestAlbumInfo{
    WeakSelf(weakSelf);
    if (_isFriends) {
        [HLHTTPSessionManager postDataWithNSString:HLFriendsAlbum_Info withDictionary:@{@"sid":self.userInfo.userid,@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            if ([code isEqualToString:@"200"] ) {
                
                weakSelf.albumArray = [HLAlbumModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            }else {
                [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
            }
            [weakSelf.tableView reloadData];
            [self setRequestFiledView];
            
        } failure:^(NSError * _Nonnull error) {
            [weakSelf.view showTostWithMessage:@"获取相册信息失败"];
            [self setRequestFiledView];
        }];
    }else{
        [HLHTTPSessionManager postDataWithNSString:HLAlbum_Info withDictionary:@{@"uid":self.userInfo.userid} success:^(NSDictionary * _Nonnull dictionary) {
            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            if ([code isEqualToString:@"200"] ) {
                
                weakSelf.albumArray = [HLAlbumModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            }else {
                [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
            }
            [weakSelf.tableView reloadData];
            [self setRequestFiledView];
            
        } failure:^(NSError * _Nonnull error) {
            [weakSelf.view showTostWithMessage:@"获取相册信息失败"];
            [self setRequestFiledView];
        }];
    }
    
}

-(void)setRequestFiledView
{
    if (self.albumArray.count == 0) {
        //设置空白界面
        UIView *blankBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
        UIImageView *logoImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-120)/2, 100, 120, 100)];
        logoImg.image = [UIImage imageNamed:@"ic_no_events"];
        [blankBg addSubview:logoImg];
        UILabel *warnMsg = [[UILabel alloc]initWithFrame:CGRectMake(30, logoImg.bottom, kScreenWidth-60, 80)];
        warnMsg.numberOfLines = 2;
        warnMsg.text = @"暂无数据~";
        warnMsg.textColor = [UIColor colorWithWhite:0.5 alpha:1.000];
        warnMsg.font = [UIFont systemFontOfSize:16];
        warnMsg.textAlignment = NSTextAlignmentCenter;
        [blankBg addSubview:warnMsg];
        [self.tableView setTableHeaderView:blankBg];
        [self.tableView.mj_header endRefreshing];
    }else
    {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        view.backgroundColor = [UIColor clearColor];
        self.tableView.tableHeaderView = view;
    }
}


#pragma mark tbaleView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.albumArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    HLAlbumModel *model = self.albumArray[section];
    return model.albumArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    HLPhotoManageTableViewCell *cell = (HLPhotoManageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HLPhotoManageTableViewCell"];
//    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    cell.delegate = self;
//    HLAlbumModel *model = self.albumArray[indexPath.section];
//    cell.albumModel = model.albumArray[indexPath.row];
//    cell.indexPath = indexPath;
//    cell.deleteButton.hidden = YES;
//    return cell;
    
    LLPhotoManageCell *cell = (LLPhotoManageCell *)[tableView dequeueReusableCellWithIdentifier:@"LLPhotoManageCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    HLAlbumModel *model = self.albumArray[indexPath.section];
    cell.albumModel = model.albumArray[indexPath.row];
    cell.indexPath = indexPath;
    cell.deleteButton.hidden = YES;
    cell.isYanPin = NO;
    cell.delegate = self;
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 25.f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 25.f)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth - 30, 25.f)];
    label.textColor = [UIColor colorWithHex:0x995ff8];
    label.font = [UIFont systemFontOfSize:16.f];
    HLAlbumModel *model = self.albumArray[section];
    label.text = model.key;
    [view addSubview:label];
    return view;
}


#pragma PhotoManageDelegte

- (void)photoButtonClick:(NSInteger)tage withIndexPath:(NSIndexPath *)indexPath andIsLike:(BOOL)islike {
    
    theRowInt = indexPath.row;
    
    HLAlbumModel *model = self.albumArray[indexPath.section];
    HLPreviewPhotoViewController *previewVC = [[HLPreviewPhotoViewController alloc] init];
    previewVC.albumModel = model.albumArray[indexPath.row];
    
    previewVC.isLike = islike;
    previewVC.isTag = @"动态";
    
    previewVC.scrollIndexPath = [NSIndexPath indexPathForItem:tage inSection:0];
    [self.navigationController pushViewController:previewVC animated:YES];
    
}



- (void)colletionButtonClick:(BOOL)isLike {
    
    NSDictionary *dic = @{
        @"idx":[NSNumber numberWithInteger:self.idx.row],
        @"isLike":[NSNumber numberWithBool:isLike]
    };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DongTaiLike" object:dic];
    
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
