// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallUIDynamicConfig.h"

@interface NECallUIIncomingBackgroundSource ()

@property(nonatomic, assign, readwrite) NECallUIIncomingBackgroundSourceType type;
@property(nonatomic, strong, nullable, readwrite) UIImage *image;
@property(nonatomic, strong, nullable, readwrite) NSURL *url;

- (instancetype)initPrivate;

@end

@implementation NECallUIIncomingBackgroundSource

+ (instancetype)imageSource:(UIImage *)image {
  NECallUIIncomingBackgroundSource *source = [[NECallUIIncomingBackgroundSource alloc] initPrivate];
  source.type = NECallUIIncomingBackgroundSourceTypeImage;
  source.image = image;
  return source;
}

+ (instancetype)urlSource:(NSURL *)url {
  NECallUIIncomingBackgroundSource *source = [[NECallUIIncomingBackgroundSource alloc] initPrivate];
  source.type = NECallUIIncomingBackgroundSourceTypeURL;
  source.url = url;
  return source;
}

- (instancetype)initPrivate {
  self = [super init];
  return self;
}

@end

@implementation NECallUIDynamicConfig

@end
