//
//  HLMyWishController.m
//  hongdou
//
//  Created by 李龙 on 2021/12/21.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLMyWishController.h"
#import "HLTogetherPlayCollectionCell.h"

@interface HLMyWishController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *leftLab;
@property (weak, nonatomic) IBOutlet UILabel *rightLab;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSDictionary *dataDic;

@end

@implementation HLMyWishController

- (IBAction)btnClick:(id)sender {
    
    [self zhuliClick];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.sc_navigationBar.title = @"我的心愿";
    
    [self loadNewData];
    
    self.btn.layer.cornerRadius = self.btn.height/2;
    self.btn.layer.masksToBounds = YES;
    
    [self.btn az_setGradientBackgroundWithColors:@[kRGB(255, 174, 157),kRGB(255, 112, 152)] locations:@[@(0),@(.8),@(0),@(0)] startPoint:CGPointMake(0, 1) endPoint:CGPointMake(1, 1)];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.estimatedItemSize = CGSizeMake(80, 80);
    
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    
    _collectionView.collectionViewLayout = layout;
    
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [_collectionView registerNib:[UINib nibWithNibName:@"HLTogetherPlayCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"HLTogetherPlayCollectionCell"];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSArray *arr = self.dataDic[@"hpl"];
    return arr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HLTogetherPlayCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HLTogetherPlayCollectionCell" forIndexPath:indexPath];
    
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:self.dataDic[@"hpl"][indexPath.item][@"head"]]];
    
//    cell.nameLab.text = _dataDic[@"hpl"][indexPath.item][@"nickname"];
    
    cell.nameLab.hidden = YES;
    
    return cell;
}

- (void)loadNewData {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"wid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/product/getinwish" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"~~~: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            self.dataDic = dictionary[@"data"];
            
            [self.imgView sd_setImageWithURL:[NSURL URLWithString:dictionary[@"data"][@"pic"]]];
            
            NSString *string = [NSString stringWithFormat:@"已有%@人帮你助力",dictionary[@"data"][@"hpc"]];
            NSString *string1 = [NSString stringWithFormat:@"%@人",dictionary[@"data"][@"hpc"]];
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
            [text addAttribute:NSForegroundColorAttributeName value:kRGBA(255, 92, 120, 1) range:[string rangeOfString:string1]];
            self.leftLab.attributedText = text;
            
            
            int i = [dictionary[@"data"][@"price"] intValue]- [dictionary[@"data"][@"sy"] intValue];
            
            NSString *stringNum = [NSString stringWithFormat:@"%d/%@红豆",i,dictionary[@"data"][@"price"]];
            NSString *stringNum1 = [NSString stringWithFormat:@"%d/",i];
            
            
            NSMutableAttributedString *text1 = [[NSMutableAttributedString alloc] initWithString:stringNum];
            
            [text1 addAttribute:NSForegroundColorAttributeName value:kRGBA(255, 92, 120, 1) range:[stringNum rangeOfString:stringNum1]];
            
            
            self.rightLab.attributedText = text1;
            
            [self.collectionView reloadData];
            
        } else {
            [self.view showTitle:dictionary[@"msg"]];
        }

        

    } failure:^(NSError * _Nonnull error) {

        [self.view showErrorWithMessage:[error localizedDescription]];

    }];
    
    
}

- (void)zhuliClick {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"puid":self.dataDic[@"id"]
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/product/helpwish" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"~~~: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [self loadNewData];
        } else {
            [self.view showTitle:dictionary[@"msg"]];
        }

    } failure:^(NSError * _Nonnull error) {

        [self.view showErrorWithMessage:[error localizedDescription]];

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
