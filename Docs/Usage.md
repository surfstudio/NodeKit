# Как этим пользоваться

## Слой моделей

Библиотека подразумевает работу с двумя слоями моделей:

1) Application Layer Models - модели прикладного уровня, которые используются по всему приложению
2) Raw Layer Models (DTO) - модели низкого уровня, на которые (или из которых) мапятся данные для (или от) сервера. 

Но допускается вохможность использование только одного модельного слоя. 

Так же допускается вохможность не использовать модели вообще. 

### Raw Layer Models (RawMappable)

За определение модели из этого слоя отвечают два протокола:

1) [RawEncodable](https://lastsprint.dev/CoreNetKit/Docs/swift_output/Protocols/RawEncodable.html)
2) [RawDecodable](https://lastsprint.dev/CoreNetKit/Docs/swift_output/Protocols/RawDecodable.html)

Существует также алиас [RawMappable](https://lastsprint.dev/CoreNetKit/Docs/swift_output/Typealiases.html#/s:10CoreNetKit14RawMappable)

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

1) [DTOEncodable](https://lastsprint.dev/CoreNetKit/Docs/swift_output/Protocols/DTOEncodable.html)
2) [DTODecodable](https://lastsprint.dev/CoreNetKit/Docs/swift_output/Protocols/DTODecodable.html)

Существует также алиас [DTOConvertible](https://lastsprint.dev/CoreNetKit/Docs/swift_output/Typealiases.html#/s:10CoreNetKit14DTOConvertiblea)

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

#### Полезно знать

Массивы с элемантами типа `DTOConvertible` и `RawMappable` также удовлетворяют этим протоколам и имеют реализацию по-умолчанию для их методов.

## Создание запроса

Отправка запроса в сеть начинается с того, что мы описываем:
1) Маршрут - URI до нужного нам сервиса
2) HTTP-метод - метод запроса (GET, PUT, e.t.c.)
3) Кодировку - куда необходимо положить параметры и в каком виде (JSON in Body, String In Query, e.t.c)
4) Метаданные - или хедеры запроса. 

CoreNetKit построен таким образом, что одинаковую модель можно использовать для любого транспортного протокола, исключая или добавляя шаги при необходимости.

### Маршрутизация

Для того, чтобы абстрагировать способ задачи маршрута (например в gRPC нет явных URL) маршрут - generic-тип данных, однако в случае URL-запросов ожидается `UrlRouteProvider`

Такой подход делает работу с URL адресами немного элегантнее. Например:

```Swift

enum RegistrationRoute {
    case auth
    case register
    case user(String)
}

extension RegistrationRoute: UrlRouteProvider {
    func url() throws -> URL {
        let base = URL(string: "http://example.com")
        switch self {
        case .auth:
            return try base + "/user/auth"
        case .register:
            return try base + "/user/register"
        case .user(let id):
            return try base + "/user/\(id)"
        }
}
```
**Хорошией практикой является разбиение маршрутов по сервисам или по отдельным файлам.**

#### Полезно знать

Для упрощения работы с URL в CoreNetKit есть [расширение](https://lastsprint.dev/CoreNetKit/Docs/swift_output/Extensions/Optional.html) для конкатенации `URL` и `String`

### Кодировка

CoreNetKit предоставляет следующие виды кодировок:
1) `json` - сериализует параметры запроса в JSON и прикрепляет к телу запроса. Является кодировкой по-умолчанию
2) `formUrl` - сериализует парамтеры запроса в формат FormUrlEncoding иприкрепляет к телу запроса. 
3) `urlQuery` - конвертирует параметры в строку, зменяя определенные символы на специальные последовательности (образует URL-encoded string)

Эти параметры находятся в [ParametersEncoding](https://lastsprint.dev/CoreNetKit/Docs/swift_output/Enums/ParametersEncoding.html)
