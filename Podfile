source 'https://cdn.cocoapods.org/'

platform :ios, '10.3'
use_frameworks!
inhibit_all_warnings!
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

def reuse_pods
    pod 'Moya', '14.0.0', :subspecs => [ "RxSwift" ] # alamofire - routing MIGRATE TO SPM change version 13.0.1 -> 14.0.0
    pod 'RxSwiftExt', '5.2.0' # MIGRATE TO SPM chang version 3.4.0 -> 5.2.0
    pod 'Socket.IO-Client-Swift', '16.0.1'
#    pod 'MessageKit', '3.1.1'
    pod 'lottie-ios', '3.2.3'
    pod 'SkeletonView', '1.29.2'
    
    pod 'Swinject', '2.7.1'
    pod 'SwinjectAutoregistration', '2.7.0'
end

target 'Geeng Goong' do
  reuse_pods
end

target 'Geeng GoongTests' do
    reuse_pods
  end

  target 'Geeng GoongUITests' do
    reuse_pods
  end

