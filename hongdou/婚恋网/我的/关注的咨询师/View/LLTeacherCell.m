//
//  LLTeacherCell.m
//  hongdou
//
//  Created by 李龙 on 2020/4/9.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLTeacherCell.h"

@interface LLTeacherCell ()
@property (nonatomic, strong) UILabel *namelabel;
@property (nonatomic, strong) UIImageView *sexImageView;

@property (nonatomic, strong) UILabel *schoolLabel;
@property (nonatomic, strong) UILabel *positionLabel;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) CSCoachMajorView *maiorView;
@property (nonatomic, strong) CSCoachMajorView *eduView;

@property (nonatomic, strong) UILabel *attentionLabel;
@property (nonatomic, strong) UIButton *connectBtn;
@property (nonatomic, strong) UIButton *attentionBtn;

@property (nonatomic, strong) UIView *bottomLineView;

@end

@implementation LLTeacherCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;

}

-(void)setType:(ListType)type{
    _type = type;
    [self addViews];
    [self layoutView];

}

#pragma mark - set
-(void)setInfoModel:(LLTeatherModel *)infoModel{
    _infoModel = infoModel;
    self.namelabel.text = _infoModel.nickname;
    
    if ([infoModel.gender isEqualToString:@"女"]) {
        self.sexImageView.image = [UIImage imageNamed:@"nvsheng_ico"];
    }
    
    self.schoolLabel.text = [NSString stringWithFormat:@"%@岁",infoModel.age];
    self.positionLabel.text = _infoModel.height;
    self.maiorView.titleString = _infoModel.habitation;
    self.eduView.titleString = _infoModel.education;
    
    if (_type == FollowType) {
        self.attentionLabel.text = @"已关注";
    } else if (_type == BlackPushType) {
        self.attentionLabel.text = @"取消";
    }
    else if (_type == CoachDetailType){
        
    } else{
//        self.connectBtn.selected = _infoModel.connect;
//        self.attentionBtn.selected = _infoModel.follow;
    }

}

#pragma mark - UI
-(void)addViews{
    [self.contentView addSubview:self.namelabel];
    [self.contentView addSubview:self.sexImageView];
    [self.contentView addSubview:self.schoolLabel];
    [self.contentView addSubview:self.positionLabel];
    [self.contentView addSubview:self.lineView];
    
    [self.contentView addSubview:self.maiorView];
    [self.contentView addSubview:self.eduView];
    if (_type == FollowType || _type == BlackPushType) {
        [self.contentView addSubview:self.attentionLabel];
    }else if (_type == CoachDetailType){
        
    }else{
        [self.contentView addSubview:self.attentionBtn];
        [self.contentView addSubview:self.connectBtn];
    }
    [self.contentView addSubview:self.bottomLineView];

}

-(void)layoutView{
    [self.namelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).mas_offset(20);
        make.top.equalTo(self.contentView.mas_top).mas_offset(20);
        
    }];
    
    [self.sexImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.namelabel.mas_right).mas_offset(10);
        make.centerY.equalTo(self.namelabel.mas_centerY);
        make.width.height.equalTo(@(15));
    }];
    
    [self.schoolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).mas_offset(20);
        make.top.equalTo(self.namelabel.mas_bottom).mas_offset(10);
    }];

    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.schoolLabel.mas_right).mas_offset(10);
        make.centerY.equalTo(self.schoolLabel.mas_centerY);
        make.height.equalTo(@(15));
        make.width.equalTo(@(1));
    }];

    [self.positionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lineView.mas_right).mas_offset(10);
        make.centerY.equalTo(self.schoolLabel.mas_centerY);
    }];

    [self.maiorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).mas_offset(20);
        make.top.equalTo(self.schoolLabel.mas_bottom).mas_offset(10);
    }];
    [self.eduView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.maiorView.mas_right).mas_offset(10);
        make.centerY.equalTo(self.maiorView.mas_centerY);
        if (_type == CoachDetailType) {
            make.bottom.equalTo(self.contentView.mas_bottom).mas_offset(-10);
        }
    }];
    if (_type == FollowType || _type == BlackPushType) {
        [self.attentionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).mas_offset(-20);
            make.top.equalTo(self.maiorView.mas_bottom).mas_offset(10);
            make.width.equalTo(@(60));
            make.height.equalTo(@(25));
        }];
        
        [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.attentionLabel.mas_bottom).mas_offset(10);
            make.right.equalTo(self.contentView.mas_right).mas_offset(-20);
            make.left.equalTo(self.contentView.mas_left).mas_offset(20);
            make.height.equalTo(@(1));
            make.bottom.equalTo(self.contentView.mas_bottom);
        }];

    }else if (_type == CoachDetailType){
        
    }else{
        [self.connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).mas_offset(-20);
            make.top.equalTo(self.maiorView.mas_bottom).mas_offset(10);
            make.width.equalTo(@(80));
            make.height.equalTo(@(30));

        }];
        
        [self.attentionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.connectBtn.mas_left).mas_offset(-20);
            make.top.equalTo(self.maiorView.mas_bottom).mas_offset(10);
            make.width.equalTo(@(80));
            make.height.equalTo(@(30));
        }];
        
        [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.connectBtn.mas_bottom).mas_offset(10);
            make.right.equalTo(self.contentView.mas_right).mas_offset(-20);
            make.left.equalTo(self.contentView.mas_left).mas_offset(20);
            make.height.equalTo(@(1));
            make.bottom.equalTo(self.contentView.mas_bottom);
        }];

    }


}


#pragma mark - lazy
-(UILabel *)namelabel{
    if (_namelabel == nil) {
        _namelabel = [[UILabel alloc]init];
        _namelabel.textColor = [UIColor blackColor];
        _namelabel.font = [UIFont systemFontOfSize:18];
        [_namelabel sizeToFit];
    }
    return _namelabel;
}

-(UILabel *)schoolLabel{
    if (_schoolLabel == nil) {
        _schoolLabel = [[UILabel alloc]init];
        _schoolLabel.textColor = [UIColor grayColor];
        _schoolLabel.font = [UIFont systemFontOfSize:14];

        [_schoolLabel sizeToFit];
    }
    return _schoolLabel;
}

-(UILabel *)positionLabel{
    if (_positionLabel == nil) {
        _positionLabel = [[UILabel alloc]init];
        _positionLabel.textColor = [UIColor grayColor];
        _positionLabel.font = [UIFont systemFontOfSize:14];
        [_positionLabel sizeToFit];
    }
    return _positionLabel;
}

-(UILabel *)attentionLabel{
    if (_attentionLabel == nil) {
        _attentionLabel = [[UILabel alloc]init];
        _attentionLabel.textColor = [UIColor darkGrayColor];
        [_attentionLabel sizeToFit];
        _attentionLabel.layer.borderColor =HEXColor(@"ececec").CGColor;
        _attentionLabel.layer.borderWidth = 1;
        _attentionLabel.layer.cornerRadius = 3;
        _attentionLabel.layer.masksToBounds = YES;
        _attentionLabel.font = [UIFont systemFontOfSize:14];
        _attentionLabel.textAlignment = NSTextAlignmentCenter;
        _attentionLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView:)];
        
        [_attentionLabel addGestureRecognizer:tap];
        
    }
    return _attentionLabel;
}

- (void)tapView:(UITapGestureRecognizer *)sender{
    
    UILabel *lab = (UILabel *)sender.view;
    
    if ([lab.text isEqualToString:@"取消"]) {
        self.connectBlock(self.row, 0);
    } else {
        self.attentionBlock(self.row, 0);
    }
    
}

-(UIImageView *)sexImageView{
    if (_sexImageView == nil) {
        _sexImageView = [[UIImageView alloc]init];
    }
    return _sexImageView;
}

-(CSCoachMajorView *)maiorView{
    if (_maiorView == nil) {
        _maiorView = [[CSCoachMajorView alloc]init];
        _maiorView.backgroundColor = HEXColor(@"ff8888");
        _maiorView.layer.borderColor =REDColor.CGColor;
        _maiorView.layer.borderWidth = 1;
        _maiorView.layer.cornerRadius = 3;
        _maiorView.layer.masksToBounds = YES;
    }
    return _maiorView;
}

-(CSCoachMajorView *)eduView{
    if (_eduView == nil) {
        _eduView = [[CSCoachMajorView alloc]init];
        _eduView.backgroundColor = HEXColor(@"ff8888");
        _eduView.layer.borderColor =REDColor.CGColor;
        _eduView.layer.borderWidth = 1;
        _eduView.layer.cornerRadius = 3;
        _eduView.layer.masksToBounds = YES;
    }
    return _eduView;
}

-(UIView *)bottomLineView{
    if (_bottomLineView == nil) {
        _bottomLineView = [[UIView alloc]init];
        _bottomLineView.backgroundColor = HEXColor(@"ececec");
    }
    return _bottomLineView;
}

-(UIView *)lineView{
    if (_lineView == nil) {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = HEXColor(@"ececec");
    }
    return _lineView;
}


-(UIButton *)connectBtn{
    if (_connectBtn == nil) {
        _connectBtn = [[UIButton alloc]init];
        [_connectBtn setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
        [_connectBtn setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateSelected];
        [_connectBtn setTitle:@"沟通" forState:UIControlStateNormal];
        [_connectBtn setTitle:@"已沟通" forState:UIControlStateSelected];
        [_connectBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_connectBtn setTitleColor:REDColor forState:UIControlStateSelected];
        _connectBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _connectBtn.tag = 101;
        [_connectBtn addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _connectBtn;
}

-(UIButton *)attentionBtn{
    if (_attentionBtn == nil) {
        _attentionBtn = [[UIButton alloc]init];
        [_attentionBtn setImage:[UIImage imageNamed:@"like_normal"] forState:UIControlStateNormal];
        [_attentionBtn setImage:[UIImage imageNamed:@"like_selected"] forState:UIControlStateSelected];
        [_attentionBtn setTitle:@"关注" forState:UIControlStateNormal];
        [_attentionBtn setTitle:@"已关注" forState:UIControlStateSelected];
        [_attentionBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_attentionBtn setTitleColor:REDColor forState:UIControlStateSelected];
        _attentionBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _attentionBtn.tag = 100;
        [_attentionBtn addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _attentionBtn;
}

-(void)attentionAction:(UIButton *)btn{
    if (btn.tag == 100) {
        if (btn.selected == NO) {
//            [NetworkApi postCustomerFollowWithcid:_infoModel.ID WithDefaultResponse:^(id  _Nullable operation, NSError * _Nullable error) {
//                btn.selected = !btn.selected;
//                self.attentionBlock(self.row, 1);
//            }];

        }else{
//            [NetworkApi postCustomerCancelfollowWithcid:_infoModel.ID WithDefaultResponse:^(id  _Nullable operation, NSError * _Nullable error) {
//                btn.selected = !btn.selected;
//                self.attentionBlock(self.row, 0);
//            }];
            
        }
    }
    
    if (btn.tag == 101) {
        self.connectBlock(_row, btn.selected);
    }
}


@end


@interface  CSCoachMajorView ()
@property (nonatomic, strong) UILabel *showLabel;

@end
@implementation CSCoachMajorView
-(instancetype)init{
    self = [super init];
    if (self) {
        [self addSubview:self.showLabel];
        [self.showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).mas_offset(5);
            make.bottom.equalTo(self.mas_bottom).mas_offset(-5);
            make.left.equalTo(self.mas_left).mas_offset(20);
            make.right.equalTo(self.mas_right).mas_offset(-20);
        }];
    }
    return self;
}

-(void)setTitleString:(NSString *)titleString{
    _titleString = titleString;
    self.showLabel.text = _titleString;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - lazy
-(UILabel *)showLabel{
    if (_showLabel == nil) {
        _showLabel = [[UILabel alloc]init];
        _showLabel.textColor = REDColor;
        _showLabel.font = [UIFont systemFontOfSize:14];
        [_showLabel sizeToFit];
    }
    return _showLabel;
}

@end
