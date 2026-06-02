// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NESingleToGroupUserInCallCell.h"
#import <Masonry/Masonry.h>
#import <NERtcCallKit/NERtcCallKit.h>
#import <NERtcSDK/NERtcSDK.h>
#import <NEXKitBase/NEXKitBase.h>
#import <SDWebImage/SDWebImage.h>
#import "NECallUIKitMacro.h"
#import "NEGroupUser.h"

@interface NESingleToGroupUserInCallCell ()

@property(nonatomic, strong) UIImageView *headerImage;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *connectingState;
@property(nonatomic, strong) UIView *preview;
@property(nonatomic, strong) NERtcVideoCanvas *canvas;
@property(nonatomic, copy) NSString *displayingUserID;
@property(nonatomic, copy) NSString *boundUserID;
@property(nonatomic, assign) uint64_t boundUid;
@property(nonatomic, assign) BOOL boundLocalVideo;
@property(nonatomic, assign) BOOL boundCanvas;
@property(nonatomic, assign) BOOL boundVideoOpen;

@end

@implementation NESingleToGroupUserInCallCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  self.contentView.backgroundColor = HEXCOLOR(0x292933);

  [self.contentView addSubview:self.headerImage];
  [self.headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.contentView);
    make.width.height.mas_equalTo(self.contentView.mas_width).multipliedBy(0.5);
  }];

  [self.contentView addSubview:self.connectingState];
  [self.connectingState mas_makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.equalTo(self.headerImage.mas_top).offset(-4);
    make.left.right.equalTo(self.contentView);
  }];

  [self.contentView addSubview:self.preview];
  [self.preview mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.contentView);
  }];

  UIView *back = [[UIView alloc] init];
  [self.contentView addSubview:back];
  back.backgroundColor = HEXCOLORA(0x000000, 0.5);
  back.clipsToBounds = YES;
  back.layer.cornerRadius = 2.0;
  [back mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.contentView).offset(4);
    make.bottom.equalTo(self.contentView).offset(-4);
  }];

  [back addSubview:self.nameLabel];
  [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.top.equalTo(back).offset(4);
    make.bottom.right.equalTo(back).offset(-4);
  }];

  self.canvas.container = self.preview;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  self.preview.hidden = YES;
  self.connectingState.hidden = YES;
}

- (void)configure:(NEGroupUser *)user {
  self.displayingUserID = user.imAccid;
  // RTC canvas 是按 uid 全局绑定的。reload 期间 cell 会交叉复用，不能在这里解绑旧账号，
  // 否则后一个 cell 可能把前一个 cell 刚绑定好的 local/remote 画面清掉。
  [self.headerImage
      sd_setImageWithURL:[NSURL URLWithString:user.avatar]
        placeholderImage:[UIImage imageNamed:@"avator"
                                                  inBundle:[NSBundle bundleForClass:[NERtcCallUIKit
                                                                                        class]]
                             compatibleWithTraitCollection:nil]];
  self.nameLabel.text = user.nickname;

  BOOL waiting = user.state == GroupMemberStateWaitting;
  self.connectingState.hidden = !waiting;

  NSString *currentUserId = [NIMSDK.sharedSDK.v2LoginService getLoginUser];
  BOOL isLocalUser = [currentUserId isEqualToString:user.imAccid];
  BOOL isLocalVideo = isLocalUser && user.isShowLocalVideo;
  BOOL needsBind = ![self.boundUserID isEqualToString:user.imAccid] || self.boundUid != user.uid ||
                   self.boundLocalVideo != isLocalVideo ||
                   self.boundVideoOpen != user.isOpenVideo;

  if (user.isOpenVideo == YES && isLocalVideo == YES) {
    self.preview.hidden = NO;
    self.connectingState.hidden = YES;
    if (needsBind) {
      [NERtcEngine.sharedEngine enableLocalVideo:YES];
      [NERtcEngine.sharedEngine setupLocalVideoCanvas:self.canvas];
      [NERtcEngine.sharedEngine startPreview];
      NEXKitBaseLogInfo(@"SingleToGroup UI bind local video, user:%@ uid:%llu isOpenVideo:%d "
                        @"isShowLocalVideo:%d",
                        user.imAccid, (unsigned long long)user.uid, user.isOpenVideo,
                        user.isShowLocalVideo);
    }
    [self markBoundUser:user localVideo:YES boundCanvas:YES videoOpen:YES];
  } else if (user.isOpenVideo == YES) {
    self.preview.hidden = NO;
    self.connectingState.hidden = YES;
    BOOL didBindCanvas = user.uid > 0;
    if (didBindCanvas && needsBind) {
      [NERtcEngine.sharedEngine setupRemoteVideoCanvas:self.canvas forUserID:user.uid];
      NEXKitBaseLogInfo(@"SingleToGroup UI bind remote video, user:%@ uid:%llu isOpenVideo:%d",
                        user.imAccid, (unsigned long long)user.uid, user.isOpenVideo);
    }
    [self markBoundUser:user localVideo:NO boundCanvas:didBindCanvas videoOpen:YES];
  } else if (isLocalUser) {
    BOOL hadBoundCanvas = self.boundCanvas;
    if ((hadBoundCanvas || self.boundVideoOpen) && self.boundLocalVideo) {
      [NERtcEngine.sharedEngine setupLocalVideoCanvas:nil];
      [NERtcEngine.sharedEngine stopPreview];
    }
    self.preview.hidden = YES;
    [self clearBoundUser];
    NEXKitBaseLogInfo(@"SingleToGroup UI hide local video, user:%@ uid:%llu isOpenVideo:%d "
                      @"hadBoundCanvas:%d",
                      user.imAccid, (unsigned long long)user.uid, user.isOpenVideo,
                      hadBoundCanvas);
  } else {
    self.preview.hidden = YES;
    BOOL hadBoundCanvas = self.boundCanvas;
    uint64_t oldBoundUid = self.boundUid;
    if ((hadBoundCanvas || self.boundVideoOpen) && oldBoundUid == user.uid && user.uid > 0) {
      [NERtcEngine.sharedEngine setupRemoteVideoCanvas:nil forUserID:user.uid];
    }
    [self clearBoundUser];
    NEXKitBaseLogInfo(@"SingleToGroup UI hide remote video, user:%@ uid:%llu waiting:%d "
                      @"isOpenVideo:%d hadBoundCanvas:%d oldBoundUid:%llu",
                      user.imAccid, (unsigned long long)user.uid, waiting, user.isOpenVideo,
                      hadBoundCanvas, (unsigned long long)oldBoundUid);
  }
}

- (BOOL)isDisplayingUserID:(NSString *)userID {
  return userID.length > 0 && [self.displayingUserID isEqualToString:userID];
}

- (void)markBoundUser:(NEGroupUser *)user
           localVideo:(BOOL)localVideo
          boundCanvas:(BOOL)boundCanvas
            videoOpen:(BOOL)videoOpen {
  self.boundUserID = user.imAccid;
  self.boundUid = user.uid;
  self.boundLocalVideo = localVideo;
  self.boundCanvas = boundCanvas;
  self.boundVideoOpen = videoOpen;
}

- (void)clearBoundUser {
  self.boundUserID = nil;
  self.boundUid = 0;
  self.boundLocalVideo = NO;
  self.boundCanvas = NO;
  self.boundVideoOpen = NO;
}

- (UIImageView *)headerImage {
  if (!_headerImage) {
    _headerImage = [[UIImageView alloc] init];
    _headerImage.clipsToBounds = YES;
    _headerImage.layer.cornerRadius = 2.0;
  }
  return _headerImage;
}

- (UILabel *)nameLabel {
  if (!_nameLabel) {
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.clipsToBounds = YES;
    _nameLabel.layer.cornerRadius = 2.0;
    _nameLabel.textColor = UIColor.whiteColor;
    _nameLabel.font = [UIFont systemFontOfSize:12.0];
  }
  return _nameLabel;
}

- (UILabel *)connectingState {
  if (!_connectingState) {
    _connectingState = [[UILabel alloc] init];
    _connectingState.text = @"待接听...";
    _connectingState.textColor = UIColor.whiteColor;
    _connectingState.font = [UIFont systemFontOfSize:13.0];
    _connectingState.textAlignment = NSTextAlignmentCenter;
  }
  return _connectingState;
}

- (UIView *)preview {
  if (!_preview) {
    _preview = [[UIView alloc] init];
  }
  return _preview;
}

- (NERtcVideoCanvas *)canvas {
  if (!_canvas) {
    _canvas = [[NERtcVideoCanvas alloc] init];
    _canvas.renderMode = kNERtcVideoRenderScaleCropFill;
  }
  return _canvas;
}

@end
