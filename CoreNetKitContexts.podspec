Pod::Spec.new do |s|

  s.name         = "CoreNetKitContexts"
  s.version      = "1.0.2"
  s.summary      = "Framework for network interaction"

  s.homepage     = "https://github.com/LastSprint/CoreNetKit"
  s.license      = "MIT"
  s.author = { "Alexander Kravchenkov" => "sprintend@gmail.com" }

  s.platform     = :ios
  s.ios.deployment_target = "10.0"

  s.source       = { :git => "https://github.com/surfstudio/CoreNetKit.git", :tag => s.version }

  s.source_files  = 'CoreNetKit/Context/Protocols/ActionableContext.swift', 'CoreNetKit/Context/Protocols/CacheableContext.swift', 'CoreNetKit/Context/Protocols/CancellableContext.swift', 'CoreNetKit/Context/Protocols/PaginableRequestContext.swift', 'CoreNetKit/Context/Protocols/PassiveContext.swift', 'CoreNetKit/Context/BaseImplementations/PassiveRequestContext.swift'
  s.dependency 'Alamofire'

end
