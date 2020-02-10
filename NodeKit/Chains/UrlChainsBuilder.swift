
import Foundation
import Alamofire

/// Реулизует набор цепочек для отправки URL запросов.
open class UrlChainsBuilder<Route: UrlRouteProvider> {

    // MARK: - Properties / State

    /// Конструктор для создания сервисных цепочек.
    public var serviceChain: UrlServiceChainBuilder

    /// Модель для конфигурирования URL-query в запросе.
    public var urlQueryConfig: URLQueryConfigModel

    /// Массив провайдеров заголовков для запроса.
    /// Эти провайдеры используются перед непосредственной отправкой запроса.
    public var headersProviders: [MetadataProvider]

    /// HTTP метод, который будет использован цепочкой
    /// По-умолчанию GET
    public var method: Method

    /// Кодировка данных для запроса.
    ///
    /// По умолчанию`.json`
    public var encoding: ParametersEncoding

    /// В случае классического HTTP это Header'ы запроса.
    /// По-умолчанию пустой.
    public var metadata: [String: String]

    /// Маршрут до удаленного метода (в частном случае - URL endpoint'a)
    public var route: Route?

    /// Менеджер сессий
    public var session: Session?

    /// Массив с ID логов, которые нужно исключить из выдачи.
    public var logFilter: [String]

    // MARK: - Init

    /// Инициаллизирует объект.
    ///
    /// - Parameter serviceChain: Конструктор для создания сервисных цепочек.
    public init(serviceChain: UrlServiceChainBuilder = UrlServiceChainBuilder()) {
        self.serviceChain = serviceChain
        self.urlQueryConfig = .init(
            query: [:]
        )

        self.metadata = [:]
        self.method = .get
        self.encoding = .json
        self.headersProviders = []
        self.logFilter = []
    }

    // MARK: - State mutators

    // MARK: -- URLQueryConfigModel

    open func set(query: [String: Any]) -> Self {
        self.urlQueryConfig.query = query
        return self
    }

    open func set(boolEncodingStartegy: URLQueryBoolEncodingStartegy) -> Self {
        self.urlQueryConfig.boolEncodingStartegy = boolEncodingStartegy
        return self
    }

    open func set(arrayEncodingStrategy: URLQueryArrayKeyEncodingStartegy) -> Self {
        self.urlQueryConfig.arrayEncodingStrategy = arrayEncodingStrategy
        return self
    }

    open func set(dictEncodindStrategy: URLQueryDictionaryKeyEncodingStrategy) -> Self {
        self.urlQueryConfig.dictEncodindStrategy = dictEncodindStrategy
        return self
    }

    open func set(boolEncodingStartegy: URLQueryBoolEncodingDefaultStartegy) -> Self {
        self.urlQueryConfig.boolEncodingStartegy = boolEncodingStartegy
        return self
    }

    open func set(arrayEncodingStrategy: URLQueryArrayKeyEncodingBracketsStartegy) -> Self {
        self.urlQueryConfig.arrayEncodingStrategy = arrayEncodingStrategy
        return self
    }

    // MARK: - Session config
    
    open func set(session: Session) -> Self {
        self.session = session
        return self
    }


    // MARK: - Request config

    open func set(metadata: [String: String]) -> Self {
        self.metadata = metadata
        return self
    }

    open func route(_ method: Method, _ route: Route) -> Self {
        self.method = method
        self.route = route
        return self
    }

    open func encode(as encoding: ParametersEncoding) -> Self {
        self.encoding = encoding
        return self
    }

    open func add(provider: MetadataProvider) -> Self {
        self.headersProviders.append(provider)
        return self
    }

    // MARK: - Infrastructure Config

    open func log(exclude: [String]) -> Self {
        self.logFilter += exclude
        return self
    }

    // MARK: - Public methods

    /// Создает цепочку узлов, описывающих слой построения запроса.
    ///
    /// - Parameter config: Конфигурация для запроса
    open func requestBuildingChain() ->  Node<Json, Json> {
        let transportChain = self.serviceChain.requestTrasportChain(providers: self.headersProviders, session: session)

        let urlRequestTrasformatorNode = UrlRequestTrasformatorNode(next: transportChain, method: self.method)
        let requstEncoderNode = RequstEncoderNode(next: urlRequestTrasformatorNode, encoding: self.encoding)

        let queryInjector = URLQueryInjectorNode(next: requstEncoderNode, config: self.urlQueryConfig)

        let requestRouterNode = self.requestRouterNode(next: queryInjector)

        return MetadataConnectorNode(next: requestRouterNode, metadata: self.metadata)
    }

    /// Создает цепочку для отправки DTO моделей данных.
    open func defaultInput<Input, Output>() -> Node<Input, Output>
        where Input: DTOEncodable, Output: DTODecodable,
        Input.DTO.Raw == Json, Output.DTO.Raw == Json {
            let buildingChain = self.requestBuildingChain()
            let dtoConverter = DTOMapperNode<Input.DTO, Output.DTO>(next: buildingChain)
            return ModelInputNode(next: dtoConverter)
    }

    func supportNodes<Input, Output>() -> Node<Input, Output>
        where Input: DTOEncodable, Output: DTODecodable,
        Input.DTO.Raw == Json, Output.DTO.Raw == Json {
            let loadIndicator = LoadIndicatableNode<Input, Output>(next: self.defaultInput())
            return loadIndicator
    }

    open func requestRouterNode<Raw, Output>(next: Node<RoutableRequestModel<UrlRouteProvider, Raw>, Output>) -> RequestRouterNode<Raw, UrlRouteProvider, Output> {

        guard let url = self.route else {
            preconditionFailure("\(self.self) URLRoute is nil")
        }

        return .init(next: next, route: url)
    }

    /// Создает цепочку по-умолчанию. Подразумеается работа с DTO-моделями.
    open func build<Input, Output>() -> Node<Input, Output>
        where Input: DTOEncodable, Output: DTODecodable,
        Input.DTO.Raw == Json, Output.DTO.Raw == Json {
            let input: Node<Input, Output> = self.supportNodes()
            let config =  ChainConfiguratorNode<Input, Output>(next: input)
            return LoggerNode(next: config, filters: self.logFilter)
    }

    /// Создает обычную цепочку, только в качестве входных данных принимает `Void`
    open func build<Output>() -> Node<Void, Output>
        where Output: DTODecodable, Output.DTO.Raw == Json {
            let input: Node<Json, Output> = self.supportNodes()
            let configNode = ChainConfiguratorNode<Json, Output>(next: input)
            let voidNode =  VoidInputNode(next: configNode)
            return LoggerNode(next: voidNode, filters: self.logFilter)
    }

    /// Создает обычную цепочку, только в качестве входных данных принимает `Void`
    open func build<Input>() -> Node<Input, Void>
        where Input: DTOEncodable, Input.DTO.Raw == Json {
            let input = self.requestBuildingChain()
            let indicator = LoadIndicatableNode(next: input)
            let configNode = ChainConfiguratorNode(next: indicator)
            let voidOutput = VoidOutputNode<Input>(next: configNode)
            return LoggerNode(next: voidOutput, filters: self.logFilter)
    }

    /// Создает обычную цепочку, только в качестве входных и вызодных данных имеет `Void`
    open func build() -> Node<Void, Void> {
        let input = self.requestBuildingChain()
        let indicator = LoadIndicatableNode(next: input)
        let configNode = ChainConfiguratorNode(next: indicator)
        let voidOutput = VoidIONode(next: configNode)
        return LoggerNode(next: voidOutput, filters: self.logFilter)
    }

    /// Формирует цепочку для отправки multipart-запроса.
    /// Для работы с этой цепочкой в качестве модели необходимо использовать `MultipartModel`
    ///
    /// - Returns: Корневой узел цепочки .
    open func build<I, O>() -> Node<I, O> where O: DTODecodable, O.DTO.Raw == Json, I: DTOEncodable, I.DTO.Raw == MultipartModel<[String : Data]> {

        let reponseProcessor = self.serviceChain.urlResponseProcessingLayerChain()

        let requestSenderNode = RequestSenderNode(rawResponseProcessor: reponseProcessor)

        let creator = MultipartRequestCreatorNode(next: requestSenderNode, session: session)

        let transformator = MultipartUrlRequestTrasformatorNode(next: creator, method: self.method)

        let queryInjector = URLQueryInjectorNode(next: transformator, config: self.urlQueryConfig)

        let router = self.requestRouterNode(next: queryInjector)
        let connector = MetadataConnectorNode(next: router, metadata: self.metadata)

        let rawEncoder = DTOMapperNode<I.DTO,O.DTO>(next: connector)
        let dtoEncoder = ModelInputNode<I, O>(next: rawEncoder)

        let indicator = LoadIndicatableNode(next: dtoEncoder)
        let configNode = ChainConfiguratorNode(next: indicator)

        return LoggerNode(next: configNode, filters: self.logFilter)
    }

    /// Позволяет загрузить бинарные данные (файл) с сервера без отправки какой-то модели на сервер.
    /// - Returns: Корневой узел цепочки.
    open func loadData() -> Node<Void, Data> {
        let loaderParser = DataLoadingResponseProcessor()
        let errorProcessor = ResponseHttpErrorProcessorNode(next: loaderParser)
        let responseProcessor = ResponseProcessorNode(next: errorProcessor)
        let sender = RequestSenderNode(rawResponseProcessor: responseProcessor)

        let creator = RequestCreatorNode(next: sender, providers: headersProviders, session: session)

        let tranformator = UrlRequestTrasformatorNode(next: creator, method: self.method)
        let encoder = RequstEncoderNode(next: tranformator, encoding: self.encoding)

        let queryInjector = URLQueryInjectorNode(next: encoder, config: self.urlQueryConfig)

        let router = self.requestRouterNode(next: queryInjector)
        let connector = MetadataConnectorNode(next: router, metadata: self.metadata)

        let indicator = LoadIndicatableNode(next: connector)
        let configNode = ChainConfiguratorNode(next: indicator)

        let voidInput = VoidInputNode(next: configNode)

        return LoggerNode(next: voidInput, filters: self.logFilter)
    }

    /// Позволяет загрузить бинарные данные (файл) с сервера.
    /// - Returns: Корневой узел цепочки.
    open func loadData<Input>() -> Node<Input, Data> where Input: DTOEncodable, Input.DTO.Raw == Json {

        let loaderParser = DataLoadingResponseProcessor()
        let errorProcessor = ResponseHttpErrorProcessorNode(next: loaderParser)
        let responseProcessor = ResponseProcessorNode(next: errorProcessor)
        let sender = RequestSenderNode(rawResponseProcessor: responseProcessor)

        let creator = RequestCreatorNode(next: sender, providers: headersProviders, session: session)

        let tranformator = UrlRequestTrasformatorNode(next: creator, method: self.method)
        let encoder = RequstEncoderNode(next: tranformator, encoding: self.encoding)

        let queryInjector = URLQueryInjectorNode(next: encoder, config: self.urlQueryConfig)

        let router = self.requestRouterNode(next: queryInjector)
        let connector = MetadataConnectorNode(next: router, metadata: self.metadata)

        let rawEncoder = RawEncoderNode<Input.DTO, Data>(next: connector)
        let dtoEncoder = DTOEncoderNode<Input, Data>(rawEncodable: rawEncoder)

        let indicator = LoadIndicatableNode(next: dtoEncoder)
        let configNode = ChainConfiguratorNode(next: indicator)

        return LoggerNode(next: configNode, filters: self.logFilter)
    }
}
