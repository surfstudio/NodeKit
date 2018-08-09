[![Build Status](https://travis-ci.org/surfstudio/CoreNetKit.svg?branch=master)](https://travis-ci.org/surfstudio/CoreNetKit)
[![codebeat badge](https://codebeat.co/badges/60829a3a-5452-4d7c-ad6c-c702ba7ab1e1)](https://codebeat.co/projects/github-com-surfstudio-corenetkit-master)
# Core Net Kit

## Поинты:
- Компоненты
- Низкоуровневая часть и ядро
- Новый подход
- Новый интерфейс 
- Набор утилит

---

## Компоненты

- __Core__ _Содержит низкоуровневые компоненты_
    - __Adapters__ _Протоколы для адаптеров_
        - __CacheAdapter__  _Адаптеры для кеширования_
            -  CacheAdapter.swift _Протокол для любого кеширующего адаптера_
            -  UrlCacheAdapter.swift _Базовая реализация URL кеша_
        - __ErrorAdapter__ _Адаптер для маппинга ошибок_
            - ErrorMapperAdapter.swift _Протокол для маппинга ошибок_
    - __ServerPart__ _Содержит совсем незкоуровневые вещи_
        - CoreServerRequest.swift _Собирает, форматирует, отправляет запрос, формирует CoreResponse, сохраняет/читает из кэша_
        - ServerRequest+SupportedClasses.swift _Вспомогательные классы_
        - CoreServerResponse.swift _Базовый ответ. Содержит базовую логику обработки сырого ответа_
        - MultipartData.swift _Класс содержащий данные для Multipart запросов_
    - BaseResult.swift _Enum представляющий низкоуровневый результат выполнения запроса_
    - BaseServerRequet.swift _Обертка, реализующая базовую логику форматирования высокоуровневых данных и предоставляющая методы для формирования запроса и обработки ответа конкретных запросов. От него нужно наследоваться для создания собственного запроса_
    - NetworkLayerBaseError.swift _Базовые ошибки серверного слоя_
    - ReusablePagingRequest.swift _Протокол для реюза созданного запроса_
- __Context__ _Содержит контексты_
    - __Protocols__ _Протоклы для контекстов_
        - ActionableContext.swift _Контекст, который инкапсулирует вызов и обработку запроса_
        - CacheableContext.swift _Контекст, который разделяет успешное выполнение запроса к серверу и успешное выполнение запроса к кешу_
        - CancellableContext.swift _Контекст, который позволяет отменить запрос_
        - HandableContext.swift _Контекст, который может получать внутренний обработчик сырого ответа и вызывать его самостоятельно. Можно использовать для конвертирования моделей_
        - PagingRequestContext.swift _Контекст для пагинации на смещениях_
        - PassiveContext.swift _Контекст который по сути являетя прокси - обработка происходит где-то в другом месте_
    - __BaseImplementation__ _Базовые реализации контекстов_
        - ActiveRequestContext.swift _Реализация ActionableContext_
        - HandleRequestContext.swift _Реализация HandableContext_
        - PagingRequestContext.swift _Реализация PagingRequestContext_
        - PassiveRequestContext.swift _Реализация PassiveContext_
    - __Kit__ _Набор утилит и хелперов_
        - __Pagination__ _Файлы с пагинаторами_
            - BaseIteratableContext.swift _Базовая реализация контекста асинхронного итератора_
            - Countable.swift _Протокол для коллекций_
            - ServicePaginator+AsyncIterator.swift _Протоколы для пагинаторов_
        - __Safe__ _Автоматическая реализация безопасного доступа (с обновлением токена доступа)_
            - AccessSafeRequestManager.swift _Менеджер для обеспечения обновления токена и переотправки запросов_
---
## Низкоуровневая часть и ядро

### BaseServerRequest
---
Инкапсулирует логику для отправки запроса в сеть и инициаллизации всей низкоуровневой логической цепочки. 

Пользователю дает возможность конструировать запрос и обрабатывать сырой ответ.

__Пример__:

```Swift
import Foundation
import ObjectMapper

class GetOrderListRequest: BaseServerRequest<[OrderMiniEntity]> {

    private struct Keys {
        public static let skipOrdersCount = "skip"
        public static let ordersPerPage = "take"
        public static let orders = "items"
    }

    private let skipOrdersCount: Int
    private let ordersPerPage: Int

    public init(skipOrdersCount: Int, ordersPerPage: Int) {
        self.skipOrdersCount = skipOrdersCount
        self.ordersPerPage = ordersPerPage
    }

    override func createAsyncServerRequest() -> ServerRequest {
        let params = ServerRequestParameter.simpleParams([Keys.skipOrdersCount: self.skipOrdersCount, Keys.ordersPerPage: self.ordersPerPage])
        let request = ServerRequest(method: .get,
                                    relativeUrl: YourURLs.orders,
                                    baseUrl: YourURLs.baseStagingUrl,
                                    token: AuthModel.accessToken,
                                    parameters: params)
        request.cachePolicy = .serverOnly

        return request
    }

    override func handle(serverResponse: ServerResponse, completion: (ResponseResult<[OrderMiniEntity]>) -> Void) {
        let result = {() -> ResponseResult<[OrderMiniEntity]> in
            switch serverResponse.result {
            case .failure(let error):
                    return .failure(error)
            case .success(let value, let  flag):

                guard let json = value as? [String: Any] else {
                    return .failure(BaseServerError.cantMapping)
                }

                guard let ordersJson = json[Keys.orders] else {
                    return .success([OrderMiniEntity](), flag)
                }

                guard let mapped = Mapper<OrderMiniEntity>().mapArray(JSONObject: ordersJson) else {
                    return .failure(BaseServerError.cantMapping)
                }
                return .success(mapped, flag)
            }
        }()
        completion(result)
    }
}
```

### Error Adapter

---

Позволяет передавать логику маппинга кастомной ошибки на низкий уровень.
Таким образом, если вместе с кодом ошибки сервер отдает какое-то тело ответа, то можно его распарсить с помощью этого адаптера и прокинуть вверх.

*Пример:*

```Swift
public enum AuthorizationError: LocalizedError {

    case invalidCode

    public var errorDescription: String? {
        switch self {
        case .invalidCode:
            return L10n.wrongPin
        }
    }
}

public class AuthorizationErrorMapperAdapter: ErrorMapperAdapter {

    private struct Keys {
        public static let error = "error"
    }

    private struct Errors {
        public static let invalidCode = "invalid_grant"
    }

    public func map(json: [String: Any]) -> LocalizedError? {
        guard let error = json[Keys.error] as? String else {
            return nil
        }

        switch error {
        case Errors.invalidCode:
            return AuthorizationError.invalidCode
        default:
            return nil
        }
    }
}
```

### Cache Adapter

Позволяет передать кастомнуб логику чтения/записи в кэш. Имеется реализация по-умолчанию для URLCache

---

## Новый подход
---
До сих пор сервис был своебразной фабрикой запросов, которая обрабатывала ответ от запроса и вызывала callback.
Это похоже на фукциональный стиль программирования. К тому же не очень расширяемо. 

*Новая идея - новый подход*. 
Он основан на идее контекстов. 
__Контекст__ - объект, который может инкапсулировать следующую логику (иметь следующе ответственности):
- Инициаллизация запроса
- Обработка ответа от запроса
- Конвертирование данных пришедших из запроса в формат, который ожидает владелец
- Отмена запроса
- Проброс типизированных ответов на уровень выше с помощью трех видов колбэков:
    - `onSuccess(_ model: <Type>)`
    - `onError(_ error: Error)`
    - `onCacheSuccess(_ model: <Type>)`

Любой сервисный метод возвращает контекст. Далее, презентер распоряжется им по своему усмотрению. 


## Новый интерфейс

Как было до этого

```Swift

ExampleService.exampleMethod(param: Type, ... , completion: { ... })

```

Как теперь

```Swift
let service = ExampleService()

service.ExampleMethod(param: Type, ...)
    .onSuccess { ...}
    .onError { ... }
    .onCacheSuccess { ... }

```

Р-р-р-р-реакт без RxSwift (:

В чем плюс:
    - Больше лаконичности
    - Больше никаких `switch result { ... }`
    - Можно прямо указать метод для обработки: `.onError(self.errorHandler)`
    - Проще тестировать (если писать тесты)
    - За счет декларативности проще изменять реализацию сервисов (Абстракция)

## Набор утилит
---
### Пагинация
Пагинатор имет простую базовую реализацию для пагинирования на оффсетах. Он принимает необходимый контекст и самостоятельно хранит состояние смещений от начала списка.
На ружу он выставляет следующий интерфейс:

```Swift

public protocol ServicePaginator {

    associatedtype Model

    func moveNext()

    func reset(to index: Int?)
}

public protocol ServiceAsyncIterator: ServicePaginator {

    var canMoveNext: Bool { get }
}
```
Таким образом - пользователю нужно просто указать откуда должна начаться пагинация. Далее нужно просто вызывать `moveNext()` и если выдача закончится, то `moveNext` вернет либо оишбку либо что-то что определит пользователь.

В качестве расширения для стандартного `ServicePaginator` можно использовать `ServiceAsyncIterator` - он выставляет наружу флаг, по которому можно определить - можно ли дальше продолжать пагинацию. 

Базовая реализация есть для `ServiceAsyncIterator`

### Менеджер обновления токена
---
Задача этого объекта - следить за ответами на запросы и если он обнаруживает ответ с 401 ошибкой, то он останавливает все запросы, посылает запрос на обновление токена, в случае успеха - обновляет токен в хранилище, повторяет провалившийся запрос и пропускает все те, которые накопились в очереди.
Таким образом запросы не теряются. 

Это синглтонный объект, который нужно заводить на все приложение. Все запросы, для которых необходимо такое поведение, нужно передавать этому менеджеру.
Внутри себя он сам менеджрит кому отправиться, а кому подождать. 

## Версионирование

Версии обозначются в формате `x.y.z` где
- х мажорный номер версии. Поднимается только в случае мажерных обновлений (изменения в имплементации, добавление новой функциональности)
- y минорный номер версии. Поднимается только в случае минорных обновлений (изменения в интерфейсах)
- z минорный номер версии. Поднимается в случае незначительных багфиксов и т.п.
