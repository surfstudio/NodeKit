# Как этим пользоваться

Содержание:
- [Как этим пользоваться](#%D0%BA%D0%B0%D0%BA-%D1%8D%D1%82%D0%B8%D0%BC-%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D1%82%D1%8C%D1%81%D1%8F)
  - [Слой моделей](#%D1%81%D0%BB%D0%BE%D0%B9-%D0%BC%D0%BE%D0%B4%D0%B5%D0%BB%D0%B5%D0%B9)
    - [Raw Layer Models (RawMappable)](#raw-layer-models-rawmappable)
    - [Application Layer Models (DTOConvertible)](#application-layer-models-dtoconvertible)
      - [Полезно знать](#%D0%BF%D0%BE%D0%BB%D0%B5%D0%B7%D0%BD%D0%BE-%D0%B7%D0%BD%D0%B0%D1%82%D1%8C)
  - [Создание запроса](#%D1%81%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-%D0%B7%D0%B0%D0%BF%D1%80%D0%BE%D1%81%D0%B0)
    - [Маршрутизация](#%D0%BC%D0%B0%D1%80%D1%88%D1%80%D1%83%D1%82%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F)
      - [Полезно знать](#%D0%BF%D0%BE%D0%BB%D0%B5%D0%B7%D0%BD%D0%BE-%D0%B7%D0%BD%D0%B0%D1%82%D1%8C-1)
    - [Кодировка](#%D0%BA%D0%BE%D0%B4%D0%B8%D1%80%D0%BE%D0%B2%D0%BA%D0%B0)
  - [Отправка запроса](#%D0%BE%D1%82%D0%BF%D1%80%D0%B0%D0%B2%D0%BA%D0%B0-%D0%B7%D0%B0%D0%BF%D1%80%D0%BE%D1%81%D0%B0)
    - [Сервис](#%D1%81%D0%B5%D1%80%D0%B2%D0%B8%D1%81)
    - [Ответ](#%D0%BE%D1%82%D0%B2%D0%B5%D1%82)

Здесь перечислены основные моменты и вспомогательная информация о том, каким образом работать с этой бибилиотекой. 
Проект содержит `Playground` в котором написаны несколько вариантов запросов - можно посмотреть туда в качестве интерактивного примера

## Слой моделей

Библиотека подразумевает работу с двумя слоями моделей:

1) Application Layer Models - модели прикладного уровня, которые используются по всему приложению
2) Raw Layer Models (DTO) - модели низкого уровня, на которые (или из которых) мапятся данные для (или от) сервера. 

Но допускается возможность использование только одного модельного слоя. 

Так же допускается возможность не использовать модели вообще. 

### Raw Layer Models (RawMappable)

За определение модели из этого слоя отвечают два протокола:

1) [RawEncodable](https://surfstudio.github.io/NodeKit/Protocols/RawEncodable.html)
2) [RawDecodable](https://surfstudio.github.io/NodeKit/Protocols/RawDecodable.html)

Существует также алиас [RawMappable](https://surfstudio.github.io/NodeKit/Typealiases.html#/s:10CoreNetKit14RawMappable)

Для сущностей, удовлетворяющих протоколам `Codable` есть реализация маппинга по-умолчанию. 

Например:

```Swift

enum Type: Int, Codable {
    case owner
    case member
}

struct PhotoEntry: Codable {
    let id: String
    let ref: String
}

extension PhotoEntry: RawDecodable {
    public typealias Raw = Json
}

struct UserEntry: Codable {
    let name: String
    let age: Int
    let type: Type
    let photos: [PhotoEntry]
}

extension UserEntry: RawDecodable {
    public typealias Raw = Json
}
```

Этого кода будет достаточно для того, чтобы замапить ответ сервера на сущности `UserEntry` и `PhotoEntry`

**Хорошим тоном считается добавление постфикса Entry к DTO-сущности.**

### Application Layer Models (DTOConvertible)

За определение модели из этого слоя отвечают два протокола:

1) [DTOEncodable](https://surfstudio.github.io/NodeKit/Protocols/DTOEncodable.html)
2) [DTODecodable](https://surfstudio.github.io/NodeKit/Protocols/DTODecodable.html)

Существует также алиас [DTOConvertible](https://surfstudio.github.io/NodeKit/Typealiases.html#/s:10CoreNetKit14DTOConvertiblea)

Продолжим пример:

```Swift

struct Photo {
    let id: String
    let image: String
}

extension Photo: DTODecodable {

    public typealias DTO = PhotoEntry

    static func from(dto: PhotoEntry) throws -> Photo {
        return .init(id: dto.id, image: dto.ref)
    }
}

struct User {
    let name: String
    let age: Int
    let type: Type
    let photos: [Photo]
}

extension User: DTODecodable {
    public typealias DTO = UserEntry

    static func from(dto: UserEntry) throws -> Photo {
        return try .init(name: dto.name, 
                        age: dto.age, 
                        type: dto.type, 
                        photos: .from(dto: dto.photos))
    }
}
```

Таким образом мы получаем связку из двух моделей, где:
1) `UserEntry: RawDecodable` - DTO-слой.
2) `User: DTODecodable` - App-слой. 

Более подробно об этом можно прочесть [тут](Models.md)

#### Полезно знать

Массивы с элемантами типа `DTOConvertible` и `RawMappable` также удовлетворяют этим протоколам и имеют реализацию по-умолчанию для их методов.

## Создание запроса

Отправка запроса в сеть начинается с того, что мы описываем:
1) Маршрут - URI до нужного нам сервиса
2) HTTP-метод - метод запроса (GET, PUT, e.t.c.)
3) Кодировку - куда необходимо положить параметры и в каком виде (JSON in Body, String In Query, e.t.c)
4) Метаданные - или хедеры запроса. 

CoreNetKit построен таким образом, что одинаковую модель можно использовать для любого транспортного протокола, исключая или добавляя шаги при необходимости.

Далее я опишу толькко 1 и 3, потому что остальное не нуждается в объяснении.

### Маршрутизация

Для того, чтобы абстрагировать способ задачи маршрута (например в gRPC нет явных URL) маршрут - generic-тип данных, однако в случае URL-запросов ожидается `UrlRouteProvider`

Такой подход делает работу с URL адресами немного элегантнее. Например:

```Swift

enum RegistrationRoute {
    case auth
    case users
    case user(String)
}

extension RegistrationRoute: UrlRouteProvider {
    func url() throws -> URL {
        let base = URL(string: "http://example.com")
        switch self {
        case .auth:
            return try base + "/user/auth"
        case .users:
            return try base + "/user/users"
        case .taskState:
            return try base + "/tasks"
        case .user(let id):
            return try base + "/user/\(id)"
        }
}
```
**Хорошией практикой является разбиение маршрутов по сервисам или по отдельным файлам.**

#### Полезно знать

Для упрощения работы с URL в CoreNetKit есть [расширение](https://surfstudio.github.io/NodeKit/Extensions/Optional.html) для конкатенации `URL` и `String`

### Кодировка

CoreNetKit предоставляет следующие виды кодировок:
1) `json` - сериализует параметры запроса в JSON и прикрепляет к телу запроса. Является кодировкой по-умолчанию
2) `formUrl` - сериализует парамтеры запроса в формат FormUrlEncoding иприкрепляет к телу запроса. 
3) `urlQuery` - конвертирует параметры в строку, зменяя определенные символы на специальные последовательности (образует URL-encoded string)

Эти параметры находятся в [ParametersEncoding](https://surfstudio.github.io/Enums/ParametersEncoding.html)

## Отправка запроса

Для отправки запроса нужно вызывать цепочку и передать ей параметры, которые были описаны выше. 

### Сервис

В качестве примера напишем сервис.

```Swift

class ExampleService {

    var builder: UrlChainsBuilder<RegistrationRoute> {
        return .init()
    }

    func auth(user: User) -> Observer<Void> {
        return self.builder
            .route(.post, .auth)
            .build()
            .process(user)
            .map { [weak self] (user: User) in 
                self?.saveToKeychain(user)
                return ()
            }
    }

    func getUser(by id: String) -> Observer<User> {
        return self.builder
            .route(.get, .user(id))
            .build()
            .process()
    }

    func getUsers() -> Observer<[User]> {
        return self.builder
            .route(.get, .users)
            .build()
            .process()
    }

    func updateState(by params:[String], descending: Bool, by map: [String: Any], max: Int, users: [User]) -> Observer<Void> {
        return self.builder
            .set(query: ["params": params], "desc": descending, "map": map, "max": maxCount)
            .set(boolEncodingStartegy: .asBool)
            .set(arrayEncodingStrategy: .noBrackets)
            .route(.post, RegistrationRoute.taskState)
            .build()
            .process(users) 
    }
}
```

Ответ от сервиса приходит в `DispatchQueue.main`, если поведение по-умолчанию не изменялось. 
Сама цепочка с самого начинает свою работу в `DispatchQueue.global(qos: .userInitiated)` (по-умолчанию)

Для выполнения запроса используются [цепочки узлов](Chains.md).

### Ответ

Для работы с сервисом предлагается использовать абстрактную сущность - `Observer<T>`. 
Это Rx-Like объект, который имеет 4 возможных события:
1) `onCompleted` - когда запрос выполнился
2) `onError` - когда произошла ошибка
3) `defer` - вызывается и в случае ошибки, и в случае успешного выполнения (аналог `finaly` в `try-catch`)
4) `onCanceled` - вызывается в случае, если операция,за которой наблюдает `Observer` была отменена

На самом деле этот объект повсеместно используется в библиотеке, а в качестве его реализации используется `Context<T>`.
Документацую можно увидеть [здесь](https://surfstudio.github.io/NodeKit/Classes/Observer.html) и [здесь](https://surfstudio.github.io/NodeKit/Classes/Context.html)

Так же более детальное описание работы контекстов находится [тут](Contexts.md)

Рассмотрим как будет выглядеть работа с сервисом из презентера (или любой другой сущности, которая общается с сервером)

```Swift

private let service = ExampleService()

func loadUsers() {
    self.showLoader()
    self.service.getUsers()
        .onCompleted { [weak self] model in
            self?.show(users: model)
        }.onError { [weak self] error in
            self?.show(error: error)
        }.defer { [weak self] in
            self?.hideLoader()
        }
}

```

Библиотека предоставляет систему логгирования, которая более детально описана [здесь](Log/Log.md)
