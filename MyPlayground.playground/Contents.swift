import UIKit
import CoreNetKit

enum Endpoints: UrlRouteProvider {
    case data

    func url() throws -> URL {
        switch self {
        case .data:
            return try "example.com/data".asURL()
        }
    }
}

func ret() -> Observer<Json> {
    return UrlChainsBuilder()
        .default(with: UrlChainConfigModel(method: .get, route: Endpoints.data))
        .process()
}
