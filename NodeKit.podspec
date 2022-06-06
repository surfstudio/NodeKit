Pod::Spec.new do |s|

  s.name         = "NodeKit"
  s.version      = "4.0.1"
  s.summary      = "Framework for network interaction"

  s.homepage     = "https://github.com/surfstudio/NodeKit"
  s.license      = "MIT"
  s.author = { "Alexander Kravchenkov" => "sprintend@gmail.com" }

  s.ios.deployment_target = "10.0"

  s.source       = { :git => "https://github.com/surfstudio/NodeKit.git", :tag => "#{s.version}"}

  s.default_subspec = 'Core'

  s.subspec 'Core' do |sp|
    sp.source_files  = 'NodeKit/Utils/**/*.swift', 'NodeKit/Chains/**/*.swift', 'NodeKit/Layers/**/*.swift', 'NodeKit/Core/**/*.swift', 'NodeKit/Encodings/**/*.swift', 'NodeKit/ThirdParty/**/*.swift'
    sp.exclude_files = 'NodeKit/Encodings/UrlBsonRequestEncodingNode.swift', 'NodeKit/Chains/UrlBsonServiceChainBuilder.swift', 'NodeKit/Chains/UrlBsonChainsBuilder.swift', 'NodeKit/Layers/Bson/*.swift', 'NodeKit/Layers/TrasportLayer/Models/TransportUrlBsonRequest.swift', 'NodeKit/Layers/ResponseProcessingLayer/Bson/*.swift', 'NodeKit/Layers/BsonLayerTypes.swift', 'NodeKit/Core/Convertion/Extensions/DTOConvertible+Document.swift', 'NodeKit/Core/Convertion/RawBsonMappable.swift'
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

  s.subspec 'BSON' do |sp|
  	sp.dependency 'NodeKit/Core'
  	sp.dependency 'BSON', '7.0.4'
  	sp.source_files = 'NodeKit/Encodings/UrlBsonRequestEncodingNode.swift', 'NodeKit/Chains/UrlBsonServiceChainBuilder.swift', 'NodeKit/Chains/UrlBsonChainsBuilder.swift', 'NodeKit/Layers/Bson/*.swift', 'NodeKit/Layers/TrasportLayer/Models/TransportUrlBsonRequest.swift', 'NodeKit/Layers/ResponseProcessingLayer/Bson/*.swift', 'NodeKit/Layers/BsonLayerTypes.swift', 'NodeKit/Core/Convertion/Extensions/DTOConvertible+Document.swift', 'NodeKit/Core/Convertion/RawBsonMappable.swift'
  end
end
