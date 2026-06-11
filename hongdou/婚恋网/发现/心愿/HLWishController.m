//
//  HLWishController.m
//  hongdou
//
//  Created by 李龙 on 2021/12/19.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLWishController.h"
#import "HLWishTopCell.h"
#import "HLAddressController.h" // 邮寄地址
#import "HLWishListController.h"

@interface HLWishController ()<HLWishTopCellDelegate>

@property (nonatomic, strong) NSDictionary *dataDic;

@end

@implementation HLWishController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initTableView];
    
    [self.tableView.mj_header beginRefreshing];
}

- (NSDictionary *)dataDic {
    if (!_dataDic) {
        _dataDic = [[NSDictionary alloc] init];
    }
    return _dataDic;
}

- (void)loadNewData {
    
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"wid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/product/getinwish" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        [self.tableView.mj_header endRefreshing];
        
        NSLog(@"~~~: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            self.dataDic = dictionary[@"data"];
            
            [self.tableView reloadData];
            
        } else {
            [self.view showTitle:dictionary[@"msg"]];
        }

        

    } failure:^(NSError * _Nonnull error) {

        [self.view showErrorWithMessage:[error localizedDescription]];

    }];
    
    
}

//创建tabbleview视图
- (void)initTableView {
    
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight-kTabBarHeight);
//    self.tableView.estimatedRowHeight = 200.f;
    
    self.tableView.estimatedRowHeight = 120;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"HLWishTopCell" bundle:nil] forCellReuseIdentifier:@"HLWishTopCell"];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HLWishTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLWishTopCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:_dataDic[@"pic"]]];
    
    cell.shengyuLab.text = [NSString stringWithFormat:@"红豆剩余:%@",self.dataDic[@"mebean"]];
    cell.dataDic = _dataDic;
    cell.delegate = self;
    
    
    return cell;
    
}

// 换一个
- (void)goExchangeVC {
    HLWishListController *vc = [[HLWishListController alloc ] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)refeshData {
    
    [self loadNewData];
}

- (void)goAddressVC {
    
    HLAddressController *vc = [[HLAddressController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goBuyVC {
    
    
}

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
