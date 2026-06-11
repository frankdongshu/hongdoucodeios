//
//  LLSelectKeMuController.m
//  PartTimeJobs
//
//  Created by 维康1 on 2020/5/13.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLSelectKeMuController.h"
#import "CSHomeTableViewCell.h"
#import "CSHomeGradeModel.h"

@interface LLSelectKeMuController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation LLSelectKeMuController

// 禁用侧滑返回手势
- (void)forbiddenGesture {
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self forbiddenGesture];
    
    self.sc_navigationBar.title = @"授课项目";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self sc_setNavigationBarBackgroundAlpha:0];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"确定" withColor:[UIColor darkGrayColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        if (self.seleArray.count == 0) {
            [self.view showTostWithMessage:@"请选择授课项目"];
        } else {
            NSLog(@"~~~ %@",self.seleArray);
            
            self.block([self.seleArray firstObject]);
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        
    }];
    
    self.dataArray = [NSMutableArray array];
    
    NSLog(@"seleArray: %@",self.seleArray);
    
    [self addViews];
    [self layoutViews];
    [self getData];
    
}

#pragma mark - UI
-(void)addViews{
    [self.view addSubview:self.tableView];
}

-(void)layoutViews{
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
    cell.cellType = FaBuShouKe;
    cell.seleArray = self.seleArray;
    cell.dataMuArray = ((CSHomeGradeModel*)self.dataArray[indexPath.section]).lists;
    cell.selectionStyle = 0;
    
    cell.seleBlock = ^(NSInteger cuid, NSString * title) {
        
        if ([self.seleArray containsObject:title]) {
            [self.seleArray removeObject:title];
        }else{
            [self.seleArray removeAllObjects];
            [self.seleArray addObject:title];
        }
        [self.tableView reloadData];
        
        
        
    };
    
    
    return cell;
}

#pragma mark - data
- (void)getData {
    
    NSDictionary *parmas = @{
        @"uid":[LoginManager defaultManager].userid,
        @"token":[LoginManager defaultManager].token
    };

    [HTTPSessionManger postDataWithNSString:@"/coach/get_curriculum" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"%@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            self.dataArray = [CSHomeGradeModel mj_objectArrayWithKeyValuesArray:dictionary[@"data"]];
            [self.tableView reloadData];
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
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
