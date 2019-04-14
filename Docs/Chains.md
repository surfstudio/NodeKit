# Реализованный цепочки

## UrlChains

Содержит цепочки из-коробки для работы с URL запросами. 

По-умолчанию реализована цепочка из следующих узлов:

1. `LoggerNode` - выводит логи
2. `ChainConfiguratorNode` - выполняет всю последующую работу в `background`, а ответ диспатчит на `main`
3. `LoadIndicatableNode` - показыавет индикатор загрузки в статус-баре.
4. `ModelInputNode` - маппит ответ из `RawMappable` в `DTOConvertible`
5. `DTOMapperNode` - мапит запрос из `DTOConvertible` в `RawMappable`
6. `MetadataConnectorNode` - добавляет `metadata` в `RequestModel`
7. `RequestRouterNode` - добавляет маршрут к запросу
8. `RequstEncoderNode` - добавляет кодировку к запросу.
9. `UrlRequestTrasformatorNode` - Этот узел формирует конкретный `URL` запрос. Преобразуя `metadata` в `headers`, `route` в `URL` и т.д.
10. `RequestCreatorNode` - создает запрос в сеть с помощью `Alamofire`
11. `TechnicaErrorMapperNode` - мапить техничесик ошибки (таймаут, отсутствие интернета и т.п.)
12. `RequestSenderNode` - отправляет запрос в сеть. Не мапит его. Просто отправляет. 
13. `ResponseProcessorNode` - занимается обработкой ответа от сервера. Проверяет, успешно выполнился запрос или нет. Если успешно,то можно ли замапить ответ в JSON или нет. 
14. `ResponseHttpErrorProcessorNode` - этот узел занимается проверкой, возникли ли какие-то HTTP ошибки (проверяет код). Если да, то создает экземпляр `ResponseHttpErrorProcessorNodeError` и заканчивает выполнение цепочки.
15. `ResponseDataPreprocessorNode` - здесь мы проверяем ответ. Является ли он Json-объектом или Json-массивом.
16. `ResponseDataParserNode` - получам `Json` из `Data`

Эта цепочка **НЕ** содерожит кэширования.