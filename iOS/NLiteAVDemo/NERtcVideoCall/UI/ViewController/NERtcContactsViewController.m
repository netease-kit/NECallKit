// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NERtcContactsViewController.h"
#import <NERtcCallUIKit/NERtcCallUIKit.h>
#import "NEAccount.h"
#import "NECallStatusRecordCell.h"
#import "NECallUISettingViewController.h"
#import "NEPSTNViewController.h"
#import "NERtcSettingViewController.h"
#import "NESearchResultCell.h"
#import "NSArray+NTES.h"
#import "NSMacro.h"
#import "SectionHeaderView.h"

@interface NERtcContactsViewController () <UITextFieldDelegate,
                                           NIMChatManagerDelegate,
                                           UITableViewDelegate,
                                           UITableViewDataSource,
                                           SearchCellDelegate,
                                           NECallViewDelegate>
@property(nonatomic, strong) UIView *searchBarView;
@property(nonatomic, strong) UITextField *textField;
@property(nonatomic, strong) UIButton *videoCallRadioBtn;
@property(nonatomic, strong) UIButton *audioCallRadioBtn;
@property(nonatomic, assign) BOOL isVideoCall;  // YES: 视频呼叫, NO: 音频呼叫

@property(nonatomic, strong) UIView *searchResutlTitleView;

@property(nonatomic, strong) UIView *searchHistroyTitleView;

@property(nonatomic, strong) UIView *recordTitleView;

@property(nonatomic, strong) UILabel *currentUserPhone;

@property(nonatomic, strong) UITableView *contentTable;
/// 最近搜索
@property(nonatomic, strong) NSMutableArray *searchHistoryData;
/// 通话记录
@property(nonatomic, strong) NSMutableArray *recordData;

@property(nonatomic, strong) SectionHeaderView *historyHeader;

@property(nonatomic, strong) SectionHeaderView *recordHeader;

@end

@implementation NERtcContactsViewController

- (instancetype)init {
  self = [super init];
  if (self) {
    self.searchHistoryData = [[NSMutableArray alloc] init];
    self.recordData = [[NSMutableArray alloc] init];
    [self loadHistoryData];
    [self loadRecordData];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  if (self.callKitType == CALLKIT) {
    self.title = @"发起呼叫";
  } else if (self.callKitType == PSTN) {
    self.title = @"发起融合呼叫";
  }
  [self setupContent];
  [self setSetting];
  [self addObserver];
  //  [[NERingPlayerManager shareInstance] playRingWithRingType:CRTRejectRing isRtcPlay:YES];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NERECORDCHANGE object:nil];
}

#pragma mark - UI

- (void)setupContent {
  [self.view addSubview:self.contentTable];
  CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
  [self.contentTable mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.bottom.equalTo(self.view);
    make.top.mas_equalTo(statusHeight + 44);
  }];
  self.contentTable.tableHeaderView = [self getHeaderView];
  self.contentTable.delegate = self;
  self.contentTable.dataSource = self;
  self.contentTable.backgroundColor = [UIColor clearColor];
  self.contentTable.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
  [self.contentTable registerClass:[NESearchResultCell class]
            forCellReuseIdentifier:@"NESearchResultCell"];
  [self.contentTable registerClass:[NECallStatusRecordCell class]
            forCellReuseIdentifier:@"NECallStatusRecordCell"];
}

- (UIView *)getHeaderView {
  // 搜索框与手机号
  UIView *back = [[UIView alloc] init];
  back.backgroundColor = UIColor.clearColor;
  back.frame = CGRectMake(0, 0, self.view.frame.size.width, 40 + 8 + 40 + 50);

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

  UILabel *currentPhoneLabel = [[UILabel alloc] init];
  currentPhoneLabel.textAlignment = NSTextAlignmentLeft;
  currentPhoneLabel.textColor = HEXCOLORA(0xFFFFFF, 0.5);
  currentPhoneLabel.font = [UIFont systemFontOfSize:14.0];
  currentPhoneLabel.text =
      [NSString stringWithFormat:@"您的accoutId：%@", [NEAccount shared].userModel.imAccid];
  [back addSubview:currentPhoneLabel];
  [currentPhoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.searchBarView);
    make.top.equalTo(self.searchBarView.mas_bottom).offset(20);
  }];

  // 添加呼叫类型选择
  UILabel *callTypeLabel = [[UILabel alloc] init];
  callTypeLabel.text = @"呼叫类型";
  callTypeLabel.textColor = HEXCOLORA(0xFFFFFF, 0.5);
  callTypeLabel.font = [UIFont systemFontOfSize:14.0];
  [back addSubview:callTypeLabel];
  [callTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.searchBarView);
    make.top.equalTo(currentPhoneLabel.mas_bottom).offset(15);
  }];

  // 视频呼叫按钮（单选）
  [back addSubview:self.videoCallRadioBtn];
  [self.videoCallRadioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(callTypeLabel.mas_right).offset(20);
    make.centerY.equalTo(callTypeLabel);
    make.width.mas_equalTo(100);
    make.height.mas_equalTo(30);
  }];

  // 音频呼叫按钮（单选）
  [back addSubview:self.audioCallRadioBtn];
  [self.audioCallRadioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.videoCallRadioBtn.mas_right).offset(10);
    make.centerY.equalTo(callTypeLabel);
    make.width.mas_equalTo(100);
    make.height.mas_equalTo(30);
  }];

  return back;
}

- (void)setSetting {
  UIBarButtonItem *rightItem =
      [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting"]
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(goToSettingView)];
  [rightItem setTintColor:UIColor.whiteColor];

  UIBarButtonItem *setting2 = [[UIBarButtonItem alloc] initWithTitle:@"设置2"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(goToUISetting)];
  [setting2 setTintColor:UIColor.whiteColor];
  self.navigationItem.rightBarButtonItems = @[ rightItem, setting2 ];
}

#pragma mark - view conroller change

- (void)goToSettingView {
  NERtcSettingViewController *setting = [[NERtcSettingViewController alloc] init];
  [self.navigationController pushViewController:setting animated:YES];
}

- (void)goToUISetting {
  NECallUISettingViewController *setting = [[NECallUISettingViewController alloc] init];
  [self.navigationController pushViewController:setting animated:YES];
}

#pragma mark - data
- (void)loadHistoryData {
  [self.searchHistoryData removeAllObjects];
  NSArray *records = [self readFileName:historyFileName];
  [self.searchHistoryData addObjectsFromArray:records];
}

- (void)loadRecordData {
  [self.recordData removeAllObjects];
  NSArray *array = [self readFileName:recordFileName];
  [self.recordData addObjectsFromArray:array];
}

- (void)callUser:(NSString *)accountId {
  [self.textField resignFirstResponder];
  if (!accountId.length) {
    [self.view ne_makeToast:@"请输入账号ID"];
    return;
  }

  // 检查是否是自己
  if ([accountId isEqualToString:[NEAccount shared].userModel.imAccid]) {
    [self.view ne_makeToast:@"呼叫用户不可以是自己哦"];
    return;
  }

  // 创建用户对象进行呼叫
  NEUser *user = [[NEUser alloc] init];
  user.imAccid = accountId;

  // 使用选择的呼叫类型
  NECallType callType = self.isVideoCall ? NECallTypeVideo : NECallTypeAudio;
  [self didCallWithUser:user withType:callType];
}

- (void)updateRecord {
  [self loadRecordData];
  [self.contentTable reloadData];
}

#pragma mark - event
- (void)callBtn:(UIButton *)button {
  [self callUser:self.textField.text];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  if (self.textField.isFirstResponder) {
    [self.textField resignFirstResponder];
  }
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self callUser:textField.text];
  return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  return YES;
}
- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
  return YES;
}
- (UITextField *)textField {
  if (!_textField) {
    _textField = [[UITextField alloc] init];
    _textField.backgroundColor = [UIColor clearColor];
    _textField.delegate = self;
    _textField.textColor = [UIColor whiteColor];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]
        initWithString:@"输入账号ID进行呼叫"
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

#pragma mark - SearchCellDelegate
- (void)didSelectSearchUser:(NEUser *)user {
  //    if ([user.imAccid isEqualToString:[NEAccount shared].userModel.imAccid]) {
  //        [self.view ne_makeToast:@"呼叫用户不可以是自己哦"];
  //        return;
  //    }
  //    [self didCallWithUser:user withType:NERtcCallTypeVideo];
}

- (void)didCallWithUser:(NEUser *)user withType:(NECallType)callType {
  if ([user.imAccid isEqualToString:[NEAccount shared].userModel.imAccid]) {
    [self.view ne_makeToast:@"呼叫用户不可以是自己哦"];
    return;
  }

  if ([[NetManager shareInstance] isClose] == YES) {
    [self.view ne_makeToast:@"网络连接异常，请稍后再试"];
    return;
  }

  if ([NECallEngine sharedInstance].callStatus != NECallStatusIdle) {
    [self.view ne_makeToast:@"正在通话中"];
    return;
  }

  NECallUIKitConfig *config = [[NERtcCallUIKit sharedInstance] valueForKey:@"config"];
  if (config.uiConfig.disableShowCalleeView == YES) {
    NEPSTNViewController *callVC = [[NEPSTNViewController alloc] init];
    callVC.localUser = [NEAccount shared].userModel;
    callVC.remoteUser = user;
    callVC.callType = callType;
    callVC.status = NERtcCallStatusCalling;
    callVC.isCaller = YES;
    callVC.delegate = self;
    callVC.callKitType = self.callKitType;
    callVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.navigationController presentViewController:callVC animated:YES completion:nil];
    return;
  }

  NEUICallParam *callParam = [[NEUICallParam alloc] init];
  callParam.remoteUserAccid = user.imAccid;
  callParam.remoteShowName = user.imAccid;  // 使用 accountId 作为显示名称
  callParam.remoteAvatar = user.avatar;
  callParam.channelName = [[SettingManager shareInstance] customChannelName];
  callParam.remoteDefaultImage = [[SettingManager shareInstance] remoteDefaultImage];
  callParam.muteDefaultImage = [[SettingManager shareInstance] muteDefaultImage];
  callParam.extra = [[SettingManager shareInstance] globalExtra];
  callParam.callType = callType;
  [[NERtcCallUIKit sharedInstance] callWithParam:callParam];
}

#pragma mark - file read & write
- (void)saveUser:(NEUser *)user {
  NSArray *array = [self readFileName:historyFileName];
  NSMutableArray *mutArray = [NSMutableArray array];
  [mutArray addObject:user];
  [mutArray addObjectsFromArray:array];
  for (NEUser *saveUser in array) {
    if ([saveUser.imAccid isEqualToString:user.imAccid]) {
      [mutArray removeObject:saveUser];
    }
  }
  while (mutArray.count > RecordCountLimit) {
    [mutArray removeLastObject];
  }
  [self writeToFile:historyFileName array:mutArray];
}

- (void)saveRecord:(NECallStatusRecordModel *)record {
  NSArray *array = [self readFileName:recordFileName];
  [self.recordData removeAllObjects];
  [self.recordData addObject:record];
  if (array.count <= 2) {
    [self.recordData addObjectsFromArray:array];
  } else {
    [self.recordData addObjectsFromArray:[array subarrayWithRange:NSMakeRange(0, 2)]];
  }
  [self writeToFile:recordFileName array:self.recordData];
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

#pragma mark - Observer

- (void)addObserver {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateRecord)
                                               name:NERECORDCHANGE
                                             object:nil];
}

#pragma mark - ui table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;  // 只保留最近搜索和通话记录
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return self.searchHistoryData.count;
  } else if (section == 1) {
    return self.recordData.count;
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
    cell.delegate = self;
    return cell;
  } else if (indexPath.section == 1) {
    NECallStatusRecordCell *cell = (NECallStatusRecordCell *)[tableView
        dequeueReusableCellWithIdentifier:@"NECallStatusRecordCell"
                             forIndexPath:indexPath];
    cell.accessibilityIdentifier = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    NSLog(@"record cell id : %@ ", cell.accessibilityIdentifier);
    NECallStatusRecordModel *model = self.recordData[indexPath.row];
    [cell configure:model];
    return cell;
  }
  return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NEUser *user;
  NECallType callType;

  if (indexPath.section == 0) {
    // 最近搜索：使用用户选择的呼叫类型
    user = self.searchHistoryData[indexPath.row];
    callType = self.isVideoCall ? NECallTypeVideo : NECallTypeAudio;
  } else if (indexPath.section == 1) {
    // 通话记录：使用历史记录中的呼叫类型
    NECallStatusRecordModel *model = self.recordData[indexPath.row];
    user = [[NEUser alloc] init];
    user.imAccid = model.imAccid;
    user.mobile = model.mobile;
    user.avatar = model.avatar;
    // 根据通话记录判断是视频还是音频
    callType = model.isVideoCall ? NECallTypeVideo : NECallTypeAudio;
  }

  if (self.callKitType == CALLKIT) {
    [self didCallWithUser:user withType:callType];
  } else if (self.callKitType == PSTN) {
    [self didCallWithUser:user withType:NECallTypeAudio];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    if (self.searchHistoryData.count > 0) {
      return SectionHeaderView.height;
    }
  }

  if (section == 1) {
    if (self.recordData.count > 0) {
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
  } else if (section == 1) {
    if (self.recordData.count > 0) {
      [self.recordHeader.dividerLine setHidden:NO];
      return self.recordHeader;
    }
  }
  return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
  view.backgroundColor = [UIColor clearColor];
  return view;
}

#pragma mark - lazy init

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

- (SectionHeaderView *)historyHeader {
  if (nil == _historyHeader) {
    _historyHeader = [[SectionHeaderView alloc] init];
    _historyHeader.frame = CGRectMake(0, 0, self.view.frame.size.width, SectionHeaderView.height);
    _historyHeader.titleLabel.text = @"最近搜索";
  }
  return _historyHeader;
}

- (SectionHeaderView *)recordHeader {
  if (nil == _recordHeader) {
    _recordHeader = [[SectionHeaderView alloc] init];
    _recordHeader.frame = CGRectMake(0, 0, self.view.frame.size.width, SectionHeaderView.height);
    _recordHeader.titleLabel.text = @"通话记录";
  }
  return _recordHeader;
}

#pragma mark - lazy init for radio buttons

- (UIButton *)videoCallRadioBtn {
  if (!_videoCallRadioBtn) {
    _videoCallRadioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_videoCallRadioBtn setTitle:@"视频呼叫" forState:UIControlStateNormal];
    [_videoCallRadioBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _videoCallRadioBtn.titleLabel.font = [UIFont systemFontOfSize:14];

    // 单选图标（选中状态：蓝色圆点，未选中：白色圆框）
    [_videoCallRadioBtn setImage:[self createRadioImage:YES] forState:UIControlStateSelected];
    [_videoCallRadioBtn setImage:[self createRadioImage:NO] forState:UIControlStateNormal];
    [_videoCallRadioBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    [_videoCallRadioBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];

    [_videoCallRadioBtn addTarget:self
                           action:@selector(selectVideoCall:)
                 forControlEvents:UIControlEventTouchUpInside];

    // 默认选中视频呼叫
    _videoCallRadioBtn.selected = YES;
    self.isVideoCall = YES;
  }
  return _videoCallRadioBtn;
}

- (UIButton *)audioCallRadioBtn {
  if (!_audioCallRadioBtn) {
    _audioCallRadioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_audioCallRadioBtn setTitle:@"音频呼叫" forState:UIControlStateNormal];
    [_audioCallRadioBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _audioCallRadioBtn.titleLabel.font = [UIFont systemFontOfSize:14];

    // 单选图标
    [_audioCallRadioBtn setImage:[self createRadioImage:YES] forState:UIControlStateSelected];
    [_audioCallRadioBtn setImage:[self createRadioImage:NO] forState:UIControlStateNormal];
    [_audioCallRadioBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    [_audioCallRadioBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];

    [_audioCallRadioBtn addTarget:self
                           action:@selector(selectAudioCall:)
                 forControlEvents:UIControlEventTouchUpInside];
  }
  return _audioCallRadioBtn;
}

// 创建单选图标
- (UIImage *)createRadioImage:(BOOL)selected {
  CGSize size = CGSizeMake(20, 20);
  UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
  CGContextRef context = UIGraphicsGetCurrentContext();

  if (selected) {
    // 选中：蓝色圆点
    CGContextSetFillColorWithColor(
        context,
        [UIColor colorWithRed:57 / 255.0 green:130 / 255.0 blue:252 / 255.0 alpha:1.0].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(4, 4, 12, 12));
  } else {
    // 未选中：白色圆框
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    CGContextAddEllipseInRect(context, CGRectMake(2, 2, 16, 16));
    CGContextStrokePath(context);
  }

  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

// 选择视频呼叫
- (void)selectVideoCall:(UIButton *)button {
  if (self.isVideoCall) return;

  self.isVideoCall = YES;
  self.videoCallRadioBtn.selected = YES;
  self.audioCallRadioBtn.selected = NO;
}

// 选择音频呼叫
- (void)selectAudioCall:(UIButton *)button {
  if (!self.isVideoCall) return;

  self.isVideoCall = NO;
  self.videoCallRadioBtn.selected = NO;
  self.audioCallRadioBtn.selected = YES;
}

#pragma mark - call view status delegate

- (void)didEndCallWithStatusModel:(NECallStatusRecordModel *)model {
  [[NSNotificationCenter defaultCenter] postNotificationName:NERECORDADD object:model];
}
@end
