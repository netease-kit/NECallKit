// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// 群呼 UI 状态枚举
///
/// 定义三种群呼 UI 状态：
/// - [calling]: 呼叫中状态（主叫等待被叫接听）
/// - [incoming]: 被叫中状态（被叫收到邀请）
/// - [inCall]: 通话中状态（至少2人已加入）
enum GroupCallUIState {
  /// 呼叫中状态 - 主叫发起群呼后，等待被叫接听
  calling,

  /// 被叫中状态 - 被叫用户收到群呼邀请
  incoming,

  /// 通话中状态 - 至少有2个成员（包括自己）已加入群呼
  inCall,
}
