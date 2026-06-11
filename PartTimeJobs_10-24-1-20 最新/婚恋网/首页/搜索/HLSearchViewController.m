//
//  HLSearchViewController.m
//  hongdou
//
//  Created by iMac on 2019/10/16.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLSearchViewController.h"
#import "HLEditInfoTableViewCell.h"
#import "HLCitySelectorViewController.h"
#import "BRStringPickerView.h"
#import "HLSearchResultViewController.h"

@interface HLSearchViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL isVip;
    NSIndexPath *currentIndexPath;
}
@property(nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *userTitleArray;/*标题数组*/
@property (nonatomic, strong) NSArray *keyArray;/*key数组*/

@property (nonatomic, strong) NSMutableDictionary *contentDic;/*内容自定*/

@property (nonatomic, strong) NSMutableDictionary *uploadDic;/*上传的数组*/


@end

@implementation HLSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = @"条件筛选";
    isVip = NO;
    [self initDataArray];
    [self creatTableView];
//    [self requestISVip];
}

- (void)initDataArray{
    self.userTitleArray = @[@"年龄",@"月收入",@"身高",@"学历",@"住房",@"车"];
    self.contentDic = [NSMutableDictionary dictionary];
    self.uploadDic = [NSMutableDictionary dictionary];

    self.keyArray = @[@"age",@"habitation",@"income",@"height",@"education",@"housing",@"car"];
    for (NSString *key in self.keyArray) {
        [self.contentDic setObject:@"不限" forKey:key];
    }
}

- (void)creatTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight-kNavigationBarHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.scrollsToTop = NO;
    if (@available(iOS 9.0, *)) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    _tableView.estimatedRowHeight = 48.f;
    _tableView.tableFooterView=[[UIView alloc] init];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"HLEditInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLEditInfoTableViewCell"];
    [self.view addSubview:_tableView];
}

// 请求查看是否是会员
- (void)requestISVip{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLIS_VIPMember withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            self->isVip = [[dictionary[@"data"] objectForKey:@"if"] boolValue];
        }else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
    }];
}


#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.userTitleArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48.f;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *view = [UIView new];
    // 确认修改按钮
    UIButton *updateBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 8, kScreenWidth - 30 , 44)];
    [updateBtn setTitle:@"确定" forState:UIControlStateNormal];
    [updateBtn az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0x995ff8],[UIColor colorWithHex:0x5d57ed]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    [updateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    updateBtn.layer.cornerRadius = 22.f;
    updateBtn.layer.masksToBounds = YES;
    [updateBtn addTarget:self action:@selector(sureAlter) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:updateBtn];
    view.backgroundColor = [UIColor whiteColor];
    return view;
    return [[UIView alloc] init];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 60;

}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.backgroundColor = [UIColor whiteColor];
    [header.textLabel setFont:[UIFont systemFontOfSize:13]];
    [header.textLabel setTextColor:[UIColor colorWithHex:0x6175F6]];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLEditInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLEditInfoTableViewCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setTitleLableText:self.userTitleArray[indexPath.row] withContent:self.contentDic[self.keyArray[indexPath.row]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    currentIndexPath = indexPath;
    switch (indexPath.row) {
        case 0:
        {
            //年龄 段
            [self requesFriendstListWithUrl:HLAge_List withTitle:@"年龄" withisAge:YES];
        }
            break;
//        case 1:
//        {
//            //居住地
//            HLCitySelectorViewController *citySelectVC = [[HLCitySelectorViewController alloc] init];
//            citySelectVC.selectorCityBlock = ^(HLCityModel * _Nonnull model) {
//                [self.contentDic setObject:model.cityName forKey:self.keyArray[indexPath.row]];
//                [self.uploadDic setObject:model.cityID forKey:self.keyArray[indexPath.row]];
//                [self.tableView reloadData];
//            };
//            [self presentViewController:citySelectVC animated:YES completion:nil];
//        }
//            break;
        case 1:
        {
            //月收入
            [self requestListWithUrl:HLIncome_List withTitle:@{@"name":@"月收入",@"value":@"8000以上"}];
            
        }
            break;
        case 2:
        {
            //身高 段
            [self requesFriendstListWithUrl:HLHeight_List withTitle:@"身高" withisAge:NO];
            
        }
            break;
        case 3:
        {
            //学历
            [self requestListWithUrl:HLEducation_List withTitle:@{@"name":@"学历",@"value":@"本科"}];
            
        }
            break;
        case 4:
        {
            //住房
            [self requestListWithUrl:HLHousing_List withTitle:@{@"name":@"住房",@"value":@"已购房"}];
            
        }
            break;
        case 5:
        {
            //车
            WeakSelf(weakSelf);
//            [BRStringPickerView showStringPickerWithTitle:@"车" dataSource:@[@"未购",@"已购"] defaultSelValue:weakSelf.contentDic[weakSelf.keyArray[indexPath.row]] resultBlock:^(id selectValue) {
//                [weakSelf.contentDic setObject:selectValue forKey:weakSelf.keyArray[indexPath.row]];
//
//                if ([selectValue isEqualToString:@"已购"]) {
//                    [weakSelf.uploadDic setObject:@"1" forKey:weakSelf.keyArray[indexPath.row]];
//                }else{
//                    [weakSelf.uploadDic setObject:@"2" forKey:weakSelf.keyArray[indexPath.row]];
//                    
//                }
//                [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
//            }];
            NSArray *arr = @[@"不限",@"未购",@"已购"];
            
            NSInteger index = [arr indexOfObject:self.contentDic[self.keyArray[indexPath.row]]];
            
            [BRStringPickerView showPickerWithTitle:@"车" dataSourceArr:arr selectIndex:index resultBlock:^(BRResultModel * _Nullable resultModel) {
                
                [self.contentDic setObject:resultModel.value forKey:self.keyArray[indexPath.row]];

                if ([resultModel.value isEqualToString:@"已购"]) {
                    
                    [self.uploadDic setObject:@"1" forKey:self.keyArray[indexPath.row]];
                    
                } else if ([resultModel.value isEqualToString:@"不限"]) {
                    
                    [self.uploadDic removeObjectForKey:self.keyArray[indexPath.row]];
                    
                } else {
                    [self.uploadDic setObject:@"2" forKey:self.keyArray[indexPath.row]];
                    
                }
                [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
                
            }];
            
        }
            break;
        default:
            break;
    }
}

#pragma mark 请求类表信息
// 请求 列表数据
- (void)requestListWithUrl:(NSString *)url withTitle:(NSDictionary *)dic{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager getDataWithNSString:url withDictionary:@{} success:^(NSDictionary * _Nonnull dictionary) {
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
            NSMutableArray *listArry = [NSMutableArray array];
            listArry = [HLListModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            NSMutableDictionary *allDiction = [NSMutableDictionary dictionary];
            NSMutableArray *allVaule  = [NSMutableArray array];
            [listArry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HLListModel *model = obj;
                [allDiction setObject:model.name forKey:model.Id];
                [allVaule addObject:model.name];
            }];
            
            NSString *string = weakSelf.contentDic[weakSelf.keyArray[self->currentIndexPath.row]];
            
            
            
//            [BRStringPickerView showStringPickerWithTitle:dic[@"name"] dataSource:allVaule defaultSelValue:[string isEqualToString:@"不限"]?dic[@"value"]:string resultBlock:^(id selectValue) {
//                [weakSelf.contentDic setObject:selectValue forKey:weakSelf.keyArray[self->currentIndexPath.row]];
//                for (NSString *key in allDiction.allKeys) {
//                    if ([allDiction[key] isEqualToString:selectValue]) {
//                        [weakSelf.uploadDic setObject:key forKey:weakSelf.keyArray[self->currentIndexPath.row]];
//                        break;
//                    }
//                }
//                [weakSelf.tableView reloadData];
//            }];
            [BRStringPickerView showPickerWithTitle:dic[@"name"] dataSourceArr:allVaule selectIndex:index resultBlock:^(BRResultModel * _Nullable resultModel) {
                
                [weakSelf.contentDic setObject:resultModel.value forKey:weakSelf.keyArray[self->currentIndexPath.row]];
                
                for (NSString *key in allDiction.allKeys) {
                    if ([allDiction[key] isEqualToString:resultModel.value]) {
                        [weakSelf.uploadDic setObject:key forKey:weakSelf.keyArray[self->currentIndexPath.row]];
                        break;
                    }
                }
                
                if ([resultModel.value isEqualToString:@"不限"]) {
                    [weakSelf.uploadDic removeObjectForKey:weakSelf.keyArray[self->currentIndexPath.row]];
                }
                
                [weakSelf.tableView reloadData];
                
            }];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)requesFriendstListWithUrl:(NSString *)url withTitle:(NSString *)title withisAge:(BOOL)isage{
    NSString *select1 = @"";
    NSString *select2 = @"";
     
    NSString *selectTitle = self.contentDic[self.keyArray[self->currentIndexPath.row]];
    
    if (selectTitle.length>0) {
        NSArray *array = [selectTitle componentsSeparatedByString:@"-"]; //从字符-中分隔成2个元素的数组
        select1 = array.firstObject;
        select2 = array.lastObject;
    }
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager getDataWithNSString:url withDictionary:@{} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            NSMutableArray *listArry = [NSMutableArray array];
            listArry = [HLListModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            NSMutableDictionary *allDiction = [NSMutableDictionary dictionary];
            NSMutableArray *allVaule  = [NSMutableArray array];
            NSMutableArray *allVaule1  = [NSMutableArray array];
            [listArry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HLListModel *model = obj;
                [allDiction setObject:model.name forKey:model.Id];
                [allVaule addObject:model.name];
                [allVaule1 addObject:model.name];
                
            }];
//            [BRStringPickerView showStringPickerWithTitle:title dataSource:@[allVaule,allVaule1] defaultSelValue:@[select1,select2] resultBlock:^(id selectValue) {
//                NSArray *resultArr = selectValue;
//                
//                NSString *reseult1 = resultArr.firstObject;
//                NSString *reseult2 = resultArr.lastObject;
//                NSString *lowId;
//                NSString *highId;
//                for (NSString *key in allDiction.allKeys) {
//                    if ([allDiction[key] isEqualToString:reseult1]) {
//                        lowId = key;
//                        break;
//                    }
//                }
//                for (NSString *key in allDiction.allKeys) {
//                    if ([allDiction[key] isEqualToString:reseult2]) {
//                        highId = key;
//                        break;
//                    }
//                }
//                
//                if ([lowId intValue] < [highId intValue]) {
//                    if (isage) {
//                        [weakSelf.uploadDic setObject:[NSString stringWithFormat:@"%@",lowId] forKey:@"age_low"];
//                        [weakSelf.uploadDic setObject:[NSString stringWithFormat:@"%@",highId] forKey:@"age_high"];
//                    }else{
//                        [weakSelf.uploadDic setObject:[NSString stringWithFormat:@"%@",lowId] forKey:@"height_low"];
//                        [weakSelf.uploadDic setObject:[NSString stringWithFormat:@"%@",highId] forKey:@"height_high"];
//                    }
//                    [weakSelf.contentDic setObject:[NSString stringWithFormat:@"%@-%@",reseult1,reseult2] forKey:self.keyArray[self->currentIndexPath.row]];
//                    [weakSelf.tableView reloadData];
//
//                }else{
//                    if (isage) {
//                        [weakSelf.view showTostWithMessage:@"请升序选择年龄"];
//                    }else{
//                        [weakSelf.view showTostWithMessage:@"请升序选择身高"];
//
//                    }
//                }
//            }];
            NSInteger index1 = [allVaule indexOfObject:select1];
            NSInteger index2 = [allVaule1 indexOfObject:select2];
            [BRStringPickerView showMultiPickerWithTitle:title dataSourceArr:@[allVaule,allVaule1] selectIndexs:@[@(index1),@(index2)] resultBlock:^(id selectValue) {
                NSArray *resultArr = selectValue;
                
                NSString *reseult1 = resultArr.firstObject;
                NSString *reseult2 = resultArr.lastObject;
                NSString *lowId;
                NSString *highId;
                for (NSString *key in allDiction.allKeys) {
                    if ([allDiction[key] isEqualToString:reseult1]) {
                        lowId = key;
                        break;
                    }
                }
                for (NSString *key in allDiction.allKeys) {
                    if ([allDiction[key] isEqualToString:reseult2]) {
                        highId = key;
                        break;
                    }
                }
                
                if ([lowId intValue] < [highId intValue]) {
                    if (isage) {
                        [weakSelf.uploadDic setObject:[NSString stringWithFormat:@"%@",lowId] forKey:@"age_low"];
                        [weakSelf.uploadDic setObject:[NSString stringWithFormat:@"%@",highId] forKey:@"age_high"];
                    }else{
                        [weakSelf.uploadDic setObject:[NSString stringWithFormat:@"%@",lowId] forKey:@"height_low"];
                        [weakSelf.uploadDic setObject:[NSString stringWithFormat:@"%@",highId] forKey:@"height_high"];
                    }
                    [weakSelf.contentDic setObject:[NSString stringWithFormat:@"%@-%@",reseult1,reseult2] forKey:self.keyArray[self->currentIndexPath.row]];
                    [weakSelf.tableView reloadData];

                }else{
                    if (isage) {
                        [weakSelf.view showTostWithMessage:@"请升序选择年龄"];
                    }else{
                        [weakSelf.view showTostWithMessage:@"请升序选择身高"];

                    }
                }
            }];
            
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

// 确认修改按钮
- (void)sureAlter{
    WeakSelf(weakSelf);
//    if (self.uploadDic.allKeys.count==0) {
//        [self.view showTostWithMessage:@"请选择筛选条件"];
//        return;
//    }
    [self.uploadDic setObject:[LoginManager defaultManager].userid forKey:@"uid"];
    
    NSLog(@"==== %@",self.uploadDic);
    
    [HLHTTPSessionManager postDataWithNSString:HLUser_Screen withDictionary:self.uploadDic success:^(NSDictionary * _Nonnull dictionary) {
        [weakSelf.view hideLoading];
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            NSArray *array  = [[NSArray alloc] init];
            array = [HLUser mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            if (array) {
                HLSearchResultViewController *resultVC = [[HLSearchResultViewController alloc] init];
                resultVC.requestDic = weakSelf.uploadDic;
                [self.navigationController pushViewController:resultVC animated:YES];
            }else{
                [self.view showTostWithMessage:@"暂无符合筛选条件的人"];

            }
        }else
        {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:@"筛选失败"];

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
