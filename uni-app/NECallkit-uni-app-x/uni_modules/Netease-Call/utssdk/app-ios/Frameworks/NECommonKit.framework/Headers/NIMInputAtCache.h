
// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

#define NIMInputAtStartChar @"@"
#define NIMInputAtEndChar @"\u2004"

@interface NIMInputAtItem : NSObject

@property(nonatomic, copy) NSString *name;

@property(nonatomic, copy) NSString *uid;

@property(nonatomic, assign) NSRange range;

@end

@interface NIMInputAtCache : NSObject

- (NSArray *)allAtUid:(NSString *)sendText;

- (void)clean;

- (void)addAtItem:(NIMInputAtItem *)item;

- (NIMInputAtItem *)item:(NSString *)name;

- (NIMInputAtItem *)removeName:(NSString *)name;

@end
