// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "GroupSettingViewController.h"
#import <AVFoundation/AVFoundation.h>

static NSString *const NEGroupCallExtraInfoTemplate =
    @"{\"source\":\"callkit-demo\",\"scene\":\"group-call\",\"key\":\"extraInfo-test\",\"value\":\"testValue\"}";

@interface GroupSettingViewController ()

@property(nonatomic, strong) UITextField *pushContent;
@property(nonatomic, strong) UITextField *groupIdTextField;
@property(nonatomic, strong) UISwitch *extraInfoAutoFillSwitch;
@property(nonatomic, strong) UITextField *extraInfoTextField;

@property(nonatomic, strong) UIScrollView *contentScroll;

@end

@implementation GroupSettingViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillChangeFrame:)
                                               name:UIKeyboardWillChangeFrameNotification
                                             object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillChangeFrameNotification
                                                object:nil];
}

- (void)loadView {
  self.view = self.contentScroll;
}

- (UIScrollView *)contentScroll {
  if (!_contentScroll) {
    _contentScroll = [[UIScrollView alloc] init];
    //      _contentScroll.frame = [[[UIApplication sharedApplication] keyWindow] frame];
    _contentScroll.bounces = YES;
  }
  return _contentScroll;
}

- (void)setupUI {
  UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(saveSetting)];
  [saveItem setTintColor:[UIColor whiteColor]];

  self.navigationItem.rightBarButtonItem = saveItem;

  UIView *line = [[UIView alloc] init];
  line.backgroundColor = [UIColor clearColor];
  [self.view addSubview:line];
  [line mas_makeConstraints:^(MASConstraintMaker *make) {
    make.height.mas_equalTo(1);
    make.left.right.equalTo(self.view);
    make.width.mas_equalTo([[[UIApplication sharedApplication] keyWindow] frame].size.width);
  }];
  UILabel *pushLabel = [self createLabelWithText:NSLocalizedString(@"enable_group_push", nil)];
  [self.view addSubview:pushLabel];
  [pushLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.view.mas_top).offset(20);
    make.left.equalTo(self.view.mas_left).offset(20);
  }];

  UISwitch *pushSwitch = [[UISwitch alloc] init];
  [self.view addSubview:pushSwitch];
  [pushSwitch setOn:[[SettingManager shareInstance] isGroupPush]];
  [pushSwitch addTarget:self
                 action:@selector(valueChange:)
       forControlEvents:UIControlEventValueChanged];
  [pushSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(pushLabel);
    make.right.equalTo(self.view).offset(-20);
  }];

  self.pushContent = [self createTextField];
  [self.view addSubview:self.pushContent];
  [self.pushContent mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(pushLabel.mas_left);
    make.right.equalTo(pushSwitch.mas_right);
    make.top.mas_equalTo(pushLabel.mas_bottom).offset(20);
  }];
  self.pushContent.placeholder = NSLocalizedString(@"group_push_content_placeholder", nil);
  if ([[SettingManager shareInstance] customPushContent].length > 0) {
    self.pushContent.text = [[SettingManager shareInstance] customPushContent];
  }

  if (self.showsGroupCallParams) {
    UILabel *groupIdLabel = [self createLabelWithText:@"业务群 groupId"];
    [self.view addSubview:groupIdLabel];
    [groupIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.pushContent.mas_bottom).offset(28);
      make.left.equalTo(pushLabel.mas_left);
    }];

    self.groupIdTextField = [self createTextField];
    self.groupIdTextField.placeholder = @"业务群 groupId（可选）";
    self.groupIdTextField.text = self.groupId;
    [self.view addSubview:self.groupIdTextField];
    [self.groupIdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(groupIdLabel.mas_bottom).offset(12);
      make.left.equalTo(pushLabel.mas_left);
      make.right.equalTo(pushSwitch.mas_right);
    }];

    UILabel *autoFillLabel = [self createLabelWithText:@"自动填充 extraInfo"];
    [self.view addSubview:autoFillLabel];
    [autoFillLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.groupIdTextField.mas_bottom).offset(24);
      make.left.equalTo(pushLabel.mas_left);
    }];

    self.extraInfoAutoFillSwitch = [[UISwitch alloc] init];
    [self.extraInfoAutoFillSwitch setOn:self.extraInfoAutoFillEnabled];
    [self.extraInfoAutoFillSwitch addTarget:self
                                     action:@selector(extraInfoAutoFillChanged:)
                           forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.extraInfoAutoFillSwitch];
    [self.extraInfoAutoFillSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
      make.centerY.equalTo(autoFillLabel);
      make.right.equalTo(self.view).offset(-20);
    }];

    self.extraInfoTextField = [self createTextField];
    self.extraInfoTextField.placeholder = @"extraInfo JSON String（可选）";
    self.extraInfoTextField.text = self.extraInfo;
    self.extraInfoTextField.enabled = !self.extraInfoAutoFillEnabled;
    [self.view addSubview:self.extraInfoTextField];
    [self.extraInfoTextField mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(autoFillLabel.mas_bottom).offset(12);
      make.left.equalTo(pushLabel.mas_left);
      make.right.equalTo(pushSwitch.mas_right);
      make.bottom.equalTo(self.view.mas_bottom).offset(-20);
    }];
  } else {
    [self.pushContent mas_makeConstraints:^(MASConstraintMaker *make) {
      make.bottom.equalTo(self.view.mas_bottom).offset(-20);
    }];
  }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
  CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
  CGRect intersection = CGRectIntersection(self.view.bounds, keyboardFrame);
  CGFloat keyboardHeight = CGRectIsNull(intersection) ? 0 : CGRectGetHeight(intersection);

  UIEdgeInsets contentInset = self.contentScroll.contentInset;
  contentInset.bottom = keyboardHeight;
  UIEdgeInsets scrollIndicatorInsets = self.contentScroll.scrollIndicatorInsets;
  scrollIndicatorInsets.bottom = keyboardHeight;

  NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]
      doubleValue];
  UIViewAnimationOptions options =
      [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
  [UIView animateWithDuration:duration
      delay:0
      options:options
      animations:^{
        self.contentScroll.contentInset = contentInset;
        self.contentScroll.scrollIndicatorInsets = scrollIndicatorInsets;

        UITextField *currentTextField = [self currentTextField];
        if (currentTextField) {
          CGRect visibleRect = [currentTextField convertRect:currentTextField.bounds
                                                      toView:self.contentScroll];
          visibleRect = CGRectInset(visibleRect, 0, -20);
          [self.contentScroll scrollRectToVisible:visibleRect animated:NO];
        }
      }
      completion:nil];
}

- (UITextField *)currentTextField {
  if (self.pushContent.isFirstResponder) {
    return self.pushContent;
  }
  if (self.groupIdTextField.isFirstResponder) {
    return self.groupIdTextField;
  }
  if (self.extraInfoTextField.isFirstResponder) {
    return self.extraInfoTextField;
  }
  return nil;
}

- (void)saveSetting {
  [[SettingManager shareInstance] setCustomPushContent:self.pushContent.text];
  if (self.showsGroupCallParams && self.completion) {
    NSString *groupId = self.groupIdTextField.text.length > 0 ? self.groupIdTextField.text : nil;
    NSString *extraInfo =
        self.extraInfoTextField.text.length > 0 ? self.extraInfoTextField.text : nil;
    self.completion(groupId, extraInfo, self.extraInfoAutoFillSwitch.isOn);
  }
  [self.navigationController popViewControllerAnimated:YES];
  [[UIApplication sharedApplication].keyWindow
      ne_makeToast:NSLocalizedString(@"save_success", nil)];
}

- (void)extraInfoAutoFillChanged:(UISwitch *)sender {
  if (sender.isOn) {
    self.extraInfoTextField.text = NEGroupCallExtraInfoTemplate;
  } else if ([self.extraInfoTextField.text isEqualToString:NEGroupCallExtraInfoTemplate]) {
    self.extraInfoTextField.text = @"";
  }
  self.extraInfoTextField.enabled = !sender.isOn;
}

- (UILabel *)createLabelWithText:(NSString *)text {
  UILabel *label = [[UILabel alloc] init];
  label.textColor = [UIColor whiteColor];
  label.font = [UIFont systemFontOfSize:16.0];
  label.textAlignment = NSTextAlignmentLeft;
  label.text = text;
  [label setContentHuggingPriority:UILayoutPriorityRequired
                           forAxis:UILayoutConstraintAxisHorizontal];
  return label;
}

- (UITextField *)createTextField {
  UITextField *field = [[UITextField alloc] init];
  field.borderStyle = UITextBorderStyleRoundedRect;
  field.textColor = UIColor.blackColor;
  field.textAlignment = NSTextAlignmentLeft;
  field.font = [UIFont systemFontOfSize:14.0];
  return field;
}

- (void)valueChange:(UISwitch *)uiswitch {
  //[[SettingManager shareInstance] setAutoJoin:uiswitch.isOn];
  [[SettingManager shareInstance] setIsGroupPush:uiswitch.isOn];
  NSLog(@"switch change value : %d", uiswitch.isOn);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before
navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
