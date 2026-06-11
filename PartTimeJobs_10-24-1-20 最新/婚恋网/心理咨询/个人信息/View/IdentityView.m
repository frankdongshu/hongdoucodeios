//
//  IdentityView.m
//  PartTimeJobs
//
//  Created by 维康1 on 2020/4/28.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "IdentityView.h"

@interface IdentityView ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *sureBtn;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) NSInteger seleIndex;

@end

@implementation IdentityView

- (instancetype)initWithFrame:(CGRect)frame andSelectString:(nonnull NSString *)select {
    if ([super initWithFrame:frame]) {
        [self addSubview:self.tableView];
        [self addSubview:self.sureBtn];
        
        self.dataArray = @[@"在校大学生",@"专职教师"];
        
        NSLog(@"-%@-",select);
        
        if (kISNullObject(select)) {
            self.seleIndex = 0;
        } else {
            for (int i=0; i<self.dataArray.count; i++) {
                if ([self.dataArray[i] isEqualToString:select]) {
                    self.seleIndex = i;
                }
            }
        }
        
        [self.tableView reloadData];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeSelf)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isDescendantOfView:self.tableView]) {
        return NO;
    }
    return YES;
}

- (UIButton *)sureBtn {
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureBtn.frame = CGRectMake(0, CGRectGetMaxY(self.tableView.frame), kScreenWidth, 44+kSafeAreaBottom);
        _sureBtn.backgroundColor = [UIColor whiteColor];
        [_sureBtn setTitleColor:REDColor forState:UIControlStateNormal];
        [_sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_sureBtn addTarget:self action:@selector(sureClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}

// 确定
- (void)sureClick {
    
    if (self.identityType == IdentityFaBu) {
        
        self.idenBlock(self.dataArray[self.seleIndex]);
        
        [self removeSelf];
        
        return;
    }
    
    
    NSDictionary *parmas = @{
        @"uid":[MyLogin getCurrentLoginUser].userid,
        @"token":[MyLogin getCurrentLoginUser].token,
        @"identity":self.dataArray[self.seleIndex]
    };

    [HTTPSessionManger postDataWithNSString:@"/coach/identity" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        NSLog(@"%@",dictionary);

        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            MyLogin *u = [MyLogin getCurrentLoginUser];
            u.identity = self.dataArray[self.seleIndex];
            [MyLogin updateUser:u];
            
            self.sureBlock();
            [self removeSelf];
        } else {
            [self showTostWithMessage:dictionary[@"msg"]];
        }


    } failure:^(NSError * _Nonnull error) {
        [kAppDelegate.window showErrorWithMessage:[error localizedDescription]];
    }];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kScreenHeight-144-kSafeAreaBottom, kScreenWidth, 100)];
        _tableView.delegate =  self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuse"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    if (indexPath.row == _seleIndex) {
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.textLabel.textColor = [UIColor grayColor];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell1 = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_seleIndex inSection:0]];
    cell1.textLabel.textColor = [UIColor grayColor];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor blackColor];
    
    _seleIndex = indexPath.row;
    
}


-(void)showSelf{
    UIWindow *windew = [UIApplication sharedApplication].keyWindow;
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    [windew addSubview:self];
}

-(void)removeSelf{
    [self removeFromSuperview];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
