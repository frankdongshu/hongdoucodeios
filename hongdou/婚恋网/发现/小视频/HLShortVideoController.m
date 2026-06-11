//
//  HLShortVideoController.m
//  hongdou
//
//  Created by 李龙 on 2021/12/19.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLShortVideoController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPSessionManager.h>
//#import <SVProgressHUD/SVProgressHUD.h>
//#import <SDWebImage/UIImageView+WebCache.h>
//#import "Movie.h"
#import "HLShortVideoComplainController.h"
#import "HLShortVedeoPopView.h"

#define VideoV self.playerList[idx]

@interface HLShortVideoController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger indexNum;
    NSInteger oldNum;
    NSInteger oldY;
    
    int page;
    
    NSInteger screenHeight;
    NSURL * videoUrl;
    BOOL isPlaying;
}

@property (nonatomic, strong) UITableView * tableview;
@property (nonatomic, strong) NSMutableArray * arr;
@property (nonatomic, strong) AVPlayer * avplayer;
@property (nonatomic, strong) AVPlayerItem * avPlayerItem;
@property (nonatomic, strong) AVPlayerLayer * avView;
@property (nonatomic, strong) NSMutableArray<AVPlayerItem *> * itemArr;
@property (nonatomic, strong) UIImageView * imageV;
@property (nonatomic, strong) UIImageView   * playOrStop; //开始暂停

@property (nonatomic, strong) UIView *floatView;

@end

@implementation HLShortVideoController

- (UIView *)floatView {
    if (!_floatView) {
        _floatView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth-130, self.tableview.height-100, 120, 40)];
        _floatView.backgroundColor = [UIColor colorWithWhite:1 alpha:.7];
        _floatView.layer.cornerRadius = 8;
        _floatView.layer.masksToBounds = YES;
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"icon_fenxiang"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(20, 5, 30, 30);
        
        [_floatView addSubview:btn];
        
        
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn1 setBackgroundImage:[UIImage imageNamed:@"icon_keybord"] forState:UIControlStateNormal];
        [btn1 addTarget:self action:@selector(juBaoClick) forControlEvents:UIControlEventTouchUpInside];
        btn1.frame = CGRectMake(CGRectGetMaxX(btn.frame)+20, 5, 30, 30);
        
        [_floatView addSubview:btn1];
        
    }
    return _floatView;
}

- (void)shareClick {
    
    HLShortVideoComplainController *vc = [[HLShortVideoComplainController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)juBaoClick {
    
    HLShortVedeoPopView *aView = [HLShortVedeoPopView initWithXib:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    NSDictionary * dic = self.arr[indexNum];
    
    aView.vid = [dic[@"id"] stringValue];
    
    aView.SelectBlock = ^{
        
    };
    
    [aView showSelf];
    
}

- (UIImageView *)imageV{
    if (!_imageV) {
        _imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight-kTabBarHeight)];
    }
    return _imageV;
}
- (AVPlayerItem *)avPlayerItem{
    if (!_avPlayerItem) {
        NSDictionary * dic = self.arr[indexNum];
        _avPlayerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:dic[@"video"]]];
        [_avPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _avPlayerItem;
}
- (AVPlayerLayer *)avView{
    if (!_avView) {
        _avView = [AVPlayerLayer playerLayerWithPlayer:self.avplayer];
        _avView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight-kTabBarHeight);
        _avView.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    return _avView;
}
- (AVPlayer *)avplayer{
    if (!_avplayer) {
        _avplayer = [[AVPlayer alloc] initWithPlayerItem:self.avPlayerItem];
    }
    return _avplayer;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    self.arr = [[NSMutableArray alloc] init];
    self.itemArr = [[NSMutableArray alloc] init];
    
    _imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight-kTabBarHeight)];
    
    indexNum = 0;
    oldNum = 0;
    oldY = 0;
    
    page = 1;
    
    screenHeight = kScreenHeight -kNavigationBarHeight-kTabBarHeight;
    isPlaying = YES;
    
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight-kTabBarHeight)];
    _tableview.dataSource = self;
    _tableview.delegate = self;
    //开启分页滑动
    _tableview.pagingEnabled = YES;
    _tableview.estimatedRowHeight = 0;
    _tableview.estimatedSectionFooterHeight = 0;
    _tableview.estimatedSectionHeaderHeight = 0;
    if (@available(iOS 11.0, *)) {
        [_tableview setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    [self.view addSubview:_tableview];
    
    [self getdata];
    
    [self.view addSubview:self.floatView];
    
}
-(void)getdata{
    
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"page":@(page)
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/album/videoList" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        [self.tableView.mj_header endRefreshing];
        
        NSLog(@"~~~: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            NSArray *arr = dictionary[@"data"];
            
            for (int i = 0; i < arr.count; i++) {
                NSDictionary * dic = arr[i];
                [self.arr addObject:dic];
                AVPlayerItem * item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:dic[@"video"]]];
                [self.itemArr addObject:item];
            }
            
            self->page++;
            
            [self.tableview reloadData];
            
        } else {
            [self.view showTitle:dictionary[@"msg"]];
        }

        

    } failure:^(NSError * _Nonnull error) {

        [self.view showErrorWithMessage:[error localizedDescription]];

    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kScreenHeight -kNavigationBarHeight-kTabBarHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = 0;
    cell.backgroundColor = [UIColor blackColor];
    //    Movie * mo = _arr[indexPath.row];
    if (indexPath.row == indexNum) {
        [cell.layer addSublayer:self.avView];
    }
    else{
        [cell addSubview:self.imageV];
        //        self.imageV.image = [self getVideoFirstViewImage:[NSURL URLWithString:mo.cover]];
//        self.imageV.image = [UIImage imageNamed:@"video"];
    }
    
    [cell addSubview:self.playOrStop];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"%ld",indexPath.row);
    
    if (isPlaying) {
        isPlaying = NO;
        [self.avplayer pause];
        self.playOrStop.hidden = NO;
    } else {
        isPlaying = YES;
        [self.avplayer play];
        self.playOrStop.hidden = YES;
    }
    
    
}

- (UIImageView *)playOrStop{
    if (_playOrStop == nil) {
        _playOrStop = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth/2-50, self.tableview.frame.size.height/2-50, 100, 100)];
        _playOrStop.image = [UIImage imageNamed:@"sound_ play"];
        _playOrStop.contentMode = UIViewContentModeScaleAspectFit;
        _playOrStop.hidden = YES;
    }
    return _playOrStop;
}

// 获取视频第一帧图片
//- (UIImage*)getVideoFirstViewImage:(NSURL *)path {
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
//    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//
//    assetGen.appliesPreferredTrackTransform = YES;
//    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
//    NSError *error = nil;
//    CMTime actualTime;
//    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
//    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
//    CGImageRelease(image);
//    return videoImage;
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (fabs(scrollView.contentOffset.y - oldY) > screenHeight) {
        if (_avplayer != nil) {
            NSLog(@"暂停");
            [self.avplayer pause];
            [self.avPlayerItem removeObserver:self forKeyPath:@"status"];
            [self.avView removeFromSuperlayer];
            self.avplayer = nil;
            self.avView = nil;
            self.avPlayerItem = nil;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollToScrollStop) {
        [self scrollViewDidEndScroll:scrollView.contentOffset.y];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (dragToDragStop) {
            [self scrollViewDidEndScroll:scrollView.contentOffset.y];
        }
    }
}

#pragma mark - scrollView 滚动停止
- (void)scrollViewDidEndScroll:(NSInteger)y {
    NSArray * array = [_tableview visibleCells];
    NSLog(@" ----- %@",array);
    UITableViewCell * cell = array[0];
    indexNum = [_tableview indexPathForCell:cell].row;
    if (indexNum == oldNum) {
        return;
    }
    oldNum = indexNum;
    oldY = indexNum * screenHeight;
    NSArray * ar = [NSArray arrayWithObjects:[_tableview indexPathForCell:cell],nil];
    //刷新单个cell
    [self.avplayer pause];
    [self.avPlayerItem removeObserver:self forKeyPath:@"status"];
    [self.avView removeFromSuperlayer];
    self.avplayer = nil;
    self.avView = nil;
    self.avPlayerItem = nil;
    [_tableview reloadRowsAtIndexPaths:ar withRowAnimation:UITableViewRowAnimationNone];
    
    //提前加载数据
    if (indexNum > self.arr.count - 3) {
        [self getdata];
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        switch (status) {
            case AVPlayerStatusReadyToPlay:
            {
                self.playOrStop.hidden = YES;
                [self.avplayer play];
            }
                break;
            default:
                break;
        }
    }
}

- (UIView *)listView {
    return self.view;
}

- (UIScrollView *)listScrollView {
    return self.tableView;
}

- (void)listDidDisappear {
    [self.avplayer pause];
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
