//
//  NEScreenShareHostOptions.h
//  NEScreenShareKit
//
//  Created by IM.NetEase on 2021/5/12.
//  Copyright © 2021 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NEScreenShareHostDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEScreenShareHostOptions : NSObject

/**
 *  AppGroup设置
 *  必须和Broadcast App中设置一致，Host需要依赖AppGroup与Broadcast Extension进行通信
 *  AppGroup的相关设置可以参考文档：https://doc.yunxin.163.com/docs/jcyOTA0ODM/Tk2NDA0MTM?platformId=50192
 */
@property (nonatomic, copy) NSString *appGroup;

/**
 *  是否开启Debug模式，默认为NO
 *  设置为YES且`NEScreenShareBroadcasterOptions`中同时设置为YES时，开启Debug模式，可以不设置AppGroup，方便开发者临时调试
 *  Release环境必须设置为NO
 */
@property (nonatomic, assign) BOOL enableDebug;

/**
 *  业务事件代理
 */
@property (nonatomic, weak) id<NEScreenShareHostDelegate> delegate;

/**
 * 附加信息，可用来向Broadcast传递数据
 */
@property (nonatomic, strong) NSDictionary *extraInfoDict;

/**
 * 针对支持ProMotion机器, 支持设置最低补帧策略, 解决静止画面下帧率过低的问题, 支持设置1 ~ 10
 */
@property (nonatomic, assign) int adaptFrameRate;

@end

NS_ASSUME_NONNULL_END
