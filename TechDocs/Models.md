# Models

- [Model Layers](#modellayer)
  - [Raw Model Layer (RawMappable)](#rawmodellayer)
  - [Application Model Layer (DTOConvertible)](#aplicationmodellayer)
- [Example 1. Replacement of value](#example1)
- [Example 2. One-to-many](#example2)

## Model Layers <a name="modellayer"></a>

The library implies working with two Model Layers:

1) Application Model Layer - The layer of the application level, which is used throughout the application.
2) Raw Model Layer (DTO) - The low-level layer to which (or from which) data is mapped for (or from) the server. 

But it is also allowed to use only one model layer or not to use models at all.

### Raw Model Layer (RawMappable) <a name="rawmodellayer"></a>

Two protocols are responsible for defining the model from this layer:

1) [RawEncodable](https://surfstudio.github.io/NodeKit/Protocols/RawEncodable.html)
2) [RawDecodable](https://surfstudio.github.io/NodeKit/Protocols/RawDecodable.html)

There is also an alias [RawMappable](https://surfstudio.github.io/NodeKit/Typealiases.html#/s:10CoreNetKit14RawMappable)

For entities that conform to the `Codable` protocols, there is a default mapping implementation.

Example:

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

This code will be sufficient to map the server response to the `UserEntry` and `PhotoEntry` entities.

**It is considered good practice to add the "Entry" postfix to DTO entities.**

### Application Model Layer (DTOConvertible) <a name="aplicationmodellayer"></a>

Two protocols are responsible for defining the model from this layer:

1) [DTOEncodable](https://surfstudio.github.io/NodeKit/Protocols/DTOEncodable.html)
2) [DTODecodable](https://surfstudio.github.io/NodeKit/Protocols/DTODecodable.html)

There is also an alias [DTOConvertible](https://surfstudio.github.io/NodeKit/Typealiases.html#/s:10CoreNetKit14DTOConvertiblea)

Example:

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

Thus, we obtain a pair of two models, where::
1) `UserEntry: RawDecodable` - DTO-Layer.
2) `User: DTODecodable` - App-Layer. 

#### Good to know

Arrays with elements of type `DTOConvertible` and `RawMappable` also satisfy these protocols and have default implementations for their methods.

### Example 1. Replacement of value <a name="example1"></a>

Let say we have a certain product. 

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

And the requirements are as follows:

1) Always output `alias` as the product name.
2) In case `alias == nil` or `alias.isEmpty`, output `name`.

These requirements are due to the fact that `alias` is set by the user, while `name `is the default product name.
Of course, it's clear that writing something like this everywhere is a bad idea:

```Swift
if let alias = model.alias, !alias.isEmpty {
    self.productNameLabel.text = alias
} else {
    self.productNameLabel.text = model.name
}
```

If we have a DTO layer, we can solve this problem during data mapping:

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
In this scenario, we solve the problem of mismatching business models to transport models at the mapping level, without carrying these mismatches up the hierarchy. 

### Example 2. One-to-many <a name="example2"></a>

Sometimes it's convenient to represent an entity coming from the server as several different entities. For example, the server sends one large model, but for a specific request, we only need a certain subset of fields.

In such cases, having two layers of models helps solve the problem perfectly.

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