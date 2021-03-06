//
//  TableViewCell.m
//  ZiMaCaiHang
//
//  Created by zhangyy on 15/8/25.
//  Copyright (c) 2015年 zimacaihang. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

-(void)setUserModel:(rewardModel *)userModel
{
    if (_userModel != userModel) {
        _userModel = userModel;
    }

    _typeNameLable.text = _userModel.title;
    _rmbLabel.text = _userModel.rewardNum;
    _dateLabel.text = _userModel.sendDate;

}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
    // Configure the view for the selected state
}

@end
