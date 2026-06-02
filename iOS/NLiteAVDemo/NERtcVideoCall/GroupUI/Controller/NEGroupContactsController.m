// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEGroupContactsController.h"
#import <NERtcCallUIKit/NEGroupUser.h>
#import <NERtcCallUIKit/NEUIGroupCallParam.h>

#import <NERtcCallUIKit/NERtcCallUIKit.h>
#import "Attachment.h"
#import "GroupSettingViewController.h"
#import "GroupUserController.h"
#import "NEAccount.h"
#import "NECallStatusRecordCell.h"
#import "NEPSTNViewController.h"
#import "NERtcSettingViewController.h"
#import "NESearchResultCell.h"
#import "NSArray+NTES.h"
#import "NSMacro.h"
#import "SectionHeaderView.h"

static NSInteger const NEGroupInviteHistoryLimit = 20;
static NSString *const NEGroupInviteHistoryFileName = @"groupInviteHistory";

static NSArray<NSString *> *NEGroupInvitePresetAccounts(void) {
  return @[
    @"yuan01", @"yuan02", @"yuan03", @"yuan04", @"yuan05", @"yuan06", @"yuan07", @"yuan08"
  ];
}

@interface NEGroupContactsController () <UITextFieldDelegate,
                                         NIMChatManagerDelegate,
                                         UITableViewDelegate,
                                         UITableViewDataSource,
                                         SearchCellDelegate,
                                         GroupUserDelegagte,
                                         V2NIMMessageListener>
@property(nonatomic, strong) UIView *searchBarView;
@property(nonatomic, strong) UITextField *textField;
@property(nonatomic, strong) NSString *lastUpdateText;

@property(nonatomic, strong) UIView *searchResutlTitleView;

@property(nonatomic, strong) UIView *searchHistroyTitleView;

@property(nonatomic, strong) UIView *recordTitleView;

@property(nonatomic, strong) UILabel *currentUserPhone;

@property(nonatomic, strong) UITableView *contentTable;
/// 最近搜索
@property(nonatomic, strong) NSMutableArray *searchHistoryData;

@property(nonatomic, strong) UIView *tableHeaderContainer;

@property(nonatomic, strong) UIView *waitingUsersContainer;

@property(nonatomic, strong) NSMutableDictionary<NSString *, NEUser *> *flagDic;

@property(nonatomic, strong) SectionHeaderView *historyHeader;

@property(nonatomic, strong) SectionHeaderView *recordHeader;

@property(nonatomic, strong) GroupUserController *userController;

@property(nonatomic, strong) NEExpandButton *callBtn;

@end

@implementation NEGroupContactsController

- (instancetype)init {
  self = [super init];
  if (self) {
    self.searchHistoryData = [[NSMutableArray alloc] init];
    self.flagDic = [[NSMutableDictionary alloc] init];
    self.inCallUserDic = [[NSMutableDictionary alloc] init];
    [self loadHistoryData];
    self.totalCount = GroupCallUserLimit;
    self.hasJoinCount = 1;
    [[[NIMSDK sharedSDK] v2MessageService] addMessageListener:self];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"发起多人呼叫";
  if (self.calledUsers == nil) {
    self.calledUsers = [[NSMutableArray alloc] init];
  } else {
    for (NEUser *user in self.calledUsers) {
      if (user.imAccid.length > 0) {
        [self.flagDic setObject:user forKey:user.imAccid];
      }
    }
  }
  [self setupContent];
  [self setSetting];
  NSLog(@"current accid : %@", [[NIMSDK sharedSDK].v2LoginService getLoginUser]);
}

- (void)setSetting {
  UIBarButtonItem *rightItem =
      [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting"]
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(goToSettingView)];
  [rightItem setTintColor:UIColor.whiteColor];
  self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)userCountDidChange {
  if ([self.userController getAllUsers].count > 0) {
    _callBtn.hidden = NO;
  } else {
    _callBtn.hidden = YES;
  }
  if (self.isInvite == YES) {
    [_callBtn
        setTitle:[NSString stringWithFormat:@"发起呼叫(%lu/15)",
                                            (unsigned long)[self.userController getAllUsers].count +
                                                15 - self.totalCount]
        forState:UIControlStateNormal];
  } else {
    [_callBtn
        setTitle:[NSString stringWithFormat:@"发起呼叫(%lu/15)",
                                            (unsigned long)[self.userController getAllUsers].count]
        forState:UIControlStateNormal];
  }
  [self refreshTableHeaderView];
}

- (void)backAction:(UIButton *)backButton {
  if (self.isInvite == YES) {
    [self dismissViewControllerAnimated:YES completion:nil];
  } else {
    [self.navigationController popViewControllerAnimated:YES];
  }
}

- (void)goToSettingView {
  GroupSettingViewController *setting = [[GroupSettingViewController alloc] init];
  [self.navigationController pushViewController:setting animated:YES];
}

#pragma mark - UI

- (void)setupContent {
  [self.view addSubview:self.contentTable];
  CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
  [self.contentTable mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.bottom.equalTo(self.view);
    make.top.mas_equalTo(statusHeight + 44);
  }];

  self.userController = [[GroupUserController alloc] init];
  [self addChildViewController:self.userController];
  self.userController.delegate = self;

  self.contentTable.tableHeaderView = [self getHeaderView];
  self.contentTable.delegate = self;
  self.contentTable.dataSource = self;
  self.contentTable.backgroundColor = [UIColor clearColor];
  self.contentTable.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
  [self.contentTable registerClass:[NESearchResultCell class]
            forCellReuseIdentifier:@"NESearchResultCell"];
  [self.contentTable registerClass:[NECallStatusRecordCell class]
            forCellReuseIdentifier:@"NECallStatusRecordCell"];

  [self.view addSubview:self.callBtn];
  [self.callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view).offset(40);
    make.right.equalTo(self.view).offset(-40);
    make.height.mas_equalTo(44);
    make.bottom.equalTo(self.view).offset(-60);
  }];
  if (self.isInvite == YES) {
    [self userCountDidChange];
  }
}

- (UIView *)getHeaderView {
  // 账号ID
  UIView *back = [[UIView alloc] init];
  self.tableHeaderContainer = back;
  back.backgroundColor = UIColor.clearColor;

  [back addSubview:self.searchBarView];
  [self.searchBarView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(20);
    make.right.mas_equalTo(-20);
    make.top.mas_equalTo(8);
    make.height.mas_equalTo(40);
  }];
  [self.searchBarView addSubview:self.textField];
  [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(10);
    make.top.mas_equalTo(0);
    make.height.mas_equalTo(40);
  }];
  UIButton *callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  [callBtn setTitle:@"呼叫" forState:UIControlStateNormal];
  callBtn.titleLabel.font = [UIFont systemFontOfSize:12];
  callBtn.layer.cornerRadius = 4.0;
  callBtn.clipsToBounds = YES;
  callBtn.backgroundColor = [UIColor colorWithRed:57 / 255.0
                                            green:130 / 255.0
                                             blue:252 / 255.0
                                            alpha:1.0];
  [callBtn addTarget:self action:@selector(callBtn:) forControlEvents:UIControlEventTouchUpInside];
  [self.searchBarView addSubview:callBtn];
  [callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(self.textField.mas_right).offset(10);
    make.right.mas_equalTo(-6);
    make.top.mas_equalTo(6);
    make.bottom.mas_equalTo(-6);
    make.width.mas_equalTo(48);
  }];

  self.currentUserPhone = [[UILabel alloc] init];
  self.currentUserPhone.textAlignment = NSTextAlignmentLeft;
  self.currentUserPhone.textColor = HEXCOLORA(0xFFFFFF, 0.5);
  self.currentUserPhone.font = [UIFont systemFontOfSize:14.0];
  self.currentUserPhone.text =
      [NSString stringWithFormat:@"您的accoutId：%@", [NEAccount shared].userModel.imAccid];
  [back addSubview:self.currentUserPhone];
  [self.currentUserPhone mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.searchBarView);
    make.top.equalTo(self.searchBarView.mas_bottom).offset(20);
  }];

  self.waitingUsersContainer = [[UIView alloc] init];
  self.waitingUsersContainer.backgroundColor = UIColor.clearColor;
  [back addSubview:self.waitingUsersContainer];
  [self refreshTableHeaderView];

  return back;
}

- (CGFloat)waitingUsersHeightWithWidth:(CGFloat)width {
  NSInteger count = [self.userController getAllUsers].count;
  if (count <= 0) {
    return 0;
  }

  CGFloat itemWidth = 80.0;
  CGFloat itemHeight = 30.0;
  CGFloat spacing = 10.0;
  CGFloat horizontalInset = 20.0;
  CGFloat availableWidth = MAX(width - horizontalInset * 2, itemWidth);
  NSInteger itemsPerRow = MAX(1, (NSInteger)floor((availableWidth + spacing) / (itemWidth + spacing)));
  NSInteger rows = (count + itemsPerRow - 1) / itemsPerRow;
  return SectionHeaderView.height + spacing + rows * itemHeight + (rows - 1) * spacing + 16.0;
}

- (void)refreshTableHeaderView {
  if (self.tableHeaderContainer == nil || self.waitingUsersContainer == nil) {
    return;
  }

  CGFloat width = CGRectGetWidth(self.view.bounds);
  CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
  CGFloat minimumHeight = 40 + 8 + 40;
  CGFloat listTopHeight = CGRectGetHeight(self.view.bounds) * 0.5 - statusHeight - 44;
  CGFloat waitingTop = 112.0;
  CGFloat waitingHeight = [self waitingUsersHeightWithWidth:width];
  CGFloat contentHeight = waitingHeight > 0 ? waitingTop + waitingHeight : minimumHeight;
  CGFloat headerHeight = MAX(contentHeight, listTopHeight);

  self.tableHeaderContainer.frame = CGRectMake(0, 0, width, headerHeight);
  self.waitingUsersContainer.frame = CGRectMake(0, waitingTop, width, waitingHeight);
  [self renderWaitingUsersWithWidth:width];

  if (self.contentTable.tableHeaderView == self.tableHeaderContainer) {
    self.contentTable.tableHeaderView = self.tableHeaderContainer;
  }
}

- (void)renderWaitingUsersWithWidth:(CGFloat)width {
  [self.waitingUsersContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  NSArray<NEUser *> *users = [[self.userController getAllUsers] copy];
  if (users.count <= 0) {
    return;
  }

  CGFloat horizontalInset = 20.0;
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalInset, 0, width - horizontalInset * 2, SectionHeaderView.height)];
  titleLabel.text = kWaittingCalledUser;
  titleLabel.textColor = UIColor.whiteColor;
  titleLabel.font = [UIFont systemFontOfSize:14.0];
  [self.waitingUsersContainer addSubview:titleLabel];

  CGFloat itemWidth = 80.0;
  CGFloat itemHeight = 30.0;
  CGFloat spacing = 10.0;
  CGFloat availableWidth = MAX(width - horizontalInset * 2, itemWidth);
  NSInteger itemsPerRow = MAX(1, (NSInteger)floor((availableWidth + spacing) / (itemWidth + spacing)));
  CGFloat startY = SectionHeaderView.height + spacing;

  [users enumerateObjectsUsingBlock:^(NEUser *_Nonnull user, NSUInteger idx, BOOL *_Nonnull stop) {
    NSInteger row = idx / itemsPerRow;
    NSInteger column = idx % itemsPerRow;
    CGFloat x = horizontalInset + column * (itemWidth + spacing);
    CGFloat y = startY + row * (itemHeight + spacing);

    UILabel *accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, itemWidth, itemHeight)];
    accountLabel.text = user.imAccid ?: user.mobile ?: @"";
    accountLabel.textAlignment = NSTextAlignmentCenter;
    accountLabel.textColor = UIColor.whiteColor;
    accountLabel.font = [UIFont systemFontOfSize:10.0];
    accountLabel.numberOfLines = 0;
    accountLabel.adjustsFontSizeToFitWidth = YES;
    accountLabel.minimumScaleFactor = 0.8;
    accountLabel.backgroundColor = [UIColor colorWithRed:0.22 green:0.29 blue:0.40 alpha:1.0];
    accountLabel.layer.cornerRadius = 4.0;
    accountLabel.clipsToBounds = YES;
    [self.waitingUsersContainer addSubview:accountLabel];
  }];
}

- (void)didSelectSearchUser:(NEUser *)user {
}

#pragma mark - user controller delegate

- (void)didRemoveWithUser:(NEUser *)user {
  [self.flagDic removeObjectForKey:user.imAccid];
  [self toggleInputAccountId:user.imAccid selected:NO];
  [self.contentTable reloadData];
  [self userCountDidChange];
}

#pragma mark - data
- (void)loadHistoryData {
  [self.searchHistoryData removeAllObjects];
  NSArray *records = [self readFileName:NEGroupInviteHistoryFileName];
  [self.searchHistoryData addObjectsFromArray:[self normalizedUsersFromUsers:records]];
  for (NSString *accountId in NEGroupInvitePresetAccounts()) {
    if (![self containsHistoryAccountId:accountId]) {
      [self.searchHistoryData addObject:[self userWithAccountId:accountId]];
    }
  }
  while (self.searchHistoryData.count > NEGroupInviteHistoryLimit) {
    [self.searchHistoryData removeLastObject];
  }
}

#pragma mark - event
- (void)callBtn:(UIButton *)button {
  // 直接发起呼叫
  if ([self.userController getAllUsers].count <= 0) {
    [[UIApplication sharedApplication].keyWindow ne_makeToast:@"请选择通话成员"];
    return;
  }

  [self saveRecentAccounts:[self selectedAccountIds]];
  if (self.isInvite == YES) {
    if (self.completion) {
      self.completion([self.userController getAllUsers]);
    }
    [self backAction:nil];
  } else {
    NSLog(@"current user : %@", [NEAccount shared].userModel);

    // 获取被叫用户ID列表
    NSMutableArray<NSString *> *remoteUserIds = [[NSMutableArray alloc] init];
    NSArray<NEUser *> *allValues = [self.flagDic allValues];
    for (NEUser *user in allValues) {
      if (user.imAccid.length > 0) {
        [remoteUserIds addObject:user.imAccid];
      }
    }

    // 创建群组通话参数（使用最新的简化接口）
    NEUIGroupCallParam *groupCallParam = [[NEUIGroupCallParam alloc] init];
    groupCallParam.remoteUsers = remoteUserIds;

    // 发起群组通话（主叫用户信息会自动获取）
    [[NERtcCallUIKit sharedInstance] groupCallWithParam:groupCallParam];
  }
}

- (void)updateCallingList:(NSString *)inputText {
  if (!inputText || inputText.length == 0) {
    // 清空待呼叫列表
    [self.userController removeUsers:[[self.userController getAllUsers] copy]];
    [self.flagDic removeAllObjects];
    [self userCountDidChange];
    [self.contentTable reloadData];
    return;
  }

  // 解析输入的 accountIds
  NSArray *accountIds = [self parseAccountIds:inputText];

  // 检查是否包含自己
  NSString *currentAccid = [NEAccount shared].userModel.imAccid;

  // 先移除所有不在新列表中的用户
  NSMutableArray *toRemove = [[NSMutableArray alloc] init];
  for (NSString *imAccid in self.flagDic.allKeys) {
    if (![accountIds containsObject:imAccid]) {
      [toRemove addObject:[self.flagDic objectForKey:imAccid]];
    }
  }
  [self.userController removeUsers:toRemove];
  for (NEUser *user in toRemove) {
    [self.flagDic removeObjectForKey:user.imAccid];
  }

  // 添加新用户
  NSMutableArray *toAdd = [[NSMutableArray alloc] init];
  for (NSString *accountId in accountIds) {
    if (!accountId || accountId.length == 0) {
      continue;
    }

    // 跳过自己
    if ([accountId isEqualToString:currentAccid]) {
      continue;
    }

    // 如果已经存在，跳过
    if ([self.flagDic objectForKey:accountId]) {
      continue;
    }

    // 检查人数限制
    if (self.ignoresMemberLimit == NO &&
        (self.hasJoinCount + [self.userController getAllUsers].count + toAdd.count) >=
        GroupCallUserLimit) {
      break;  // 达到限制，停止添加
    }

    // 创建新用户对象
    NEUser *user = [[NEUser alloc] init];
    user.imAccid = accountId;
    user.mobile = accountId;
    [toAdd addObject:user];
    [self.flagDic setObject:user forKey:accountId];
  }

  if (toAdd.count > 0) {
    [self.userController addUsers:toAdd];
  }

  [self userCountDidChange];
  [self.contentTable reloadData];
}

- (NSArray *)parseAccountIds:(NSString *)inputText {
  NSCharacterSet *separators =
      [NSCharacterSet characterSetWithCharactersInString:@",，;； \n\t"];
  NSArray *components = [inputText componentsSeparatedByCharactersInSet:separators];

  NSMutableArray *accountIds = [[NSMutableArray alloc] init];
  for (NSString *component in components) {
    NSString *trimmed = [component
        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmed.length > 0 && ![accountIds containsObject:trimmed]) {
      [accountIds addObject:trimmed];
    }
  }

  return [accountIds copy];
}

- (NEUser *)userWithAccountId:(NSString *)accountId {
  NEUser *user = [[NEUser alloc] init];
  user.imAccid = accountId;
  user.mobile = accountId;
  return user;
}

- (NSArray<NEUser *> *)normalizedUsersFromUsers:(NSArray *)users {
  NSMutableArray<NEUser *> *result = [NSMutableArray array];
  NSMutableSet<NSString *> *seenAccountIds = [NSMutableSet set];
  for (NEUser *user in users) {
    if (![user isKindOfClass:NEUser.class] || user.imAccid.length <= 0) {
      continue;
    }
    NSString *accountId = [user.imAccid
        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (accountId.length <= 0 || [seenAccountIds containsObject:accountId]) {
      continue;
    }
    [seenAccountIds addObject:accountId];
    NEUser *normalizedUser = [self userWithAccountId:accountId];
    normalizedUser.avatar = user.avatar;
    normalizedUser.imToken = user.imToken;
    normalizedUser.avRoomUid = user.avRoomUid;
    [result addObject:normalizedUser];
  }
  return result;
}

- (BOOL)containsHistoryAccountId:(NSString *)accountId {
  for (NEUser *user in self.searchHistoryData) {
    if ([user.imAccid isEqualToString:accountId]) {
      return YES;
    }
  }
  return NO;
}

- (NSArray<NSString *> *)selectedAccountIds {
  NSMutableArray<NSString *> *accountIds = [NSMutableArray array];
  for (NEUser *user in [self.userController getAllUsers]) {
    if (user.imAccid.length > 0 && ![accountIds containsObject:user.imAccid]) {
      [accountIds addObject:user.imAccid];
    }
  }
  return accountIds;
}

- (void)saveRecentAccounts:(NSArray<NSString *> *)accountIds {
  if (accountIds.count <= 0) {
    return;
  }

  NSMutableArray<NEUser *> *mergedUsers = [NSMutableArray array];
  NSMutableSet<NSString *> *seenAccountIds = [NSMutableSet set];
  void (^appendAccount)(NSString *) = ^(NSString *accountId) {
    NSString *trimmedAccountId = [accountId
        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedAccountId.length <= 0 || [seenAccountIds containsObject:trimmedAccountId]) {
      return;
    }
    [seenAccountIds addObject:trimmedAccountId];
    [mergedUsers addObject:[self userWithAccountId:trimmedAccountId]];
  };

  for (NSString *accountId in accountIds) {
    appendAccount(accountId);
  }
  for (NEUser *user in self.searchHistoryData) {
    appendAccount(user.imAccid);
  }
  for (NSString *accountId in NEGroupInvitePresetAccounts()) {
    appendAccount(accountId);
  }
  while (mergedUsers.count > NEGroupInviteHistoryLimit) {
    [mergedUsers removeLastObject];
  }

  [self.searchHistoryData removeAllObjects];
  [self.searchHistoryData addObjectsFromArray:mergedUsers];
  [self writeToFile:NEGroupInviteHistoryFileName array:self.searchHistoryData];
  [self.contentTable reloadData];
}

- (void)refreshInputWithAccountIds:(NSArray<NSString *> *)accountIds {
  NSString *inputText = [accountIds componentsJoinedByString:@","];
  self.textField.text = inputText;
  self.lastUpdateText = inputText;
  [self updateCallingList:inputText];
}

- (void)toggleInputAccountId:(NSString *)accountId selected:(BOOL)selected {
  NSMutableArray<NSString *> *accountIds = [[self parseAccountIds:self.textField.text] mutableCopy];
  if (selected) {
    if (![accountIds containsObject:accountId]) {
      [accountIds addObject:accountId];
    }
  } else {
    [accountIds removeObject:accountId];
  }
  [self refreshInputWithAccountIds:accountIds];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  if (self.textField.isFirstResponder) {
    [self.textField resignFirstResponder];
  }
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  // 收起键盘，然后直接呼叫
  [self.textField resignFirstResponder];
  [self callBtn:nil];  // 触发呼叫按钮逻辑
  return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  return YES;
}
- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
  // 延迟更新，避免 range 错误
  dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *currentText = textField.text ?: @"";
        if (![self.lastUpdateText isEqualToString:currentText]) {
          self.lastUpdateText = currentText;
          [self updateCallingList:currentText];
        }
      });
  return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
  self.lastUpdateText = @"";
  [self updateCallingList:@""];
  [self.contentTable reloadData];
  return YES;
}
- (UITextField *)textField {
  if (!_textField) {
    _textField = [[UITextField alloc] init];
    _textField.backgroundColor = [UIColor clearColor];
    _textField.delegate = self;
    _textField.textColor = [UIColor whiteColor];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]
        initWithString:@"输入账号ID，多个账号用逗号隔开"
            attributes:@{
              NSForegroundColorAttributeName : [UIColor grayColor],
              NSFontAttributeName : _textField.font
            }];
    _textField.attributedPlaceholder = string;
    _textField.layer.cornerRadius = 8;

    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.returnKeyType = UIReturnKeyGo;
    _textField.keyboardType = UIKeyboardTypeDefault;
  }
  return _textField;
}

#pragma mark - file read & write
- (void)saveUser:(NEUser *)user {
  NSArray *array = [self readFileName:NEGroupInviteHistoryFileName];
  NSMutableArray *mutArray = [NSMutableArray array];
  [mutArray addObject:user];
  [mutArray addObjectsFromArray:array];
  for (NEUser *saveUser in array) {
    if ([saveUser.imAccid isEqualToString:user.imAccid]) {
      [mutArray removeObject:saveUser];
    }
  }
  while (mutArray.count > NEGroupInviteHistoryLimit) {
    [mutArray removeLastObject];
  }
  [self writeToFile:NEGroupInviteHistoryFileName array:mutArray];
}

- (NSArray *)readFileName:(NSString *)fileName {
  NEUser *user = [NEAccount shared].userModel;
  fileName = [NSString stringWithFormat:@"%@_%@", fileName, user.imAccid];
  NSArray *array = [NSArray readArchiveFile:fileName];
  return array;
}

- (void)writeToFile:(NSString *)fileName array:(NSArray *)array {
  NEUser *user = [NEAccount shared].userModel;
  fileName = [NSString stringWithFormat:@"%@_%@", fileName, user.imAccid];
  [array writeToFile:fileName];
}

- (void)didCall {
  if ([self.userController getAllUsers].count <= 0) {
    [[UIApplication sharedApplication].keyWindow ne_makeToast:@"请选择通话成员"];
    return;
  }

  [self saveRecentAccounts:[self selectedAccountIds]];
  if (self.isInvite == YES) {
    if (self.completion) {
      self.completion([self.userController getAllUsers]);
    }
    [self backAction:nil];
  } else {
    NSLog(@"current user : %@", [NEAccount shared].userModel);

    // 获取被叫用户ID列表
    NSMutableArray<NSString *> *remoteUserIds = [[NSMutableArray alloc] init];
    NSArray<NEUser *> *allValues = [self.flagDic allValues];
    for (NEUser *user in allValues) {
      if (user.imAccid.length > 0) {
        [remoteUserIds addObject:user.imAccid];
      }
    }

    // 创建群组通话参数（使用最新的简化接口）
    NEUIGroupCallParam *groupCallParam = [[NEUIGroupCallParam alloc] init];
    groupCallParam.remoteUsers = remoteUserIds;

    // 发起群组通话（主叫用户信息会自动获取）
    [[NERtcCallUIKit sharedInstance] groupCallWithParam:groupCallParam];
  }
}

#pragma mark - 转换方法
// 注意：convertToGroupUser 方法已移除，用户信息转换现在在 NERtcCallUIKit 内部处理

#pragma mark - ui table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;  // 只保留最近搜索
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return self.searchHistoryData.count;
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    NEUser *user = self.searchHistoryData[indexPath.row];
    NESearchResultCell *cell =
        (NESearchResultCell *)[tableView dequeueReusableCellWithIdentifier:@"NESearchResultCell"
                                                              forIndexPath:indexPath];
    [cell configureUI:user];
    NEUser *calledUser = [self.flagDic objectForKey:user.imAccid];
    if (calledUser != nil) {
      [cell setGrayBtn];
    } else {
      [cell setBlueBtn];
    }

    NEUser *inCallUser = [self.inCallUserDic objectForKey:user.imAccid];
    if (inCallUser != nil) {
      [cell setConectting];
    }
    cell.delegate = self;
    return cell;
  }
  return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    NEUser *user = self.searchHistoryData[indexPath.row];

    if ([user.imAccid isEqualToString:[NIMSDK.sharedSDK.v2LoginService getLoginUser]]) {
      [UIApplication.sharedApplication.keyWindow ne_makeToast:@"不能呼叫自己"];
      return;
    }
    NEUser *inCallUser = [self.inCallUserDic objectForKey:user.imAccid];
    if (inCallUser != nil) {
      return;
    }

    NEUser *calledUser = [self.flagDic objectForKey:user.imAccid];
    if (calledUser == nil) {
      if (self.ignoresMemberLimit == NO &&
          (self.hasJoinCount + [self.userController getAllUsers].count) >= GroupCallUserLimit) {
        [UIApplication.sharedApplication.keyWindow ne_makeToast:@"邀请已达上限"];
        return;
      }
      [self.userController addUsers:@[ user ]];
      [self.flagDic setObject:user forKey:user.imAccid];
      [self toggleInputAccountId:user.imAccid selected:YES];
      [tableView reloadData];
    } else {
      [self.userController removeUsers:@[ calledUser ]];
      [self.flagDic removeObjectForKey:user.imAccid];
      [self toggleInputAccountId:user.imAccid selected:NO];
      [tableView reloadData];
    }
    [self userCountDidChange];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    if (self.searchHistoryData.count > 0) {
      return SectionHeaderView.height;
    }
  }
  return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    if (self.searchHistoryData.count > 0) {
      [self.historyHeader.dividerLine setHidden:NO];
      return self.historyHeader;
    }
  }
  return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 44.0;
}

#pragma mark - lazy init

- (NEExpandButton *)callBtn {
  if (!_callBtn) {
    _callBtn = [[NEExpandButton alloc] init];
    [_callBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _callBtn.backgroundColor = HEXCOLOR(0x337EFF);
    _callBtn.layer.cornerRadius = 2.0;
    _callBtn.clipsToBounds = YES;
    [_callBtn setTitle:@"发起呼叫(0/15)" forState:UIControlStateNormal];
    [_callBtn addTarget:self
                  action:@selector(didCall)
        forControlEvents:UIControlEventTouchUpInside];
    _callBtn.hidden = YES;
  }
  return _callBtn;
}

- (UIView *)searchBarView {
  if (!_searchBarView) {
    _searchBarView = [[UIView alloc] init];
    _searchBarView.backgroundColor = [UIColor colorWithRed:57 / 255.0
                                                     green:57 / 255.0
                                                      blue:69 / 255.0
                                                     alpha:1.0];
    _searchBarView.layer.cornerRadius = 8;
  }
  return _searchBarView;
}

- (UITableView *)contentTable {
  if (nil == _contentTable) {
    _contentTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _contentTable.delegate = self;
    _contentTable.dataSource = self;
    _contentTable.separatorColor = [UIColor clearColor];
  }
  return _contentTable;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  return 0;
}

- (SectionHeaderView *)historyHeader {
  if (nil == _historyHeader) {
    _historyHeader = [[SectionHeaderView alloc] init];
    _historyHeader.frame = CGRectMake(0, 0, self.view.frame.size.width, SectionHeaderView.height);
    _historyHeader.titleLabel.text = @"最近邀请";
  }
  return _historyHeader;
}

- (SectionHeaderView *)recordHeader {
  if (nil == _recordHeader) {
    _recordHeader = [[SectionHeaderView alloc] init];
    _recordHeader.frame = CGRectMake(0, 0, self.view.frame.size.width, SectionHeaderView.height);
    _recordHeader.titleLabel.text = kWaittingCalledUser;
  }
  return _recordHeader;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
  view.backgroundColor = [UIColor clearColor];
  return view;
}

#pragma mark - call view status delegate

- (void)didEndCallWithStatusModel:(NECallStatusRecordModel *)model {
  [[NSNotificationCenter defaultCenter] postNotificationName:NERECORDADD object:model];
}

@end
