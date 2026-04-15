// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Flutter
import Foundation
import NERtcCallKit
import NERtcSDK
import NIMSDK

/// 群呼平台桥接类
///
/// 实现 Pigeon 生成的 FLTGroupCallKitApi 协议，
/// 将 Flutter 调用转发到原生 SDK。
class FLTGroupCallkit: NSObject, FLTGroupCallKitApi {

    private var eventSink: FLTGroupCallKitEventSink?
    private var mediaEventSink: FLTGroupMediaEventSink?
    private var registrar: FlutterPluginRegistrar?

    // MARK: - 初始化与释放

    func initConfig(_ config: FLTNEGroupConfigParam, completion: @escaping (FLTGroupSimpleResponse?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: init - appKey=\(config.appKey)")

        // 创建群呼配置
        let groupConfig = GroupConfigParam()
        groupConfig.appid = config.appKey
        if let rtcSafeMode = config.rtcSafeMode {
            groupConfig.rtcSafeMode = rtcSafeMode.boolValue
        }
        if let currentUserRtcUid = config.currentUserRtcUid {
            groupConfig.currentUserUid = currentUserRtcUid.uint64Value
        }

        // 初始化群呼 SDK
        NEGroupCallKit.sharedInstance().setupGroupCall(groupConfig)

        // 添加群呼代理
        NEGroupCallKit.sharedInstance().add(self)

        // 设置 NERtc 媒体回调代理
        // 通过 NECallEngine.engineDelegate 设置 NERtcEngineDelegateEx 实例
        NECallEngine.sharedInstance().engineDelegate = self

        let response = FLTGroupSimpleResponse.make(withCode: NSNumber(value: 0), msg: "Init successful")
        completion(response, nil)
    }

    func release(completion: @escaping (FLTGroupSimpleResponse?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: release")

        // 移除群呼代理
        NEGroupCallKit.sharedInstance().remove(self)

        // 移除 NERtc 媒体回调代理
        NECallEngine.sharedInstance().engineDelegate = nil

        let response = FLTGroupSimpleResponse.make(withCode: NSNumber(value: 0), msg: "Release successful")
        completion(response, nil)
    }

    // MARK: - 群呼基础操作

    func groupCallParam(_ param: FLTNEGroupCallParam, completion: @escaping (FLTGroupCallResponse?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: groupCall - callId=\(param.callId ?? "nil"), calleeList=\(param.calleeList.count)")

        // 创建群呼参数
        let groupCallParam = GroupCallParam()
        groupCallParam.callId = param.callId ?? ""
        groupCallParam.calleeList = param.calleeList
        groupCallParam.groupId = param.groupId ?? ""
        groupCallParam.groupType = param.groupType.intValue
        if let inviteMode = param.inviteMode {
            groupCallParam.inviteMode = inviteMode.intValue
        }
        if let joinMode = param.joinMode {
            groupCallParam.joinMode = joinMode.intValue
        }
        groupCallParam.extraInfo = param.extraInfo ?? ""

        // 设置推送参数
        if let pushParam = param.pushParam {
            let nePushParam = GroupPushParam()
            nePushParam.pushContent = pushParam.pushContent ?? ""
            nePushParam.payload = pushParam.pushPayload ?? ""
            if let pushMode = pushParam.pushMode {
                nePushParam.pushMode = pushMode.intValue
            }
            nePushParam.sound = pushParam.sound ?? ""
            groupCallParam.pushParam = nePushParam
        }

        // 发起群呼
        NEGroupCallKit.sharedInstance().groupCall(groupCallParam) { [weak self] error, result in
            if let nsError = error as? NSError {
                let response = FLTGroupCallResponse.make(
                    withCode: NSNumber(value: nsError.code),
                    msg: nsError.localizedDescription,
                    callInfo: nil
                )
                completion(response, nil)
            } else {
                // iOS 原生 SDK 的 GroupCallResult 只包含部分字段
                // 只填充可用字段，其他字段由 Flutter 层补充
                let fltCallInfo = self?.buildPartialGroupCallInfo(result: result)
                let response = FLTGroupCallResponse.make(
                    withCode: NSNumber(value: result?.code ?? 0),
                    msg: nil,
                    callInfo: fltCallInfo
                )
                completion(response, nil)
            }
        }
    }

    func groupAcceptParam(_ param: FLTNEGroupAcceptParam, completion: @escaping (FLTGroupAcceptResponse?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: groupAccept - callId=\(param.callId)")

        // 创建接听参数
        let acceptParam = GroupAcceptParam()
        acceptParam.callId = param.callId

        // 接听群呼
        NEGroupCallKit.sharedInstance().groupAccept(acceptParam) { [weak self] error, result in
            if let nsError = error as? NSError {
                let response = FLTGroupAcceptResponse.make(
                    withCode: NSNumber(value: nsError.code),
                    msg: nsError.localizedDescription,
                    callInfo: nil
                )
                completion(response, nil)
            } else {
                let fltCallInfo = self?.convertToFLTGroupCallInfo(result?.groupCallInfo)
                let response = FLTGroupAcceptResponse.make(
                    withCode: NSNumber(value: result?.code ?? 0),
                    msg: nil,
                    callInfo: fltCallInfo
                )
                completion(response, nil)
            }
        }
    }

    func groupHangupParam(_ param: FLTNEGroupHangupParam, completion: @escaping (FLTGroupSimpleResponse?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: groupHangup - callId=\(param.callId), reason=\(param.reason ?? "nil")")

        // 创建挂断参数
        let hangupParam = GroupHangupParam()
        hangupParam.callId = param.callId
        hangupParam.reason = (param.reason ?? "") as NSString

        // 挂断群呼
        NEGroupCallKit.sharedInstance().groupHangup(hangupParam) { error, result in
            if let nsError = error as? NSError {
                let response = FLTGroupSimpleResponse.make(
                    withCode: NSNumber(value: nsError.code),
                    msg: nsError.localizedDescription
                )
                completion(response, nil)
            } else {
                let response = FLTGroupSimpleResponse.make(
                    withCode: NSNumber(value: result?.code ?? 0),
                    msg: nil
                )
                completion(response, nil)
            }
        }
    }

    func groupInviteParam(_ param: FLTNEGroupInviteParam, completion: @escaping (FLTGroupSimpleResponse?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: groupInvite - callId=\(param.callId), calleeList=\(param.calleeList.count)")

        // 创建邀请参数
        let inviteParam = GroupInviteParam()
        inviteParam.callId = param.callId
        inviteParam.calleeList = param.calleeList

        // 邀请成员
        NEGroupCallKit.sharedInstance().groupInvite(inviteParam) { error, result in
            if let nsError = error as? NSError {
                let response = FLTGroupSimpleResponse.make(
                    withCode: NSNumber(value: nsError.code),
                    msg: nsError.localizedDescription
                )
                completion(response, nil)
            } else {
                let response = FLTGroupSimpleResponse.make(
                    withCode: NSNumber(value: result?.code ?? 0),
                    msg: nil
                )
                completion(response, nil)
            }
        }
    }

    func groupJoinParam(_ param: FLTNEGroupJoinParam, completion: @escaping (FLTGroupJoinResponse?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: groupJoin - callId=\(param.callId)")

        // 创建加入参数
        let joinParam = GroupJoinParam()
        joinParam.callId = param.callId

        // 加入群呼
        NEGroupCallKit.sharedInstance().groupJoin(joinParam) { [weak self] error, result in
            if let nsError = error as? NSError {
                let response = FLTGroupJoinResponse.make(
                    withCode: NSNumber(value: nsError.code),
                    msg: nsError.localizedDescription,
                    callInfo: nil
                )
                completion(response, nil)
            } else {
                let fltCallInfo = self?.convertToFLTGroupCallInfo(result?.groupCallInfo)
                let response = FLTGroupJoinResponse.make(
                    withCode: NSNumber(value: result?.code ?? 0),
                    msg: nil,
                    callInfo: fltCallInfo
                )
                completion(response, nil)
            }
        }
    }

    func groupQueryCallInfoCallId(_ callId: String, completion: @escaping (FLTGroupQueryCallInfoResponse?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: groupQueryCallInfo - callId=\(callId)")

        // 创建查询参数
        let queryParam = GroupQueryCallInfoParam()
        queryParam.callId = callId

        // 查询群呼信息
        NEGroupCallKit.sharedInstance().groupQueryCallInfo(queryParam) { [weak self] error, result in
            if let nsError = error as? NSError {
                let response = FLTGroupQueryCallInfoResponse.make(
                    withCode: NSNumber(value: nsError.code),
                    msg: nsError.localizedDescription,
                    callInfo: nil
                )
                completion(response, nil)
            } else {
                // 将 NEGroupInfo 转换为 FLTNEGroupCallInfo
                let fltCallInfo = self?.convertNEGroupInfoToFLTGroupCallInfo(result?.groupCallInfo)
                let response = FLTGroupQueryCallInfoResponse.make(
                    withCode: NSNumber(value: result?.code ?? 0),
                    msg: nil,
                    callInfo: fltCallInfo
                )
                completion(response, nil)
            }
        }
    }

    func groupQueryMembersCallId(_ callId: String, completion: @escaping (FLTGroupQueryMembersResponse?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: groupQueryMembers - callId=\(callId)")

        // 创建查询参数
        let queryParam = GroupQueryMembersParam()
        queryParam.callId = callId

        // 查询成员列表
        NEGroupCallKit.sharedInstance().groupQueryMembers(queryParam) { [weak self] error, result in
            if let nsError = error as? NSError {
                let response = FLTGroupQueryMembersResponse.make(
                    withCode: NSNumber(value: nsError.code),
                    msg: nsError.localizedDescription,
                    members: nil
                )
                completion(response, nil)
            } else {
                // 转换成员列表
                var fltMembers: [FLTNEGroupCallMember] = []

                // 添加主叫信息
                if let callerInfo = result?.callerInfo {
                    let fltCaller = self?.convertToFLTGroupCallMember(callerInfo)
                    if let fltCaller = fltCaller {
                        fltMembers.append(fltCaller)
                    }
                }

                // 添加被叫列表
                if let calleeList = result?.calleeList {
                    for callee in calleeList {
                        if let fltMember = self?.convertToFLTGroupCallMember(callee) {
                            fltMembers.append(fltMember)
                        }
                    }
                }

                let response = FLTGroupQueryMembersResponse.make(
                    withCode: NSNumber(value: result?.code ?? 0),
                    msg: nil,
                    members: fltMembers
                )
                completion(response, nil)
            }
        }
    }

    // MARK: - 媒体操作接口

    func enableLocalVideoEnable(_ enable: NSNumber, completion: @escaping (FLTGroupSimpleResponse?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: enableLocalVideo - enable=\(enable)")
        let result = NERtcEngine.shared().enableLocalVideo(enable.boolValue)
        let response = FLTGroupSimpleResponse.make(
            withCode: NSNumber(value: result),
            msg: result == 0 ? "EnableLocalVideo successful" : "EnableLocalVideo failed"
        )
        completion(response, nil)
    }

    func muteLocalVideoMute(_ mute: NSNumber, completion: @escaping (FLTGroupSimpleResponse?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: muteLocalVideo - mute=\(mute)")
        let result = NERtcEngine.shared().muteLocalVideo(mute.boolValue, streamType: .mainStream)
        let response = FLTGroupSimpleResponse.make(
            withCode: NSNumber(value: result),
            msg: result == 0 ? "MuteLocalVideo successful" : "MuteLocalVideo failed"
        )
        completion(response, nil)
    }

    func enableLocalAudioEnable(_ enable: NSNumber, completion: @escaping (FLTGroupSimpleResponse?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: enableLocalAudio - enable=\(enable)")
        let result = NERtcEngine.shared().enableLocalAudio(enable.boolValue)
        let response = FLTGroupSimpleResponse.make(
            withCode: NSNumber(value: result),
            msg: result == 0 ? "EnableLocalAudio successful" : "EnableLocalAudio failed"
        )
        completion(response, nil)
    }

    func muteLocalAudioMute(_ mute: NSNumber, completion: @escaping (FLTGroupSimpleResponse?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: muteLocalAudio - mute=\(mute)")
        let result = NERtcEngine.shared().muteLocalAudio(mute.boolValue)
        let response = FLTGroupSimpleResponse.make(
            withCode: NSNumber(value: result),
            msg: result == 0 ? "MuteLocalAudio successful" : "MuteLocalAudio failed"
        )
        completion(response, nil)
    }

    func setSpeakerphoneOnEnable(_ enable: NSNumber, completion: @escaping (FLTGroupSimpleResponse?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: setSpeakerphoneOn - enable=\(enable)")
        let result = NERtcEngine.shared().setLoudspeakerMode(enable.boolValue)
        let response = FLTGroupSimpleResponse.make(
            withCode: NSNumber(value: result),
            msg: result == 0 ? "SetSpeakerphoneOn successful" : "SetSpeakerphoneOn failed"
        )
        completion(response, nil)
    }

    func isSpeakerphoneOn(completion: @escaping (NSNumber?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: isSpeakerphoneOn")
        var enabled: Bool = false
        NERtcEngine.shared().getLoudspeakerMode(&enabled)
        completion(NSNumber(value: enabled), nil)
    }

    func switchCamera(completion: @escaping (FLTGroupSimpleResponse?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: switchCamera")
        let result = NERtcEngine.shared().switchCamera()
        let response = FLTGroupSimpleResponse.make(
            withCode: NSNumber(value: result),
            msg: result == 0 ? "SwitchCamera successful" : "SwitchCamera failed"
        )
        completion(response, nil)
    }

    func setupLocalViewParam(_ param: FLTNEGroupViewParam, completion: @escaping (FLTGroupSimpleResponse?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: setupLocalView - viewId=\(param.viewId ?? 0)")

        var targetView: UIView?
        if let viewId = param.viewId {
            targetView = FLTCallKitViewManager.shared.findView(withId: viewId.intValue)
            print("FLTGroupCallkit: setupLocalView - found view=\(targetView != nil)")
        }

        let canvas = NERtcVideoCanvas()
        canvas.container = targetView
        canvas.renderMode = .cropFill
        canvas.mirrorMode = .auto

        let result = NERtcEngine.shared().setupLocalVideoCanvas(canvas)
        let response = FLTGroupSimpleResponse.make(
            withCode: NSNumber(value: result),
            msg: result == 0 ? "SetupLocalView successful" : "SetupLocalView failed"
        )
        completion(response, nil)
    }

    func setupRemoteViewParam(_ param: FLTNEGroupViewParam, completion: @escaping (FLTGroupSimpleResponse?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: setupRemoteView - uid=\(param.uid ?? 0), viewId=\(param.viewId ?? 0)")

        guard let uid = param.uid else {
            let response = FLTGroupSimpleResponse.make(
                withCode: NSNumber(value: -1),
                msg: "uid is required for setupRemoteView"
            )
            completion(response, nil)
            return
        }

        var targetView: UIView?
        if let viewId = param.viewId {
            targetView = FLTCallKitViewManager.shared.findView(withId: viewId.intValue)
            print("FLTGroupCallkit: setupRemoteView - found view=\(targetView != nil)")
        }

        let canvas = NERtcVideoCanvas()
        canvas.container = targetView
        canvas.renderMode = .cropFill
        canvas.mirrorMode = .auto

        let result = NERtcEngine.shared().setupRemoteVideoCanvas(canvas, forUserID: uid.uint64Value)
        let response = FLTGroupSimpleResponse.make(
            withCode: NSNumber(value: result),
            msg: result == 0 ? "SetupRemoteView successful" : "SetupRemoteView failed"
        )
        completion(response, nil)
    }

    func enableAudioVolumeIndicationEnable(_ enable: NSNumber, interval: NSNumber, completion: @escaping (FLTGroupSimpleResponse?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: enableAudioVolumeIndication - enable=\(enable), interval=\(interval)")
        let result = NERtcEngine.shared().enableAudioVolumeIndication(enable.boolValue, interval: UInt64(interval.intValue), vad: true)
        let response = FLTGroupSimpleResponse.make(
            withCode: NSNumber(value: result),
            msg: result == 0 ? "EnableAudioVolumeIndication successful" : "EnableAudioVolumeIndication failed"
        )
        completion(response, nil)
    }

    func setParametersParams(_ params: [String : Any], completion: @escaping (FLTGroupSimpleResponse?, FlutterError?) -> Void) {
        print("FLTGroupCallkit: setParameters - params=\(params)")

        // 设置参数
        let result = NERtcEngine.shared().setParameters(params)
        let response = FLTGroupSimpleResponse.make(
            withCode: NSNumber(value: result),
            msg: result == 0 ? "SetParameters successful" : "SetParameters failed"
        )
        completion(response, nil)
    }

    // MARK: - 类型转换辅助方法

    /// 从 GroupCallResult 构建部分填充的 FLTNEGroupCallInfo
    /// iOS 原生 SDK 的 GroupCallResult 只包含 callId, callerUid, startTimestamp
    /// 其他字段由 callkit 包的 Dart 层根据传入参数补充
    private func buildPartialGroupCallInfo(result: GroupCallResult?) -> FLTNEGroupCallInfo? {
        guard let result = result else { return nil }

        // 通过 NIMSDK 获取当前登录用户作为 callerAccId
        let callerAccId = NIMSDK.shared().v2LoginService.getLoginUser()

        return FLTNEGroupCallInfo.make(
            withCallId: result.callId,
            groupId: nil,           // callkit Dart 层补充
            groupType: nil,         // callkit Dart 层补充
            callerAccId: callerAccId,
            callerRtcUid: NSNumber(value: result.callerUid),
            memberList: nil,        // callkit Dart 层补充
            inviteMode: nil,        // callkit Dart 层补充
            joinMode: nil,          // callkit Dart 层补充
            extraInfo: nil,         // callkit Dart 层补充
            startTimestamp: NSNumber(value: result.startTimestamp)
        )
    }

    /// 将原生 NEGroupCallInfo 转换为 FLTNEGroupCallInfo
    private func convertToFLTGroupCallInfo(_ callInfo: NEGroupCallInfo?) -> FLTNEGroupCallInfo? {
        guard let callInfo = callInfo else { return nil }

        // 转换被叫列表
        var fltMembers: [FLTNEGroupCallMember] = []
        for member in callInfo.calleeList {
            if let fltMember = convertToFLTGroupCallMember(member) {
                fltMembers.append(fltMember)
            }
        }

        // 从 callerInfo 获取主叫信息
        let callerAccId = callInfo.callerInfo.imAccid ?? ""
        let callerRtcUid = callInfo.callerInfo.rtcUid

        return FLTNEGroupCallInfo.make(
            withCallId: callInfo.callId,
            groupId: callInfo.groupId,
            groupType: NSNumber(value: callInfo.groupType),
            callerAccId: callerAccId,
            callerRtcUid: NSNumber(value: callerRtcUid),
            memberList: fltMembers.isEmpty ? nil : fltMembers,
            inviteMode: NSNumber(value: callInfo.inviteMode),
            joinMode: NSNumber(value: callInfo.joinMode),
            extraInfo: callInfo.extraInfo,
            startTimestamp: NSNumber(value: callInfo.startTimestamp)
        )
    }

    /// 将原生 GroupCallMember 转换为 FLTNEGroupCallMember
    private func convertToFLTGroupCallMember(_ member: GroupCallMember?) -> FLTNEGroupCallMember? {
        guard let member = member else { return nil }

        return FLTNEGroupCallMember.make(
            withAccId: member.imAccid ?? "",
            rtcUid: NSNumber(value: member.rtcUid),
            state: NSNumber(value: member.state),
            action: member.action,
            reason: member.extraInfo
        )
    }

    /// 将原生 NEGroupInfo 转换为 FLTNEGroupCallInfo
    /// NEGroupInfo 与 NEGroupCallInfo 结构类似，但没有 calleeList 属性
    private func convertNEGroupInfoToFLTGroupCallInfo(_ groupInfo: NEGroupInfo?) -> FLTNEGroupCallInfo? {
        guard let groupInfo = groupInfo else { return nil }

        // 从 callerInfo 获取主叫信息
        let callerAccId = groupInfo.callerInfo.imAccid ?? ""
        let callerRtcUid = groupInfo.callerInfo.rtcUid

        return FLTNEGroupCallInfo.make(
            withCallId: groupInfo.callId,
            groupId: groupInfo.groupId,
            groupType: NSNumber(value: groupInfo.groupType),
            callerAccId: callerAccId,
            callerRtcUid: NSNumber(value: callerRtcUid),
            memberList: nil,  // NEGroupInfo 没有 calleeList 属性
            inviteMode: NSNumber(value: groupInfo.inviteMode),
            joinMode: NSNumber(value: groupInfo.joinMode),
            extraInfo: groupInfo.extraInfo,
            startTimestamp: NSNumber(value: groupInfo.startTimestamp)
        )
    }
}

// MARK: - NEGroupCallKitDelegate 群呼回调实现

extension FLTGroupCallkit: NEGroupCallKitDelegate {

    /// 收到群呼邀请
    func onGroupInvited(with info: NEGroupCallInfo) {
        print("FLTGroupCallkit: onGroupInvited - callId=\(info.callId)")
        if let fltCallInfo = convertToFLTGroupCallInfo(info) {
            eventSink?.onReceiveGroupInvitationInfo(fltCallInfo) { error in
                if let error = error {
                    print("FLTGroupCallkit: onGroupInvited callback error: \(error)")
                }
            }
        }
    }

    /// 成员列表变更
    func onGroupUserDidChange(_ members: [GroupCallMember]) {
        print("FLTGroupCallkit: onGroupUserDidChange - members=\(members.count)")
        var fltMembers: [FLTNEGroupCallMember] = []
        for member in members {
            if let fltMember = convertToFLTGroupCallMember(member) {
                fltMembers.append(fltMember)
            }
        }
        // 获取当前通话的 callId
        let callId = NEGroupCallKit.sharedInstance().callId
        eventSink?.onGroupMemberListChangedCallId(callId, members: fltMembers) { error in
            if let error = error {
                print("FLTGroupCallkit: onGroupUserDidChange callback error: \(error)")
            }
        }
    }

    /// 成员挂断
    func onGroupHangup(withReason reason: String) {
        print("FLTGroupCallkit: onGroupHangup - reason=\(reason)")
        let callId = NEGroupCallKit.sharedInstance().callId
        let fltEvent = FLTNEGroupCallHangupEvent.make(
            withCallId: callId,
            reason: 0,
            message: reason
        )
        eventSink?.onGroupCallHangupEvent(fltEvent) { error in
            if let error = error {
                print("FLTGroupCallkit: onGroupHangup callback error: \(error)")
            }
        }
    }

    /// 群呼结束
    func onGroupEndCall(withReason reason: Int, message: String?, callId: String) {
        print("FLTGroupCallkit: onGroupEndCall - callId=\(callId), reason=\(reason)")
        let fltEvent = FLTNEGroupCallEndEvent.make(
            withCallId: callId,
            reason: NSNumber(value: reason),
            message: message
        )
        eventSink?.onGroupCallEndEvent(fltEvent) { error in
            if let error = error {
                print("FLTGroupCallkit: onGroupEndCall callback error: \(error)")
            }
        }
    }
}

// MARK: - NERtcEngineDelegateEx 媒体回调实现

extension FLTGroupCallkit: NERtcEngineDelegateEx {

    /// 远端用户开启音频
    func onNERtcEngineUserAudioDidStart(_ userID: UInt64) {
        print("FLTGroupCallkit: onUserAudioStart - uid=\(userID)")
        mediaEventSink?.onUserAudioStartUid(NSNumber(value: userID)) { error in
            if let error = error {
                print("FLTGroupCallkit: onUserAudioStart callback error: \(error)")
            }
        }
    }

    /// 远端用户关闭音频
    func onNERtcEngineUserAudioDidStop(_ userID: UInt64) {
        print("FLTGroupCallkit: onUserAudioStop - uid=\(userID)")
        mediaEventSink?.onUserAudioStopUid(NSNumber(value: userID)) { error in
            if let error = error {
                print("FLTGroupCallkit: onUserAudioStop callback error: \(error)")
            }
        }
    }

    /// 远端用户音频静音状态变更
    func onNERtcEngineUser(_ userID: UInt64, audioMuted muted: Bool) {
        print("FLTGroupCallkit: onUserAudioMute - uid=\(userID), muted=\(muted)")
        mediaEventSink?.onUserAudioMuteUid(NSNumber(value: userID), muted: NSNumber(value: muted)) { error in
            if let error = error {
                print("FLTGroupCallkit: onUserAudioMute callback error: \(error)")
            }
        }
    }

    /// 远端用户开启视频
    func onNERtcEngineUserVideoDidStart(withUserID userID: UInt64, videoProfile profile: NERtcVideoProfileType) {
        print("FLTGroupCallkit: onUserVideoStart - uid=\(userID), profile=\(profile.rawValue)")
        mediaEventSink?.onUserVideoStartUid(NSNumber(value: userID), maxProfile: NSNumber(value: profile.rawValue)) { error in
            if let error = error {
                print("FLTGroupCallkit: onUserVideoStart callback error: \(error)")
            }
        }
    }

    /// 远端用户关闭视频
    func onNERtcEngineUserVideoDidStop(_ userID: UInt64) {
        print("FLTGroupCallkit: onUserVideoStop - uid=\(userID)")
        mediaEventSink?.onUserVideoStopUid(NSNumber(value: userID)) { error in
            if let error = error {
                print("FLTGroupCallkit: onUserVideoStop callback error: \(error)")
            }
        }
    }

    /// 远端用户视频静音状态变更（带 streamType）
    func onNERtcEngineUser(_ userID: UInt64, videoMuted muted: Bool, streamType: NERtcStreamChannelType) {
        print("FLTGroupCallkit: onUserVideoMute - uid=\(userID), muted=\(muted), streamType=\(streamType.rawValue)")
        mediaEventSink?.onUserVideoMuteUid(NSNumber(value: userID), muted: NSNumber(value: muted)) { error in
            if let error = error {
                print("FLTGroupCallkit: onUserVideoMute callback error: \(error)")
            }
        }
    }

    /// 远端用户视频静音状态变更（不带 streamType，兼容旧版 SDK 回调）
    func onNERtcEngineUser(_ userID: UInt64, videoMuted muted: Bool) {
        print("FLTGroupCallkit: onUserVideoMute(no streamType) - uid=\(userID), muted=\(muted)")
        mediaEventSink?.onUserVideoMuteUid(NSNumber(value: userID), muted: NSNumber(value: muted)) { error in
            if let error = error {
                print("FLTGroupCallkit: onUserVideoMute callback error: \(error)")
            }
        }
    }

    /// 远端用户音量指示
    func onRemoteAudioVolumeIndication(_ speakers: [NERtcAudioVolumeInfo]?, totalVolume: Int32) {
        var fltVolumes: [FLTNEAudioVolumeInfo] = []
        if let speakers = speakers {
            for speaker in speakers {
                let fltVolume = FLTNEAudioVolumeInfo.make(
                    withUid: NSNumber(value: speaker.uid),
                    volume: NSNumber(value: speaker.volume)
                )
                fltVolumes.append(fltVolume)
            }
        }
        mediaEventSink?.onRemoteAudioVolumeIndicationVolumes(fltVolumes, totalVolume: NSNumber(value: totalVolume)) { error in
            if let error = error {
                print("FLTGroupCallkit: onRemoteAudioVolumeIndication callback error: \(error)")
            }
        }
    }

    /// 连接断开
    func onNERtcEngineDidDisconnect(withReason reason: NERtcError) {
        print("FLTGroupCallkit: onDisconnect - reason=\(reason.rawValue)")
        mediaEventSink?.onDisconnectReason(NSNumber(value: reason.rawValue)) { error in
            if let error = error {
                print("FLTGroupCallkit: onDisconnect callback error: \(error)")
            }
        }
    }

    /// 发生错误
    func onNERtcEngineDidError(_ errCode: NERtcError) {
        print("FLTGroupCallkit: onError - code=\(errCode.rawValue)")
        mediaEventSink?.onErrorCode(NSNumber(value: errCode.rawValue)) { error in
            if let error = error {
                print("FLTGroupCallkit: onError callback error: \(error)")
            }
        }
    }

    // MARK: - NERtcEngineDelegateEx 其他必要回调（空实现）

    func onNERtcEngineUserDidJoin(withUserID userID: UInt64, userName: String) {
        print("FLTGroupCallkit: onUserJoined - uid=\(userID), userName=\(userName)")
    }

    func onNERtcEngineUserDidLeave(withUserID userID: UInt64, reason: NERtcSessionLeaveReason) {
        print("FLTGroupCallkit: onUserLeave - uid=\(userID), reason=\(reason.rawValue)")
    }

    func onNERtcEngineDidLeaveChannel(withResult result: NERtcError) {
        print("FLTGroupCallkit: onLeaveChannel - result=\(result.rawValue)")
    }
}

// MARK: - FLTAssociativeWrapper 实现

extension FLTGroupCallkit: FLTAssociativeWrapper {
    func onAttachedToEngine(_ registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        eventSink = FLTGroupCallKitEventSink(binaryMessenger: registrar.messenger())
        mediaEventSink = FLTGroupMediaEventSink(binaryMessenger: registrar.messenger())
        FLTGroupCallKitApiSetup(registrar.messenger(), self)
        print("FLTGroupCallkit: onAttachedToEngine")
    }

    func onDetachedFromEngine(_ registrar: FlutterPluginRegistrar) {
        // 清理资源
        NEGroupCallKit.sharedInstance().remove(self)
        NECallEngine.sharedInstance().engineDelegate = nil

        eventSink = nil
        mediaEventSink = nil
        self.registrar = nil
        FLTGroupCallKitApiSetup(registrar.messenger(), nil)
        print("FLTGroupCallkit: onDetachedFromEngine")
    }
}
