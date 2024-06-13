/*
 * Copyright (c) 2021 NetEase, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "NERtcEngineBase.h"


NS_ASSUME_NONNULL_BEGIN

@protocol NERtcEngineDelegateEx;

/**
 * @if English 
 * Initializes the NERtcEngine instance.
 * @endif
 * @if Chinese
 * 初始化设置 NERtcEngine 
 * @endif
 */
NERTC_EXPORT  @interface NERtcEngineContext: NSObject

 /**
 * @if English 
 * The App Key of an app. You can view the App Key in the CommsEase console after you create an app.
 * @endif
 * @if Chinese
 * 应用的 App Key。在云信控制台创建应用后，可以查看对应的 App Key。
 * @endif
 */
@property (nonatomic, copy) NSString *appKey;

 /**
 * @if English 
 * The log setting of NERtc. For more information, see {@link NERtcLogSetting}.
 * @endif
 * @if Chinese
 * 日志配置，详细信息请参考 {@link NERtcLogSetting}。
 * @endif
 */
@property (nonatomic, strong) NERtcLogSetting *logSetting;

 /**
 * @if English 
 * The callback interface of NERtcEngine provided by the developer.
 * @endif
 * @if Chinese
 * NERtcEngine 的回调接口，由用户提供。
 * @endif
 */
@property (nonatomic, weak) id<NERtcEngineDelegateEx> engineDelegate;

/**
 * @if English 
 * The private server address.
 * @note To use a private server, contact technical support for help.
 * @endif
 * @if Chinese
 * 私有化服务器地址
 * @note 如需启用私有化功能，请联系技术支持获取详情
 * @endif
 */
@property (nonatomic, strong, nullable) NERtcServerAddresses *serverAddress;

/**
 *  代码内部默认值是0
 *  详见NERtcAreaCodeType定义
 */
@property (nonatomic, assign) NERtcAreaCodeType areaCodeType;

@end

NS_ASSUME_NONNULL_END
