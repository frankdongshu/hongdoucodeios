//
//  CSHomeCityViewController.m
//  hongdou
//
//  Created by 李龙 on 2020/3/6.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "CSHomeCityViewController.h"
#import "CSHomeTableViewCell.h"
#import "CSSelectCityModel.h"
#import "CSUserInfoViewController.h" // 信息填写

@interface CSHomeCityViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CSSelectCityModel *cityModel;
@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) NSMutableArray *titleSectionArray;
@property (nonatomic, strong) NSMutableArray *seleArray;

@end

@implementation CSHomeCityViewController

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
    
    self.sc_navigationBar.title = @"所在城市";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        if (self.cityType == CityNo) {
            [JMSGUser logout:^(id resultObject, NSError *error) {
                if (!error) {
                    NSLog(@"resultObject: %@",resultObject);
                } else {
                    NSLog(@"error: %@",error);
                }
            }];
            [MyLogin logOut];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        
    }];
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"下一步" withColor:[UIColor darkGrayColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self nextPageWithCityType:self.cityType];
        
    }];
    
    [self addViews];
    [self layoutViews];
    [self getData];
    
}

// 下一步
- (void)nextPageWithCityType:(CityListType)type {
    
    if (_seleArray.count > 0) {
        
        NSDictionary *parmas = @{
            @"uid":[MyLogin getCurrentLoginUser].userid,
            @"token":[MyLogin getCurrentLoginUser].token,
            @"city":self.seleArray.firstObject
        };

        [HTTPSessionManger postDataWithNSString:@"/user/city" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
            
            if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
                
                MyLogin *loo = [MyLogin getCurrentLoginUser];
                loo.city = self.seleArray.firstObject;
                [MyLogin updateUser:loo];
                
                if (type == CityNo) {
                    CSUserInfoViewController *vc = [[CSUserInfoViewController alloc] init];
                    [self.navigationController pushViewController:vc animated:YES];
                } else {
                    self.sureBlock();
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
                
            } else {
                [self.view showTostWithMessage:dictionary[@"msg"]];
            }
            
        } failure:^(NSError * _Nonnull error) {
            [self.view showTostWithMessage:@"请求失败, 请重试"];
        }];
        
    } else {
        [self.view showTostWithMessage:@"请选择城市"];
    }
}

#pragma mark - UI
- (void)addViews {
    [self.view addSubview:self.tableView];
}


-(void)layoutViews{
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kNavBarHeight);
        make.left.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - data
-(void)getData{
    
    [HTTPSessionManger postDataWithNSString:@"/index/city" withDictionary:@{} success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([dictionary[@"code"] integerValue] == 200) {
            self.cityModel = [CSSelectCityModel mj_objectWithKeyValues:dictionary[@"data"]];
            self.titleSectionArray = [[NSMutableArray alloc]init];
            [self.titleSectionArray addObject:@""];
            for (int i = 0; i < self.cityModel.all.count; i++) {
                [self.titleSectionArray addObject:self.cityModel.all[i].title];
            }
            [self.tableView reloadData];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

#pragma mark -  delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.cityModel.all.count + (self.cityModel.major ? 1 : 0);
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return (self.cityModel.major.lists.count > 0 ? 1 : 0);
    }else{
        return (self.cityModel.all[section -1].lists.count > 0 ? 1 : 0);
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CSHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSHomeTableViewCell" forIndexPath:indexPath];
    cell.cellType = CityType;
    cell.seleArray = self.seleArray;
    cell.selectionStyle = 0;
    if (indexPath.section == 0) {
        cell.dataMuArray = self.cityModel.major.lists;
    }else{
        cell.dataMuArray = (self.cityModel.all[indexPath.section - 1]).lists;
    }
    
    WeakSelf(ws);
    cell.seleBlock = ^(NSInteger cuid,NSString *title) {
        if ([ws.seleArray containsObject:title]) {
        }else{
            [ws.seleArray removeAllObjects];
            [ws.seleArray addObject:title];
        }
        [self.tableView reloadData];

    };

    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"";
    }else{
        return (self.cityModel.all[section-1]).title;
    }
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{

    return self.titleSectionArray;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index{
    return index;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0.01;
    NSMutableArray *array;
    if (indexPath.section == 0) {
        array = self.cityModel.major.lists;
    }else{
        array = (self.cityModel.all[indexPath.section - 1]).lists;
    }
    NSInteger rowww = array.count / 3;
    if (array.count % 3 == 0) {
        height = rowww *30 + (rowww - 1)*20;
    }else{
        height = (rowww + 1) *30 + (rowww)*20;
        
    }
    return  height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

#pragma mark - lazy
-(UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.separatorStyle = 0;
        [_tableView registerClass:[CSHomeTableViewCell class] forCellReuseIdentifier:@"CSHomeTableViewCell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        
        _tableView.sectionIndexColor = [UIColor blackColor];
        _tableView.sectionIndexBackgroundColor = [UIColor whiteColor];
    }
    return _tableView;
}

-(UIView*)tableHeaderView{
    if (_tableHeaderView == nil) {
        _tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, self.view.frame.size.width-20, 40)];
        NSMutableAttributedString *muAttString = [[NSMutableAttributedString alloc]initWithString:@"定位你要找家教/请家教的城市（慎重选择变更收费）"];
        NSRange idRange = [@"定位你要找家教/请家教的城市（慎重选择变更收费）" rangeOfString:@"（慎重选择变更收费）" options:NSRegularExpressionSearch];
        if (idRange.location != NSNotFound) {
            [muAttString addAttribute:NSForegroundColorAttributeName value:REDColor range:idRange];
        }
        label.font = kFontSize(14);
        label.attributedText = muAttString;
        label.numberOfLines = 2;
        [label sizeToFit];
        [_tableHeaderView addSubview:label];
    }
    return _tableHeaderView;
}

-(NSMutableArray *)seleArray{
    if (_seleArray == nil) {
        _seleArray = [[NSMutableArray alloc]init];
    }
    return _seleArray;
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
