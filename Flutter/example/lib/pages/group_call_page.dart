// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:callkit_example/utils/toast_utils.dart';
import 'package:callkit_example/auth/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';

/// 群呼模式
enum GroupCallMode {
  /// 发起群呼
  initiate,

  /// 加入群呼
  join,
}

/// 群呼测试页面
class GroupCallPage extends StatefulWidget {
  const GroupCallPage({Key? key}) : super(key: key);

  @override
  State<GroupCallPage> createState() => _GroupCallPageState();
}

class _GroupCallPageState extends State<GroupCallPage> {
  /// 当前模式
  GroupCallMode _mode = GroupCallMode.initiate;

  /// CallId 输入控制器
  final TextEditingController _callIdController = TextEditingController();

  /// 手动输入联系人控制器
  final TextEditingController _contactInputController = TextEditingController();

  /// 已选择的联系人
  final Set<String> _selectedContacts = {};

  /// 手动添加的联系人
  final List<String> _manualContacts = [];

  /// 预设联系人列表
  static final List<String> _presetContacts = [];

  /// 获取全部联系人列表（手动添加 + 预设）
  List<String> get _allContacts => [..._manualContacts, ..._presetContacts];

  /// 获取过滤后的联系人列表（排除当前登录账号）
  List<String> get _filteredContacts {
    final currentAccount = AuthManager().accountId;
    if (currentAccount == null || currentAccount.isEmpty) {
      return _allContacts;
    }
    return _allContacts.where((c) => c != currentAccount).toList();
  }

  /// 是否正在加载
  bool _isLoading = false;

  @override
  void dispose() {
    _callIdController.dispose();
    _contactInputController.dispose();
    super.dispose();
  }

  /// 构建联系人输入框
  Widget _buildContactInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _contactInputController,
              decoration: InputDecoration(
                hintText: '输入账号ID，多个用逗号分隔',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (_) => _addManualContact(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _addManualContact,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff056DF6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('添加', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// 添加手动输入的联系人
  void _addManualContact() {
    final input = _contactInputController.text.trim();
    if (input.isEmpty) return;
    // 支持逗号、空格分隔的多个账号
    final ids = input
        .split(RegExp(r'[,，\s]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final currentAccount = AuthManager().accountId;
    int added = 0;
    for (final id in ids) {
      if (id == currentAccount) continue;
      if (_manualContacts.contains(id) || _presetContacts.contains(id)) continue;
      _manualContacts.add(id);
      _selectedContacts.add(id); // 手动添加的默认选中
      added++;
    }
    _contactInputController.clear();
    setState(() {});
    if (added > 0) {
      ToastUtils.showToast(context, '已添加 $added 个联系人');
    } else {
      ToastUtils.showToast(context, '联系人已存在或无效');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark, // 深色图标
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('群呼测试'),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark, // 深色图标
            systemStatusBarContrastEnforced: false,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark, // 浅色图标
            systemNavigationBarContrastEnforced: false,
          ),
        ),
        body: Column(
          children: [
            _buildModeSelector(),
            if (_mode == GroupCallMode.join) _buildCallIdInput(),
            if (_mode == GroupCallMode.initiate) _buildContactInput(),
            if (_mode == GroupCallMode.initiate)
              Expanded(child: _buildContactList()),
            if (_mode == GroupCallMode.join) const Spacer(),
            _buildActionButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 构建模式选择器
  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text('模式：', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 16),
          Expanded(
            child: SegmentedButton<GroupCallMode>(
              segments: const [
                ButtonSegment(
                  value: GroupCallMode.initiate,
                  label: Text('发起'),
                  icon: Icon(Icons.add_call),
                ),
                ButtonSegment(
                  value: GroupCallMode.join,
                  label: Text('加入'),
                  icon: Icon(Icons.login),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (Set<GroupCallMode> selected) {
                setState(() {
                  _mode = selected.first;
                  _selectedContacts.clear();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建 CallId 输入框
  Widget _buildCallIdInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text('CallId：', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _callIdController,
              decoration: InputDecoration(
                hintText: '请输入 CallId',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      _callIdController.text = data!.text!;
                    }
                  },
                  tooltip: '粘贴',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建联系人列表
  Widget _buildContactList() {
    final contacts = _filteredContacts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '选择联系人 (${_selectedContacts.length}/${contacts.length})',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedContacts.addAll(contacts);
                      });
                    },
                    child: const Text('全选'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedContacts.clear();
                      });
                    },
                    child: const Text('清空'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              final isSelected = _selectedContacts.contains(contact);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getAvatarColor(contact),
                  child: Text(
                    contact.substring(0, 2).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                title: Text(contact),
                trailing: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedContacts.add(contact);
                      } else {
                        _selectedContacts.remove(contact);
                      }
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedContacts.remove(contact);
                    } else {
                      _selectedContacts.add(contact);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// 根据联系人名称获取头像颜色
  Color _getAvatarColor(String name) {
    if (name.startsWith('lcd')) {
      return Colors.blue;
    } else if (name.startsWith('lqj')) {
      return Colors.green;
    } else if (name.startsWith('wulei')) {
      return Colors.orange;
    } else {
      return Colors.purple;
    }
  }

  /// 构建操作按钮
  Widget _buildActionButton() {
    String buttonText;
    IconData buttonIcon;

    switch (_mode) {
      case GroupCallMode.initiate:
        buttonText = '发起群呼';
        buttonIcon = Icons.call;
        break;
      case GroupCallMode.join:
        buttonText = '加入群呼';
        buttonIcon = Icons.login;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _onActionPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff056DF6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(buttonIcon, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// 操作按钮点击处理
  Future<void> _onActionPressed() async {
    switch (_mode) {
      case GroupCallMode.initiate:
        await _initiateGroupCall();
        break;
      case GroupCallMode.join:
        await _joinGroupCall();
        break;
    }
  }

  /// 发起群呼
  Future<void> _initiateGroupCall() async {
    if (_selectedContacts.isEmpty) {
      ToastUtils.showToast(context, '请至少选择一位联系人');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final param = NEGroupCallParam(
        calleeList: _selectedContacts.toList(),
        groupType: NEGroupCallGroupType.NORMAL_TEAM,
      );

      // 使用 NECallKitUI 接口，注入邀请回调
      final result = await NECallKitUI.instance.groupCall(
        param,
        onInvitePressed: (callId) {
          // 邀请回调触发时，打开邀请页面
          _openInvitePage(callId);
        },
      );

      if (result.code == 0) {
        ToastUtils.showToast(
            context, '发起成功，CallId: ${result.callInfo?.callId}');
      } else {
        ToastUtils.showToast(context, '发起失败: ${result.msg ?? result.code}');
      }
    } catch (e) {
      ToastUtils.showToast(context, '发起异常: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 加入群呼
  Future<void> _joinGroupCall() async {
    final callId = _callIdController.text.trim();
    if (callId.isEmpty) {
      ToastUtils.showToast(context, '请输入 CallId');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final param = NEGroupJoinParam(callId: callId);

      // 使用 NECallKitUI 接口，注入邀请回调
      final result = await NECallKitUI.instance.groupJoin(
        param,
        onInvitePressed: (callId) {
          // 邀请回调触发时，打开邀请页面
          _openInvitePage(callId);
        },
      );

      if (result.code == 0) {
        ToastUtils.showToast(context, '加入成功');
      } else {
        ToastUtils.showToast(context, '加入失败: ${result.msg ?? result.code}');
      }
    } catch (e) {
      ToastUtils.showToast(context, '加入异常: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 打开邀请页面
  void _openInvitePage(String callId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupCallInvitePage(callId: callId),
      ),
    );
  }
}

/// 群呼邀请页面（仅在邀请回调触发时显示）
class GroupCallInvitePage extends StatefulWidget {
  final String callId;

  const GroupCallInvitePage({Key? key, required this.callId}) : super(key: key);

  @override
  State<GroupCallInvitePage> createState() => _GroupCallInvitePageState();
}

class _GroupCallInvitePageState extends State<GroupCallInvitePage> {
  /// 已选择的联系人
  final Set<String> _selectedContacts = {};

  /// 手动输入联系人控制器
  final TextEditingController _contactInputController = TextEditingController();

  /// 手动添加的联系人
  final List<String> _manualContacts = [];

  /// 预设联系人列表
  static final List<String> _presetContacts = [];

  /// 获取全部联系人列表（手动添加 + 预设）
  List<String> get _allContacts => [..._manualContacts, ..._presetContacts];

  /// 获取过滤后的联系人列表（排除当前登录账号）
  List<String> get _filteredContacts {
    final currentAccount = AuthManager().accountId;
    if (currentAccount == null || currentAccount.isEmpty) {
      return _allContacts;
    }
    return _allContacts.where((c) => c != currentAccount).toList();
  }

  /// 是否正在加载
  bool _isLoading = false;

  @override
  void dispose() {
    _contactInputController.dispose();
    super.dispose();
  }

  /// 添加手动输入的联系人
  void _addManualContact() {
    final input = _contactInputController.text.trim();
    if (input.isEmpty) return;
    final ids = input
        .split(RegExp(r'[,，\s]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final currentAccount = AuthManager().accountId;
    int added = 0;
    for (final id in ids) {
      if (id == currentAccount) continue;
      if (_manualContacts.contains(id) || _presetContacts.contains(id)) continue;
      _manualContacts.add(id);
      _selectedContacts.add(id);
      added++;
    }
    _contactInputController.clear();
    setState(() {});
    if (added > 0) {
      ToastUtils.showToast(context, '已添加 $added 个联系人');
    } else {
      ToastUtils.showToast(context, '联系人已存在或无效');
    }
  }

  /// 构建联系人输入框
  Widget _buildContactInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _contactInputController,
              decoration: InputDecoration(
                hintText: '输入账号ID，多个用逗号分隔',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (_) => _addManualContact(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _addManualContact,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff28A745),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('添加', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark, // 深色图标
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('邀请成员'),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        body: Column(
          children: [
            // 显示当前 CallId
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('CallId：', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.callId,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.callId));
                      ToastUtils.showToast(context, 'CallId 已复制');
                    },
                    tooltip: '复制',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 手动输入联系人
            _buildContactInput(),
            // 联系人列表
            Expanded(child: _buildContactList()),
            // 邀请按钮
            _buildInviteButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 构建联系人列表
  Widget _buildContactList() {
    final contacts = _filteredContacts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '选择联系人 (${_selectedContacts.length}/${contacts.length})',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedContacts.addAll(contacts);
                      });
                    },
                    child: const Text('全选'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedContacts.clear();
                      });
                    },
                    child: const Text('清空'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              final isSelected = _selectedContacts.contains(contact);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getAvatarColor(contact),
                  child: Text(
                    contact.substring(0, 2).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                title: Text(contact),
                trailing: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedContacts.add(contact);
                      } else {
                        _selectedContacts.remove(contact);
                      }
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedContacts.remove(contact);
                    } else {
                      _selectedContacts.add(contact);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// 根据联系人名称获取头像颜色
  Color _getAvatarColor(String name) {
    if (name.startsWith('lcd')) {
      return Colors.blue;
    } else if (name.startsWith('lqj')) {
      return Colors.green;
    } else if (name.startsWith('wulei')) {
      return Colors.orange;
    } else {
      return Colors.purple;
    }
  }

  /// 构建邀请按钮
  Widget _buildInviteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _inviteMembers,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff28A745),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      '邀请成员',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// 邀请成员
  Future<void> _inviteMembers() async {
    if (_selectedContacts.isEmpty) {
      ToastUtils.showToast(context, '请至少选择一位联系人');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 使用 NECallKitUI 公共接口邀请成员（自动过滤已在通话中的用户，检查人数上限）
      final result =
          await NECallKitUI.instance.groupInvite(_selectedContacts.toList());

      if (result.code == 0) {
        ToastUtils.showToast(context, '邀请成功');
        Navigator.of(context).pop(); // 邀请成功后关闭页面
      } else {
        ToastUtils.showToast(context, '邀请失败: ${result.msg ?? result.code}');
      }
    } catch (e) {
      ToastUtils.showToast(context, '邀请异常: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
