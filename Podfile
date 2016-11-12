platform :ios, '9.0'

use_frameworks!
target 'Pictograph' do
  pod 'SVProgressHUD'
  pod 'RNCryptor'
  pod 'EAIntroView'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'CustomIOSAlertView'
  pod 'PromiseKit'
end

target 'PictographTests' do

end

target 'PictographUITests' do

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
