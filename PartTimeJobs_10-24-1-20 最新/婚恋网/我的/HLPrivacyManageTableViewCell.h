//
//  HLPrivacyManageTableViewCell.h
//  hongdou
//
//  Created by iMac on 2019/10/11.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"
#import "HLUser.h"

@protocol  HLPrivacyManageDeleagte <NSObject>

- (void)deleteButtonClickIndexPath:(NSIndexPath *_Nullable)indexPath;


@end



NS_ASSUME_NONNULL_BEGIN

@interface HLPrivacyManageTableViewCell : HXBaseTableViewCell

@property (nonatomic,assign) id <HLPrivacyManageDeleagte>delegate;

@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (nonatomic, strong) HLFriendUserModel *friendModel;

@property (nonatomic, strong) NSIndexPath *currentIndex;

@end

NS_ASSUME_NONNULL_END
