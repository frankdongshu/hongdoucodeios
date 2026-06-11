//
//  HLCommunityViewController.m
//  hongdou
//
//  Created by user on 2022/3/15.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import "HLCommunityViewController.h"
#import "HLCommunityCell.h"
#import "CoreLocation/CoreLocation.h"
#import "HLWebYanPinController.h"

@interface HLCommunityViewController ()

@property (nonatomic, strong)NSMutableArray *dataSource;
/**缓存图片高度*/
@property (nonatomic,strong)NSMutableDictionary *imageHeightArray;

@end

@implementation HLCommunityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadNewData) name:DismissLoginView object:nil];
    self.dataSource = [NSMutableArray array];
    self.imageHeightArray = [NSMutableDictionary dictionary];
    [self initTableView];
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.mj_footer.hidden = YES;
    
}

// 创建tabbleview视图
- (void)initTableView {
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight-kTabBarHeight);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 120.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"HLCommunityCell" bundle:nil] forCellReuseIdentifier:@"HLCommunityCell"];
}


- (void)loadNewData{
    
    [self.imageHeightArray removeAllObjects];
    [self.dataSource removeAllObjects];
    
    NSString *url = @"/index/plistinios";
    
    if (self.isLogin) {
        url = @"/index/plist";
    }
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:url withDictionary:@{} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"--->: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            self.dataSource = dictionary[@"data"];
        } else {
            [self.view showError:dictionary[@"msg"]];
        }
        
        [self setRequestFiledView];
        
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showError:error.localizedDescription];
        [self setRequestFiledView];
        [weakSelf.tableView.mj_header endRefreshing];
        
    }];
    
}

- (void)setRequestFiledView {
    
    if (self.dataSource.count == 0) {
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        //设置空白界面
        UIView *blankBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
        UIImageView *logoImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-120)/2, 100, 120, 100)];
        logoImg.image = [UIImage imageNamed:@"ic_no_events"];
        [blankBg addSubview:logoImg];
        UILabel *warnMsg = [[UILabel alloc]initWithFrame:CGRectMake(30, logoImg.bottom, kScreenWidth-60, 80)];
        warnMsg.numberOfLines = 2;
//        warnMsg.text = @"下拉可以刷新哦~";
        warnMsg.textColor = [UIColor colorWithWhite:0.5 alpha:1.000];
        warnMsg.font = [UIFont systemFontOfSize:16];
        warnMsg.textAlignment = NSTextAlignmentCenter;
        [blankBg addSubview:warnMsg];
        [self.tableView setTableHeaderView:blankBg];
        [self.tableView.mj_header endRefreshing];
    } else {
        
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        view.backgroundColor = [UIColor clearColor];
        self.tableView.tableHeaderView = view;
    }
}

#pragma mark - tableDelegaet

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HLCommunityCell *cell = (HLCommunityCell*)[tableView dequeueReusableCellWithIdentifier:@"HLCommunityCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    if (!kISNullObject(self.dataSource[indexPath.row][@"pic"])) {
        
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:self.dataSource[indexPath.row][@"pic"]] placeholderImage:[UIImage imageNamed:@"tupianzhanwei"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image.size.height>0) {
                
                CGFloat scaleHeight = image.size.height/image.size.width*(kScreenWidth-30);
                
                if (![[self.imageHeightArray allKeys] containsObject:@(indexPath.row)]) {
                    [self.imageHeightArray setObject:@(scaleHeight) forKey:@(indexPath.row)];
                    [self.tableView beginUpdates];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                }
            }
        }];
        
        cell.imgHeight.constant = [[self.imageHeightArray objectForKey:@(indexPath.row)] floatValue];
        
    } else {
        cell.imgHeight.constant = 0;
    }
    
    if (!kISNullObject(self.dataSource[indexPath.row][@"title"])) {
        cell.titleLab.text = [NSString stringWithFormat:@"    %@",self.dataSource[indexPath.row][@"title"]];
        cell.labHeight.constant = 40;
    } else {
        
        cell.titleLab.text = @"";
        cell.labHeight.constant = 0;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HLWebYanPinController *vc = [[HLWebYanPinController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.titleString = @"社区";
    vc.url = kISNullObject(self.dataSource[indexPath.row][@"val"])?self.dataSource[indexPath.row][@"pic"]:self.dataSource[indexPath.row][@"val"];
    [self.navigationController pushViewController:vc animated:YES];
    
    
}


#pragma mark - JXCategoryListContentViewDelegate

- (UIView *)listView {
    return self.view;
}

- (UIScrollView *)listScrollView {
    return self.tableView;
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
