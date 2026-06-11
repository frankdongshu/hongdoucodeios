//
//  LLActivityController.m
//  hongdou
//
//  Created by 李龙 on 2020/3/19.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLActivityController.h"
#import "LLActivityCell.h"
#import "LLRankingCell.h"

#import "HLRewardController.h"

@interface LLActivityController () {
    NSInteger _sectionNum;
}
@property (nonatomic, strong) LLActivityModel *actModel;
@property (nonatomic, strong) UIButton *rewardBtn;

@end

@implementation LLActivityController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initTableView];
    
    [self loadNewData];
}

- (void)initTableView {
    
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight-kTabBarHeight);
    
    //设置预估行高
    self.tableView.estimatedRowHeight = 100.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.backgroundColor = kRGBA(245, 245, 249, 1);
    self.tableView.tableHeaderView = self.rewardBtn;
    // 去掉多余分割线
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LLActivityCell" bundle:nil] forCellReuseIdentifier:@"LLActivityCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LLRankingCell" bundle:nil] forCellReuseIdentifier:@"LLRankingCell"];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionNum;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        return 80;
    }
    
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] init];
    
    if (section == 1) {
        
        view.backgroundColor = [UIColor whiteColor];
        
        if (!kISNullObject(self.actModel.being) &&
            !kISNullObject(self.actModel.being.tips) &&
            !kISNullObject(self.actModel.being.rk_title)) {
            
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 40)];
            lab.text = [NSString stringWithFormat:@"%@",self.actModel.being.tips];
            lab.textColor = kRGBA(255, 92, 120, 1);
            lab.font = [UIFont systemFontOfSize:14];
            [view addSubview:lab];
            
            UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, 200, 40)];
            lab1.text = [NSString stringWithFormat:@"%@",self.actModel.being.rk_title];
            lab1.font = [UIFont systemFontOfSize:16];
            [view addSubview:lab1];
            
        } else {
            
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 80/2-20, kScreenWidth, 40)];
            lab.text = @"无正在进行的活动~";
            lab.textAlignment = NSTextAlignmentCenter;
            lab.font = [UIFont systemFontOfSize:16];
            [view addSubview:lab];
            
        }
        
    }
    
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (kISNullObject(self.actModel.being)) {
            return 0;
        }
        return 1;
    }
    else if (section == 1) {
        NSMutableArray *arr = self.actModel.being.ranking;
        return arr.count;
    }
    else {
        NSMutableArray *arr = self.actModel.future;
        return arr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        LLRankingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LLRankingCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setActivityInfo:self.actModel withCurrentIndex:indexPath];
        
        return cell;
        
    }
    
    LLActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LLActivityCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setActivityInfo:self.actModel withCurrentIndex:indexPath];

    return cell;
}

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

- (void)loadNewData {
    
    if (!self.isLogin) {
        [self.view showErrorWithMessage:@"请登录后尝试!"];
        self.rewardBtn.hidden = YES;
        self.tableView.hidden = YES;
        [self.tableView.mj_header endRefreshing];
        return;
    }
    
    self.rewardBtn.hidden = NO;
    self.tableView.hidden = NO;
    
    [HLHTTPSessionManager postDataWithNSString:HLActivity withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"-->%@",dictionary);
       
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            self.actModel = [LLActivityModel mj_objectWithKeyValues:dictionary[@"data"]];
            
            self->_sectionNum = 3; // 直接显示3行没数据, 防止闪动现象
            
            [self.tableView reloadData];
            
            
        } else {
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
    
    [self.tableView.mj_header endRefreshing];
    
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
