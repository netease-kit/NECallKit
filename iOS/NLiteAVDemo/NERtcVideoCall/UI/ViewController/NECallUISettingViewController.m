//// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallUISettingViewController.h"

static NSString *const kDemoIncomingBackgroundURL =
    @"https://picsum.photos/id/1018/900/1600.jpg";

@interface NECallUISettingViewController ()

@property(nonatomic, strong) UILabel *incomingBackgroundStatusLabel;

@end

@implementation NECallUISettingViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor colorWithRed:36 / 255.0
                                              green:36 / 255.0
                                               blue:45 / 255.0
                                              alpha:1.0];
  self.navigationItem.leftBarButtonItem.title = @"返回";
  self.navigationItem.title = @"UI设置";
  [self setupUI];
}

- (void)setupUI {
  // 生成一个居左的标签，显示是否开启小窗功能
  UILabel *floatWindow = [[UILabel alloc] init];
  floatWindow.translatesAutoresizingMaskIntoConstraints = NO;
  floatWindow.textColor = [UIColor whiteColor];
  floatWindow.text = @"小窗功能";
  [self.view addSubview:floatWindow];
  [NSLayoutConstraint activateConstraints:@[
    [floatWindow.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:80],
    [floatWindow.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
    [floatWindow.heightAnchor constraintEqualToConstant:30]
  ]];

  // 生成一个 UISwitch，用于控制是否开启小窗功能
  UISwitch *floatSwitch = [[UISwitch alloc] init];
  floatSwitch.translatesAutoresizingMaskIntoConstraints = NO;
  [floatSwitch addTarget:self
                  action:@selector(floatSwitchAction:)
        forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:floatSwitch];
  [NSLayoutConstraint activateConstraints:@[
    [floatSwitch.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20],
    [floatSwitch.centerYAnchor constraintEqualToAnchor:floatWindow.centerYAnchor],
  ]];

  // 生成一个标签，显示是否开启应用外浮窗功能
  UILabel *floatWindowOutApp = [[UILabel alloc] init];
  floatWindowOutApp.translatesAutoresizingMaskIntoConstraints = NO;
  floatWindowOutApp.textColor = [UIColor whiteColor];
  floatWindowOutApp.text = @"应用外浮窗功能";
  [self.view addSubview:floatWindowOutApp];
  [NSLayoutConstraint activateConstraints:@[
    [floatWindowOutApp.topAnchor constraintEqualToAnchor:floatWindow.bottomAnchor constant:20],
    [floatWindowOutApp.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
    [floatWindowOutApp.heightAnchor constraintEqualToConstant:30]
  ]];

  // 生成一个 UISwitch，用于控制是否开启应用外浮窗功能
  UISwitch *floatSwitchOutApp = [[UISwitch alloc] init];
  floatSwitchOutApp.translatesAutoresizingMaskIntoConstraints = NO;
  [floatSwitchOutApp addTarget:self
                        action:@selector(floatSwitchOutAppAction:)
              forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:floatSwitchOutApp];
  [NSLayoutConstraint activateConstraints:@[
    [floatSwitchOutApp.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20],
    [floatSwitchOutApp.centerYAnchor constraintEqualToAnchor:floatWindowOutApp.centerYAnchor],
  ]];

  // 生成一个label，是否开启被叫预览功能
  UILabel *calleePreview = [[UILabel alloc] init];
  calleePreview.translatesAutoresizingMaskIntoConstraints = NO;
  calleePreview.textColor = [UIColor whiteColor];
  calleePreview.text = @"被叫预览功能";
  [self.view addSubview:calleePreview];
  [NSLayoutConstraint activateConstraints:@[
    [calleePreview.topAnchor constraintEqualToAnchor:floatWindowOutApp.bottomAnchor constant:20],
    [calleePreview.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
    [calleePreview.heightAnchor constraintEqualToConstant:30]
  ]];

  // 生成一个 UISwitch，用于控制是否开启被叫预览功能
  UISwitch *calleePreviewSwitch = [[UISwitch alloc] init];
  calleePreviewSwitch.translatesAutoresizingMaskIntoConstraints = NO;
  [calleePreviewSwitch addTarget:self
                          action:@selector(calleePreviewSwitchAction:)
                forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:calleePreviewSwitch];
  [NSLayoutConstraint activateConstraints:@[
    [calleePreviewSwitch.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20],
    [calleePreviewSwitch.centerYAnchor constraintEqualToAnchor:calleePreview.centerYAnchor],
  ]];

  // 生成一个 label，显示是否开启虚化
  UILabel *blur = [[UILabel alloc] init];
  blur.translatesAutoresizingMaskIntoConstraints = NO;
  blur.textColor = [UIColor whiteColor];
  blur.text = @"虚化";
  [self.view addSubview:blur];
  [NSLayoutConstraint activateConstraints:@[
    [blur.topAnchor constraintEqualToAnchor:calleePreview.bottomAnchor constant:20],
    [blur.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
    [blur.heightAnchor constraintEqualToConstant:30]
  ]];

  // 生成一个 UISwitch，用于控制是否开启虚化
  UISwitch *blurSwitch = [[UISwitch alloc] init];
  blurSwitch.translatesAutoresizingMaskIntoConstraints = NO;
  [blurSwitch addTarget:self
                 action:@selector(blurSwitchAction:)
       forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:blurSwitch];
  [NSLayoutConstraint activateConstraints:@[
    [blurSwitch.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20],
    [blurSwitch.centerYAnchor constraintEqualToAnchor:blur.centerYAnchor],
  ]];

  // 获取小窗配置，设置小窗switch值
  BOOL floatWindowValue = [[[NERtcCallUIKit sharedInstance]
      valueForKeyPath:@"config.uiConfig.enableFloatingWindow"] boolValue];
  [floatSwitch setOn:floatWindowValue];

  // 获取应用外浮窗配置，设置应用外浮窗switch值
  BOOL floatWindowOutAppValue = [[[NERtcCallUIKit sharedInstance]
      valueForKeyPath:@"config.uiConfig.enableFloatingWindowOutOfApp"] boolValue];
  [floatSwitchOutApp setOn:floatWindowOutAppValue];

  // 获取被叫预览配置，设置被叫预览switch值
  BOOL calleePreviewValue = [[[NERtcCallUIKit sharedInstance]
      valueForKeyPath:@"config.uiConfig.enableCalleePreview"] boolValue];
  [calleePreviewSwitch setOn:calleePreviewValue];

  // 获取虚化配置，设置虚化switch值
  BOOL blurValue = [[[NERtcCallUIKit sharedInstance]
      valueForKeyPath:@"config.uiConfig.enableVirtualBackground"] boolValue];
  [blurSwitch setOn:blurValue];

  // 来电横幅功能
  UILabel *bannerLabel = [[UILabel alloc] init];
  bannerLabel.translatesAutoresizingMaskIntoConstraints = NO;
  bannerLabel.textColor = [UIColor whiteColor];
  bannerLabel.text = @"开启来电横幅";
  [self.view addSubview:bannerLabel];
  [NSLayoutConstraint activateConstraints:@[
    [bannerLabel.topAnchor constraintEqualToAnchor:blur.bottomAnchor constant:20],
    [bannerLabel.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
    [bannerLabel.heightAnchor constraintEqualToConstant:30]
  ]];

  UISwitch *bannerSwitch = [[UISwitch alloc] init];
  bannerSwitch.translatesAutoresizingMaskIntoConstraints = NO;
  [bannerSwitch addTarget:self
                   action:@selector(bannerSwitchAction:)
         forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:bannerSwitch];
  [NSLayoutConstraint activateConstraints:@[
    [bannerSwitch.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20],
    [bannerSwitch.centerYAnchor constraintEqualToAnchor:bannerLabel.centerYAnchor],
  ]];
  // 初始值：读取 UserDefaults 中已持久化的值，并同步到 UIKit 实例
  BOOL bannerValue = [[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableIncomingBanner"];
  [bannerSwitch setOn:bannerValue];
  [[NERtcCallUIKit sharedInstance] enableIncomingBanner:bannerValue];

  UILabel *incomingBackgroundLabel = [[UILabel alloc] init];
  incomingBackgroundLabel.translatesAutoresizingMaskIntoConstraints = NO;
  incomingBackgroundLabel.textColor = [UIColor whiteColor];
  incomingBackgroundLabel.text = @"来电背景测试";
  [self.view addSubview:incomingBackgroundLabel];
  [NSLayoutConstraint activateConstraints:@[
    [incomingBackgroundLabel.topAnchor constraintEqualToAnchor:bannerLabel.bottomAnchor constant:24],
    [incomingBackgroundLabel.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
    [incomingBackgroundLabel.heightAnchor constraintEqualToConstant:30]
  ]];

  UIButton *localBackgroundButton = [self incomingBackgroundButtonWithTitle:@"使用本地风景图"];
  [localBackgroundButton addTarget:self
                            action:@selector(applyLocalIncomingBackground)
                  forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:localBackgroundButton];
  [NSLayoutConstraint activateConstraints:@[
    [localBackgroundButton.topAnchor constraintEqualToAnchor:incomingBackgroundLabel.bottomAnchor constant:12],
    [localBackgroundButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
    [localBackgroundButton.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20],
    [localBackgroundButton.heightAnchor constraintEqualToConstant:42]
  ]];

  UIButton *urlBackgroundButton = [self incomingBackgroundButtonWithTitle:@"使用 URL 风景图"];
  [urlBackgroundButton addTarget:self
                          action:@selector(applyURLIncomingBackground)
                forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:urlBackgroundButton];
  [NSLayoutConstraint activateConstraints:@[
    [urlBackgroundButton.topAnchor constraintEqualToAnchor:localBackgroundButton.bottomAnchor constant:10],
    [urlBackgroundButton.leftAnchor constraintEqualToAnchor:localBackgroundButton.leftAnchor],
    [urlBackgroundButton.rightAnchor constraintEqualToAnchor:localBackgroundButton.rightAnchor],
    [urlBackgroundButton.heightAnchor constraintEqualToConstant:42]
  ]];

  UIButton *clearBackgroundButton = [self incomingBackgroundButtonWithTitle:@"清空来电背景"];
  [clearBackgroundButton addTarget:self
                            action:@selector(clearIncomingBackground)
                  forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:clearBackgroundButton];
  [NSLayoutConstraint activateConstraints:@[
    [clearBackgroundButton.topAnchor constraintEqualToAnchor:urlBackgroundButton.bottomAnchor constant:10],
    [clearBackgroundButton.leftAnchor constraintEqualToAnchor:localBackgroundButton.leftAnchor],
    [clearBackgroundButton.rightAnchor constraintEqualToAnchor:localBackgroundButton.rightAnchor],
    [clearBackgroundButton.heightAnchor constraintEqualToConstant:42]
  ]];

  self.incomingBackgroundStatusLabel = [[UILabel alloc] init];
  self.incomingBackgroundStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
  self.incomingBackgroundStatusLabel.textColor = [UIColor colorWithWhite:0.75 alpha:1.0];
  self.incomingBackgroundStatusLabel.font = [UIFont systemFontOfSize:13];
  self.incomingBackgroundStatusLabel.numberOfLines = 0;
  self.incomingBackgroundStatusLabel.text = @"当前：默认头像背景";
  [self.view addSubview:self.incomingBackgroundStatusLabel];
  [NSLayoutConstraint activateConstraints:@[
    [self.incomingBackgroundStatusLabel.topAnchor
        constraintEqualToAnchor:clearBackgroundButton.bottomAnchor
                       constant:10],
    [self.incomingBackgroundStatusLabel.leftAnchor constraintEqualToAnchor:localBackgroundButton.leftAnchor],
    [self.incomingBackgroundStatusLabel.rightAnchor constraintEqualToAnchor:localBackgroundButton.rightAnchor]
  ]];
}

// 小窗开关的响应函数
- (void)floatSwitchAction:(UISwitch *)sender {
  // 设置 NECallUIConfig 的 enableFloatingWindow 属性
  // 用于控制是否开启小窗功能
  [[NERtcCallUIKit sharedInstance] setValue:[NSNumber numberWithBool:sender.on]
                                 forKeyPath:@"config.uiConfig.enableFloatingWindow"];
}

// 应用外浮窗开关的响应函数
- (void)floatSwitchOutAppAction:(UISwitch *)sender {
  // 设置 NECallUIConfig 的 enableFloatingWindowOutApp 属性
  // 用于控制是否开启应用外浮窗功能
  [[NERtcCallUIKit sharedInstance] setValue:[NSNumber numberWithBool:sender.on]
                                 forKeyPath:@"config.uiConfig.enableFloatingWindowOutOfApp"];
}

// 被叫预览开关的响应函数
- (void)calleePreviewSwitchAction:(UISwitch *)sender {
  // 设置 NECallUIConfig 的 enableCalleePreview 属性
  // 用于控制是否开启被叫预览功能
  [[NERtcCallUIKit sharedInstance] setValue:[NSNumber numberWithBool:sender.on]
                                 forKeyPath:@"config.uiConfig.enableCalleePreview"];
}

// 虚化开关的响应函数
- (void)blurSwitchAction:(UISwitch *)sender {
  // 设置 NECallUIConfig 的 enableBlur 属性
  // 用于控制是否开启虚化
  [[NERtcCallUIKit sharedInstance] setValue:[NSNumber numberWithBool:sender.on]
                                 forKeyPath:@"config.uiConfig.enableVirtualBackground"];
}

// 来电横幅开关的响应函数
- (void)bannerSwitchAction:(UISwitch *)sender {
  [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"kEnableIncomingBanner"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [[NERtcCallUIKit sharedInstance] enableIncomingBanner:sender.isOn];
}

- (UIButton *)incomingBackgroundButtonWithTitle:(NSString *)title {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
  button.translatesAutoresizingMaskIntoConstraints = NO;
  [button setTitle:title forState:UIControlStateNormal];
  [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
  button.backgroundColor = [UIColor colorWithRed:64 / 255.0
                                           green:64 / 255.0
                                            blue:78 / 255.0
                                           alpha:1.0];
  button.layer.cornerRadius = 6;
  button.layer.borderWidth = 1;
  button.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.16].CGColor;
  return button;
}

- (void)applyLocalIncomingBackground {
  UIImage *image = [UIImage imageNamed:@"custom_answer_bg_local"];
  if (!image) {
    [UIApplication.sharedApplication.keyWindow ne_makeToast:@"本地风景图加载失败"];
    return;
  }
  NECallUIDynamicConfig *config = [[NECallUIDynamicConfig alloc] init];
  config.incomingCallBackground = [NECallUIIncomingBackgroundSource imageSource:image];
  [[NERtcCallUIKit sharedInstance] setDynamicUIConfig:config];
  self.incomingBackgroundStatusLabel.text = @"当前：本地风景图，下一次来电页生效";
  [UIApplication.sharedApplication.keyWindow ne_makeToast:@"已设置本地风景图"];
}

- (void)applyURLIncomingBackground {
  NSURL *url = [NSURL URLWithString:kDemoIncomingBackgroundURL];
  NECallUIDynamicConfig *config = [[NECallUIDynamicConfig alloc] init];
  config.incomingCallBackground = [NECallUIIncomingBackgroundSource urlSource:url];
  [[NERtcCallUIKit sharedInstance] setDynamicUIConfig:config];
  self.incomingBackgroundStatusLabel.text =
      [NSString stringWithFormat:@"当前：URL 风景图，下一次来电页生效\n%@", kDemoIncomingBackgroundURL];
  [UIApplication.sharedApplication.keyWindow ne_makeToast:@"已设置 URL 风景图"];
}

- (void)clearIncomingBackground {
  [[NERtcCallUIKit sharedInstance] setDynamicUIConfig:nil];
  self.incomingBackgroundStatusLabel.text = @"当前：默认头像背景";
  [UIApplication.sharedApplication.keyWindow ne_makeToast:@"已清空来电背景"];
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
