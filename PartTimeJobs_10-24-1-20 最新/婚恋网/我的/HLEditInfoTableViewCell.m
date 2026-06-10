//
//  HLEditInfoTableViewCell.m
//  婚恋网
//
//  Created by iMac on 2019/5/15.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLEditInfoTableViewCell.h"

@interface HLEditInfoTableViewCell ()



@property (weak, nonatomic) IBOutlet UILabel *contentLable;

@end

@implementation HLEditInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
// 编辑用户信息
- (void)setTitleLableText:(NSString *)title withHLUserInfo:(HLUser *)userModel withCurrentIndex:(NSIndexPath *)indexPath{
    self.titleLable.text = title;
    switch (indexPath.row) {
        case 0:
//            self.contentLable.text = userModel.nickname;
//            self.redImgView.hidden = kISNullString(userModel.nickname) ? NO : YES;
            self.redImgView.hidden = YES;
            break;
        case 1:
            self.contentLable.text = userModel.nickname;
            self.redImgView.hidden = kISNullString(userModel.nickname) ? NO : YES;
            break;
//        case 2:
//            self.contentLable.text = userModel.age;
//            self.redImgView.hidden = kISNullString(userModel.age) ? NO : YES;
//            break;
        case 2:
            self.contentLable.text = userModel.habitation;
            self.redImgView.hidden = kISNullString(userModel.habitation) ? NO : YES;
            break;
//        case 2:
//            self.contentLable.text = userModel.earns;
//            self.redImgView.hidden = kISNullString(userModel.earns) ? NO : YES;
//            break;
//        case 3:
//            self.contentLable.text = userModel.height;
//            self.redImgView.hidden = kISNullString(userModel.height) ? NO : YES;
//            break;
//        case 4:
//            self.contentLable.text = userModel.weight;
//            self.redImgView.hidden = kISNullString(userModel.weight) ? NO : YES;
//            break;
//        case 5:
//            self.contentLable.text = userModel.education;
//            self.redImgView.hidden = kISNullString(userModel.education) ? NO : YES;
//            break;
//        case 6:
//            self.contentLable.text = userModel.industry;
//            self.redImgView.hidden = kISNullString(userModel.industry) ? NO : YES;
//            break;
//        case 7:
//            self.contentLable.text = userModel.housing;
//            self.redImgView.hidden = kISNullString(userModel.housing) ? NO : YES;
//            break;
//        case 8:
//            self.contentLable.text = userModel.car;
//            self.redImgView.hidden = kISNullString(userModel.car) ? NO : YES;
//            break;
//        case 9:
//            self.contentLable.text = userModel.registered; // 户口
//            self.redImgView.hidden = kISNullString(userModel.registered) ? NO : YES;
//            break;
//        case 10:
//            self.contentLable.text = userModel.native;
//            self.redImgView.hidden = kISNullString(userModel.native) ? NO : YES;
//            break;
//        case 11:
//            self.contentLable.text = userModel.nation;
//            self.redImgView.hidden = kISNullString(userModel.nation) ? NO : YES;
//            break;
//        case 12:
//            self.contentLable.text = userModel.school;
//            self.redImgView.hidden = kISNullString(userModel.school) ? NO : YES;
//            break;
//        case 13:
//            self.contentLable.text = userModel.company;
//            self.redImgView.hidden = kISNullString(userModel.company) ? NO : YES;
//            break;
//        case 14:
//            self.contentLable.text = userModel.position;
//            self.redImgView.hidden = kISNullString(userModel.position) ? NO : YES;
//            break;
//        case 15:
//            self.contentLable.text = userModel.marital;
//            self.redImgView.hidden = kISNullString(userModel.marital) ? NO : YES;
//            break;
//        case 16:
//            self.contentLable.text = userModel.children;
//            self.redImgView.hidden = kISNullString(userModel.children) ? NO : YES;
//            break;
//        case 17:
//            self.contentLable.text = userModel.blood;
//            self.redImgView.hidden = kISNullString(userModel.blood) ? NO : YES;
//            break;
        default:
            break;
    }
}

- (void)setBaseinfoText:(NSString *)title withHLUserInfo:(HLUser *)userModel withCurrentIndex:(NSIndexPath *)indexPath{
//    self.titleLable.text = title;
    self.nextImageView.hidden = YES;
    self.redImgView.hidden = YES;
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: // 年龄
                self.contentLable.text = userModel.age;
                break;
            case 1: // 居住地
                self.contentLable.text = userModel.habitation;
                break;
            case 2: // 收入
                self.contentLable.text = userModel.earns;
                break;
            case 3: // 身高
                self.contentLable.text = userModel.height;
                break;
            case 4: // 体重
                self.contentLable.text = userModel.weight;
                break;
            case 5: // 学历
                self.contentLable.text = userModel.education;
                break;
            case 6: // 行业
                self.contentLable.text = userModel.industry;
                break;
            case 7: // 住房
                self.contentLable.text = userModel.housing;
                break;
            case 8: // 车
                self.contentLable.text = userModel.car;
                break;
            case 9: // 户口
                self.contentLable.text = userModel.registered;
                break;
            case 10: // 籍贯
                self.contentLable.text = userModel.native;
                break;
            case 11: // 民族
                self.contentLable.text = userModel.nation;
                break;
            case 12: // 毕业院校
                self.contentLable.text = userModel.school;
                break;
            case 13: // 单位
                self.contentLable.text = userModel.company;
                break;
            case 14: // 职位
                self.contentLable.text = userModel.position;
                break;
            case 15: // 婚姻状况
                self.contentLable.text = userModel.marital;
                break;
            case 16: // 子女
                self.contentLable.text = userModel.children;
                break;
            case 17: // 属相
                self.contentLable.text = userModel.animals;
                break;
            case 18: // 星座
                self.contentLable.text = userModel.constellation;
                break;
            case 19: // 血型
                self.contentLable.text = userModel.blood;
                break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
                self.contentLable.text = userModel.marital;
                break;
            case 1:
                self.contentLable.text = userModel.animals;
                break;
            case 2:
                self.contentLable.text = userModel.constellation;
                break;
            
            default:
                break;
        }
    }
}

// 编辑交友信息
- (void)setFriendTitleLableText:(NSString *)title withHLUserInfo:(HLFriendModel *)frindModel withCurrentIndex:(NSIndexPath *)indexPath{
    self.titleLable.text = title;
    self.redImgView.hidden = YES;
    switch (indexPath.row) {
        case 0:
            self.contentLable.text = frindModel.f_age;
//            self.redImgView.hidden = [frindModel.f_age isEqualToString:@"18岁-不限"] ? NO : YES;
            break;
        case 1:
            self.contentLable.text = frindModel.f_habitation;
//            self.redImgView.hidden = [frindModel.f_habitation isEqualToString:@"不限"] ? NO : YES;
            break;
        case 2:
            self.contentLable.text = frindModel.f_income;
//            self.redImgView.hidden = [frindModel.f_income isEqualToString:@"不限"] ? NO : YES;
            break;
        case 3:
            self.contentLable.text = frindModel.f_height;
//            self.redImgView.hidden = [frindModel.f_height isEqualToString:@"不限-不限"] ? NO : YES;
            break;
        case 4:
            self.contentLable.text = frindModel.f_education;
//            self.redImgView.hidden = [frindModel.f_education isEqualToString:@"不限"] ? NO : YES;
            break;
        default:
            break;
    }
}


- (void)setTitleLableText:(NSString *)title withContent:(NSString *)conetent{
    self.redImgView.hidden = YES;
    self.titleLable.text = title;
    self.contentLable.text = conetent;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
