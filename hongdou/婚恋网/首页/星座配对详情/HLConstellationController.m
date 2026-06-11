//
//  HLConstellationController.m
//  hongdou
//
//  Created by 李龙 on 2020/6/26.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLConstellationController.h"
#import "HLFirstCell.h"
#import "HLSecondCell.h"
#import "HLThirdAndFourthCell.h"

@interface HLConstellationController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *oneImgV;
@property (weak, nonatomic) IBOutlet UIImageView *twoImgV;
@property (weak, nonatomic) IBOutlet UILabel *oneLab;
@property (weak, nonatomic) IBOutlet UILabel *twoLab;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *coverView;

@end

@implementation HLConstellationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.sc_navigationBar.title = @"星座CP";
    self.sc_navigationBar.titleLabel.textColor = [UIColor whiteColor];
    
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [self.oneImgV sd_setImageWithURL:[NSURL URLWithString:[LoginManager defaultManager].avatar]];
    [self.twoImgV sd_setImageWithURL:[NSURL URLWithString:self.userInfo.head]];
    
    if ([self.userInfo.gender isEqualToString:@"男"]) {
        self.oneLab.text = [NSString stringWithFormat:@"%@女",self.dic[@"women"]];
        self.twoLab.text = [NSString stringWithFormat:@"%@男",self.dic[@"men"]];
    } else {
        self.oneLab.text = [NSString stringWithFormat:@"%@男",self.dic[@"men"]];
        self.twoLab.text = [NSString stringWithFormat:@"%@女",self.dic[@"women"]];
    }
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HLFirstCell" bundle:nil] forCellReuseIdentifier:@"HLFirstCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"HLSecondCell" bundle:nil] forCellReuseIdentifier:@"HLSecondCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"HLThirdAndFourthCell" bundle:nil] forCellReuseIdentifier:@"HLThirdAndFourthCell"];
    
    self.tableView.estimatedRowHeight = 200;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.tableView.layer.masksToBounds = YES;
    self.tableView.layer.cornerRadius = 15;
    
    self.coverView.layer.masksToBounds = YES;
    self.coverView.layer.cornerRadius = 15;
    
    self.coverView.layer.shadowColor = kRGBA(215, 210, 232, 1).CGColor;//shadowColor阴影颜色
    self.coverView.layer.shadowOffset = CGSizeMake(0,0);//shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
    self.coverView.layer.shadowOpacity = 1;//阴影透明度，默认0
    self.coverView.layer.shadowRadius = 3;//阴影半径，默认3

    self.coverView.clipsToBounds = NO;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        HLFirstCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLFirstCell"];
        cell.selectionStyle = 0;
        
        cell.jieGuoLab.text = self.dic[@"jieguo"];
        cell.xingZuoVsLab.text = [NSString stringWithFormat:@"    %@ vs %@    ",self.oneLab.text,self.twoLab.text];
        
        return cell;
    }
    else if (indexPath.row == 1) {
        HLSecondCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLSecondCell"];
        cell.selectionStyle = 0;
        
        cell.contentDic = self.dic;
        
        return cell;
    }
    else {
        HLThirdAndFourthCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLThirdAndFourthCell"];
        cell.selectionStyle = 0;
        
        [cell setContentDic:self.dic indexpath:indexPath];
        
        return cell;
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
