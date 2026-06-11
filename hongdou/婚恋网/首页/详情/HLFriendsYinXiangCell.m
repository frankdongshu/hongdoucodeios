//
//  HLFriendsYinXiangCell.m
//  hongdou
//
//  Created by 维康1 on 2019/12/17.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLFriendsYinXiangCell.h"
#import "LXTagsView.h"

@interface HLFriendsYinXiangCell ()

@property (nonatomic ,strong)LXTagsView *tagsView;

@property (nonatomic ,strong)UIView *container;

@end

@implementation HLFriendsYinXiangCell

-(void)setItems:(NSArray *)items{
    _items = items;
    
    self.tagsView.dataA = items;
    [self.contentView layoutIfNeeded];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.tagsView =[[LXTagsView alloc] init];
//    self.tagsView.layer.borderWidth = 1;
//    self.tagsView.layer.borderColor = [UIColor redColor].CGColor;
    [self.contentView addSubview:self.tagsView];

    [self.tagsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.contentView);
    }];
    
    self.tagsView.tagClick = ^(NSString *tagTitle) {
        NSLog(@"cell打印---%@",tagTitle);
    };
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
