# Uncomment the next line to define a global platform for your project
 platform :ios, '12.0'

target 'OneSignalNotificationServiceExtension' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for OneSignalNotificationServiceExtension
  pod 'OneSignal', '< 3.0'
end



target 'WebViewGold' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for WebViewGold
  pod 'OneSignal', '< 3.0'
  pod 'Google-Mobile-Ads-SDK', '< 8.0'
  pod 'Firebase/Core', '6.34.0'
  pod 'Firebase/Messaging', '6.34.0'
  pod 'SwiftQRScanner'
  pod 'SwiftyStoreKit'
  pod 'FBAudienceNetwork'

end


post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
end