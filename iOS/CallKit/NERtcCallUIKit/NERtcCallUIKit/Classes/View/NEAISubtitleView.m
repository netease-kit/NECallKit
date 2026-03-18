// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEAISubtitleView.h"
#import <NERtcCallKit/NERtcCallKit.h>
#import <NEXKitBase/NEXKitBase.h>
#import <NIMSDK/NIMSDK.h>

@interface NEAISubtitleView ()

@property(nonatomic, strong) UILabel *textLabel;
@property(nonatomic, strong) NSMutableArray<NSDictionary *> *messages;

@property(nonatomic, assign) BOOL showTranslation;

@end

@implementation NEAISubtitleView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupUI];
  }
  return self;
}

- (instancetype)init {
  return [self initWithFrame:CGRectZero];
}

- (void)setupUI {
  [self addSubview:self.textLabel];
  self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
  [NSLayoutConstraint activateConstraints:@[
    [self.textLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
    [self.textLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
    [self.textLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-16],
    [self.textLabel.heightAnchor constraintGreaterThanOrEqualToConstant:40]
  ]];
}

- (UILabel *)textLabel {
  if (!_textLabel) {
    _textLabel = [[UILabel alloc] init];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.font = [UIFont systemFontOfSize:16];
    _textLabel.textAlignment = NSTextAlignmentLeft;
    _textLabel.numberOfLines = 0;
    _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _textLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _textLabel.layer.cornerRadius = 12;
    _textLabel.layer.masksToBounds = YES;
    _textLabel.hidden = YES;

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8;
    _textLabel.attributedText =
        [[NSAttributedString alloc] initWithString:@""
                                        attributes:@{
                                          NSParagraphStyleAttributeName : paragraphStyle,
                                          NSForegroundColorAttributeName : [UIColor whiteColor]
                                        }];
  }
  return _textLabel;
}

- (NSMutableArray<NSDictionary *> *)messages {
  if (!_messages) {
    _messages = [[NSMutableArray alloc] init];
  }
  return _messages;
}

- (void)updateSubtitle:(NERtcAsrCaptionResult *)result {
  // 只有最终结果才显示
  if (!result || !result.isFinal) {
    return;
  }

  // 检查内容是否有效
  if (!result.content || result.content.length == 0) {
    return;
  }

  // 获取原文和翻译文本
  NSString *originalText = result.content;
  NSString *translatedText = nil;

  // 根据 showTranslation 标志决定是否处理翻译
  if (self.showTranslation) {
    // 需要展示翻译：如果没有翻译或翻译文本为空，则直接返回
    if (!result.haveTranslation || !result.translatedText || result.translatedText.length == 0) {
      return;
    }
    translatedText = result.translatedText;
  } else {
    // 不需要展示翻译：如果有翻译，则直接返回（只显示原文）
    if (result.haveTranslation) {
      return;
    }
  }

  // 获取用户 accId
  NSString *userAccId = nil;
  NEUserInfo *userInfo = [[NECallEngine sharedInstance] getUserWithRtcUid:result.uid];
  if (userInfo && userInfo.accId) {
    userAccId = userInfo.accId;
  } else {
    // 如果无法通过 rtcUid 获取，尝试使用当前登录用户或远端用户
    NSString *currentAccId = [NIMSDK.sharedSDK.v2LoginService getLoginUser];
    if (result.isLocalUser) {
      userAccId = currentAccId;
    } else {
      // 尝试从通话信息中获取远端用户 accId
      NECallInfo *callInfo = [[NECallEngine sharedInstance] getCallInfo];
      if (callInfo) {
        if ([callInfo.currentAccId isEqualToString:callInfo.callerInfo.accId]) {
          userAccId = callInfo.calleeInfo.accId;
        } else {
          userAccId = callInfo.callerInfo.accId;
        }
      }
    }
  }

  // 获取用户显示名称
  __block NSString *displayName = userAccId;
  if (userAccId) {
    __weak typeof(self) weakSelf = self;
    [NIMSDK.sharedSDK.userManager
        fetchUserInfos:@[ userAccId ]
            completion:^(NSArray<NIMUser *> *_Nullable users, NSError *_Nullable error) {
              if (!error && users.count > 0) {
                NIMUser *user = users.firstObject;
                if (user && user.userInfo.nickName.length > 0) {
                  displayName = user.userInfo.nickName;
                } else if (user) {
                  displayName = user.userId;
                }
              }
              [weakSelf updateSubtitleWithDisplayName:displayName
                                         originalText:originalText
                                       translatedText:translatedText];
            }];
  } else {
    [self updateSubtitleWithDisplayName:displayName
                           originalText:originalText
                         translatedText:translatedText];
  }
}

- (void)updateSubtitleWithDisplayName:(NSString *)displayName
                         originalText:(NSString *)originalText
                       translatedText:(NSString *)translatedText {
  // 构建显示文本：如果有翻译，第一行原文，第二行翻译
  NSMutableString *displayText = [[NSMutableString alloc] init];
  if (originalText && originalText.length > 0) {
    [displayText appendString:originalText];
  }
  if (translatedText && translatedText.length > 0) {
    if (displayText.length > 0) {
      [displayText appendString:@"\n"];
    }
    [displayText appendString:translatedText];
  }

  // 添加消息到数组
  [self.messages addObject:@{@"sender" : displayName ?: @"", @"text" : displayText ?: @""}];

  // 只保留最近 2 条消息
  if (self.messages.count > 2) {
    [self.messages removeObjectAtIndex:0];
  }

  // 格式化文本并设置不同颜色
  NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
  // 0xFFD9CC66: ARGB格式，A=0xFF(255), R=0xD9(217), G=0xCC(204), B=0x66(102)
  UIColor *senderColor = [UIColor colorWithRed:0xD9 / 255.0
                                         green:0xCC / 255.0
                                          blue:0x66 / 255.0
                                         alpha:1.0];
  UIColor *textColor = [UIColor whiteColor];

  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.lineSpacing = 8;

  for (NSInteger i = 0; i < self.messages.count; i++) {
    NSDictionary *message = self.messages[i];
    NSString *sender = message[@"sender"] ?: @"";
    NSString *msgText = message[@"text"] ?: @"";

    if (i > 0) {
      [attributedText
          appendAttributedString:[[NSAttributedString alloc]
                                     initWithString:@"\n\n"
                                         attributes:@{
                                           NSParagraphStyleAttributeName : paragraphStyle,
                                           NSForegroundColorAttributeName : textColor
                                         }]];
    }

    // 添加 sender（带颜色）
    NSString *senderPart = [NSString stringWithFormat:@" %@:\n", sender];
    [attributedText appendAttributedString:[[NSAttributedString alloc]
                                               initWithString:senderPart
                                                   attributes:@{
                                                     NSParagraphStyleAttributeName : paragraphStyle,
                                                     NSForegroundColorAttributeName : senderColor
                                                   }]];

    // 添加消息文本（白色）
    [attributedText appendAttributedString:[[NSAttributedString alloc]
                                               initWithString:msgText
                                                   attributes:@{
                                                     NSParagraphStyleAttributeName : paragraphStyle,
                                                     NSForegroundColorAttributeName : textColor
                                                   }]];
  }

  // 更新 UI（主线程）
  dispatch_async(dispatch_get_main_queue(), ^{
    self.textLabel.attributedText = attributedText;
    self.textLabel.hidden = NO;
  });
}

- (void)dealloc {
}

@end
