import UIKit
import NodeKit

// MARK: - Инфраструктура

enum CustomError: Error {
    case badUrl
}

enum Endpoint {
    case isHttp2
}

extension URL {
    static func from(_ string: String) throws -> URL {
        guard let url = URL(string: string) else {
            throw CustomError.badUrl
        }
        return url
    }
}

extension Endpoint: UrlRouteProvider {
    func url() throws -> URL {
        switch self {
        case .isHttp2:
            return try .from("https://http2.pro/api/v1")
        }
    }
}

/// Пример запроса без параметров.

/// ---------------- Модели для запроса

/// DTOConvertible (верхний слой)
struct Http2CheckResult {
    let status: Http2Status
    let `protocol`: String
    let push: Http2Status
    let userAgent: String
}

extension Http2CheckResult: DTODecodable {

    typealias DTO = Http2CheckResultEntry

    static func from(dto model: Http2CheckResultEntry) throws -> Http2CheckResult {
        return .init(status: model.http2,
                     protocol: model.protocol,
                     push: model.push,
                     userAgent: model.user_agent)
    }
}

enum Http2Status: Int, Codable {
    case used = 2
    case notUsed = 1
}

/// RawMappable (нижний слой)

struct Http2CheckResultEntry: Codable {
    let http2: Http2Status
    let `protocol`: String
    let push: Http2Status
    let user_agent: String
}

extension Http2CheckResultEntry: RawDecodable {
    typealias Raw = Json
}

// ------- Сервис

func checkHttp2() -> Observer<Http2CheckResult> {
    return UrlChainsBuilder()
            .route(.post, Endpoint.isHttp2)
        .log(exclude: ["ResponseDataParserNode"])
            .build()
            .process()
}

// ---------- Presenter

print("checkHttp2")

let cnt = checkHttp2().onCompleted { result in
    print(result.status)
    print("Protocol: \(result.protocol)")
    print("Server-push: \(result.push)")
    print(result.userAgent)
}.onError { error in
    print(error)
}


// POST lastsprint.dev:8822/pfood/auth
//
//{"profile":{"balance":100,"birthday":"1990-09-02","email":"test@test2.ru","gender":1,"has_orders":false,"has_saved_cards":false,"id":"12656941231","name":"Иван Иванов","phone":"79001234567"},"tokens":{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwiZXhwIjoxNTE2MjM5MDIyfQ.AgNLCIRwkhE9zEvARcUz3dhxFH6MvrZVXrWEfm7X9Xs","refresh_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwiZXhwIjoxNTE2MjM5MDIyfQ.AgNLCIRwkhE9zEvARcUz3dhxFH6MvrZVXrWEfm7X9Xs"}}

// Entity

struct AuthEntity: DTODecodable {
    let profile: ProfileEntity
    let tokens: TokensEntity

    static func from(dto: AuthEntry) throws -> AuthEntity {
        return try .init(profile: .from(dto: dto.profile), tokens: .from(dto: dto.tokens))
    }
}

struct AuthEntry: Codable, RawMappable {
    let profile: ProfileEntry
    let tokens: TokensEntry

    typealias Raw = Json
}

struct ProfileEntity: DTODecodable {

    typealias DTO = ProfileEntry

    let balance: Double
    let birthday: String
    let email: String

    static func from(dto: ProfileEntry) throws -> ProfileEntity {
        return .init(balance: dto.balance, birthday: dto.birthday, email: dto.email)
    }
}

struct TokensEntity: DTODecodable {
    let accessToken: String
    let refreshToken: String

    static func from(dto: TokensEntry) throws -> TokensEntity {
        return .init(accessToken: dto.access_token, refreshToken: dto.refresh_token)
    }
}

// Entry

struct ProfileEntry: Codable, RawMappable {

    typealias Raw = Json

    let balance: Double
    let birthday: String
    let email: String
}

struct TokensEntry: Codable, RawMappable {

    typealias Raw = Json

    let access_token: String
    let refresh_token: String
}

enum AuthRoute: UrlRouteProvider {
    case auth

    func url() throws -> URL {
        return URL(string: "http://lastsprint.dev:8822/pfood/auth")!
    }
}

func auth() -> Observer<AuthEntity> {
    return UrlChainsBuilder()
        .route(.post, AuthRoute.auth)
        .build()
        .process()
}

auth().onCompleted { model in
    print(model.profile)
}

