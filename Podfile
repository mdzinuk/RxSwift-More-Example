# Uncomment the next line to define a global platform for your project
# platform :ios, '12.0'

target 'RxPhotoViewer' do
	use_frameworks!

	workspace 'RxSwift'
	project 'RxPhotoViewer/RxPhotoViewer.xcodeproj'

  	# Pods for RxSwift-WorkSpace
   	pod 'RxSwift', '~> 5'

  	target 'RxPhotoViewerTests' do
    	inherit! :search_paths
    	pod 'RxSwift', '~> 5'
  	end

  	target 'RxPhotoViewerUITests' do
    	inherit! :search_paths
    	pod 'RxSwift', '~> 5'
  	end
end

target 'RxNetworking' do
	use_frameworks!

	workspace 'RxSwift'
	project 'RxNetworking/RxNetworking.xcodeproj'

  	# Pods for RxSwift-WorkSpace
   	pod 'RxSwift', '~> 5'
	pod 'RxCocoa', '~> 5'
  	pod 'Kingfisher', '~> 5.0'


  	target 'RxNetworkingTests' do
    	inherit! :search_paths
    	pod 'RxSwift', '~> 5'
	pod 'RxCocoa', '~> 5'
  	pod 'Kingfisher', '~> 5.0'
	end

  	target 'RxNetworkingUITests' do
    	inherit! :search_paths
    	pod 'RxSwift', '~> 5'
	pod 'RxCocoa', '~> 5'
  	pod 'Kingfisher', '~> 5.0'
  	end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'RxSwift'
      target.build_configurations.each do |config|
        if config.name == 'Debug'
          config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
        end
      end
    end
  end
end
