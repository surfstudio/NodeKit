# Реализованный цепочки

## UrlChains

Содержит цепочки из-коробки для работы с URL запросами. 

По умолчанию реализована цепочка из следующих узлов:

1. `LoggerNode` - выводит логи
2. `ChainConfiguratorNode` - выполняет всю последующую работу в `background`, а ответ диспатчит на `main`
3. `LoadIndicatableNode` - показывает индикатор загрузки в статус-баре
4. `ModelInputNode` - маппит ответ из `RawMappable` в `DTOConvertible`
5. `DTOMapperNode` - маппит запрос из `DTOConvertible` в `RawMappable`
6. `MetadataConnectorNode` - добавляет `metadata` в `RequestModel`
7. `RequestRouterNode` - добавляет маршрут к запросу
8. `RequstEncoderNode` - добавляет кодировку к запросу
9. `UrlRequestTrasformatorNode` - Этот узел формирует конкретный `URL` запрос. Преобразуя `metadata` в `headers`, `route` в `URL` и т.д.
10. `RequestCreatorNode` - создает запрос в сеть с помощью `Alamofire`
11. `TechnicaErrorMapperNode` - маппит технические ошибки (таймаут, отсутствие интернета и т.п.)
12. `RequestSenderNode` - отправляет запрос в сеть. Не маппит его. Просто отправляет
13. `ResponseProcessorNode` - занимается обработкой ответа от сервера. Проверяет, успешно выполнился запрос или нет. Если успешно, то можно ли замаппить ответ в JSON или нет
14. `ResponseHttpErrorProcessorNode` - этот узел занимается проверкой, возникли ли какие-то HTTP-ошибки (проверяет код). Если да, то создает экземпляр `ResponseHttpErrorProcessorNodeError` и заканчивает выполнение цепочки
15. `ResponseDataPreprocessorNode` - здесь мы проверяем ответ. Является ли он Json-объектом или Json-массивом
16. `ResponseDataParserNode` - получаем `Json` из `Data`

Эта цепочка **НЕ** содержит кэширования.

`default<I,O>` - классический запрос. Ожидает данные как на вход так и на выход. (описано выше)

`default<Void, Void>` - цепочка не ожидающая данных на вход и на выход (да, и такое бывает)

`default<I, Void>` - цепочка, ожидающая данные на вход, но не возвращающая данные (сервер отвечает пустым телом)

`default<Void, I>` - цепочка, не ожидающая данные на вход, но ожидающая на выход (классический GET-запрос)

`loadData<Void, Data>` - цепочка, которая просто скачивает нужный файл (например, качаем статически раздающийся файл)

`loadData<I, Data>` - цепочка, скачивающая файл и передающая на сервер какие-то данные (и так бывает, да)

`default<I, O> where I.DTO.Raw = MultipartModel<[String : Data]>` - цепочка, которая позволяет отправлять multipart-запросы 

### Операции

`set(query: [String: Any])` - изменяет URL-Query параметр у запроса. 

`set(boolEncodingStartegy: URLQueryBoolEncodingStartegy)` - устанавливает стратегию парсинга булевых переменных в URL-query параметры. Доступные из-коробки имплементации: `URLQueryBoolEncodingDefaultStartegy.asInt`, `URLQueryBoolEncodingDefaultStartegy.asBool`. По-умолчанию ставится `.asInt`

`set(boolEncodingStartegy: URLQueryBoolEncodingDefaultStartegy)` - то же самое, только вместо протокола принимает тип доступный из-коробки (для красоты конфигурирования)

`set(arrayEncodingStrategy: URLQueryArrayKeyEncodingStartegy)` - устанавливает стратегию парсинга ключей массивов в URL-query параметры. Доступные из-коробки имплементации: `URLQueryArrayKeyEncodingBracketsStartegy.brackets`, `URLQueryArrayKeyEncodingBracketsStartegy.noBrackets`. По-умолчанию ставится `.brackets`

`set(arrayEncodingStrategy: URLQueryArrayKeyEncodingBracketsStartegy)` - то же самое, только вместо протокола принимает тип доступный из-коробки (для красоты конфигурирования)

`set(dictEncodindStrategy: URLQueryDictionaryKeyEncodingStrategy)` - устанавливает стратегию парсинга ключей словарей в URL-query параметры. Из-коробки доступна только `URLQueryDictionaryKeyEncodingDefaultStrategy`.

`set(metadata: [String: String])` - устанавливает хедеры запроса, которые добавляются на этапе конструирования в запросе (узел `MetadataProviderNode`). По-умолчанию словарь пуст. 

`route(_ method: Method, _ route: Route)` - устанавливает http-метод и url для запроса.

`encode(as encoding: ParametersEncoding)` - устанавлиает кодировку для запроса. По-умолчанию `.json`

`add(provider: MetadataProvider)` - добавляет провайдер заголовков к запросу. Эти провайдеры будут вызываны непосредственно перед отправкой запроса.

`log(exclude: [String])` - позволяет исключить какие-то определенные логи по их ID. В качестве ID у лога ставится имя узла. Подробнее [тут](Log/Log.md)