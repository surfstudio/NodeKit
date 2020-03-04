Pod::Spec.new do |s|

  s.name         = "NodeKit"
  s.version      = "3.2.0"
  s.summary      = "Framework for network interaction"

  s.homepage     = "https://github.com/surfstudio/NodeKit"
  s.license      = "MIT"
  s.author = { "Alexander Kravchenkov" => "sprintend@gmail.com" }

  s.ios.deployment_target = "10.0"

  s.source       = { :git => "https://github.com/surfstudio/NodeKit.git", :tag => "#{s.version}"}

  s.default_subspec = 'Core'

  s.subspec 'Core' do |sp|
    sp.source_files  = 'NodeKit/Utils/**/*.swift', 'NodeKit/Chains/**/*.swift', 'NodeKit/Layers/**/*.swift', 'NodeKit/Core/**/*.swift', 'NodeKit/Encodings/*.swift'
    sp.dependency 'Alamofire', '5.0.0-beta.4'
    sp.dependency 'CoreEvents', '~> 2.0.1'
  end

  s.subspec 'MockerIntegration' do |sp|
    sp.dependency 'NodeKit/Core'
    sp.source_files = 'NodeKit/MockerIntegration/*.swift'
  end
  
  s.subspec 'UrlCache' do |sp|
    sp.dependency 'NodeKit/Core'
    sp.source_files = 'NodeKit/CacheNode/**/*.swift'
  end

end
