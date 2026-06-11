//
//  HLFindSoundController.m
//  hongdou
//
//  Created by 李龙 on 2021/12/11.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLFindSoundController.h"
#import "HLFindSoundCell.h"
#import "HLPreviewPhotoViewController.h"
#import "HLFrienderDetailViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"

@interface HLFindSoundController ()<HLFindSoundCellDelegate> {
    
    NSInteger currentPage;
    NSInteger theRowInt;
}
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

static NSString *identyfy = @"HLFindSoundCell";

@implementation HLFindSoundController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.isLogin) {
        [self.dataSource removeAllObjects];
        self.tableView.mj_footer.hidden = YES;
    } else {
//        self.tableView.mj_footer.hidden = NO;
        
        
//        [self loadNewData];
    }
    
    
    [self.tableView reloadData];
}

- (void)removePersonClick:(NSNotification *)notifi {
    
//    NSString *mobile = notifi.object;
    
    [self loadNewData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 添加监听
    [self addNotification];
    
    self.dataSource = [[NSMutableArray alloc] init];
    
    [self initTableView];
    
    [self.tableView.mj_header beginRefreshing];
}

// 添加监听
- (void)addNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadNewData) name:DismissLoginView object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadNewData) name:@"ADD_SOUND" object:nil];
}

- (void)initTableView {
    
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight-kTabBarHeight);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 200.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HLFindSoundCell" bundle:nil] forCellReuseIdentifier:@"HLFindSoundCell"];
    
}

// 下拉刷新
- (void)loadNewData {
    
    if (!self.isLogin) {
        [self.view showErrorWithMessage:@"请登录后尝试"];
        [self.tableView.mj_header endRefreshing];
        
        return;
    }
    
    currentPage = 1;
    [self.dataSource removeAllObjects];
    [self requestDataWithPege:currentPage];
    
}

// 上拉加载
- (void)loadMoreData {
    
    if (!self.isLogin) {
        [self.view showErrorWithMessage:@"请登录后尝试"];
        [self.tableView.mj_footer endRefreshing];
        
        return;
    }
    
    currentPage ++;
    [self requestDataWithPege:currentPage];
    
}

// 请求列表
- (void)requestDataWithPege:(NSInteger)page{
    if (self.isLogin) {
        WeakSelf(weakSelf);
        
        NSDictionary *params = @{
            @"uid":[LoginManager defaultManager].userid,
            @"page":[NSNumber numberWithInteger:page]
        };
        
        [HLHTTPSessionManager postDataWithNSString:@"/album/get_voice_wall" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
            
            NSLog(@"~~~: %@",dictionary);
            
            self.tableView.mj_footer.hidden = NO;
            
            if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
                
                NSMutableArray *dataArray = [dictionary objectForKey:@"data"];
                
                if (dataArray.count >= 10) {
                    [weakSelf.dataSource addObjectsFromArray:dataArray];
                    [weakSelf.tableView.mj_header endRefreshing];
                    [weakSelf.tableView.mj_footer endRefreshing];
                } else if (dataArray.count < 10 && dataArray.count != 0) {
                    [weakSelf.dataSource addObjectsFromArray:dataArray];
                    [weakSelf.tableView.mj_header endRefreshing];
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                } else {
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                }
                
                
            }
            else if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"202"]) { // 暂无数据
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                [weakSelf.tableView.mj_header endRefreshing];
            }
            else {
                [self.view showError:dictionary[@"msg"]];
            }
            
            [self setRequestFiledView];
            [weakSelf.tableView reloadData];
            
        } failure:^(NSError * _Nonnull error) {
            [self.view showError:error.localizedDescription];
            [self setRequestFiledView];
            [weakSelf.tableView.mj_header endRefreshing];
            
        }];
    }
}

- (void)setRequestFiledView {
    
    if (self.dataSource.count == 0) {
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        //设置空白界面
        UIView *blankBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
        UIImageView *logoImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-120)/2, 100, 120, 100)];
        logoImg.image = [UIImage imageNamed:@"ic_no_events"];
        [blankBg addSubview:logoImg];
        UILabel *warnMsg = [[UILabel alloc]initWithFrame:CGRectMake(30, logoImg.bottom, kScreenWidth-60, 80)];
        warnMsg.numberOfLines = 2;
//        warnMsg.text = @"下拉可以刷新哦~";
        warnMsg.textColor = [UIColor colorWithWhite:0.5 alpha:1.000];
        warnMsg.font = [UIFont systemFontOfSize:16];
        warnMsg.textAlignment = NSTextAlignmentCenter;
        [blankBg addSubview:warnMsg];
        [self.tableView setTableHeaderView:blankBg];
        [self.tableView.mj_header endRefreshing];
        
    } else {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        view.backgroundColor = [UIColor clearColor];
        self.tableView.tableHeaderView = view;
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    return [tableView fd_heightForCellWithIdentifier:identyfy configuration:^(id cell) {
//        [self configCell:cell indexpath:indexPath];
//    }];
//    
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HLFindSoundCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLFindSoundCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [cell.headImgV sd_setImageWithURL:[NSURL URLWithString:self.dataSource[indexPath.row][@"head"]]];
    cell.nameLab.text = self.dataSource[indexPath.row][@"nickname"];
    cell.ageLab.text = [NSString stringWithFormat:@"   %@岁   ",self.dataSource[indexPath.row][@"age"]];
    cell.dataDic = self.dataSource[indexPath.row];
    cell.secondLab.text = [NSString stringWithFormat:@"%@\"",self.dataSource[indexPath.row][@"sec"]];
    cell.contentLab.text = self.dataSource[indexPath.row][@"txt"];
    cell.timeLab.text = self.dataSource[indexPath.row][@"time"];
    
    
    cell.likeBtn.selected = [self.dataSource[indexPath.row][@"mylabel"] boolValue];
    [cell.likeBtn setTitle:[NSString stringWithFormat:@" %@",self.dataSource[indexPath.row][@"likes"]] forState:UIControlStateNormal];
    
    NSInteger wid = [self setupVoiceSize:self.dataSource[indexPath.row][@"sec"]];
    
    [cell.recordBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(wid);
    }];
    
    [self configCell:cell indexpath:indexPath];
    
    cell.indexPath = indexPath;
    cell.delegate = self;
    
    return cell;
}

- (void)deleteButtonClick:(NSString *)vwid {
    
    
    UIAlertController *alertAC =  [UIAlertController alertControllerWithTitle:@"确认删除吗?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *ensure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSDictionary *params = @{
            @"uid":[LoginManager defaultManager].userid,
            @"vwid":vwid
        };
        
        
        [HLHTTPSessionManager postDataWithNSString:@"/album/dle_voice_wall" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
            
            if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
                
                [self loadNewData];
                
            } else {
                
                
            }

        } failure:^(NSError * _Nonnull error) {

        }];
        
        
    }];
    [alertAC addAction:cancel];
    [alertAC addAction:ensure];
    [self presentViewController:alertAC animated:YES completion:nil];
    
}

- (NSInteger)setupVoiceSize:(NSNumber *)timeduration {
    
    NSInteger voiceBubbleWidth = 0;
    NSInteger duration = [timeduration integerValue];
    
    if (duration <= 2) {
      voiceBubbleWidth = 115;
    } else if (duration >2 && duration <=20) {
      voiceBubbleWidth = 120 + 2.5 * duration;
    } else if (duration > 20 && duration < 30){
      voiceBubbleWidth = 150 + 2 * (duration - 20);
    } else if (duration >=30  && duration < 60) {
      voiceBubbleWidth = 170 + 1 * (duration - 30);
    } else {
      voiceBubbleWidth = 250;
    }
    
    return voiceBubbleWidth;
    
}

- (void)configCell:(HLFindSoundCell *)cell indexpath:(NSIndexPath *)indexpath {
    
    [cell.tagView removeAllTags];
    cell.tagView.preferredMaxLayoutWidth = kScreenWidth-79;
    cell.tagView.padding = UIEdgeInsetsMake(0, 0, 0, 0);
    cell.tagView.lineSpacing = 12;
    cell.tagView.interitemSpacing = 12;
    cell.tagView.singleLine = NO;
    // 给出两个字段，如果给的是0，那么就是变化的,如果给的不是0，那么就是固定的
//        cell.tagView.regularWidth = 80;
        cell.tagView.regularHeight = 25;
    
    NSArray *arr = self.dataSource[indexpath.row][@"label"];
    
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        SKTag *tag = [[SKTag alloc] initWithText:arr[idx]];
        tag.font = [UIFont systemFontOfSize:12];
        tag.textColor = kRGBA(188, 96, 255, 1);
        tag.bgColor = kRGBA(251, 240, 255, 1);
        tag.cornerRadius = 12.5;
        tag.enable = YES;
        tag.padding = UIEdgeInsetsMake(5, 10, 5, 10);
        [cell.tagView addTag:tag];
        
    }];
    
    cell.tagView.didTapTagAtIndex = ^(NSUInteger index, UIButton *btn)
    {
        NSLog(@"点击了%ld",index);
    };
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
    detailVC.hidesBottomBarWhenPushed = YES;
    NSDictionary *dic = self.dataSource[indexPath.row];
    detailVC.userId = dic[@"uid"];
    detailVC.nickName = dic[@"nickname"];
    detailVC.refreshBlock  = ^{
        NSLog(@"非移除类操作~~~~~~~");
    };
    detailVC.removeBlock = ^{
        
        [self.dataSource removeObject:self.dataSource[indexPath.row]];
        
        [self.tableView reloadData];
        
    };
    [self.navigationController pushViewController:detailVC animated:YES];
    
}


#pragma mark - JXCategoryListContentViewDelegate

- (UIView *)listView {
    return self.view;
}

- (UIScrollView *)listScrollView {
    return self.tableView;
}

/**
 可选实现，列表消失的时候调用
 */
- (void)listDidDisappear {
    [[LGAudioPlayer shareInstance] stopPlaying];
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
