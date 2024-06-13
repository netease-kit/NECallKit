//
//  NIMQChatCheckPermissionParam.h
//  NIMLib
//
//  Created by Evang on 2022/3/24.
//  Copyright © 2022 Netease. All rights reserved.
//

#import "NIMQChatCheckPermissionParam.h"
#import "qchat_protocol.h"


@interface NIMQChatCheckPermissionParam ()

- (void)convertToRequest:(nimbiz::QChatCheckPermissionRequest &)request;

@end

