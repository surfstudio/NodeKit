Pod::Spec.new do |s|

  s.name         = "CoreNetKit"
  s.version      = "0.0.7"
  s.summary      = "Framework for network interaction"

  s.homepage     = "https://github.com/LastSprint/CoreNetKit"
  s.license      = "MIT"
  s.author = { "Alexander Kravchenkov" => "sprintend@gmail.com" }

  s.platform     = :ios
  s.ios.deployment_target = "10.0"

  s.source       = { :git => "https://github.com/LastSprint/CoreNetKit.git", :tag => s.version }

  s.source_files  = 'CoreNetKit/*.swift'
  s.dependency 'Alamofire'

end
