//
//  HLComplaintViewController.m
//  hongdou
//
//  Created by iMac on 2019/10/21.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLComplaintViewController.h"
#import "HLCoPlaintSelectTableViewCell.h"
#import "HLCoplaintUpPhotoTableViewCell.h"
#import "HLComplaintMessageTableViewCell.h"

@interface HLComplaintViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
{
    NSString *complaintID; // 举报类型ID
    NSArray *uplodaPicArr; // 存放url地址图片数组
    NSString *remarks; // 留言

}
@property(nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *placeHolderlabel;

@end

@implementation HLComplaintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = @"投诉举报";
    self.dataSource = [NSMutableArray array];
    complaintID = @"";
    remarks = @"";
    [self creatTableView];
    
    if (self.pertEnum == HongDouUser) {
        [self requestComplain];
    } else {
        [self getComplaintList];
    }
    
    
    
    
    // 用于点击TableView是移除软键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
        
    // 设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
}

- (void)keyboardHide:(UITapGestureRecognizer*)tap {
 
    if (self.textView.isFirstResponder) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.textView resignFirstResponder];
            
            self.tableView.contentOffsetY = 78.0;
            
        }];
        
    }
}

- (void)creatTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight-kNavigationBarHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.scrollsToTop = NO;
    _tableView.contentInsetTop = 0;
    _tableView.estimatedRowHeight = 0; // 之前设置的: 60.f 刷新时跳动
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;

    _tableView.tableFooterView=[[UIView alloc] init];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"HLCoPlaintSelectTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLCoPlaintSelectTableViewCell"];
    [self.tableView registerClass:[HLCoplaintUpPhotoTableViewCell class] forCellReuseIdentifier:@"HLCoplaintUpPhotoTableViewCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
//    [_tableView registerNib:[UINib nibWithNibName:@"HLComplaintMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLComplaintMessageTableViewCell"];
    
    [self.view addSubview:_tableView];
}
// 请求拉黑条件列表
- (void)requestComplain{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLComplaint_List withDictionary:@{} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            weakSelf.dataSource = [HLListModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
        }else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
    }];
}

// 投诉列表
- (void)getComplaintList {
    [self.view showLoading];

    [HTTPSessionManger postDataWithNSString:@"/customer/getcomplaint" withDictionary:@{} success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [self.view hideLoading];
            
            self.dataSource = [HLListModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        [self.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        
        [self.view showTostWithMessage:[error localizedDescription]];
    }];
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section == 0) {
        return self.dataSource.count;
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return 48.f;
    }else if(indexPath.section == 2){
        return 120.f;
    }
    return kScreenWidth/2 + 24;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 33;
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *array = @[@"举报原因",@"上传图片(最多八张)",@"备注"];
    return [array objectAtIndex:section];
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.backgroundColor = [UIColor whiteColor];
    [header.textLabel setFont:[UIFont systemFontOfSize:13]];
    [header.textLabel setTextColor:[UIColor colorWithHex:0x6175F6]];
    
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 2) {
        UIView *view = [UIView new];
        // 确认修改按钮
        UIButton *updateBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 8, kScreenWidth - 30 , 44)];
        [updateBtn setTitle:@"提交" forState:UIControlStateNormal];
        [updateBtn az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0x995ff8],[UIColor colorWithHex:0x5d57ed]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
        [updateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        updateBtn.layer.cornerRadius = 22.f;
        updateBtn.layer.masksToBounds = YES;
        [updateBtn addTarget:self action:@selector(sureAlter) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:updateBtn];
        view.backgroundColor = [UIColor whiteColor];
        return view;
    }
    return [[UIView alloc] init];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return 60;
    }
    return 0.001f;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        HLCoPlaintSelectTableViewCell *cell = (HLCoPlaintSelectTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HLCoPlaintSelectTableViewCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        HLListModel *model = self.dataSource[indexPath.row];
        cell.listModel = model;

        cell.refreshBlock = ^{
            [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                HLListModel *newModel = obj;
                if ([model.Id isEqualToString:newModel.Id]) {
                    newModel.isSelect = YES;
                    self->complaintID = newModel.Id;
                }else{
                    newModel.isSelect = NO;
                }
            }];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];

        };
        return cell;

    }else if(indexPath.section == 1){
        HLCoplaintUpPhotoTableViewCell *cell = (HLCoplaintUpPhotoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HLCoplaintUpPhotoTableViewCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.weakSelf = self;
        cell.picsBlock = ^(NSArray * _Nonnull picArray) {
            self->uplodaPicArr = picArray;
        };
        return cell;

    }else{
//        HLComplaintMessageTableViewCell *cell = (HLComplaintMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HLComplaintMessageTableViewCell"];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(17, 10, kScreenWidth - 34, 100)];
        self.textView.backgroundColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.0];
        self.textView.textColor = [UIColor blackColor];
        self.textView.font = [UIFont systemFontOfSize:16];
        self.textView.delegate = self;
        self.textView.text = remarks;
        [cell.contentView addSubview:self.textView];
        
        self.placeHolderlabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 6 , kScreenWidth , 21)];
        self.placeHolderlabel.font = [UIFont systemFontOfSize:16];
        self.placeHolderlabel.textColor = [UIColor colorWithRed:157/255.0 green:164/255.0 blue:174/255.0 alpha:1.0];
        self.placeHolderlabel.text = @"填写…";
        self.placeHolderlabel.hidden = NO;
        if (remarks.length>0) {
            self.placeHolderlabel.hidden = YES;
        }
        [self.textView addSubview:self.placeHolderlabel];
        return cell;
    }
}

// 在拖动开始时调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (self.textView.isFirstResponder) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.textView resignFirstResponder];
        }];
        
    }
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    NSLog(@"开始编辑");
    
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentOffsetY= 48 *self.dataSource.count + kScreenWidth/2 + 100;
    }];
    
    
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    NSLog(@"结束编辑");
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
        
    }
    remarks = textView.text;
    self.tableView.contentOffsetY = 48 *5;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (range.location==0) {
        self.placeHolderlabel.hidden = NO;
    }
    if (text.length>0) {
        self.placeHolderlabel.hidden = YES;
        
    }
    return YES;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
        
    }
}

// 确认发布
- (void)sureAlter{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
        
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (complaintID.length==0) {
        [self.view showTostWithMessage:@"请选择举报类型!"];
        return;
    }
    [dic setObject:[LoginManager defaultManager].userid forKey:@"uid"];
    [dic setObject:self.userMobile forKey:@"mobile"];
    [dic setObject:complaintID forKey:@"complaint"];
    //备注  remarks
    if (remarks.length > 0) {
        [dic setObject:remarks forKey:@"remarks"];
    }
    if (uplodaPicArr.count > 0) {
        [uplodaPicArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            HLAlbumUploadModel *model = obj;
            [dic setObject:model.var forKey:[NSString stringWithFormat:@"pics[%lu]",idx]];
        }];
    }
    
    [self.view showLoading];
    [HLHTTPSessionManager postDataWithNSString:HLFriends_Complaint withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [kAppDelegate.window showSuccessWithMessage:dictionary[@"msg"]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RemovePerson" object:self.userMobile];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        } else {
            [self.view showErrorWithMessage:dictionary[@"msg"]];
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
