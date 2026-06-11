//
//  CSProjectTypeController.m
//  hongdou
//
//  Created by 李龙 on 2020/3/11.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "CSProjectTypeController.h"
#import "CSHomeTableViewCell.h"
#import "CSHomeGradeModel.h"

@interface CSProjectTypeController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *seleArray;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation CSProjectTypeController

- (void)nextClick {
    
    if (self.seleArray.count == 0) {
        [self.view showTostWithMessage:@"请选择擅长项目"];
    } else {
        [self nextPage];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    self.sc_navigationBar.title = @"选择擅长项目";
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"确定" withColor:[UIColor darkGrayColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self nextClick];
        
    }];
    
    
    self.dataArray = [NSMutableArray array];
    self.seleArray = [NSMutableArray arrayWithArray:[MyLogin getCurrentLoginUser].curriculum];
    
    NSLog(@"seleArray: %@",self.seleArray);
    
    [self addViews];
    [self layoutViews];
    [self getData];
    
}

#pragma mark - UI
- (void)addViews {
    [self.view addSubview:self.tableView];
}

- (void)layoutViews {
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kNavBarHeight);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.separatorStyle = 0;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[CSHomeTableViewCell class] forCellReuseIdentifier:@"CSHomeTableViewCell"];
    }
    return _tableView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(10, 16, 8, 8)];
    redView.layer.cornerRadius = 4;
    redView.layer.masksToBounds = YES;
    redView.backgroundColor = REDColor;
    [view addSubview:redView];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(redView.frame)+10, 0, 150, 40)];
    titleLab.text = ((CSHomeGradeModel*)self.dataArray[section]).title;
    titleLab.font = kFontSize(17);
    [view addSubview:titleLab];
    
    return view;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height ;
    NSInteger rowww = ((CSHomeGradeModel*)self.dataArray[indexPath.section]).lists.count / 3;
    if (((CSHomeGradeModel*)self.dataArray[indexPath.section]).lists.count % 3 == 0) {
        height = rowww *30 + (rowww - 1)*20;
    }else{
        height = (rowww + 1) *30 + (rowww)*20;

    }
    return  height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CSHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSHomeTableViewCell" forIndexPath:indexPath];
    cell.cellType = GradeType;
    cell.seleArray = self.seleArray;
    cell.dataMuArray = ((CSHomeGradeModel*)self.dataArray[indexPath.section]).lists;
    cell.selectionStyle = 0;
    
    cell.seleBlock = ^(NSInteger cuid, NSString * title) {
        
        if ([self.seleArray containsObject:@(cuid)]) {
            [self.seleArray removeObject:@(cuid)];
        }else{
            [self.seleArray addObject:@(cuid)];
        }
        [self.tableView reloadData];
        
    };
    
    
    return cell;
}

#pragma mark - data
- (void)getData {
    
    NSDictionary *parmas = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/mind/get_curriculum" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/mind/get_curriculum: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            self.dataArray = [CSHomeGradeModel mj_objectArrayWithKeyValuesArray:dictionary[@"data"]];
            [self.tableView reloadData];
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

// 确定
- (void)nextPage {
    
    NSDictionary *parmas = @{
        @"uid":[LoginManager defaultManager].userid,
        @"curriculum":self.seleArray
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/mind/curriculum" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/mind/curriculum: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            MyLogin *u = [MyLogin getCurrentLoginUser];
            u.curriculum = self.seleArray;
            [MyLogin updateUser:u];
            
            [self.navigationController popViewControllerAnimated:YES];
            
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
