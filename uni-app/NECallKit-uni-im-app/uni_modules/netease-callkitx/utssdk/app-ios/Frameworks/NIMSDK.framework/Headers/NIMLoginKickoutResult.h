//
//  NIMLoginKickoutResult.h
//  NIMLib
//
//  Created by 丁文超 on 2020/5/22.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMLoginManagerProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@interface NIMLoginKickoutResult : NSObject

@property (nonatomic, assign) NIMKickReason reasonCode;

@property (nonatomic, assign) NIMLoginClientType clientType;

@property (nonatomic, copy) NSString *reasonDesc;

@property (nonatomic, assign) NSInteger customClientType;

@end

NS_ASSUME_NONNULL_END
