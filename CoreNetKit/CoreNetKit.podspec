Pod::Spec.new do |s|

  s.name         = "CoreNetKit"
  s.version      = "0.0.5"
  s.summary      = "Framework for network interaction"

  s.description  = <<-DESC
  Framework for network interaction
                   DESC

  s.homepage     = "https://github.com/LastSprint/CoreNetKit"
  s.license      = "MIT"
  s.author             = { "Александр Кравченков" => "sprintend@gmail.com" }

  s.platform     = :ios
  s.ios.deployment_target = "10.0"

  s.source       = { :git => "https://github.com/LastSprint/CoreNetKit.git", :tag => "#{s.version}" }

  s.source_files  = "CoreNetKit/**/**/*.swift"
  s.dependency 'Alamofire'

end
