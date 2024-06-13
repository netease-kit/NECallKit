//
//  NIMRtcCallRecordObject.h
//  NIMLib
//
//  Created by Wenchao Ding on 2020/11/5.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMMessageObjectProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NIMRtcCallType) {
    NIMRtcCallTypeAudio = 1,
    NIMRtcCallTypeVideo
};

typedef NS_ENUM(NSUInteger, NIMRtcCallStatus) {
    NIMRtcCallStatusComplete = 1,    // 通话完成
    NIMRtcCallStatusCanceled,        // 通话取消
    NIMRtcCallStatusRejected,        // 通话拒绝
    NIMRtcCallStatusTimeout,         // 超时未接听
    NIMRtcCallStatusBusy             // 对方忙线
};

@interface NIMRtcCallRecordObject : NSObject<NIMMessageObject>

/**
 通话类型，音频/视频
 */
@property (nonatomic, assign) NIMRtcCallType callType;

/**
 频道ID
 */
@property (nonatomic, copy) NSString *channelID;

/**
 通话状态
 */
@property (nonatomic, assign) NIMRtcCallStatus callStatus;

/**
 时长Map {"accid1": 10, "accid2": 20}
 */
@property (nonatomic, copy) NSDictionary<NSString *, NSNumber *> *durations;

@end

NS_ASSUME_NONNULL_END
