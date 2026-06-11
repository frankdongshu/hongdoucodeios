//
//  XBZKeyBoardGreetListView.m
//  hongdou
//
//  Created by iMac on 2019/11/8.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "XBZKeyBoardGreetListView.h"
#import "HLListModel.h"



@implementation XBZKeyBoardGreetListView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.height)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.scrollsToTop = NO;
        _tableView.contentInsetTop = 0;
        if (@available(iOS 9.0, *)) {
            self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [self addSubview:self.tableView];
        self.dataSource  = [NSMutableArray array];
        [self requestList];
    }
    return self;
}


- (void)requestList{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLSyntax_list withDictionary:@{} success:^(NSDictionary * _Nonnull dictionary) {
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
            weakSelf.dataSource = [HLListModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
        }else{
            
        }
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark tableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001f;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    HLListModel *model = self.dataSource[indexPath.row];
    cell.textLabel.textColor  = [UIColor colorWithHex:0x333333];
    cell.textLabel.font  = [UIFont systemFontOfSize:15.f];
    cell.textLabel.text = model.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatGreetDidSelectItemWithTitle:index:)]) {
        HLListModel *model = self.dataSource[indexPath.row];

        [self.delegate chatGreetDidSelectItemWithTitle:model.name index:indexPath.row];
    }
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
