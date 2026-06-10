//
//  CSCoachDetailDescriptCell.m
//  hongdou
//
//  Created by 李龙 on 2020/3/15.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "CSCoachDetailDescriptCell.h"
#import "DetailDescTool.h"

@interface CSCoachDetailDescriptCell ()
@property (weak, nonatomic) IBOutlet UILabel *lab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labHeight;

@property (nonatomic,strong) NSString *contentString;
@property (nonatomic,strong) NSString *fixedText;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation CSCoachDetailDescriptCell

-(void)setDicinfo:(NSDictionary *)dicinfo{
    
    _dicinfo = dicinfo;
    self.lab.text = _dicinfo[@"content"];
    BOOL flage = [self infocount:self.lab];
    
    if (flage) {
        if ([_dicinfo[@"isChoice"] isEqualToString:@"NO"]) {
            NSInteger theRange = self.contentString.length-self.fixedText.length+3;
            self.lab.attributedText = [DetailDescTool theRichText:self.contentString theRange:theRange changeRange:4 color:[UIColor grayColor]];
            self.labHeight.constant =0;
        }else{
            self.labHeight.constant =25;
        }
    }else{
        self.labHeight.constant =0;
        self.lab.text = _dicinfo[@"content"];
    }
}

- (BOOL)infocount:(UILabel *)lable{
    
    NSArray *stringArr = [DetailDescTool getLinesArrayOfStringInLabel:lable];
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:stringArr];
    
    if (arr.count > 0) {
        if ([arr[0] isEqualToString:@"\r\n"]) {
            [arr removeObjectAtIndex:0];
        }
    }
    
    if (arr.count > 2) {
        NSString *string1 = arr[0];
        NSString *string2 = arr[1];
        self.fixedText = @"...【展开】";
        NSString *string3 = [NSString stringWithFormat:@"%@%@",string2,self.fixedText];

        if (string3.length > string1.length) {
            NSInteger len = string3.length - string1.length;
            string2 = [string2 substringToIndex:string2.length-len-4];
            string2 = [NSString stringWithFormat:@"%@%@",string2,self.fixedText];
        }
        self.contentString = [NSString stringWithFormat:@"%@%@",string1,string2];
        return YES;
    }

    return NO;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.containerView.backgroundColor = kRGBA(245, 245, 245, 1);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
