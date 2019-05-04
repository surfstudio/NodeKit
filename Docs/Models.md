# Про использование моделей

В этом разделе подробно описано почему библиотека работает с 2мя слоями моделей. Для чего это нужно и какие из этого можно извлечь выгоды. 

Начнем с того, что еще раз перечслим слои:

1) **Application Layer Models** - или `DTOConvertible`. Это модели верхнего уровня. Их можно смело использовать внутри презентеров и разных вью. Эти модели получаются из `DTO`
2) **Raw Layer Models** - или `DTO` или `RawMappable`. Это модели нижнего уровня. Именно с этими моделями работают почти все стандартные узлы. 

## Application Layer Models

Эти модели должны использоваться выше сервисов. Просто маппинг в них происходит в библиотеке для автоматизации этого процесса. 
Эти модели **НЕ** должны быть связаны с БД.
Иными словами это просто обычная модель. 

Процесс устроен таким образом, что при отправке запроса с этой моделью она практически сразу конвертируется в связанную с ней `DTO`-модель.
После получения ответа от сервера модель этого типа конвертируется из связанной с ней `DTO`-модели только в самом конце работы цепочки узлов. 

**Это бизнес-модели.**

## Raw Layer Models

Эти модели данных не должны использоваться **нигде**, кроме узлов цепочки (и методов маппинга в `Application Layer Model`).
Эти модели можно использовать как сущности для хранения в БД. 

Модели такого типа в конечном итоге мапятся в RAW-данные и отправляются на сервер. Так же RAW-овтет сервера мапится на эти данные. 

Эта модель еще не RAW. Она будет конвретироваться в RAW.

**Это модели доступа к данным.**

## Как использовать два слоя моделей

На самом деле архитектура с двумя слоями моделей это давно устоявшийся подход, и в разработке бэкэнда этот подход используется по-умолчанию. 

Помимо очевидных положительных вещей (разделение логической ответственности на бизнес и не-бизнес) есть следующие положительные стороны:

### Пример 1. Замена значения. 

Допустим, у нас есть некоторый продукт. 

```Swift

struct Product: DTODecodable {
    let id: String
    let name: String
    let alias: String?

    static func from(dto: ProductEntry) -> Product {
        return .init(id: dto.id, name: dto.name, alias: dto.alias)
    }
}
```

И требования такие:
1) Всегда выводить `alias` в качестве названия продукта. 
2) В случае если `alias == nil` или `alias.isEmpty`, то выводить `name` 

Эти требования обуславливаются тем, что `alias` - задает пользователь, а `name` это имя продукта по-умолчанию. 

Понятное дело, что писать во всех местах что-то вроде:

```Swift
    if let alias = model.alias, !alias.isEmpty {
        self.productNameLabel.text = alias
    } else {
        self.productNameLabel.text = model.name
    }
```

Еще можно написать `extension` но это все равно выглядит немного костыльно. Считай лишнее поле добавили. 

Если у нас есть `DTO` слой, то эту проблему можно решить при маппинге данных:

```Swift
    static func from(dto: ProductEntry) -> Product {
        let alias = {
            guard let alias = dto.alias, !alias.IsEmpty else {
                return dto.name
            }
            return alias
        }()
        return .init(id: dto.id, name: dto.name, alias: alias)
    }
```
В таком варианте мы решаем проблему несоответствия бизнес-моделей транспортным на уровне маппинга одних в другие и не тащим эти самые проблемы несоответствия вверх по иерархии. 

### Пример 2. Один ко многим.

Иногда бывает удобно прелставить сущность, приходящую с сервера, как несколько разных сущностей. Например, сервер присылает одну большую модель, но на определенный запрос нам необходим только некоторый определенный набор полей. 

Как раз в таких случаях два слоя моделей отлично помогают решить проблему. 

```Swift

struct PaymentEntry: Codable, RawMappable {

    typealias Raw = Json

    let subitems: [PaymentEntry]
    let mask: String?
    let regexp: String?
    let action: String?
}

struct PayemntAction: DTOEncodable {
    let action: String

    static func from(dto: PaymentEntry) -> PayemntAction {
        guard let action = dto.action else { throw .badType } 

        return .init(action: action)
    }
}

struct PaymentField: DTOEncodable {
    let inputMask: String
    let regExp: String

    static func from(dto: PaymentEntry) -> PaymentField {
        guard let mask = dto.mask, let regExp = dto.regExp else { 
            throw .badType 
        } 

        return .init(inputMask: mask, regExp: regExp)
    }
}

struct PaymentList: DTOEncodable {
    let subitems: [PaymentEntry]

    static func from(dto: PaymentEntry) -> PaymentList {
        guard let subitems = .from(dto: dto.subitems) else { throw .badType } 

        return .init(subitems: subitems)
    }
}
```

Таким образом мы разбили входящую сущность на 3 разных сущности, тем самым избавив себя от макаронного кода. 