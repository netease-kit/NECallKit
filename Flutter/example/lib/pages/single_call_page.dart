// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:callkit_example/settings/settings_widget.dart';
import 'package:callkit_example/utils/record_utils.dart';
import 'package:callkit_example/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:callkit_example/l10n/app_localizations.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:nim_core_v2/nim_core.dart';
import 'package:callkit_example/service/call_record_service_impl.dart';
import 'package:callkit_example/service/call_record_service.dart';
import 'package:callkit_example/settings/settings_config.dart';

class SingleCallWidget extends StatefulWidget {
  const SingleCallWidget({Key? key}) : super(key: key);

  @override
  State<SingleCallWidget> createState() => _SingleCallWidgetState();
}

class _SingleCallWidgetState extends State<SingleCallWidget> {
  String _calledUserId = '';
  bool _isAudioCall = true;

  // 添加TextEditingController来控制输入框
  late TextEditingController _userIdController;

  // 通话记录列表
  List<CallRecord> _callRecords = [];
  late StreamSubscription _receiveMessageSubscription;
  late StreamSubscription _receiveMessageModifiedSubscription;
  late StreamSubscription _sendMessageSubscription;
  final CallRecordServiceImpl _callRecordService = CallRecordServiceImpl();

  bool get _isDesktopRuntime => NECallKitUI.instance.isDesktopUiReuseEnabled;

  @override
  void initState() {
    super.initState();
    _userIdController = TextEditingController();
    _receiveMessageSubscription = NimCore
        .instance.messageService.onReceiveMessages
        .listen(_handleRecordMessages);
    _receiveMessageModifiedSubscription = NimCore
        .instance.messageService.onReceiveMessagesModified
        .listen(_handleRecordMessages);
    _sendMessageSubscription =
        NimCore.instance.messageService.onSendMessage.listen((message) async {
      CallRecord? record = await RecordUtils.parseForCallRecord(
        message,
        requireSendSucceeded: true,
      );
      if (record != null) {
        await _addCallRecord(record);
      }
    });
    _loadCallRecords();

    // 页面出现时设置通话超时时间
    _setCallTimeout();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _receiveMessageSubscription.cancel();
    _receiveMessageModifiedSubscription.cancel();
    _sendMessageSubscription.cancel();
    super.dispose();
  }

  Future<void> _handleRecordMessages(List<NIMMessage> messages) async {
    for (final message in messages) {
      final record = await RecordUtils.parseForCallRecord(message);
      if (record != null) {
        await _addCallRecord(record);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.single_call),
          leading: IconButton(
              onPressed: () => _goBack(),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
          actions: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 20),
              child: InkWell(
                onTap: () => _goSettings(),
                child: Text(
                  AppLocalizations.of(context)!.settings,
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff056DF6)),
                ),
              ),
            )
          ]),
      body: Stack(
        children: [
          _getCallParamsWidget(),
          _getCallRecordWidget(),
          _getBtnWidget()
        ],
      ),
    );
  }

  _getCallParamsWidget() {
    return Positioned(
        top: 38,
        left: 10,
        width: MediaQuery.of(context).size.width - 20,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.user_id,
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                Expanded(
                    child: TextField(
                        controller: _userIdController,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context)!.enter_callee_id,
                          border: InputBorder.none,
                        ),
                        onChanged: ((value) => _calledUserId = value)))
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.media_type,
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                Row(children: [
                  Row(
                    children: [
                      Checkbox(
                        value: !_isAudioCall,
                        onChanged: (value) {
                          setState(() {
                            _isAudioCall = !value!;
                          });
                        },
                        shape: const CircleBorder(),
                      ),
                      Text(
                        AppLocalizations.of(context)!.video_call,
                        style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: _isAudioCall,
                        onChanged: (value) {
                          setState(() {
                            _isAudioCall = value!;
                          });
                        },
                        shape: const CircleBorder(),
                      ),
                      Text(
                        AppLocalizations.of(context)!.voice_call,
                        style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ])
              ],
            ),
            if (!_isDesktopRuntime) const SizedBox(height: 45),
          ],
        ));
  }

  _getCallRecordWidget() {
    return Positioned(
        top: 200,
        // 调整位置，在_getCallParamsWidget下方
        left: 10,
        right: 10,
        bottom: 120,
        // 为_getBtnWidget留出空间
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.call_records,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (_callRecords.isNotEmpty)
                  GestureDetector(
                    onTap: _clearCallRecords,
                    child: Text(
                      AppLocalizations.of(context)!.clear,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff056DF6),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _callRecords.isEmpty
                  ? const Center(
                      child: Text(
                        '暂无通话记录',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _callRecords.length,
                      itemBuilder: (context, index) {
                        final record = _callRecords[index];
                        return _buildCallRecordItem(record);
                      },
                    ),
            ),
          ],
        ));
  }

  Widget _buildCallRecordItem(CallRecord record) {
    return GestureDetector(
      onTap: () => _callFromRecord(record),
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!, width: 0.5),
        ),
        child: Row(
          children: [
            // 呼入/呼出图标
            Icon(
              record.isIncoming ? Icons.call_received : Icons.call_made,
              color: record.isIncoming ? Colors.green : Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 12),
            // 对方accountId
            Expanded(
              child: Text(
                record.accountId,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            // 时间
            Text(
              _formatTimestamp(record.timestamp),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            // 通话图标提示 - 根据通话类型显示不同图标
            Icon(
              record.callType == NECallType.video ? Icons.videocam : Icons.call,
              color: const Color(0xff056DF6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (recordDate == today) {
      // 今天显示时间
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
    } else {
      // 其他日期显示完整日期和时间
      return '${timestamp.month}月${timestamp.day}日 ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
    }
  }

  _getBtnWidget() {
    return Positioned(
        left: 0,
        bottom: 50,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 60,
              width: MediaQuery.of(context).size.width * 5 / 6,
              child: ElevatedButton(
                  onPressed: () => _call(),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xff056DF6)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.call),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.call,
                        style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      ),
                    ],
                  )),
            ),
          ],
        ));
  }

  _goBack() {
    Navigator.of(context).pop();
  }

  Future<void> _call() async {
    if (_calledUserId.isNotEmpty) {
      final result = await _placeCallViaPublicEntry(_calledUserId);
      if (result.code != 0 &&
          mounted &&
          !_shouldSuppressDesktopPermissionToast(result)) {
        ToastUtils.showToast(
          context,
          result.message ?? 'Call failed: ${result.code}',
        );
      }
    } else {
      ToastUtils.showToast(context, '请输入对方用户ID');
    }
  }

  Future<void> _callFromRecord(CallRecord record) async {
    // 设置被叫用户ID
    _calledUserId = record.accountId;

    // 更新输入框显示
    _userIdController.text = record.accountId;

    FocusScope.of(context).unfocus();

    // 2. 延迟 100ms 确保键盘完全关闭
    Future.delayed(const Duration(milliseconds: 100), () async {
      // 发起通话
      final result = await _placeCallViaPublicEntry(record.accountId);
      if (result.code != 0 &&
          mounted &&
          !_shouldSuppressDesktopPermissionToast(result)) {
        ToastUtils.showToast(
          context,
          result.message ?? 'Call failed: ${result.code}',
        );
      }
    });
  }

  Future<NEResult> _placeCallViaPublicEntry(String accountId) {
    return NECallKitUI.instance.call(
      accountId,
      _isAudioCall ? NECallType.audio : NECallType.video,
    );
  }

  bool _shouldSuppressDesktopPermissionToast(NEResult result) {
    if (!(Platform.isMacOS || Platform.isWindows)) {
      return false;
    }
    return result.message == NECallKitUI.localizations.permissionResultFail;
  }

  _goSettings() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return const SettingsWidget();
      },
    ));
  }

  // 加载通话记录
  Future<void> _loadCallRecords() async {
    try {
      final records = await _callRecordService.loadCurrentAccountRecords();
      setState(() {
        _callRecords = records;
      });
    } catch (e) {
      debugPrint('Failed to load call records: $e');
    }
  }

  // 添加通话记录并保存
  Future<void> _addCallRecord(CallRecord record) async {
    final added = await _callRecordService.addRecordToCurrentAccount(record);
    if (!added || !mounted) {
      return;
    }
    setState(() {
      _callRecords.remove(record);
      _callRecords.insert(0, record);
    });
  }

  // 清除通话记录
  Future<void> _clearCallRecords() async {
    setState(() {
      _callRecords.clear();
    });

    await _callRecordService.clearCurrentAccountRecords();
  }

  // 设置通话超时时间
  Future<void> _setCallTimeout() async {
    try {
      final timeout = SettingsConfig.normalizeTimeout(SettingsConfig.timeout);
      SettingsConfig.timeout = timeout;
      await NECallEngine.instance.setTimeout(timeout);
      debugPrint('SingleCallWidget: applied timeout=${timeout}s');
    } catch (e) {
      debugPrint('Set timeout failed: $e');
    }
  }
}
