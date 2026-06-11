//
//  HLRewardController.m
//  hongdou
//
//  Created by 维康1 on 2019/12/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLRewardController.h"
#import "LLActivityCell.h"
#import "LLRankingCell.h"
#import "LLBeingModel.h"

@interface HLRewardController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation HLRewardController

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight-kNavBarHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        //设置预估行高
        self.tableView.estimatedRowHeight = 100.0f;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        
        [self.tableView registerNib:[UINib nibWithNibName:@"LLActivityCell" bundle:nil] forCellReuseIdentifier:@"LLActivityCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"LLRankingCell" bundle:nil] forCellReuseIdentifier:@"LLRankingCell"];
    }
    return _tableView;
}

// 多少分区
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

// 每个分区多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    LLBeingModel *mod = self.dataArray[section];
    
    return mod.ranking.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.0001;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LLBeingModel *model = self.dataArray[indexPath.section];
    
    if (indexPath.row == 0) {
        LLActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LLActivityCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [cell.imgV sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:[UIImage imageNamed:@"tupianzhanwei"]];
        cell.nameLab.text = model.name;
        cell.timeLab.text = [NSString stringWithFormat:@"%@-%@",model.start_time,model.end_time];
        cell.numLab.text = [NSString stringWithFormat:@"%@以上可参与",model.mininv];
        cell.awardNumLab.text = [NSString stringWithFormat:@"排名前%@可获得奖品",model.number];
        cell.explainLab.text = model.introduce;
        
        return cell;
    }
    if (indexPath.row > 0) {
        LLRankingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LLRankingCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        cell.rankingLab.text = [NSString stringWithFormat:@"%ld",indexPath.row];
        if (indexPath.row < 4) { //
            cell.medalImgV.image = [UIImage imageNamed:[NSString stringWithFormat:@"jiang%ld",indexPath.row-1]];
        }
        
        LLRankingModel *m = model.ranking[indexPath.row-1];
        
        [cell.headImgV sd_setImageWithURL:[NSURL URLWithString:m.head]];
        cell.numberLab.text = [NSString stringWithFormat:@"%@人",m.c];
        cell.nameLab.text = [NSString stringWithFormat:@"%@",m.nickname];
        cell.cityLab.text = [NSString stringWithFormat:@"%@",m.habitation];
        
        return cell;
    }
    
    return nil;
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
    self.sc_navigationBar.title = @"开奖记录";
    
    [self.view addSubview:self.tableView];
    
    [self requestData];
}

// 开奖记录
- (void)requestData {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLLottery_Record withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        NSLog(@"%@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        
        if ([code isEqualToString:@"200"] ) {
            
            weakSelf.dataArray = [LLBeingModel mj_objectArrayWithKeyValuesArray:dictionary[@"data"]];
            
            [weakSelf.tableView reloadData];
            
        } else {
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        
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
