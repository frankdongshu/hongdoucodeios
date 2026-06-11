//
//  HLHTMLLableViewController.m
//  hongdou
//
//  Created by iMac on 2019/9/25.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLHTMLLableViewController.h"

@interface HLHTMLLableViewController ()

@property (nonatomic,strong) UIScrollView *scroView;

@property (nonatomic, strong) UILabel *contenLabel;
@end

@implementation HLHTMLLableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = self.navTitle;
    [self creatView];
    [self requestHtml:self.type];
    
    
}
- (void)creatView{
    self.scroView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight - kNavigationBarHeight)];
    [self.view addSubview:self.scroView];
    
    self.contenLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,0, kScreenWidth - 30, kScreenHeight - kNavigationBarHeight)];
    self.contenLabel.numberOfLines = 0;
    self.contenLabel.font = [UIFont systemFontOfSize:17.f];
    
    [self.scroView addSubview:self.contenLabel];
    

    
}

- (void)requestHtml:(NSString *)sign{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLNotice withDictionary:@{@"sign":sign} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            NSString *htmlString = [dictionary objectForKey:@"data"][@"val"];
            NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSFontAttributeName:[UIFont systemFontOfSize:18.0f]} documentAttributes:nil error:nil];
            weakSelf.contenLabel.attributedText = attrStr;
            [weakSelf.contenLabel sizeToFit];
            weakSelf.scroView.contentSize = CGSizeMake(kScreenWidth, self.contenLabel.height);
            weakSelf.scroView.showsHorizontalScrollIndicator = NO;//不显示水平拖地的条
            weakSelf.scroView.showsVerticalScrollIndicator=NO;//不显示垂直拖动的条
            weakSelf.scroView.pagingEnabled = YES;//允许分页滑动
            weakSelf.scroView.bounces = NO;//到边了就不能再拖地
            [weakSelf.view layoutIfNeeded];

        }else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
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
