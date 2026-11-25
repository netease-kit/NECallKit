// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "GroupUserViewCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>

@interface GroupUserViewCell ()

@property(nonatomic, strong) UILabel *accountLabel;

@end

@implementation GroupUserViewCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  self.accountLabel = [[UILabel alloc] init];
  self.accountLabel.textAlignment = NSTextAlignmentCenter;
  self.accountLabel.textColor = [UIColor whiteColor];
  self.accountLabel.font = [UIFont systemFontOfSize:10.0];
  self.accountLabel.numberOfLines = 0;  // 支持多行显示
  self.accountLabel.adjustsFontSizeToFitWidth = YES;
  self.accountLabel.minimumScaleFactor = 0.8;
  self.accountLabel.backgroundColor = [UIColor colorWithRed:0.22
                                                      green:0.29
                                                       blue:0.40
                                                      alpha:1.0];  // 半透明背景
  self.accountLabel.layer.cornerRadius = 4.0;
  self.accountLabel.clipsToBounds = YES;
  [self addSubview:self.accountLabel];
  [self.accountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self).insets(UIEdgeInsetsMake(2, 2, 2, 2));
  }];
}

- (void)configureWithUser:(NEUser *)user {
  // 显示 accountId
  self.accountLabel.text = user.imAccid ?: user.mobile ?: @"";
}

@end
