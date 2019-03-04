Pod::Spec.new do |s|

  s.name         = "CoreNetKit"
  s.version      = "2.0.0"
  s.summary      = "Framework for network interaction"

  s.homepage     = "https://github.com/surfstudio/CoreNetKit"
  s.license      = "MIT"
  s.author = { "Alexander Kravchenkov" => "sprintend@gmail.com" }

  s.platform     = :ios
  s.ios.deployment_target = "11.0"

  s.source       = { :git => "https://github.com/surfstudio/CoreNetKit.git"}

  s.source_files  = 'CoreNetKit/Utils/**/*.swift', 'CoreNetKit/Chains/**/*.swift', 'CoreNetKit/Layers/**/*.swift', 'CoreNetKit/Core/**/*.swift'
  s.dependency 'Alamofire', '~> 4.7.2'
  s.dependency 'CoreEvents', '~> 1.3.0'

end
