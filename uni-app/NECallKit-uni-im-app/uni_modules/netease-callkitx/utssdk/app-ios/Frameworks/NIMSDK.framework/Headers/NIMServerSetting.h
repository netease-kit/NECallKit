//
//  NIMServerSetting.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMEncryptionConfig.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, NIMHandshakeType){
    NIMHandshakeTypeBasics = 0,
    NIMHandshakeTypeAdvanced,
};

typedef NS_ENUM (NSInteger, NIMLinkAddressType){
    NIMLinkAddressTypeIpv4 = 0,  //仅使用IPv4
    NIMLinkAddressTypeIpv6,      //仅使用IPv6
    NIMLinkAddressTypeAuto,      //自动选择
    NIMLinkAddressTypeIpv6First  //IPv6优先
};

typedef NS_ENUM (NSInteger, NIMServerEnv){
    NIMServerEnvProd = 0,       // 线上环境
    NIMServerEnvDev,            // 测试环境
};

/**
 *  云信服务器配置
 */
@interface NIMServerSetting : NSObject

/**
* 握手协议类型。基础的类型仅支持设置module和version.使用RSA和RC4加密方式。
* 高级类型，可以通过配置encryptConfig来指定使用的加密类型。默认：NIMHandshakeTypeBasics
*/
@property (nonatomic,assign)            NIMHandshakeType handshakeType;

/**
 服务器环境(默认线上环境)
 */
@property (nonatomic,assign)            NIMServerEnv    env;

/**
 * module
 */
@property (nonatomic,copy)              NSString    *module;
/**
 * 版本
 */
@property (nonatomic,assign)            NSInteger   version;

/**
* 是否是专属云
*/
@property (nonatomic, assign)           BOOL isSpecialCloud;

/**
* 握手加密配置
*/
@property (nonatomic,readonly)          NIMEncryptionConfig   *encryptConfig;

/**
 * IM 服务器 lbs 地址
 */
@property (nonatomic,copy)              NSString    *lbsAddress;
/**
 * IM 服务器默认地址, IPv4
 */
@property (nonatomic,copy)              NSString    *linkAddress;

/**
 * IM 服务器默认地址, IPv6
 */
@property (nonatomic,copy)              NSString    *ipv6LinkAddress;

/**
 * NOS 服务器 lbs 地址
 */
@property (nonatomic,copy)              NSString    *nosLbsAddress;
/**
 * NOS 上传服务器默认地址
 */
@property (nonatomic,copy)              NSString    *nosUploadAddress;

/**
 * 是否开启 HTTPS 支持
 * @discussion 默认情况为 YES，若需要使用非 HTTPS 进行文件上传下载，则设置为 NO。
 * 如果设置为 YES，上传将使用 https 上传，所有返回 url 的地方也会尝试将 http url 调整为 https url
 * 如果设置为 NO，上传将使用 http 上传，而所有返回 url 的地方都只返回原 url，而不做任何处理，同时 `SDKConfig` 中 `enabledHttpsForInfo` 和 `enabledHttpsForMessage` 将无效
 */
@property (nonatomic,assign)            BOOL       httpsEnabled;

/**
 * NOS 上传 Host，用于 HTTPS 上传时 Host 验证
 */
@property (nonatomic,copy,nullable)     NSString    *nosUploadHost;
/**
 * NOS 下载地址，用于拼接下载地址
 */
@property (nonatomic,copy)              NSString    *nosDownloadAddress;
/**
 * NOS 加速 Host
 */
@property (nonatomic,copy,nullable)     NSString    *nosAccelerateHost;
/**
* NOS加速需要被替换的域名列表 不包含bucket部分
*/
@property(strong,nonatomic,nullable)    NSArray     <NSString *> *nosAccelerateHosts;
/**
 * NOS 加速替换地址
 */
@property (nonatomic,copy,nullable)     NSString    *nosAccelerateAddress;
/**
 * NT 服务器地址
 */
//@property (nonatomic,copy,nullable)     NSString    *ntServerAddress;
/**
 * 异常上报地址: 408、415、500等
 */
@property (nonatomic,copy)              NSString    *exceptionUploadAddress;
/**
* IPv4 连通性检测地址
*/
@property (nonatomic,copy,nullable)     NSString    *lbsIpv4DetectAddress;
/**
* IPv6 连通性检测地址
*/
@property (nonatomic,copy,nullable)     NSString    *lbsIpv6DetectAddress;

/**
* lbs返回的link地址的类型, 在初始化前设置
*/
@property (nonatomic, assign) NIMLinkAddressType lbsLinkAddressType;

/**
* 在端测加速域名（nosAccelerateAddress）和后台CDN域名都配置的情况下，选择后台CDN域名下发优先，默认为 YES
*/
@property (nonatomic, assign) BOOL cdnEnable;


/**
* 从配置数据更新
*/
- (void)updateSettingFromConfigData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
