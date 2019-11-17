# Как начать

Для того, чтобы отправить запрос нам нужны две вещи:
1) Адрес (куда отправить)
2) Модель (что отправить, что получить)

Начнем по порядку. Определим адрес

```Swift

import NodeKit

var base = URL(string: "https://server.host")

enum UserServiceRoute: UrlRouteProvider {
    case auth
    case docs
    case doc(String)

    func url() throws -> URL {

        switch self {
        case .auth:
            return try base + "/auth"
        case .docs:
            return try base + "/docs"
        case .doc(id):
            return try base + "/docs/\(id)"
        }
    }
}
```
`UrlRouteProvider` - это абстракция, которая нужна библиотеке.

В некотором смысле она позволяет абстрагировать способ получения адреса.

Напрмиер в `gRPC` мы не управляем адресами напрямую, поэтому здесь механика выбора эндпоинта будет уже другая. 

И так. Теперь нам нужна модель. А точнее модели.

Модель для аутентификации. 

```Swift
import NodeKit

struct AuthEntry: Codable, RawEncodable {

    typealias Raw = Json

    let log: String
    let pass: String
}

struct AuthEntity: DTOEncodable {
    let login: String
    let password: String

    func toDTO() throws -> AuthEntry {
        return .init(log: self.login, pass: self.password)
    }
}

```

Модель пользователя (для простоты)

```Swift

import NodeKit

struct UserEntry: Codable, RawDecodable {

    typealias Raw = Json

    let name: String
    let id: String
}

struct UserEntity: DTODecodable {
    let name: String
    let id: String

    static func from(dto: UserEntry) throws -> UserEntity {
        return .init(name: dto.name, id: dto.id)
    }
}

```

Здесь у нас `Decodable` вместо `Encodable` это просто для оптимизации времени. 

`Decodable` означает, что модель умеет ТОЛЬКО `json -> dto -> entity`

В то время как `Encodable` - наборот `entity -> dto -> json`

Модель документа

```Swift 

import NodeKit

struct DocumentEntry: Codable, RawConvertible {
    typealias Raw = Json

    let id: String
    let name: String
    let modDate: TimeInterval
    let content: String
}

struct DocumentEntity: Codable, DTOConvertible {
    let id: String
    let name: String
    let modDate: Date
    let content: String

    init(id: String, name: String, content: String) {
        self.id = id
        self.name = name
        self.modDate = Date()
        self.content = content
    }
    
    func toDTO() throws -> DocumentEntry {
        return .init(id: self.id, 
                     name: self.name, 
                     modDate: self.modDate.timeIntervalSince1970,
                     content: self.content)
    }

    static func from(dto: DocumentEntry) throws -> Self {
        return .init(id: dto.id, 
                     name: dto.name, 
                     modDate: .init(timeIntervalSince1970: dto.modDate),
                     content: self.content)
    }
}

```

И эта моделька явно отличается от предыдущей.

У нее протокол другой (`Convertible`) и методов побольше. 

Это композиция `Encodable` и `Decodable`. 

Это нужно потому, что документ мы можем не только отправлять, но и получать. 

Вот собственно и все. Мы закончили с моделями. Теперь можно отправлять запросы

```Swift
import NodeKit

class UserService {
    func auth(login: String, password: String) -> Observer<UserEntity> {
        let model = AuthEntity(login: login, password: password)
        return UrlChainsBuilder()
            .default(.init(method: .post, route: UserServiceRoute.auth, encoding: .formUrl))
            .process(model)
    }

    func getDocs(for user: UserEntity) -> Observer<[DocumentEntity]> {
        return UrlChainsBuilder()
            .default(.init(method: .get, route: UserServiceRoute.docs, encoding: .urlQuery))
            .process(["id": user.id])
    }

    func update(doc: DocumentEntity) -> Observer<Void> {
        return UrlChainsBuilder()
            .default(.init(method: .put, route: UserServiceRoute.doc(doc.id)))
            .process(doc)
    }

    func postDoc(name: String, content: String, for user: UserEntity) -> Observer<Void> {

        let model = DocumentEntity(id: user.id, name: name, content: content)

        return UrlChainsBuilder()
            .default(.init(method: .post, route: UserServiceRoute.docs))
            .process(model)
    }
}

```

Вот мы и написали сервис

Рассмотри подробнее каждый метод.

`auth` - делает POST с нужными параметрами и ождиает в ответ `UserEntity`. 

Это сделано для упрощения. 

Curl-репрезентация выглядит так:

```Shell

curl -d "log=$login&pas=$pasword" -X POST https://server.host/auth

```

То есть мы отправляем данные в кодировке `form-url`


`getDocs` - Запрашиваем все документы пользователя. 

Для этого наш сервер засталяет нас отправлять в запросе ID пользователя. Что мы и делаем используя `urlQuery` кодировку. 

Обратите внимание, что в ответ от этого метода приходит массив `DocumentEntity` 

у `NodeKit` массивы и словари расширены протоколами `DTOConvertible` и `RawConvertible`

Curl-репрезентация

```Shell
curl https://server.host/docs\?id=$userid
```

`update` - этот метод нужны чтобы обновить документ по его id. 

Видимо у нашего сервера сквозная идентифкация. 

ID документа уникален для всех пользователей (надо же 🙃)

Здесь мы явно не указываем кодировку - `json` по-умолчанию. 

Curl-репрезентация:

```Shell
curl -d {id:$id,name:$name,modDate:$modDate,content:$content} -X PUT https://server.host/doc/$id
```

`postDoc` И наконец создание документа.

Здесь ничего нового.

---

Итак. Мы написали не такой уж простенький сервис за 25 минут (я засекал 😊)

На самом деле обычно аутентификация бывает куда сложнее, но стоит заметить, что это повлияет только на один метод - `auth`. 

Например если нам придет какой-нибудь токен, то мы можем переписать его (метод) вот так:

```Swift

    func auth(login: String, password: String) -> Observer<Void> {
        let model = AuthEntity(login: login, password: password)
        return UrlChainsBuilder()
            .default(.init(method: .post, route: UserServiceRoute.auth, encoding: .formUrl))
            .process(model)
            .map { self.saveToken($0) }
    }
```

Все остальные запросы отсануться без изменений (если у вас есть узел, который умеет подставлять токены 🙃)

После прочтения гайда настоятельно рекомендую почитать [документацию](Usage.md)

## URL-Query

Здесь речь пойдет о том как отправить запрос вот примерно с таким `http://test.h/path?key=value&arr[]=value&map[key]=value` URL. 

NodeKit позволяет прикрепить query-компоненту к URL для любого запроса. 

Для этого есть специальный механизм за который отвечает `QueryInjectorNode` и `URLQueryConfigModel`.

Пример использования:

```Swift
func testService(arr: [String], flag: Bool, map: [String: Any], data: [SomeType]) -> Observer<Void> {
    return UrlChainsBuilder()
            .set(query: ["arr": params], "flag": flag, "map": map)
            .set(boolEncodingStartegy: .asBool)
            .set(arrayEncodingStrategy: .noBrackets)
            .default(with: UrlChainConfigModel(method: .post, route: Route.postPath)
            .process(data)
}
```
