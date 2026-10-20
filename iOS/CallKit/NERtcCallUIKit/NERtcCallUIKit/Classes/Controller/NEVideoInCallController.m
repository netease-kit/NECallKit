// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVideoInCallController.h"
#import "NEAISubtitleView.h"

@interface NEVideoInCallController ()

@property(nonatomic, assign) BOOL didApplyInitialSmallVideoPosition;

@end

@implementation NEVideoInCallController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
}

- (void)setupUI {
  [self.view addSubview:self.bigVideoView];
  [NSLayoutConstraint activateConstraints:@[
    [self.bigVideoView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
    [self.bigVideoView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
    [self.bigVideoView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
    [self.bigVideoView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
  ]];

  [self.view addSubview:self.smallVideoView];

  self.smallVideoView.translatesAutoresizingMaskIntoConstraints = YES;
  CGFloat topInset = self.view.safeAreaInsets.top;
  self.smallVideoView.frame = CGRectMake(self.view.bounds.size.width - 20 - 90,
                                         topInset + 20, 90, 160);
  self.didApplyInitialSmallVideoPosition = topInset > 0;

  self.smallVideoView.clipsToBounds = YES;
  self.smallVideoView.layer.cornerRadius = self.radius;
}

- (void)viewSafeAreaInsetsDidChange {
  [super viewSafeAreaInsetsDidChange];
  if (self.didApplyInitialSmallVideoPosition || self.smallVideoView == nil) {
    return;
  }
  CGRect frame = self.smallVideoView.frame;
  frame.origin.y = self.view.safeAreaInsets.top + 20;
  self.smallVideoView.frame = frame;
  self.didApplyInitialSmallVideoPosition = YES;
}

- (void)refreshUI {
  [self refreshVideoView];
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
