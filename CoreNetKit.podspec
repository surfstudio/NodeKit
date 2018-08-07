Pod::Spec.new do |s|

  s.name         = "CoreNetKit"
  s.version      = "1.2.0"
  s.summary      = "Framework for network interaction"

  s.homepage     = "https://github.com/LastSprint/CoreNetKit"
  s.license      = "MIT"
  s.author = { "Alexander Kravchenkov" => "sprintend@gmail.com" }

  s.platform     = :ios
  s.ios.deployment_target = "10.0"

  s.source       = { :git => "https://github.com/surfstudio/CoreNetKit.git"}

  s.source_files  = 'CoreNetKit/Context/**/*.swift', 'CoreNetKit/Core/*.swift', 'CoreNetKit/Core/Adapters/**/*.swift', 'CoreNetKit/Core/Adapters/**/*.swift', 'CoreNetKit/Core/ServerPart/*.swift', 'CoreNetKit/Core/ServerPart/Protocols/*.swift', 'CoreNetKit/Kit/**/*.swift'
  s.dependency 'Alamofire', '~> 4.7.2'
  s.dependency 'CoreEvents', '~> 1.1.2'

end
