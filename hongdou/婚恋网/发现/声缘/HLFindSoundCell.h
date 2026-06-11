//
//  HLFindSoundCell.h
//  hongdou
//
//  Created by 李龙 on 2021/12/11.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"
#import "SKTagView.h"
#import "LGAudioPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HLFindSoundCellDelegate <NSObject>

- (void)photoButtonClick:(NSInteger)tage withIndexPath:(NSIndexPath *)indexPath andIsLike:(BOOL)islike;

- (void)deleteButtonClick:(NSString *)vwid;

@end

@interface HLFindSoundCell : HXBaseTableViewCell

@property (nonatomic, assign) id <HLFindSoundCellDelegate>delegate;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, assign) CGFloat cellHight;

@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet UILabel *ageLab;
@property (weak, nonatomic) IBOutlet SKTagView *tagView;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIView *recordBgView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *secondLab;
@property (weak, nonatomic) IBOutlet UIImageView *voiceAnimationImageView;

@property (nonatomic, strong) NSDictionary *dataDic;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@end

NS_ASSUME_NONNULL_END
