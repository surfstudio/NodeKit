Pod::Spec.new do |s|

  s.name         = "NodeKit"
  s.version      = "2.1.0"
  s.summary      = "Framework for network interaction"

  s.homepage     = "https://github.com/surfstudio/NodeKit"
  s.license      = "MIT"
  s.author = { "Alexander Kravchenkov" => "sprintend@gmail.com" }

  s.platform     = :ios
  s.ios.deployment_target = "10.0"

  s.source       = { :git => "https://github.com/surfstudio/NodeKit.git", :tag => "#{s.version}"}

  s.source_files  = 'NodeKit/Utils/**/*.swift', 'NodeKit/Chains/**/*.swift', 'NodeKit/Layers/**/*.swift', 'NodeKit/Core/**/*.swift', 'NodeKit/Encodings/*.swift'
  s.dependency 'Alamofire', '5.0.0-beta.4'
  s.dependency 'CoreEvents', '~> 1.3.0'

end
