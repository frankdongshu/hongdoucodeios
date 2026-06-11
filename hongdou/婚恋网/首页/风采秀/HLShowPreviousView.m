//
//  HLShowPreviousView.m
//  hongdou
//
//  Created by user on 2022/8/12.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import "HLShowPreviousView.h"

@interface HLShowPreviousView ()<UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource> {
    NSInteger idx;
    BOOL isSel;
}

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation HLShowPreviousView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        self.dataArray = [NSMutableArray array];
        
        [self addSubview:self.headerView];
        
        [self requestData];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.headerView.frame = CGRectMake(0, kScreenHeight-373, kScreenWidth, 373);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeSelf)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isDescendantOfView:self.headerView]) {
        return NO;
    }
    return YES;
}

-(void)showSelf{
    UIWindow *windew = [UIApplication sharedApplication].keyWindow;
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    [windew addSubview:self];
}

-(void)removeSelf{
    [self removeFromSuperview];
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight+373, kScreenWidth, 373)];
        _headerView.backgroundColor = [UIColor whiteColor];
        
        _headerView.layer.cornerRadius = 5;
        _headerView.layer.masksToBounds = YES;
        
        self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, kScreenWidth, 40)];
        self.titleLab.text = @"本期: 2022.05.20";
        self.titleLab.textAlignment = NSTextAlignmentCenter;
        self.titleLab.font = [UIFont systemFontOfSize:16 weight:.3];
        self.titleLab.textColor = kRGBA(63, 70, 88, 1);
        [_headerView addSubview:self.titleLab];
        
        [_headerView addSubview:self.tableView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tableView.frame)+20, kScreenWidth, 1)];
        lineView.backgroundColor = kRGBA(242, 242, 242, 1);
        [_headerView addSubview:lineView];
        
        
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.backgroundColor = kRGBA(255, 89, 130, 1);
        [btn1 setTitle:@"确定" forState:UIControlStateNormal];
        btn1.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn1.frame = CGRectMake(16, CGRectGetMaxY(lineView.frame)+12, kScreenWidth-32, 48);
        [btn1 addTarget:self action:@selector(btn1Click) forControlEvents:UIControlEventTouchUpInside];
        btn1.layer.cornerRadius = 24;
        btn1.layer.masksToBounds = YES;
        
        btn1.right = _headerView.right-15;
        
        btn1.layer.borderColor = [kRGBA(221, 221, 221, 1) CGColor];
        btn1.layer.borderWidth = 1;
        [_headerView addSubview:btn1];
        
    }
    return _headerView;
}

- (void)btn1Click {
    
    if (self->isSel == YES) {
        [self removeSelf];
        [self.delegate previousListWithId:self.dataArray[self->idx][@"id"]];
    } else {
        [self showTostWithMessage:@"请选择日期"];
    }
    
}

- (void)requestData {
    
    [self showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/album/activityhistory" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"--->: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [self hideLoading];
            
            self.dataArray = dictionary[@"data"];
            
            self.titleLab.text = [NSString stringWithFormat:@"本期:%@",[self.dataArray firstObject][@"start"]];
            
            [self.tableView reloadData];
            
        } else {
            [kAppDelegate.window showTostWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [kAppDelegate.window showTostWithMessage:[error localizedDescription]];
    }];
    
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(20, 70, kScreenWidth-40, 200)];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = kRGBA(247, 247, 247, 1);
        
        _tableView.layer.cornerRadius = 8;
        _tableView.layer.masksToBounds = YES;
        
        _tableView.layer.borderColor = [kRGBA(221, 221, 221, 1) CGColor];
        _tableView.layer.borderWidth = 1;
        
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuse"];
    }
    
    return _tableView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse"];
    cell.selectionStyle = 0;
    cell.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    
    if (self->idx == indexPath.row && self->isSel == YES) {
        cell.textLabel.textColor = kRGBA(255, 89, 130, 1);
    } else {
        cell.textLabel.textColor = kRGBA(34, 34, 34, 1);
    }
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@    %@",self.dataArray[indexPath.row][@"name"],self.dataArray[indexPath.row][@"start"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc]init];

    cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.textLabel.textColor = kRGBA(255, 89, 130, 1);
    
    self->idx = indexPath.row;
    
    self->isSel = YES;
    
}


- (void)tableView:(UITableView*)tableView didDeselectRowAtIndexPath:(NSIndexPath*)indexPath{

    UITableViewCell *cell = [[UITableViewCell alloc]init];

    cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    //这里可以改变label失去颜色的时候，会变成初始黑色
    cell.textLabel.textColor = kRGBA(34, 34, 34, 1);

}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
