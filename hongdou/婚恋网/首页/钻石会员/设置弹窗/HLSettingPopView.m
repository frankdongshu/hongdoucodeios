//
//  HLSettingPopView.m
//  hongdou
//
//  Created by 维康1 on 2020/9/8.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLSettingPopView.h"
#import "HLVSettingCell.h"

@interface HLSettingPopView ()<UITableViewDelegate,UITableViewDataSource,HLSwitchCellDeleagte, UIGestureRecognizerDelegate> {
    UIView *_view;
}

@property(nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *titleArray;



@end

@implementation HLSettingPopView

- (void)setDataDic:(NSDictionary *)dataDic {
    _dataDic = dataDic;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        self->_view = [[UIView alloc] init];
        self->_view.frame = CGRectMake(kScreenWidth/2, kScreenHeight/2-50, 0, 0);
        self->_view.backgroundColor = [UIColor whiteColor];
        self->_view.layer.masksToBounds = YES;
        self->_view.layer.cornerRadius = 8;
        
        [self addSubview:self->_view];
        
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HLVSettingCell *cell = (HLVSettingCell*)[tableView dequeueReusableCellWithIdentifier:@"HLVSettingCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.titleLabel.text = self.titleArray[indexPath.row];
    cell.index = indexPath.row;
    cell.delegate = self;
    
    switch (indexPath.row) {
        case 0:
        {
            cell.statu = [self.dataDic[@"in_svip"] boolValue];
            [cell.swicthOn setOn:[self.dataDic[@"in_svip"] boolValue] animated:YES];
        }
            break;
        case 1:
        {
            cell.statu = [self.dataDic[@"in_com"] boolValue];
            [cell.swicthOn setOn:[self.dataDic[@"in_com"] boolValue] animated:YES];
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)refreshTableView{
    
    [self removeSelf];
    
    self.SelectBlock();
    
}

-(void)showSelf{
    UIWindow *windew = [UIApplication sharedApplication].keyWindow;
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    
    [UIView animateWithDuration:.2 animations:^{
        self->_view.frame = CGRectMake(50, kScreenHeight/2-100, kScreenWidth-100, 160);
    } completion:^(BOOL finished) {
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self->_view.frame.size.width, 50)];
        lab.text = @"设置";
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont boldSystemFontOfSize:18];
        
        [self->_view addSubview:lab];
        
        self.titleArray = @[@"仅钻石会员可见我",@"只看同城"];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, self->_view.frame.size.width, 110) style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.scrollEnabled = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerNib:[UINib nibWithNibName:@"HLVSettingCell" bundle:nil] forCellReuseIdentifier:@"HLVSettingCell"];
        [self->_view addSubview:self.tableView];
        
    }];
    
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
