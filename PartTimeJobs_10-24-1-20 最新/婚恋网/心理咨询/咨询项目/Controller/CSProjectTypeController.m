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
#import "XinLiViewController.h" // 心理咨询TabBarController

@interface CSProjectTypeController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *seleArray;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation CSProjectTypeController

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
    
    self.sc_navigationBar.title = @"选择擅长项目";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self sc_setNavigationBarBackgroundAlpha:0];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        if (self.projType == TypeYes) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [JMSGUser logout:^(id resultObject, NSError *error) {
                if (!error) {
                    NSLog(@"resultObject: %@",resultObject);
                } else {
                    NSLog(@"error: %@",error);
                }
            }];
            [MyLogin logOut];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        
    }];
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"确定" withColor:[UIColor darkGrayColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        if (self.seleArray.count == 0) {
            [self.view showTostWithMessage:@"请选择擅长项目"];
        } else {
            [self nextPage];
        }
        
        
    }];
    
    self.dataArray = [NSMutableArray array];
    self.seleArray = [NSMutableArray arrayWithArray:[MyLogin getCurrentLoginUser].curriculum];
    
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
        @"uid":[MyLogin getCurrentLoginUser].userid,
        @"token":[MyLogin getCurrentLoginUser].token
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

// 确定
- (void)nextPage {
    NSDictionary *parmas = @{
        @"uid":[MyLogin getCurrentLoginUser].userid,
        @"token":[MyLogin getCurrentLoginUser].token,
        @"curriculum":self.seleArray
    };

    [HTTPSessionManger postDataWithNSString:@"/coach/curriculum" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            MyLogin *u = [MyLogin getCurrentLoginUser];
            u.curriculum = self.seleArray;
            [MyLogin updateUser:u];
            
            if (self.projType == TypeNo) {
//                XinLiViewController *vc = [[XinLiViewController alloc] init];
//                vc.modalPresentationStyle = 0;
//                [self presentViewController:vc animated:YES completion:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
                
                [self.navigationController popToRootViewControllerAnimated:YES];
                
                
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
        [self.view showTostWithMessage:@"请求失败"];

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
