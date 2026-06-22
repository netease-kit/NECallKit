Pod::Spec.new do |s|
  s.name = 'netease_callkit_ui'
  s.module_name = 'netease_callkit_ui'
  s.version = '0.0.1'
  s.summary = 'NetEase CallKit UI desktop helpers.'
  s.description = <<-DESC
Desktop helper plugin for ringtone playback and permission handling.
                       DESC
  s.homepage = 'http://example.com'
  s.license = { :file => '../LICENSE' }
  s.author = { 'NetEase' => 'example@example.com' }
  s.source = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.osx.dependency 'FlutterMacOS'
  s.osx.deployment_target = '10.15'
  s.frameworks = 'AVFoundation'
  s.static_framework = true
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
  }
end
