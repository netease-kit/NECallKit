#
# Be sure to run `pod lib lint NERtcCallUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NERtcCallUIKit'
  s.version          = '2.6.0'
  s.summary          = 'Netease XKit'
  s.homepage         = 'http://netease.im'
  s.license          =  { :'type' => "Copyright", :'text' => " Copyright 2022 Netease " }
  s.author           = 'yunxin engineering department'
  s.ios.deployment_target = '13.0'
  s.swift_versions = ['5.0']
  s.source = { :http => "" }
  s.source_files = 'NERtcCallUIKit/Classes/**/*'
  s.resource = 'NERtcCallUIKit/Assets/**/*'

  s.subspec 'NOS' do |subspec|
    subspec.dependency 'NERtcCallKit/NOS', '2.6.0'
    subspec.dependency 'SDWebImage', '5.15.4'
    subspec.dependency 'NECoreKit', '9.8.4'
    subspec.dependency 'NECommonKit', '9.7.8'
    subspec.dependency 'NECommonUIKit', '9.8.5'
  end

  s.subspec 'FCS' do |subspec|
    subspec.dependency 'NERtcCallKit/FCS', '2.6.0'
    subspec.dependency 'SDWebImage', '5.15.4'
    subspec.dependency 'NECoreKit', '9.8.4'
    subspec.dependency 'NECommonKit', '9.7.8'
    subspec.dependency 'NECommonUIKit', '9.8.5'
  end

  s.subspec 'NOS_Special' do |subspec|
    subspec.dependency 'NERtcCallKit/NOS_Special', '2.6.0'
    subspec.dependency 'SDWebImage', '>= 5.15.4'
    subspec.dependency 'NECoreKit', '>= 9.8.4'
    subspec.dependency 'NECommonKit', '>= 9.7.8'
    subspec.dependency 'NECommonUIKit', '>= 9.8.5'
  end

  s.subspec 'FCS_Special' do |subspec|
    subspec.dependency 'NERtcCallKit/FCS_Special', '2.6.0'
    subspec.dependency 'SDWebImage', '>= 5.15.4'
    subspec.dependency 'NECoreKit', '>= 9.8.4'
    subspec.dependency 'NECommonKit', '>= 9.7.8'
    subspec.dependency 'NECommonUIKit', '>= 9.8.5'
  end
  s.default_subspecs = 'NOS'

end
