Pod::Spec.new do |s|
  s.name = 'netease_callkit'
  s.module_name = 'netease_callkit'
  s.version = '0.0.1'
  s.summary = 'NetEase CallKit macOS desktop bridge.'
  s.description = <<-DESC
Desktop bridge and runtime packaging for NetEase CallKit.
                       DESC
  s.homepage = 'http://example.com'
  s.license = { :file => '../LICENSE' }
  s.author = { 'NetEase' => 'example@example.com' }
  s.source = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.frameworks = 'AVFoundation'
  s.platform = :osx, '10.15'
  s.vendored_libraries = 'Frameworks/libne_callkit.dylib'
  s.vendored_frameworks = 'Frameworks/nertc_sdk_Mac.xcframework', 'Frameworks/NEXKitBase.xcframework'
  s.preserve_paths = 'Frameworks/**/*', '../desktop_bridge/include/*.h'
  s.static_framework = true
  s.library = 'c++'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'HEADER_SEARCH_PATHS' => '"$(PODS_TARGET_SRCROOT)/../desktop_bridge/include"',
    'LD_RUNPATH_SEARCH_PATHS' => '$(inherited) @executable_path/../Frameworks @loader_path/../Frameworks',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'gnu++17',
  }
  s.xcconfig = {
    'CLANG_CXX_LIBRARY' => 'libc++',
  }
  s.prepare_command = <<-CMD
    cd ../
    python3 ./scripts/prepare_macos_desktop.py
                      CMD
end
