Pod::Spec.new do |s|

  s.name         = "CoreNetKitContexts"
  s.version      = "1.0.0"
  s.summary      = "Framework for network interaction"

  s.homepage     = "https://github.com/LastSprint/CoreNetKit"
  s.license      = "MIT"
  s.author = { "Alexander Kravchenkov" => "sprintend@gmail.com" }

  s.platform     = :ios
  s.ios.deployment_target = "10.0"

  s.source       = { :git => "https://github.com/LastSprint/CoreNetKit.git", :tag => s.version }

  s.source_files  = 'CoreNetKit/Context/Protocols/*.swift', 'CoreNetKit/Context/BaseImplementations/PassiveRequestContext.swift', 'CoreNetKit/Core/Adapters/**/*.swift', 'CoreNetKit/Core/Adapters/**/*.swift', 'CoreNetKit/Core/ServerPart/*.swift', 'CoreNetKit/Core/ServerPart/Protocols/*.swift', 'CoreNetKit/Kit/**/*.swift'
  s.dependency 'Alamofire'

end
