//
//  HLFinishWishController.m
//  hongdou
//
//  Created by 李龙 on 2021/12/19.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLFinishWishController.h"
#import "HLWishCell.h"

@interface HLFinishWishController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arr;

@end

@implementation HLFinishWishController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.tableView];
    
    [self loadNewData];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        self.tableView.estimatedRowHeight = 200;
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerNib:[UINib nibWithNibName:@"HLWishCell" bundle:nil] forCellReuseIdentifier:@"HLWishCell"];
    }
    return _tableView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HLWishCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLWishCell"];
    cell.selectionStyle = 0;
    
    
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:self.arr[indexPath.row][@"pic"]]];
    
    NSString *stringNum = [NSString stringWithFormat:@"%@/%@红豆",self.arr[indexPath.row][@"hd"],self.arr[indexPath.row][@"price"]];
    NSString *stringNum1 = [NSString stringWithFormat:@"%@/",self.arr[indexPath.row][@"hd"]];
    
    
    NSMutableAttributedString *text1 = [[NSMutableAttributedString alloc] initWithString:stringNum];
    
    [text1 addAttribute:NSForegroundColorAttributeName value:kRGBA(255, 92, 120, 1) range:[stringNum rangeOfString:stringNum1]];
    
    cell.leftLab.attributedText = text1;
    
    cell.rightLab.text = @"我的心愿";
    
    return cell;
}

- (void)loadNewData {
    
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/product/successfulwish" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {

        
        NSLog(@"~~~: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            self.arr = dictionary[@"data"];
        } else {
            [self.view showTitle:dictionary[@"msg"]];
        }
        
        [self setRequestFiledView];
        
        [self.tableView reloadData];

    } failure:^(NSError * _Nonnull error) {

        [self.view showErrorWithMessage:[error localizedDescription]];

    }];
    
    
}

- (void)setRequestFiledView {
    
    if (self.arr.count == 0) {
        [self.arr removeAllObjects];
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        //设置空白界面
        UIView *blankBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
        UIImageView *logoImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-120)/2, 100, 120, 100)];
        logoImg.image = [UIImage imageNamed:@"ic_no_events"];
        [blankBg addSubview:logoImg];
        UILabel *warnMsg = [[UILabel alloc]initWithFrame:CGRectMake(30, logoImg.bottom, kScreenWidth-60, 80)];
        warnMsg.numberOfLines = 2;
        warnMsg.text = @"还没有数据哦~";
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
