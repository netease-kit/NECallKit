#
# Be sure to run `pod lib lint NERtcCallUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NERtcCallUIKit'
  s.version          = '3.6.0'
  s.summary          = 'Netease XKit'
  s.homepage         = 'http://netease.im'
  s.license          =  { :'type' => "Copyright", :'text' => " Copyright 2022 Netease " }
  s.author           = 'yunxin engineering department'
  s.ios.deployment_target = '13.0'
  s.source = { :http => "" }
  s.source_files = 'NERtcCallUIKit/Classes/**/*'
  s.resource = 'NERtcCallUIKit/Assets/**/*'

  s.subspec 'NOS' do |nos|
    nos.dependency 'NERtcCallKit/NOS','3.6.0'
    nos.dependency 'SDWebImage'
    nos.dependency 'NECoreKit'
    nos.dependency 'NECommonKit'
    nos.dependency 'NECommonUIKit'
    nos.dependency 'NERtcSDK'
  end

  s.subspec 'NOS_Special' do |nos|
    nos.dependency 'NERtcCallKit/NOS_Special', '3.6.0'
    nos.dependency 'SDWebImage'
    nos.dependency 'NECoreKit'
    nos.dependency 'NECommonKit'
    nos.dependency 'NECommonUIKit'
    nos.dependency 'NERtcSDK'

  end

  s.subspec 'FCS' do |fcs|
    fcs.dependency 'NERtcCallKit/FCS','3.6.0'
    fcs.dependency 'SDWebImage'
    fcs.dependency 'NECoreKit'
    fcs.dependency 'NECommonKit'
    fcs.dependency 'NECommonUIKit'
    fcs.dependency 'NERtcSDK'

  end

  s.subspec 'FCS_Special' do |fcs|
    fcs.dependency 'NERtcCallKit/FCS_Special', '3.6.0'
    fcs.dependency 'SDWebImage'
    fcs.dependency 'NECoreKit'
    fcs.dependency 'NECommonKit'
    fcs.dependency 'NECommonUIKit'
    fcs.dependency 'NERtcSDK'

  end
  s.default_subspecs = 'NOS'

end
