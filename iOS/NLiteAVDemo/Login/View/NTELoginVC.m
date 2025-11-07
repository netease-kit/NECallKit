// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NTELoginVC.h"
#import "NEAccount.h"
#import "NELoginOptions.h"
#import "NENavigator.h"
#import "NSMacro.h"
#import "UIColor+NTES.h"
#import "UIImage+NTES.h"
#import "UIView+NTES.h"

@interface NTELoginVC () <UITextFieldDelegate>

@property(nonatomic, strong) UILabel *titleLab;
@property(nonatomic, strong) UILabel *linkLab;
@property(nonatomic, strong) UITextField *accountIdField;
@property(nonatomic, strong) UIView *horLine1;
@property(nonatomic, strong) UITextField *tokenField;
@property(nonatomic, strong) UIView *horLine2;
@property(nonatomic, strong) UILabel *tipLab;
@property(nonatomic, strong) UIButton *loginBtn;
@property(nonatomic, strong) UITextView *protocolView;
@property(nonatomic, strong) UIButton *cancelBtn;

@property(nonatomic, strong) NELoginOptions *options;

@end

@implementation NTELoginVC

- (instancetype)initWithOptions:(NELoginOptions *_Nullable)options {
  self = [super init];
  if (self) {
    _options = options;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  self.view.backgroundColor = [UIColor whiteColor];
  [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self.navigationController setNavigationBarHidden:YES];
}

/**
 *  self code
 */

- (void)setupSubviews {
  [self.view addSubview:self.cancelBtn];
  [self.view addSubview:self.titleLab];
  [self.view addSubview:self.linkLab];
  [self.view addSubview:self.accountIdField];
  [self.view addSubview:self.horLine1];
  [self.view addSubview:self.tokenField];
  [self.view addSubview:self.horLine2];
  [self.view addSubview:self.tipLab];
  [self.view addSubview:self.loginBtn];
  [self.view addSubview:self.protocolView];

  self.cancelBtn.frame = CGRectMake(self.view.width - 60, 80, 30, 30);
  self.titleLab.frame = CGRectMake(30, 130, self.view.width - 60, 40);
  self.linkLab.frame =
      CGRectMake(self.titleLab.left, self.titleLab.bottom + 20, self.titleLab.width, 20);
  self.accountIdField.frame =
      CGRectMake(self.titleLab.left, self.linkLab.bottom + 30, self.titleLab.width, 44);
  [self.accountIdField becomeFirstResponder];
  self.horLine1.frame =
      CGRectMake(self.titleLab.left, self.accountIdField.bottom + 1, self.titleLab.width, 1);
  self.tokenField.frame =
      CGRectMake(self.titleLab.left, self.horLine1.bottom + 20, self.titleLab.width, 44);
  self.horLine2.frame =
      CGRectMake(self.titleLab.left, self.tokenField.bottom + 1, self.titleLab.width, 1);
  self.tipLab.frame =
      CGRectMake(self.titleLab.left, self.horLine2.bottom + 10, self.titleLab.width, 18);
  self.loginBtn.frame =
      CGRectMake(self.titleLab.left, self.tipLab.bottom + 36, self.titleLab.width, 50);

  CGFloat safeAreaHeight = 0;
  if (@available(iOS 11.0, *)) {
    safeAreaHeight =
        [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0 ? 34 : 0;
  }
  self.protocolView.frame =
      CGRectMake(self.titleLab.left, self.loginBtn.bottom + 30, self.titleLab.width, 30);

  self.protocolView.attributedText = [self protocolText];
  self.protocolView.textAlignment = NSTextAlignmentCenter;

  UITapGestureRecognizer *tap =
      [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
  [self.view addGestureRecognizer:tap];
}

- (void)endEditing {
  [self.view endEditing:YES];
}

- (void)openYunxinDoc {
  NSURL *url = [NSURL URLWithString:@"https://doc.yunxin.163.com/messaging2/guide/"
                                    @"jU0Mzg0MTU?platform=client#%E7%AC%AC%E4%BA%8C%E6%AD%A5%E6%B3%"
                                    @"A8%E5%86%8C-im-%E8%B4%A6%E5%8F%B7"];
  if ([[UIApplication sharedApplication] canOpenURL:url]) {
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
  }
}

- (void)loginAction {
  NSString *accountId = self.accountIdField.text;
  NSString *token = self.tokenField.text;

  if (accountId.length == 0 || token.length == 0) {
    [self.view ne_makeToast:@"请输入完整的账号ID和Token"];
    return;
  }

  [NEAccount loginWithAccountId:accountId
                          token:token
                     completion:^(NSDictionary *_Nullable data, NSError *_Nullable error) {
                       ntes_main_async_safe(^{
                         if (error) {
                           NSString *msg = [error localizedDescription] ?: @"登录失败";
                           [self.view ne_makeToast:msg];
                         } else {
                           if (self.options.successBlock) {
                             self.options.successBlock();
                           }
                           [[NENavigator shared] closeLoginWithCompletion:nil];
                           [self.view ne_makeToast:@"登录成功"];
                         }
                       });
                     }];
}

- (NSAttributedString *)protocolText {
  NSDictionary *norAttr = @{NSForegroundColorAttributeName : HEXCOLOR(0x999999)};
  NSMutableAttributedString *attr =
      [[NSMutableAttributedString alloc] initWithString:@"登录即视为您已同意 " attributes:norAttr];

  NSMutableAttributedString *tempAttr =
      [[NSMutableAttributedString alloc] initWithString:@"隐私政策"
                                             attributes:@{
                                               NSForegroundColorAttributeName : HEXCOLOR(0x337EFF),
                                               NSLinkAttributeName : kPrivatePolicyURL
                                             }];
  [attr appendAttributedString:[tempAttr copy]];

  tempAttr = [[NSMutableAttributedString alloc] initWithString:@" 和 " attributes:norAttr];
  [attr appendAttributedString:[tempAttr copy]];

  tempAttr =
      [[NSMutableAttributedString alloc] initWithString:@"用户协议"
                                             attributes:@{
                                               NSForegroundColorAttributeName : HEXCOLOR(0x337EFF),
                                               NSLinkAttributeName : kUserAgreementURL
                                             }];
  [attr appendAttributedString:[tempAttr copy]];

  return [attr copy];
}

#pragma mark - UITextField delegate

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
  return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
  BOOL valid = self.accountIdField.text.length > 0 && self.tokenField.text.length > 0;
  self.loginBtn.enabled = valid;
}
- (void)cancelBtnClick {
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - lazy method
- (UIButton *)cancelBtn {
  if (!_cancelBtn) {
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelBtn setImage:[UIImage imageNamed:@"login_cancel"] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self
                   action:@selector(cancelBtnClick)
         forControlEvents:UIControlEventTouchUpInside];
  }
  return _cancelBtn;
}
- (UILabel *)titleLab {
  if (!_titleLab) {
    _titleLab = [[UILabel alloc] init];
    _titleLab.font = [UIFont systemFontOfSize:28];
    _titleLab.textColor = [UIColor colorWithHexString:@"#222222"];
    _titleLab.text = @"你好, 欢迎登录";
  }
  return _titleLab;
}

- (UILabel *)linkLab {
  if (!_linkLab) {
    _linkLab = [[UILabel alloc] init];
    _linkLab.font = [UIFont systemFontOfSize:14];
    _linkLab.textColor = [UIColor colorWithHexString:@"#337EFF"];
    _linkLab.text = @"如何获取云信账号与Token";
    _linkLab.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openYunxinDoc)];
    [_linkLab addGestureRecognizer:tap];
  }
  return _linkLab;
}

- (UITextField *)accountIdField {
  if (!_accountIdField) {
    _accountIdField = [[UITextField alloc] init];
    _accountIdField.placeholder = @"请输入账号ID";
    _accountIdField.font = [UIFont systemFontOfSize:17];
    _accountIdField.textColor = [UIColor colorWithHexString:@"#333333"];
    _accountIdField.delegate = self;
    [_accountIdField addTarget:self
                        action:@selector(textFieldDidChange:)
              forControlEvents:UIControlEventEditingChanged];
  }
  return _accountIdField;
}

- (UIView *)horLine1 {
  if (!_horLine1) {
    _horLine1 = [[UIView alloc] init];
    _horLine1.backgroundColor = [UIColor colorWithHexString:@"#DCDFE5"];
  }
  return _horLine1;
}

- (UITextField *)tokenField {
  if (!_tokenField) {
    _tokenField = [[UITextField alloc] init];
    _tokenField.placeholder = @"请输入Token";
    _tokenField.font = [UIFont systemFontOfSize:17];
    _tokenField.textColor = [UIColor colorWithHexString:@"#333333"];
    _tokenField.delegate = self;
    _tokenField.secureTextEntry = YES;
    [_tokenField addTarget:self
                    action:@selector(textFieldDidChange:)
          forControlEvents:UIControlEventEditingChanged];
  }
  return _tokenField;
}

- (UIView *)horLine2 {
  if (!_horLine2) {
    _horLine2 = [[UIView alloc] init];
    _horLine2.backgroundColor = [UIColor colorWithHexString:@"#DCDFE5"];
  }
  return _horLine2;
}

- (UILabel *)tipLab {
  if (!_tipLab) {
    _tipLab = [[UILabel alloc] init];
    _tipLab.font = [UIFont systemFontOfSize:12];
    _tipLab.textColor = [UIColor colorWithHexString:@"#B0B6BE"];
    _tipLab.text = @"请输入您的云信账号ID和Token进行登录";
  }
  return _tipLab;
}

- (UIButton *)loginBtn {
  if (!_loginBtn) {
    _loginBtn = [[UIButton alloc] init];
    _loginBtn.enabled = NO;
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIColor *activeCol = [UIColor colorWithHexString:@"#337EFF"];
    [_loginBtn setBackgroundImage:[UIImage ne_imageWithColor:activeCol]
                         forState:UIControlStateNormal];
    UIColor *disableCol = [UIColor colorWithHexString:@"#cccccc"];
    [_loginBtn setBackgroundImage:[UIImage ne_imageWithColor:disableCol]
                         forState:UIControlStateDisabled];
    _loginBtn.layer.cornerRadius = 25;
    _loginBtn.layer.masksToBounds = YES;
    [_loginBtn addTarget:self
                  action:@selector(loginAction)
        forControlEvents:UIControlEventTouchUpInside];
  }
  return _loginBtn;
}

- (UITextView *)protocolView {
  if (!_protocolView) {
    _protocolView = [[UITextView alloc] init];
    _protocolView.textAlignment = NSTextAlignmentCenter;
    _protocolView.editable = NO;
    _protocolView.scrollEnabled = NO;
    _protocolView.backgroundColor = [UIColor whiteColor];
  }
  return _protocolView;
}

@end
