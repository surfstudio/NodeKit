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
            .default(with: UrlChainConfigModel(method: .post, route: Endpoint.isHttp2))
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
