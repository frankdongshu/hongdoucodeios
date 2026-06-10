//
//  CSUserInfoViewController.m
//  hongdou
//
//  Created by 李龙 on 2020/3/7.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "CSUserInfoViewController.h"
#import "AccountGenderItemView.h"
#import "AccountInputItemView.h"
#import "DatePickerView.h"
#import "CSPersonInfoController.h"

@interface CSUserInfoViewController ()<GenderDelegate,DatePickerViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UITextField *identityTF;
@property (nonatomic, strong) AccountGenderItemView *genderView;
@property (nonatomic, strong) AccountGenderItemView *birthdayView;


@property (nonatomic, strong) UILabel *birthdayLabel;

@property (nonatomic, strong) UIButton *yearBtn, *monthBtn, *dayBtn;

@property (nonatomic, strong) UIButton *timeBtn; // 时间


@property (nonatomic, strong) UIButton *sureBtn;

@property (nonatomic, strong) DatePickerView *datePickerView;
@property (nonatomic, strong) UIView *lightGrayView;

@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *sex;
@property (nonatomic,copy)NSDate *now;

@end

@implementation CSUserInfoViewController

// 禁用侧滑返回手势
- (void)forbiddenGesture {
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self forbiddenGesture];
    
    self.sc_navigationBar.title = @"咨询师注册";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self sc_setNavigationBarBackgroundAlpha:0];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [JMSGUser logout:^(id resultObject, NSError *error) {
            if (!error) {
                NSLog(@"resultObject: %@",resultObject);
            } else {
                NSLog(@"error: %@",error);
            }
        }];
        [MyLogin logOut];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
//    self.now = [NSDate date];
    
    
    AccountInputItemView *identityView = [[AccountInputItemView alloc] init];
    identityView.titleLabel.text = @"姓名";
    identityView.textField.placeholder = @"请输入姓名";
    self.identityTF = identityView.textField;
    self.identityTF.delegate = self;
    [self.view addSubview:identityView];
    [identityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top).offset(kNavBarHeight);
        make.height.offset(81);
    }];

    
    AccountGenderItemView *genderView = [[AccountGenderItemView alloc] init];
    genderView.type = LeftRightType;
    self.genderView = genderView;
    genderView.genderDelegate = self;
    genderView.titleLabel.text = @"性别";
    [genderView.manButton setTitle:@"男" forState:UIControlStateNormal];
    genderView.manButton.selected = YES;
    self.sex = @"男";
    [genderView.womenButton setTitle:@"女" forState:UIControlStateNormal];
    [genderView.manButton addTarget:self action:@selector(seleSex:) forControlEvents:UIControlEventTouchUpInside];
    [genderView.womenButton addTarget:self action:@selector(seleSex:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:genderView];
    [genderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(self.view);
        make.top.mas_equalTo(identityView.mas_bottom).offset(0);
        make.height.offset(81);
    }];
    
    
    [self.view addSubview:self.birthdayLabel];
    
    [self.view addSubview:self.yearBtn];
    [self.view addSubview:self.monthBtn];
    [self.view addSubview:self.dayBtn];
    
    [self.view addSubview:self.timeBtn];
    
    [self.view addSubview:self.sureBtn];

    [self.birthdayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(15));
        make.top.equalTo(self.genderView.mas_bottom).mas_offset(10);
    }];
    
    [self.yearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(15));
        make.top.equalTo(self.birthdayLabel.mas_bottom).mas_offset(10);
        
    }];
    
    [self.monthBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.yearBtn.mas_right).mas_offset(8);
        make.top.equalTo(self.birthdayLabel.mas_bottom).mas_offset(10);
    }];
    [self.dayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.monthBtn.mas_right).mas_offset(8);
        make.top.equalTo(self.birthdayLabel.mas_bottom).mas_offset(10);
        
    }];
    
    UIView *yearLine = [[UIView alloc] init];
    yearLine.backgroundColor = HEXColor(@"e5e5e5");
    [self.view addSubview:yearLine];
    
    [yearLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(15));
        make.top.equalTo(self.yearBtn.mas_bottom);
        make.width.equalTo(self.yearBtn.mas_width);
        make.height.mas_equalTo(2);
    }];
    
    UIView *monthLine = [[UIView alloc] init];
    monthLine.backgroundColor = HEXColor(@"e5e5e5");
    [self.view addSubview:monthLine];
    
    [monthLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.monthBtn.mas_left);
        make.top.equalTo(self.monthBtn.mas_bottom);
        make.width.equalTo(self.monthBtn.mas_width);
        make.height.mas_equalTo(2);
    }];
    
    UIView *dayLine = [[UIView alloc] init];
    dayLine.backgroundColor = HEXColor(@"e5e5e5");
    [self.view addSubview:dayLine];
    
    [dayLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.dayBtn.mas_left);
        make.top.equalTo(self.dayBtn.mas_bottom);
        make.width.equalTo(self.dayBtn.mas_width);
        make.height.mas_equalTo(2);
    }];
    
    [self.timeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(15));
        make.right.equalTo(@(-15));
        make.top.equalTo(self.birthdayLabel.mas_bottom).mas_offset(10);
    }];


    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(15));
        make.right.equalTo(self.view.mas_right).mas_offset(-15);
        make.top.equalTo(yearLine.mas_bottom).mas_offset(50);
        make.height.mas_equalTo(40);
    }];

    
    self.datePickerView = [[DatePickerView alloc] initWithFrame:CGRectMake(0, kScreenHeight -235, kScreenWidth, 235) withTimeShowMode:ShowAllTime withIsShowTodayDate:YES];
    self.datePickerView.backgroundColor = [UIColor whiteColor];
    self.datePickerView.delegate = self;
    [self.view addSubview:self.datePickerView];
    self.datePickerView.hidden = YES;

    
    self.lightGrayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 235)];
    [self.view addSubview:self.lightGrayView];
    self.lightGrayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.lightGrayView.hidden = YES;
    // 单击的 Recognizer(_typeBottomView添加手势)
    UITapGestureRecognizer* singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lightGrayViewSingleTapFromAction)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [self.lightGrayView addGestureRecognizer:singleRecognizer];

    // Do any additional setup after loading the view.
}

#pragma mark - action
-(void)selebirthday:(UIButton*)btn{
    [self BtnAction];
}

-(void)seleSex:(UIButton*)btn{
    if (btn.tag == 100) {
        self.genderView.manButton.selected = YES;
        self.genderView.womenButton.selected = NO;
        self.sex = @"男";
    }else{
        self.genderView.manButton.selected = NO;
        self.genderView.womenButton.selected = YES;
        self.sex = @"女";
    }

}


#pragma mark - DatePickerViewDelegate
- (void)DatePickerView:(NSString *)year withMonth:(NSString *)month withDay:(NSString *)day withDate:(NSString *)date withTag:(NSInteger)tag{
    //确定
    if (tag == 1001) {
        
        [self.yearBtn setTitle:year forState:UIControlStateNormal];
        [self.monthBtn setTitle:month forState:UIControlStateNormal];
        [self.dayBtn setTitle:day forState:UIControlStateNormal];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];//解决8小时时间差问题
        self.now = [dateFormatter dateFromString:date];
        
        [self lightGrayViewSingleTapFromAction];
        
        
    } else { //1002：取消
        [self lightGrayViewSingleTapFromAction];
    }
    
    
}

- (void)BtnAction {
    // 关闭键盘
    [self.view endEditing:YES];
    
    self.datePickerView.hidden = NO;
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.3 // 动画时长
                          delay:0.0 // 动画延迟
                        options:UIViewAnimationOptionCurveEaseIn // 动画过渡效果
                     animations:^{
                         __strong typeof (weakSelf) strongSelf = weakSelf;
                         strongSelf.datePickerView.frame = CGRectMake(0, kScreenHeight - 235, kScreenWidth, 235);
                     }
                     completion:^(BOOL finished) {
                         // 动画完成后执行
                         __strong typeof (weakSelf) strongSelf = weakSelf;
                         strongSelf.lightGrayView.hidden = NO;
                     }];
    
}

- (void)lightGrayViewSingleTapFromAction {
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.3 // 动画时长
                          delay:0.0 // 动画延迟
                        options:UIViewAnimationOptionCurveEaseIn // 动画过渡效果
                     animations:^{
                         __strong typeof (weakSelf) strongSelf = weakSelf;
                         strongSelf.lightGrayView.hidden = YES;
                         strongSelf.datePickerView.frame = CGRectMake(0, kScreenHeight + 235, kScreenWidth, 235);
                     }
                     completion:^(BOOL finished) {
                         // 动画完成后执行
                         __strong typeof (weakSelf) strongSelf = weakSelf;
                         strongSelf.datePickerView.hidden = YES;
                     }];
    
}

- (void)getData {
    [self BtnAction];
}

- (void)sure { // 设置必填信息
    
    if (self.identityTF.text.length < 1) {
        [self.view showTostWithMessage:@"请输入姓名"];
        return;
    }
    if (kISNullObject(self.now)) {
        [self.view showTostWithMessage:@"请选择出生日期"];
        return;
    }
    
    NSDictionary *parmas = @{
        @"uid":[MyLogin getCurrentLoginUser].userid,
        @"token":[MyLogin getCurrentLoginUser].token,
        @"nickname":self.identityTF.text,
        @"sex":self.sex,
        @"birthday":self.now
    };

    [HTTPSessionManger postDataWithNSString:@"/user/must" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {

        NSLog(@"%@",dictionary);

        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {

            MyLogin *u = [MyLogin mj_objectWithKeyValues:dictionary[@"data"]];
            [MyLogin updateUser:u];

            CSPersonInfoController *vc = [[CSPersonInfoController alloc] init];
            vc.login = LoginNo;
            [self.navigationController pushViewController:vc animated:YES];

        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }


    } failure:^(NSError * _Nonnull error) {

    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.identityTF resignFirstResponder];
    return YES;
}

#pragma mark - lazy

-(UILabel *)birthdayLabel{
    if (_birthdayLabel == nil) {
        _birthdayLabel = [[UILabel alloc]init];
        _birthdayLabel.font = kScaleFont(15);
        _birthdayLabel.textColor = [UIColor blackColor];
        _birthdayLabel.text = @"生日";
        [_birthdayLabel sizeToFit];
    }
    return _birthdayLabel;

}


- (UIButton *)timeBtn {
    if (!_timeBtn) {
        _timeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_timeBtn sizeToFit];
        
        [_timeBtn addTarget:self action:@selector(getData) forControlEvents:UIControlEventTouchUpInside];
    }
    return _timeBtn;
}

- (UIButton *)yearBtn {
    if (!_yearBtn) {
        _yearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _yearBtn.backgroundColor = [UIColor redColor];
//        _yearBtn.titleLabel.font = kScaleFont(15);
        [_yearBtn sizeToFit];
        [_yearBtn setTitleColor:REDColor forState:UIControlStateNormal];
//        [_yearBtn setTitle:@"1997" forState:UIControlStateNormal];
    }
    return _yearBtn;
}
- (UIButton *)monthBtn {
    if (!_monthBtn) {
        _monthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _monthBtn.backgroundColor = [UIColor redColor];
//        _monthBtn.titleLabel.font = kScaleFont(15);
        [_monthBtn sizeToFit];
        [_monthBtn setTitleColor:REDColor forState:UIControlStateNormal];
//        [_monthBtn setTitle:@"05" forState:UIControlStateNormal];
    }
    return _monthBtn;
}
- (UIButton *)dayBtn {
    if (!_dayBtn) {
        _dayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _dayBtn.backgroundColor = [UIColor redColor];
//        _dayBtn.titleLabel.font = kScaleFont(15);
        [_dayBtn sizeToFit];
        [_dayBtn setTitleColor:REDColor forState:UIControlStateNormal];
//        [_dayBtn setTitle:@"29" forState:UIControlStateNormal];
    }
    return _dayBtn;
}

-(UIButton *)sureBtn{
    if (_sureBtn == nil) {
        _sureBtn = [[UIButton alloc]init];
        [_sureBtn setTitle:@"确认" forState:UIControlStateNormal];
        _sureBtn.titleLabel.font = kScaleFont(15);
        [_sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureBtn addTarget:self action:@selector(sure) forControlEvents:UIControlEventTouchUpInside];
        _sureBtn.layer.cornerRadius = 20;
        _sureBtn.layer.masksToBounds = YES;
        _sureBtn.backgroundColor = REDColor;
    }
    return _sureBtn;
    
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
