//
//  NIMQuicClientProtocol.h
//  NIMQuic
//
//  Created by Netease.
//  Copyright (c) 2024 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

// models
@class NIMQuicConnectOption;
@class NIMQuicStats;

// interfaces
@protocol NIMQuicClient;
@protocol NIMQuicClientCallback;
@protocol NIMQuicClientLogger;

// factory
@class NIMQuicClientFactory;

// logger
@class NIMQuicClientLogger;

typedef uint32_t NIMQuicClientId;
typedef int NIMQuicConnectionId;

typedef NS_ENUM(NSInteger, NIMQuicError) {
    NIMQuicErrorNone = 0,
    NIMQuicErrorHandshakeTimeout,
    NIMQuicErrorIdleTimeout,
    NIMQuicErrorSocketOpenError,
    NIMQuicErrorUrlParseFailed,
    NIMQuicErrorKickOff,
};

typedef NS_ENUM(NSInteger, NIMQuicHandshakeStatus) {
    NIMQuicHandshakeStatusUnknown = -1,
    NIMQuicHandshakeStatusFail,
    NIMQuicHandshakeStatusSuccess,
    NIMQuicHandshakeStatusResumedOK,
    NIMQuicHandshakeStatusResumedFail,
};

typedef NS_ENUM(NSInteger, NIMQuicCongestionMode) {
    NIMQuicCongestionModeCubic = 1,
    NIMQuicCongestionModeBbr,
};

typedef NS_ENUM(NSInteger, NIMQuicLogLevel) {
    NIMQuicLogLevelDebug = 0,
    NIMQuicLogLevelInfo,
    NIMQuicLogLevelWarning,
    NIMQuicLogLevelError,
};

NS_ASSUME_NONNULL_BEGIN

@protocol NIMQuicClient <NSObject>

@property(nonatomic,assign,readonly) NIMQuicClientId clientId;

// client operations
- (NIMQuicError)startClient;
- (void)stopClient;

// connection operations
- (NIMQuicConnectionId)connectToUri:(NSString *)uriString
                      sessionResume:(nullable NSData *)sessionResume;
- (void)closeConnection:(NIMQuicConnectionId)connectionId;

// data operations
- (void)sendTo:(NIMQuicConnectionId)connectionId
          data:(NSData *)data;

// stats
@property(nonatomic,copy,readonly) NIMQuicStats *stat;

@end

@protocol NIMQuicClientCallback <NSObject>

@optional

// connection operations
- (void)connectionOpened:(NIMQuicConnectionId)connectionId;
- (void)connectionHandshake:(NIMQuicConnectionId)connectionId
                     status:(NIMQuicHandshakeStatus)status;
- (void)connectionFailed:(NIMQuicConnectionId)connectionId
                   error:(NIMQuicError)error;
- (void)connectionClosed:(NIMQuicConnectionId)connectionId
                   error:(NIMQuicError)error;
- (void)connection:(NIMQuicConnectionId)connectionId
     sessionResume:(NSData *)data;

// data operations
- (void)receiveFrom:(NIMQuicConnectionId)connectionId
               data:(NSData *)data;

@end

@protocol NIMQuicClientLogger <NSObject>

@required

- (void)logMessage:(NSString *)log;

@end

@interface NIMQuicClientFactory : NSObject

+ (id<NIMQuicClient>)clientWithOption:(nullable NIMQuicConnectOption *)option
                             callback:(id<NIMQuicClientCallback>)callback;

@end

@interface NIMQuicConnectOption : NSObject <NSCopying>

// default 3000
@property(nonatomic,assign) int32_t handshakeTimeout;
// default 60000
@property(nonatomic,assign) int32_t idleTimeout;
// default NIMQuicCongestionModeBbr
@property(nonatomic,assign) NIMQuicCongestionMode congestionMode;
// default YES
@property(nonatomic,assign) BOOL enableRedundantPackets;
// default 3
@property(nonatomic,assign) int32_t minRedundantPackets;

+ (instancetype)defaultOption;

@end

@interface NIMQuicStats : NSObject <NSCopying>

@property(nonatomic,assign,readonly) int32_t sendBitrate;
@property(nonatomic,assign,readonly) int32_t recvBitrate;
@property(nonatomic,assign,readonly) int32_t RTT;
@property(nonatomic,assign,readonly) int32_t CWND;
@property(nonatomic,assign,readonly) int32_t lossRate;

@end

@interface NIMQuicClientLogger : NSObject

@property(class,nonatomic,strong) id<NIMQuicClientLogger> logger;
@property(class,nonatomic,assign) NIMQuicLogLevel logLevel;

@end

NS_ASSUME_NONNULL_END
