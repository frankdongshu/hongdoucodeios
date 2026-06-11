//
//  HLComplaintMessageTableViewCell.m
//  hongdou
//
//  Created by iMac on 2019/10/22.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLComplaintMessageTableViewCell.h"

@implementation HLComplaintMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    NSLog(@"开始编辑");
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    NSLog(@"结束编辑");
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (range.location==0) {
        self.planceLabel.hidden = NO;
    }
    if (text.length>0) {
        self.planceLabel.hidden = YES;
        
    }
    return YES;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.inputTextView.isFirstResponder) {
        [self.inputTextView resignFirstResponder];
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
