//
//  HLAwardViewController.m
//  hongdou
//
//  Created by 维康1 on 2019/12/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLAwardViewController.h"
#import "HLActProductCell.h"
#import "HLRankingCell.h" // 排名Cell
#import "HLRewardController.h"

@interface HLAwardViewController ()

@property (nonatomic, strong) NSDictionary *activityDic;

@property (nonatomic, strong) NSArray *rankImgArray;

@property (nonatomic, strong) UIButton *rewardBtn;

@end

@implementation HLAwardViewController

- (UIButton *)rewardBtn {
    if (!_rewardBtn) {
        _rewardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rewardBtn.frame = CGRectMake(0, 10, kScreenWidth, 40);
        _rewardBtn.backgroundColor = [UIColor whiteColor];
        [_rewardBtn setTitle:@"开奖记录" forState:UIControlStateNormal];
        [_rewardBtn setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
        _rewardBtn.titleLabel.font = kScaleFont(14);
        [_rewardBtn setTitleColor:kRGBA(255, 92, 121, 1) forState:UIControlStateNormal];
        [_rewardBtn addTarget:self action:@selector(rewardClick) forControlEvents:UIControlEventTouchUpInside];
        _rewardBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_rewardBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, - _rewardBtn.imageView.image.size.width, 0, _rewardBtn.imageView.image.size.width+20)];
        [_rewardBtn setImageEdgeInsets:UIEdgeInsetsMake(0, _rewardBtn.titleLabel.bounds.size.width, 0, -_rewardBtn.titleLabel.bounds.size.width+10)];
        
    }
    return _rewardBtn;
}

// 中奖记录
- (void)rewardClick {
    
    HLRewardController *rewardVC = [[HLRewardController alloc] init];
    rewardVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:rewardVC animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [self loadNewData];
    
    
    if (!self.isLogin) {
        self.rewardBtn.hidden = YES;
        self.activityDic = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView reloadData];
    } else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.rewardBtn.hidden = NO;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initTableView];
    
    [self loadNewData];
    
}

//创建tabbleview视图
-(void)initTableView
{
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight-kTabBarHeight);
    self.tableView.estimatedRowHeight = 200.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.backgroundColor = kRGBA(245, 245, 249, 1);
    self.tableView.tableHeaderView = self.rewardBtn;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.tableView.mj_footer.hidden = YES;
}

#pragma mark - table

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        
        UIView *view = [[UIView alloc] init];
        if (self.isLogin) {
            view.backgroundColor = [UIColor whiteColor];
            
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 40)];
            lab.text = [NSString stringWithFormat:@"%@",self.activityDic[@"being"][@"tips"]];
            lab.textColor = kRGBA(255, 92, 120, 1);
            lab.font = kFontSize(14);
            [view addSubview:lab];
            
            UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, 200, 40)];
            lab1.text = [NSString stringWithFormat:@"%@",self.activityDic[@"being"][@"rk_title"]];
            lab1.font = kFontSize(16);
            [view addSubview:lab1];
            
            
            if (kISNullDict(self.activityDic)) {
                view.hidden = YES;
            } else {
                view.hidden = NO;
            }
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(0, 40, kScreenWidth, 40);
            [btn setTitle:@"展开全部" forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
            btn.titleLabel.font = kFontSize(14);
            [btn setTitleColor:kRGBA(138, 155, 173, 1) forState:UIControlStateNormal];
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, - btn.imageView.image.size.width, 0, btn.imageView.image.size.width+20)];
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.bounds.size.width, 0, -btn.titleLabel.bounds.size.width+10)];
            btn.hidden = YES;
            
            [view addSubview:btn];
        }
        
        if (kISNullObject(self.activityDic[@"being"][@"ranking"])) {
            return [[UIView alloc] init];
        } else {
            return view;
        }
        
        
        
    }
    
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        if (kISNullObject(self.activityDic[@"being"][@"ranking"])) {
            return 0;
        } else {
            return 80;
        }
        
    }
    
    return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0) {
//        return 63;
//    }
    if (indexPath.section == 0) {
        return 140;
    }
    if (indexPath.section == 1) {
        return 70;
    }
    return 140;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return kISNullObject(self.activityDic[@"being"])? 0:1;
    }
    
    if (section == 1) {
        NSArray *arr = self.activityDic[@"being"][@"ranking"];
        
        return arr.count;
    }
    
    if (section == 2) {
        NSArray *arr = self.activityDic[@"future"];
        
        return arr.count;
    }
    
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        HLActProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLActProductCell"];
        
        if (!cell) {
            cell = [[HLActProductCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HLActProductCell"];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if (self.isLogin) {
            [cell.imgV sd_setImageWithURL:[NSURL URLWithString:self.activityDic[@"being"][@"pic"]] placeholderImage:[UIImage imageNamed:@"tupianzhanwei"]];
            
            cell.nameLab.text = [NSString stringWithFormat:@"奖品名称: %@",self.activityDic[@"being"][@"name"]];
            cell.timeLab.text = [NSString stringWithFormat:@"活动时间: %@-%@",self.activityDic[@"being"][@"start_time"],self.activityDic[@"being"][@"end_time"]];
            cell.countLab.text = [NSString stringWithFormat:@"资格数量: %@",self.activityDic[@"being"][@"mininv"]];
            cell.prizeCountLab.text = [NSString stringWithFormat:@"获奖数量: 排名前%@可获得奖品",self.activityDic[@"being"][@"number"]];
            cell.messageLab.text = [NSString stringWithFormat:@"活动说明: %@",self.activityDic[@"being"][@"introduce"]];
        } else {
            cell.hidden = YES;
        }
        
        
        
        
        return cell;
    }
    if (indexPath.section == 1) {
        HLRankingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLRankingCell"];
        
        if (!cell) {
            cell = [[HLRankingCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HLRankingCell"];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        cell.numLab.text = [NSString stringWithFormat:@"%ld",indexPath.row+1];
        if (indexPath.row < 3) { // 
            cell.rankImgV.image = [UIImage imageNamed:[NSString stringWithFormat:@"jiang%ld",indexPath.row]];
        }
        
        
        cell.rankLab.text = [NSString stringWithFormat:@"%@人",self.activityDic[@"being"][@"ranking"][indexPath.row][@"c"]];
        [cell.imgV sd_setImageWithURL:[NSURL URLWithString:self.activityDic[@"being"][@"ranking"][indexPath.row][@"head"]]];
        
        cell.nameLab.text = [NSString stringWithFormat:@"%@",self.activityDic[@"being"][@"ranking"][indexPath.row][@"nickname"]];
        cell.addLab.text = [NSString stringWithFormat:@"%@",self.activityDic[@"being"][@"ranking"][indexPath.row][@"habitation"]];
        
        
        return cell;
    }
    else {
        HLActProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLActProductCell"];
        
        if (!cell) {
            cell = [[HLActProductCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HLActProductCell"];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [cell.imgV sd_setImageWithURL:[NSURL URLWithString:self.activityDic[@"future"][indexPath.row][@"pic"]] placeholderImage:[UIImage imageNamed:@"tupianzhanwei"]];
        
        cell.nameLab.text = [NSString stringWithFormat:@"奖品名称: %@",self.activityDic[@"future"][indexPath.row][@"name"]];
        cell.timeLab.text = [NSString stringWithFormat:@"活动时间: %@-%@",self.activityDic[@"future"][indexPath.row][@"start_time"],self.activityDic[@"future"][indexPath.row][@"end_time"]];
        cell.countLab.text = [NSString stringWithFormat:@"资格数量: %@",self.activityDic[@"future"][indexPath.row][@"mininv"]];
        cell.prizeCountLab.text = [NSString stringWithFormat:@"获奖数量: 排名前%@可获得奖品",self.activityDic[@"future"][indexPath.row][@"number"]];
        cell.messageLab.text = [NSString stringWithFormat:@"活动说明: %@",self.activityDic[@"future"][indexPath.row][@"introduce"]];
        
        
        return cell;
    }
    
    
}



// 活动信息
- (void)loadNewData {
    
    if (self.isLogin) {
        NSDictionary *params = @{
            @"uid":[LoginManager defaultManager].userid,
        };
        
        WeakSelf(weakSelf);
        [HLHTTPSessionManager postDataWithNSString:HLActivity withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
            NSLog(@"========>>>>%@",dictionary);
            
            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            
            if ([code isEqualToString:@"200"] ) {
                
                self.activityDic = dictionary[@"data"];
                
                
            } else {
                
            }
            [self setRequestFiledView];
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView reloadData];
            
            
        } failure:^(NSError * _Nonnull error) {
            [weakSelf.view showTostWithMessage:@"请求失败"];
            [self setRequestFiledView];
            [weakSelf.tableView.mj_header endRefreshing];
            
        }];
    } else {
        [self.view showErrorWithMessage:@"请登录后尝试!"];
        [self.tableView.mj_header endRefreshing];
    }
    
    
    
}

- (void)setRequestFiledView {
    
    if (kISNullDict(self.activityDic)) {
        self.rewardBtn.hidden = YES;
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView reloadData];
    } else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.rewardBtn.hidden = NO;
    }
    
}


#pragma mark - JXCategoryListContentViewDelegate

- (UIView *)listView {
    return self.view;
}

- (UIScrollView *)listScrollView {
    return self.tableView;
}

/**
 可选实现，列表显示的时候调用
 */
- (void)listDidAppear {

    [self loadNewData];
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
