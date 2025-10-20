// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallStatusRecordModel.h"

@implementation NECallStatusRecordModel

- (void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeInteger:self.status forKey:@"status"];
  [coder encodeInteger:self.duration forKey:@"duration"];
  [coder encodeObject:self.startTime forKey:@"startTime"];
  [coder encodeBool:self.isCaller forKey:@"isCaller"];
  [coder encodeBool:self.isVideoCall forKey:@"isVideoCall"];
  [coder encodeObject:self.imAccid forKey:@"imAccid"];
  [coder encodeObject:self.mobile forKey:@"mobile"];
  [coder encodeObject:self.avatar forKey:@"avatar"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super init];
  if (self) {
    self.status = [coder decodeIntegerForKey:@"status"];
    self.duration = [coder decodeIntegerForKey:@"duration"];
    self.startTime = [coder decodeObjectForKey:@"startTime"];
    self.isCaller = [coder decodeBoolForKey:@"isCaller"];
    self.isVideoCall = [coder decodeBoolForKey:@"isVideoCall"];
    self.imAccid = [coder decodeObjectForKey:@"imAccid"];
    self.mobile = [coder decodeObjectForKey:@"mobile"];
    self.avatar = [coder decodeObjectForKey:@"avatar"];
  }
  return self;
}

@end
