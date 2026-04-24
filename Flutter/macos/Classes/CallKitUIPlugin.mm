#import "CallKitUIPlugin.h"

#import <AVFoundation/AVFoundation.h>

namespace {

constexpr NSInteger kPermissionGranted = 0;
constexpr NSInteger kPermissionDenied = 1;
constexpr NSInteger kCameraPermission = 0;
constexpr NSInteger kMicrophonePermission = 1;
constexpr NSInteger kBluetoothPermission = 2;

}  // namespace

@interface CallKitUIPlugin ()

@property(nonatomic, strong) AVAudioPlayer* audioPlayer;
@property(nonatomic, strong) id applicationWillTerminateObserver;
@property(nonatomic, strong) id windowWillCloseObserver;

@end

@implementation CallKitUIPlugin

+ (void)registerWithRegistrar:(id<FlutterPluginRegistrar>)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"call_kit_ui"
                                  binaryMessenger:[registrar messenger]];
  CallKitUIPlugin* instance = [[CallKitUIPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  [registrar publish:instance];
}

- (instancetype)init {
  self = [super init];
  if (self != nil) {
    [self registerLifecycleObservers];
  }
  return self;
}

- (void)dealloc {
  [self removeLifecycleObservers];
  [self stopRingPlayback];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"startRing"]) {
    [self handleStartRing:call result:result];
    return;
  }
  if ([call.method isEqualToString:@"stopRing"]) {
    [self stopRingPlayback];
    result(nil);
    return;
  }
  if ([call.method isEqualToString:@"hasPermissions"]) {
    [self handleHasPermissions:call result:result];
    return;
  }
  if ([call.method isEqualToString:@"requestPermissions"]) {
    [self handleRequestPermissions:call result:result];
    return;
  }
  if ([call.method isEqualToString:@"startToPermissionSetting"]) {
    result(@([self openPrivacySettings]));
    return;
  }

  result(FlutterMethodNotImplemented);
}

- (void)handleStartRing:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary* args =
      [call.arguments isKindOfClass:[NSDictionary class]] ? call.arguments : nil;
  NSString* filePath =
      [args[@"filePath"] isKindOfClass:[NSString class]] ? args[@"filePath"] : nil;
  if (filePath == nil || filePath.length == 0) {
    result([FlutterError errorWithCode:@"invalid_args"
                               message:@"filePath is required"
                               details:nil]);
    return;
  }
  if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    result([FlutterError errorWithCode:@"ring_missing"
                               message:@"ring file does not exist"
                               details:filePath]);
    return;
  }

  [self stopRingPlayback];

  NSError* error = nil;
  AVAudioPlayer* player =
      [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath]
                                             error:&error];
  if (player == nil || error != nil) {
    result([FlutterError errorWithCode:@"ring_start_failed"
                               message:@"failed to create audio player"
                               details:error.localizedDescription]);
    return;
  }

  player.numberOfLoops = -1;
  [player prepareToPlay];
  if (![player play]) {
    result([FlutterError errorWithCode:@"ring_start_failed"
                               message:@"failed to play ring"
                               details:filePath]);
    return;
  }

  self.audioPlayer = player;
  result(nil);
}

- (void)handleHasPermissions:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary* args =
      [call.arguments isKindOfClass:[NSDictionary class]] ? call.arguments : nil;
  NSArray<NSNumber*>* permissions =
      [args[@"permission"] isKindOfClass:[NSArray class]] ? args[@"permission"] : nil;
  if (permissions == nil) {
    result(@(NO));
    return;
  }

  BOOL granted = YES;
  for (NSNumber* permission in permissions) {
    if (![self hasPermission:permission.integerValue]) {
      granted = NO;
      break;
    }
  }
  result(@(granted));
}

- (void)handleRequestPermissions:(FlutterMethodCall*)call
                          result:(FlutterResult)result {
  NSDictionary* args =
      [call.arguments isKindOfClass:[NSDictionary class]] ? call.arguments : nil;
  NSArray<NSNumber*>* permissions =
      [args[@"permission"] isKindOfClass:[NSArray class]] ? args[@"permission"] : nil;
  if (permissions == nil || permissions.count == 0) {
    result(@(kPermissionDenied));
    return;
  }

  [self requestPermissionAtIndex:0
                     permissions:permissions
                      completion:^(BOOL granted) {
    result(@(granted ? kPermissionGranted : kPermissionDenied));
  }];
}

- (BOOL)openPrivacySettings {
  NSURL* url = [NSURL URLWithString:
      @"x-apple.systempreferences:com.apple.preference.security?Privacy"];
  return url != nil && [[NSWorkspace sharedWorkspace] openURL:url];
}

- (AVMediaType)mediaTypeForPermission:(NSInteger)permissionType {
  switch (permissionType) {
    case kCameraPermission:
      return AVMediaTypeVideo;
    case kMicrophonePermission:
      return AVMediaTypeAudio;
    default:
      return nil;
  }
}

- (BOOL)hasPermission:(NSInteger)permissionType {
  if (permissionType == kBluetoothPermission) {
    return YES;
  }

  AVMediaType mediaType = [self mediaTypeForPermission:permissionType];
  if (mediaType == nil) {
    return NO;
  }

  AVAuthorizationStatus status =
      [AVCaptureDevice authorizationStatusForMediaType:mediaType];
  return status == AVAuthorizationStatusAuthorized;
}

- (void)requestPermissionAtIndex:(NSUInteger)index
                     permissions:(NSArray<NSNumber*>*)permissions
                      completion:(void (^)(BOOL granted))completion {
  if (index >= permissions.count) {
    completion(YES);
    return;
  }

  NSInteger permissionType = permissions[index].integerValue;
  if (permissionType == kBluetoothPermission) {
    [self requestPermissionAtIndex:index + 1
                       permissions:permissions
                        completion:completion];
    return;
  }

  AVMediaType mediaType = [self mediaTypeForPermission:permissionType];
  if (mediaType == nil) {
    completion(NO);
    return;
  }

  AVAuthorizationStatus status =
      [AVCaptureDevice authorizationStatusForMediaType:mediaType];
  if (status == AVAuthorizationStatusAuthorized) {
    [self requestPermissionAtIndex:index + 1
                       permissions:permissions
                        completion:completion];
    return;
  }
  if (status == AVAuthorizationStatusDenied ||
      status == AVAuthorizationStatusRestricted) {
    completion(NO);
    return;
  }

  [AVCaptureDevice requestAccessForMediaType:mediaType
                           completionHandler:^(BOOL granted) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (!granted) {
        completion(NO);
        return;
      }
      [self requestPermissionAtIndex:index + 1
                         permissions:permissions
                          completion:completion];
    });
  }];
}

- (void)registerLifecycleObservers {
  __weak typeof(self) weakSelf = self;
  NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
  self.applicationWillTerminateObserver =
      [center addObserverForName:NSApplicationWillTerminateNotification
                          object:nil
                           queue:[NSOperationQueue mainQueue]
                      usingBlock:^(NSNotification* notification) {
    (void)notification;
    [weakSelf stopRingPlayback];
  }];
  self.windowWillCloseObserver =
      [center addObserverForName:NSWindowWillCloseNotification
                          object:nil
                           queue:[NSOperationQueue mainQueue]
                      usingBlock:^(NSNotification* notification) {
    (void)notification;
    [weakSelf stopRingPlayback];
  }];
}

- (void)removeLifecycleObservers {
  NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
  if (self.applicationWillTerminateObserver != nil) {
    [center removeObserver:self.applicationWillTerminateObserver];
    self.applicationWillTerminateObserver = nil;
  }
  if (self.windowWillCloseObserver != nil) {
    [center removeObserver:self.windowWillCloseObserver];
    self.windowWillCloseObserver = nil;
  }
}

- (void)stopRingPlayback {
  [self.audioPlayer stop];
  self.audioPlayer = nil;
}

@end
