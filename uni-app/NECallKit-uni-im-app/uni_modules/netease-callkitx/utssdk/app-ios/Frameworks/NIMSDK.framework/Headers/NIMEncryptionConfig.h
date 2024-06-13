//
//  NIMEncryptionConfig.h
//  NIMSDK
//
//  Created by Netease on 2019/10/14.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMAsymEncryptionOption.h"

NS_ASSUME_NONNULL_BEGIN

/**
 非对称加密类型

 - NIMAsymEncryptionTypeRSA: RSA加密
 - NIMAsymEncryptionTypeSM2: SM加密
 */
typedef NS_ENUM (NSInteger, NIMAsymEncryptionType){
    NIMAsymEncryptionTypeRSA = 1, //RSA
    NIMAsymEncryptionTypeSM2 = 1 << 1, //SM2
};

/**
 对称加密类型

 - NIMSymEncryptionTypeRC4: RC4加密
 - NIMSymEncryptionTypeAES: AES加密
 - NIMSymEncryptionTypeSM4: SM4加密
 */
typedef NS_ENUM (NSInteger, NIMSymEncryptionType){
    NIMSymEncryptionTypeRC4 = 1,  //RC4
    NIMSymEncryptionTypeAES = 1 << 1,  //AES
    NIMSymEncryptionTypeSM4 = 1 << 2,  //SM4
};

@interface NIMEncryptionConfig : NSObject

/// 非对称加密类型（默认：RSA）
@property (nonatomic, assign) NIMAsymEncryptionType asymEncryptionType;

/// 对称加密类型（默认：RC4）
@property (nonatomic, assign) NIMSymEncryptionType symEncryptionType;

/// 更新非对称加密RSA的配置
/// @param option RSA配置
- (void)updateRSAOption:(NIMRSAOption *)option;

/// 更新非对称加密SM2的配置
/// @param option SM2配置
- (void)updateSM2Option:(NIMSM2Option *)option;

@end




NS_ASSUME_NONNULL_END
