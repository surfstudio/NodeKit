import Foundation

/// Реулизует набор цепочек для отправки URL запросов.
open class UrlChainsBuilder {

    /// Конструктор для создания сервисных цепочек.
    public var serviceChain: UrlServiceChainBuilder

    /// Инициаллизирует объект.
    ///
    /// - Parameter serviceChain: Конструктор для создания сервисных цепочек.
    public init(serviceChain: UrlServiceChainBuilder = UrlServiceChainBuilder()) {
        self.serviceChain = serviceChain
    }

    /// Создает цепочку узлов, описывающих слой построения запроса.
    ///
    /// - Parameter config: Конфигурация для запроса
    open func requestBuildingChain(with config: UrlChainConfigModel) ->  Node<Json, Json> {
        let transportChain = self.serviceChain.requestTrasportChain()
        let urlRequestTrasformatorNode = UrlRequestTrasformatorNode(next: transportChain, method: config.method)
        let requstEncoderNode = RequstEncoderNode(next: urlRequestTrasformatorNode, encoding: config.encoding)
        let requestRouterNode = RequestRouterNode(next: requstEncoderNode, route: config.route)
        return MetadataConnectorNode(next: requestRouterNode, metadata: config.metadata)
    }

    /// Создает цепочку для отправки DTO моделей данных.
    ///
    /// - Parameter config: Конфигурация для запроса.
    open func defaultInput<Input, Output>(with config: UrlChainConfigModel) -> Node<Input, Output>
        where Input: DTOEncodable, Output: DTODecodable,
        Input.DTO.Raw == Json, Output.DTO.Raw == Json {
            let buildingChain = self.requestBuildingChain(with: config)
            let dtoConverter = DTOMapperNode<Input.DTO, Output.DTO>(next: buildingChain)
            return ModelInputNode(next: dtoConverter)
    }

    func supportNodes<Input, Output>(with config: UrlChainConfigModel) -> Node<Input, Output>
        where Input: DTOEncodable, Output: DTODecodable,
        Input.DTO.Raw == Json, Output.DTO.Raw == Json {
            let loadIndicator = LoadIndicatableNode<Input, Output>(next: self.defaultInput(with: config))
            return loadIndicator
    }

    /// Создает цепочку по-умолчанию. Подразумеается работа с DTO-моделями.
    ///
    /// - Parameter config: Конфигурация для запроса.
    open func `default`<Input, Output>(with config: UrlChainConfigModel) -> Node<Input, Output>
        where Input: DTOEncodable, Output: DTODecodable,
        Input.DTO.Raw == Json, Output.DTO.Raw == Json {
            let input: Node<Input, Output> = self.supportNodes(with: config)
            let config =  ChainConfiguratorNode<Input, Output>(next: input)
            return LoggerNode(next: config)
    }

    /// Создает обычную цепочку, только в качестве входных данных принимает `Void`
    ///
    /// - Parameter config: Конфигурация для запроса.
    open func `default`<Output>(with config: UrlChainConfigModel) -> Node<Void, Output>
        where Output: DTODecodable, Output.DTO.Raw == Json {
            let input: Node<Json, Output> = self.supportNodes(with: config)
            let configNode = ChainConfiguratorNode<Json, Output>(next: input)
            let voidNode =  VoidInputNode(next: configNode)
            return LoggerNode(next: voidNode)
    }

    /// Создает обычную цепочку, только в качестве входных данных принимает `Void`
    ///
    /// - Parameter config: Конфигурация для запроса.
    open func `default`<Input>(with config: UrlChainConfigModel) -> Node<Input, Void>
        where Input: DTOEncodable, Input.DTO.Raw == Json {
            let input = self.requestBuildingChain(with: config)
            let indicator = LoadIndicatableNode(next: input)
            let configNode = ChainConfiguratorNode(next: indicator)
            let voidOutput = VoidOutputNode<Input>(next: configNode)
            return LoggerNode(next: voidOutput)
    }

    /// Создает обычную цепочку, только в качестве входных и вызодных данных имеет `Void`
    ///
    /// - Parameter config: Конфигурация для запроса.
    open func `default`(with config: UrlChainConfigModel) -> Node<Void, Void> {
        let input = self.requestBuildingChain(with: config)
        let indicator = LoadIndicatableNode(next: input)
        let configNode = ChainConfiguratorNode(next: indicator)
        let voidOutput = VoidIONode(next: configNode)
        return LoggerNode(next: voidOutput)
    }

    /// Позволяет загрузить бинарные данные (файл) с сервера без отправки какой-то модели на сервер.
    ///
    /// - Parameter config: Конфигурация.
    /// - Returns: Корневой узел цепочки.
    open func loadData(with config: UrlChainConfigModel) -> Node<Void, Data> {
        let loaderParser = DataLoadingResponseProcessor()
        let errorProcessor = ResponseHttpErrorProcessorNode(next: loaderParser)
        let responseProcessor = ResponseProcessorNode(next: errorProcessor)
        let sender = RequestSenderNode(rawResponseProcessor: responseProcessor)

        let creator = RequestCreatorNode(next: sender)

        let tranformator = UrlRequestTrasformatorNode(next: creator, method: config.method)
        let encoder = RequstEncoderNode(next: tranformator, encoding: config.encoding)
        let router = RequestRouterNode(next: encoder, route: config.route)
        let connector = MetadataConnectorNode(next: router, metadata: config.metadata)

        let indicator = LoadIndicatableNode(next: connector)
        let configNode = ChainConfiguratorNode(next: indicator)

        let voidInput = VoidInputNode(next: configNode)

        return LoggerNode(next: voidInput)
    }

    /// Позволяет загрузить бинарные данные (файл) с сервера.
    ///
    /// - Parameter config: Конфигурация.
    /// - Returns: Корневой узел цепочки.
    open func loadData<Input>(with config: UrlChainConfigModel) -> Node<Input, Data> where Input: DTOEncodable, Input.DTO.Raw == Json {

        let loaderParser = DataLoadingResponseProcessor()
        let errorProcessor = ResponseHttpErrorProcessorNode(next: loaderParser)
        let responseProcessor = ResponseProcessorNode(next: errorProcessor)
        let sender = RequestSenderNode(rawResponseProcessor: responseProcessor)

        let creator = RequestCreatorNode(next: sender)

        let tranformator = UrlRequestTrasformatorNode(next: creator, method: config.method)
        let encoder = RequstEncoderNode(next: tranformator, encoding: config.encoding)
        let router = RequestRouterNode(next: encoder, route: config.route)
        let connector = MetadataConnectorNode(next: router, metadata: config.metadata)

        let rawEncoder = RawEncoderNode<Input.DTO, Data>(next: connector)
        let dtoEncoder = DTOEncoderNode<Input, Data>(rawEncodable: rawEncoder)

        let indicator = LoadIndicatableNode(next: dtoEncoder)
        let configNode = ChainConfiguratorNode(next: indicator)

        return LoggerNode(next: configNode)
    }


    /// Формирует цепочку для отправки multipaer-запроса.
    /// Для работы с этой цепочкой в качестве модели необходимо использовать `MultipartModel`
    ///
    /// - Parameter config: Конфигурация.
    /// - Returns: Корневой узел цепочки .
    open func `default`<I, O>(with config: UrlChainConfigModel) -> Node<I, O> where O: DTODecodable, O.DTO.Raw == Json, I: DTOEncodable, I.DTO.Raw == MultipartModel<[String : Data]> {

        let reponseProcessor = self.serviceChain.urlResponseProcessingLayerChain()

        let requestSenderNode = RequestSenderNode(rawResponseProcessor: reponseProcessor)

        let creator = MultipartRequestCreatorNode(next: requestSenderNode)

        let transformator = MultipartUrlRequestTrasformatorNode(next: creator, method: config.method)

        let router = RequestRouterNode(next: transformator, route: config.route)
        let connector = MetadataConnectorNode(next: router, metadata: config.metadata)

        let rawEncoder = DTOMapperNode<I.DTO,O.DTO>(next: connector)
        let dtoEncoder = ModelInputNode<I, O>(next: rawEncoder)

        let indicator = LoadIndicatableNode(next: dtoEncoder)
        let configNode = ChainConfiguratorNode(next: indicator)

        return LoggerNode(next: configNode)
    }
}
