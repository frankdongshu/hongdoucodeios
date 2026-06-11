//
//  CSMySettingViewController.m
//  CSPartTimeJobs
//
//  Created by 这是一个笑脸 on 2019/7/20.
//  Copyright © 2019 FangPursuit. All rights reserved.
//

#import "CSMySettingViewController.h"

@interface CSMySettingViewController ()<UITableViewDataSource,UITableViewDelegate>
/**视图**/
//列表视图
@property (nonatomic, strong) UITableView *tableView;
//行标题
@property (nonatomic, strong) NSArray *titleArr;
@end

@implementation CSMySettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.sc_navigationBar.title = @"设置";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self sc_setNavigationBarBackgroundAlpha:0];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    [self initObjects];
    [self createUI];
    // Do any additional setup after loading the view.
}

- (void)initObjects{
    _titleArr = @[@"清除缓存",@"检查更新"];
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _titleArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger row = indexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCellID"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = kFontSize(13);
    cell.textLabel.text = _titleArr[row];
    if (row == 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fM",[self getCachSize]];
    }
    if(row == 1) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"V%@",[self SystemVersion]];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger row = indexPath.row;
    
    switch (row) {
        case 0:
            //清除缓存
            [self clearAnyeLocalCache];
            [self.tableView reloadData];
            break;
        case 1:
            //检查更新
            [self requestServerAppUpdate];
            break;
            
        default:
            break;
    }
}

//清除缓存
-(void)clearAnyeLocalCache {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask,YES);
    NSString *path = [paths lastObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childrenFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childrenFiles) {
            // 拼接路径
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            // 将文件删除
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
    //SDWebImage的清除功能
    [[SDImageCache sharedImageCache] clearMemory];
}

- (CGFloat)getCachSize {
    
    NSUInteger imageCacheSize = [[SDImageCache sharedImageCache] getSize];
    
    //获取自定义缓存大小
    
    //用枚举器遍历 一个文件夹的内容
    
    //1.获取 文件夹枚举器
    
    NSString *myCachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]enumeratorAtPath:myCachePath];
    
    __block NSUInteger count =0;
    
    //2.遍历
    
    for(NSString *fileName in enumerator) {
        
        NSString *path = [myCachePath stringByAppendingPathComponent:fileName];
        
        NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        
        count += fileDict.fileSize;//自定义所有缓存大小
        
    }
    
    // 得到是字节  转化为M
    CGFloat totalSize = ((CGFloat)imageCacheSize + count)/1024/1024;
    return totalSize;
}

- (NSString *)SystemVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return app_Version;
}


#pragma mark - Config UI

- (void)createUI{
    
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView{
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight/2) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        // 去掉多余分割线
        self.tableView.tableFooterView = [[UIView alloc] init];
    }
    
    return _tableView;
}


#pragma mark - requestServer

- (void)requestServerAppUpdate {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/id%@",@"1485694517"]];
    [[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionsSourceApplicationKey : @YES} completionHandler:^(BOOL success) {
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
