class UnsupportedDesktopPlatformException implements Exception {
  UnsupportedDesktopPlatformException(this.platform);

  final String platform;

  @override
  String toString() {
    return 'Desktop CallKit is only supported on windows/macos, current: $platform';
  }
}

class DesktopPlatformGuard {
  const DesktopPlatformGuard._();

  static const DesktopPlatformGuard instance = DesktopPlatformGuard._();

  bool isSupportedPlatform(String platform) {
    return platform == 'macos' || platform == 'windows';
  }

  void ensureSupportedPlatform(String platform) {
    if (!isSupportedPlatform(platform)) {
      throw UnsupportedDesktopPlatformException(platform);
    }
  }
}
