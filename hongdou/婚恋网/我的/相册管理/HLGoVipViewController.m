//
//  HLGoVipViewController.m
//  hongdou
//
//  Created by user on 2022/5/3.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import "HLGoVipViewController.h"
#import "HLGaoYanZhiCollectionCell.h"
#import "HLOpenMemberViewController.h"

@interface HLGoVipViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *oneLab;
@property (weak, nonatomic) IBOutlet UILabel *twoLab;
@property (weak, nonatomic) IBOutlet UILabel *threeLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation HLGoVipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = @"开通会员";
    
    self.view.backgroundColor = kRGB(247, 247, 247);
    
    self.dataArray = [[NSMutableArray alloc] init];
    
    [self requestData];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [_collectionView registerNib:[UINib nibWithNibName:@"HLGaoYanZhiCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"HLGaoYanZhiCollectionCell"];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HLGaoYanZhiCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HLGaoYanZhiCollectionCell" forIndexPath:indexPath];
    
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:self.dataArray[indexPath.item]] placeholderImage:[UIImage imageNamed:@"icon_head"]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (IBAction)btnClick:(id)sender {
    
    HLOpenMemberViewController *vc = [[HLOpenMemberViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)requestData {
    
    if (![LoginManager defaultManager].userid ) {
        
        return;
    }
    [self.view showLoading];
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid?:@""
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/get_display" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/user/get_display: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [self.view hideLoading];
            
            NSString *string = [NSString stringWithFormat:@"%@",dictionary[@"data"][@"c"]];
            NSString *string2 = [NSString stringWithFormat:@"有%@位近期活跃的%@",string,dictionary[@"data"][@"xb"]];
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string2];
            [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:[string2 rangeOfString:string]];
            [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Semibold" size:20] range:[string2 rangeOfString:string]];
            self.oneLab.attributedText = text;
            
            // ====
            
            NSString *twoString = [NSString stringWithFormat:@"%@",dictionary[@"data"][@"fh"]];
            NSString *twoString2 = [NSString stringWithFormat:@"有%@位近期活跃的%@",twoString,dictionary[@"data"][@"xb"]];
            NSMutableAttributedString *text1 = [[NSMutableAttributedString alloc] initWithString:twoString2];
            [text1 addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:[twoString2 rangeOfString:twoString]];
            [text1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Semibold" size:20] range:[twoString2 rangeOfString:twoString]];
            self.twoLab.attributedText = text1;
            
            // ==
            NSString *threeString = @"1.5元/月";
            NSString *threeString2 = [NSString stringWithFormat:@"开通仅需%@",threeString];
            NSMutableAttributedString *text2 = [[NSMutableAttributedString alloc] initWithString:threeString2];
            [text2 addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:[threeString2 rangeOfString:threeString]];
            [text2 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Semibold" size:20] range:[threeString2 rangeOfString:threeString]];
            self.threeLab.attributedText = text2;
            
            
            self.timeLab.text = [NSString stringWithFormat:@"剩余时间 %@",dictionary[@"data"][@"time"]];
            
            
            self.dataArray = dictionary[@"data"][@"users"];
            
            [self.collectionView reloadData];
            
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:error.localizedDescription];
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
