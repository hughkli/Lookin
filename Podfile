use_frameworks!

#inhibit_all_warnings!

target 'LookinClient' do 
    platform :osx, '11.0'
    pod 'AppCenter'
    pod 'ReactiveObjC', '3.1.0'
    pod 'Sparkle', '~> 1.0'
    pod 'LookinShared', :git=>'https://github.com/QMUI/LookinServer.git', :branch => 'release/1.2.7'
    #pod 'LookinShared', :path=>'../LookinServer/'
end

# ReactiveObjc 之类的 SDK 的 deployment target 太低了导致无法编译，所以这里改成以项目为准
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'MACOSX_DEPLOYMENT_TARGET'
    end
  end
end
